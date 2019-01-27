module geometry
    real(kind=8), parameter:: pi = 4.0_8*atan(1.0_8)
    real(kind=8), parameter :: Lx  = 20.0_8*pi
    real(kind=8), parameter:: Ly  = 20.0_8*pi
    integer, parameter :: Nx = 128
    integer, parameter :: Ny = 128

    real(kind=8), parameter :: dx  = Lx/Nx
    real(kind=8), parameter:: dy  = Ly/Ny
    real(kind=8), parameter:: dt = .1_8
    real(kind=8), parameter:: Tmax = 2000._8 
    real(kind=8), parameter:: D = .1_8
    real(kind=8), parameter:: V = -0.01_8
    integer ::inx ! local x size
    integer ::iny ! local y size
    ! following constant are used in the time scheme, don't modify them
    real(kind=8), parameter:: Toutput = dble(int(Tmax)/10_8) ! 10 outputs during the simulation
    real(kind=8), parameter:: dt6 = dt/6.0_8
    real(kind=8), parameter ::cdiff_x = D/(dx*dx) 
    real(kind=8), parameter ::cdiff_y = D/(dy*dy) 
    real(kind=8), parameter ::cadv_x = -V/(2.0_8*dx)
    real(kind=8), parameter ::cadv_y = -V/(2.0_8*dy)    
end module geometry