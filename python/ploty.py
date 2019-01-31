import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

def readh2d(filename):
    with open(filename, 'rb') as f:
        dummy_wtf = np.fromfile(f, dtype=np.int, count=1)
        _ = np.fromfile(f, dtype='<f8', count=3)
        dummy_wtf = np.fromfile(f, dtype=np.int, count=2)
        d1 = np.fromfile(f, dtype=np.int, count=2)
        dummy_wtf = np.fromfile(f, dtype=np.int, count=2)
        ut = np.fromfile(f, dtype='<f8')
        ut = ut.reshape(d1[0], d1[1])
    return ut

if __name__=='__main__':
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument('file', action="store")
    #parser.add_argument('--show', action="store_true", default=False)

    results = parser.parse_args()
    
    # make figure
    fname = results.file
    ut = readh2d(fname)
    plt.figure(figsize=(16,16))
    plt.pcolormesh(ut[:, :])
    plt.colorbar()
    outname = '{0}.png'.format((fname.split('.')[0]))
    plt.savefig(outname)

