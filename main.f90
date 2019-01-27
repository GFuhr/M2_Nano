program main
    use geometry

    use fields, only: init_fields, rk4, free_fields, u_t
    use h2d_IO, only:output
    implicit none

    integer ::i, imax, iout, iter
    !real(kind=8) ::CFL = D*dt/min(dx**2, dy**2)

i = 0
imax = int(Tmax/dt)
iout = int(Toutput/dt)
call init_fields(Nx, Ny)
print *,imax, iout, dt, Tmax, Toutput
do i=0, imax

    call rk4(u_t, dt)
    if (mod(i, iout) .eq. 0) then
        call output(dble(i*dt), iter, 0)
        iter = iter +1
    end if
end do
call free_fields()
end program main