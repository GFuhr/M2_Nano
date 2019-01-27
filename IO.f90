!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! -*- Mode: F90 -*- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!! module_IO.f90 --- 
!!!!
!! subroutine read_params
!! subroutine output 
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

module h2d_IO
    integer, parameter:: prec = 8
    private
    public output
    contains
    
    subroutine output(t, nout, mype)
      use geometry
      use fields, only:u_t
      implicit none
    
      ! Local variables
      character(LEN=80) :: filename
      character(LEN=5)  :: char,charpe
      integer, intent(in) :: nout,MYPE
      real(kind=prec), intent(in) :: t

      call title(nout,char)
      call title(MYPE,charpe)
      filename='output_'//TRIM(char)//'.'//TRIM(charpe)
      open(10,file=filename,form='unformatted', status='replace')
      rewind(10)
     
      write(10)real(t,kind=prec),real(D,kind=prec),real(V,kind=prec)
      write(10)nx,ny
      write(10)u_t(:,:)
      close(10)
    
    contains
    
    subroutine title(n,nchar)
      implicit none
    
      integer, intent(in) :: n
      character(LEN=5), intent(out) :: nchar
      character(LEN=1) :: nchar1
      character(LEN=2) :: nchar2
      character(LEN=3) :: nchar3
      character(LEN=4) :: nchar4
      character(LEN=5) :: nchar5
    
      if(n.ge.10000)then
         write(nchar5,'(i5)') n
         nchar = nchar5
      elseif(n.ge.1000)then
         write(nchar4,'(i4)') n
         nchar = '0'//nchar4
      elseif(n.ge.100)then
         write(nchar3,'(i3)') n
         nchar = '00'//nchar3
      elseif(n.ge.10)then
         write(nchar2,'(i2)') n
         nchar = '000'//nchar2
      else
         write(nchar1,'(i1)') n
         nchar = '0000'//nchar1
      endif
    end subroutine title
    
    end subroutine output
    
    end module h2d_io
    