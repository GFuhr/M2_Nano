import os
import subprocess
import time
import json
import zipfile
EXENAME = "h2D_serial.exe"
OPT_MOD = ""

# don't modify the clean list nor the command strings here
CLEAN_LIST = ("geometry.mod", "fields.mod", "h2d_io.mod", "h2d_serial.trace", EXENAME)
COMPILE_STR = ("gfortran", "-O2", "-g", "-pg", "-Wall", "-Wextra", "-Werror", "-fdefault-integer-8", 
"-fdefault-real-8", "-fdefault-double-8",\
"geometry.f90", "fields.f90", "IO.f90", "main.f90", "-o", "{0} >/dev/null".format(EXENAME))
VALGRIND_RUN = ("valgrind", "--D1=32768,8,64", "--quiet", "--tool=cachegrind", \
 "--cachegrind-out-file=h2d_serial.trace", "./{0} >/dev/null".format(EXENAME),)
VALGRIND_CHECK = "cg_annotate h2d_serial.trace | grep \",\" | grep -v \"cache\""


def estimate(optim=0, exe=EXENAME):
    """
    optim : 0 : current version
            1 : optimised version
            2 : initial version
    """
    cstr = list(COMPILE_STR)

# initial cleaning
    print('cleaning previous files')
    for modfiles in CLEAN_LIST:  
        compil_return = subprocess.run(["rm","-f", modfiles ], shell=False)


    if optim == 1:
        sed_1 = r"sed 's/use fields/use fields_opt/g' "
        subprocess.run(sed_1 + "IO.f90 > IO_opt.f90" , shell=True)
        subprocess.run(sed_1 + "main.f90 > main_opt.f90" , shell=True)
        cstr[10] = "geometry.f90"
        cstr[11] = 'IO_opt.f90'
        cstr[12] = "main_opt.f90"
        cstr[13] = "fields_opt.o"
    elif optim ==2:
        cstr[11] = 'fields_init.f90'
    cstr = ' '.join(cstr)

    
    #compilation
    print("compilation")
    compil_return = subprocess.run(cstr, shell=True)
    rcode = compil_return.returncode
    if rcode != 0:
        print("compilation error, aborted")
        print(compil_return.stderr)
        quit(1)

    print('memory cache verification')
    vgrun = ' '.join(VALGRIND_RUN)
    compil_return = subprocess.run( vgrun , shell=True)
    rcode = compil_return.returncode



    compil_return = subprocess.check_output([VALGRIND_CHECK, ], shell=True)#, stdout = subprocess.PIPE)
    compil_return = compil_return.replace(b",",b"").split(b"\n")
    cache_miss_read = 0
    cache_miss_write = 0
    cache_total_read = 0
    cache_total_write = 0
    global_dict = {}
    for elems in compil_return:
        current_element = elems.split()

        if len(current_element)<2:
            continue
        try:
            fname = current_element[9].split(b':')[1].decode("utf-8") 
        except IndexError:
            fname = current_element[9].split(b':')[0]
            continue
        data = {
            'Ir'  :int(current_element[0]),
            'I1mr' :int(current_element[1]),
            'ILmr':int(current_element[2]),
            'Dr':int(current_element[3]),
            'D1mr':int(current_element[4]),
            'DLmr':int(current_element[5]),
            'Dw':int(current_element[6]),
            'D1mw':int(current_element[7]),
            'DLmw':int(current_element[8]),
            'function':fname,
        }
        cache_miss_read += data['D1mr'] + data['DLmr']
        cache_miss_write += data['D1mw'] + data['DLmw']
        cache_total_read += data['D1mr'] + data['DLmr'] + data['Dr'] 
        cache_total_write += data['D1mw'] + data['DLmw'] + data['Dw'] 
        global_dict.update({fname:data})
        global_dict[fname].update({
            'cache_read' : cache_total_read,
            'cache_read_miss' : cache_miss_read,
            'cache_write' : cache_total_write,
            'cache_write_miss' : cache_miss_write,
        })


        global_dict['cache'] = {
                    'total_cache_io' : cache_total_read+cache_total_write,
            'total_cache_miss_ratio' : (cache_miss_read+cache_miss_write)/(cache_total_read+cache_total_write)
        }
    print("""summary : 
    cache read : {0} (miss :  {1:.02F}%)
    cache write : {2} (miss :  {3:.02F}%)
    total : {4} (miss :  {5:.02F}%)
    """.format(cache_total_read, 
    100.*cache_miss_read/cache_total_read, 
    cache_total_write,
    100.*cache_miss_write/cache_total_write,
    cache_total_read+cache_total_write, 100.*(cache_miss_read+cache_miss_write)/(cache_total_read+cache_total_write)
    ))

    print("measure of execution time")
    t1 = time.time()
    compil_return = subprocess.run([ "./{0}>/dev/null".format(EXENAME) ], shell=True)
    t2 = time.time() - t1
    global_dict.update({'execution_time':t2})
    print('elapsed time(s) : {0:.02f}'.format(t2))
    return global_dict

def compress(fname):
    ziph = zipfile.ZipFile(fname, 'w', zipfile.ZIP_DEFLATED)
    for root, dirs, files in os.walk('./'):
        for curfile in files:
            if curfile.lower().find('.f90')>-1:
                ziph.write(os.path.join(root, curfile))
            elif curfile.lower().find('.json')>-1:
                ziph.write(os.path.join(root, curfile))
            elif curfile.lower().find('.o')>-1:
                ziph.write(os.path.join(root, curfile))
            elif curfile.lower().find('.mod')>-1:
                ziph.write(os.path.join(root, curfile))

if __name__ == "__main__":
    bench_current = estimate(optim=0)
    bench_optim = estimate(optim=1)
    bench_init = estimate(optim=2)
    print("actual speedup : {0:.2f}".format(bench_current['execution_time']/bench_init['execution_time']))
    print("optimal speedup : {0:.2f}".format(bench_optim['execution_time']/bench_init['execution_time']))
    speedup_ratio = (bench_init['execution_time'] / bench_optim['execution_time'] )/10.
    current_ratio = bench_init['execution_time'] / bench_current['execution_time']
    print("points for speedup (/10): {0}".format(current_ratio/speedup_ratio))

#total_cache_miss_ratio
    cache_ratio = (bench_optim['cache']['total_cache_miss_ratio'] - bench_init['cache']['total_cache_miss_ratio'])/10.
    points_cache_ratio = (bench_current['cache']['total_cache_miss_ratio'] - bench_optim['cache']['total_cache_miss_ratio'])/cache_ratio
    print("points for optimization (/10): {0}".format(abs(points_cache_ratio)))

    summary_dict = {'initial': bench_init, 'current': bench_current, 'optim': bench_optim}

    with open('summary.json', 'w') as f:
        f.write(json.dumps(summary_dict))

    compress("tp.zip")
    print("data zipped in file tp.zip")



