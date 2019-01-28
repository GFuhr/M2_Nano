program main
use mpi !or self made mpi module
    use geometry

    use fields, only: init_fields, rk4, free_fields, u_t
    use h2d_IO, only:output
    implicit none

    integer ::i, imax, iout, iter
    !real(kind=8) ::CFL = D*dt/min(dx**2, dy**2)

! initialize MPI


i = 0
imax = int(Tmax/dt)
iout = int(Toutput/dt)
call init_fields(Nx, Ny)

! do domain decomposition here

do i=0, imax

    call rk4(u_t, dt)
    ! backup to file should be made by only 1 processor, take care of synchronization process
    if (mod(i, iout) .eq. 0) then
        call output(dble(i*dt), iter, 0)
        iter = iter +1
    end if
end do
call free_fields()

! MPI terminate

end program main