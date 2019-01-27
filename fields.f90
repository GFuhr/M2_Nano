module fields

use geometry
implicit none
real(kind=8), allocatable::u_t(:,:)
real(kind=8), allocatable::k1(:,:)
real(kind=8), allocatable::k2(:,:)
real(kind=8), allocatable::k3(:,:)
real(kind=8), allocatable::k4(:,:)
real(kind=8), allocatable::u_tmp(:,:)
private
public u_t, init_fields, free_fields, rk4

contains
subroutine init_fields(Nx, Ny)
    integer, intent(in)::Nx
    integer, intent(in)::Ny

    allocate(u_t(Nx, Ny))
    allocate(u_tmp(Nx, Ny))

    call random_number(u_t)
end subroutine init_fields

subroutine init_ki(Nx, Ny)
    integer, intent(in)::Nx
    integer, intent(in)::Ny

    allocate(k1(Nx, Ny))
    allocate(k2(Nx, Ny))
    allocate(k3(Nx, Ny))
    allocate(k4(Nx, Ny))

end subroutine init_ki

subroutine free_ki()
    deallocate(k1)
    deallocate(k2)
    deallocate(k3)
    deallocate(k4)
end subroutine free_ki

subroutine free_fields()
    deallocate(u_t)
    deallocate(u_tmp)
end subroutine free_fields


subroutine rhs_field(field_out, field_in)
    ! routine to compute RHS of equation
    implicit none
    real(kind=8), intent(in)::field_in(:,:)
    real(kind=8), intent(out)::field_out(:,:)
    integer ::i,j


    do i=2, Nx-1
        do j=2, Ny-1
        
            if (i==2) then
                field_out(i,j) = cdiff_x*( -2.0_8*field_in(i, j)) +&
                cadv_x*(2.0_8*field_in(i+1, j)) 
            else if (i==Nx-1) then
                field_out(i,j) = cdiff_x*( -2.0_8*field_in(i, j)) +&
                cadv_x*(-2.0_8*field_in(i-1, j)) 
            else
                field_out(i,j) = cdiff_x*(field_in(i+1, j) + field_in(i-1, j) -2.0_8*field_in(i, j)) +&
                cadv_x*(field_in(i+1, j) - field_in(i-1, j)) 
            end if

        end do
    end do
    do i=2, Nx-1
        do j=2, Ny-1
            if (j==2) then
                field_out(i,j) = field_out(i,j) + cdiff_y*( -2.0_8*field_in(i, j)) +&
                cadv_y*(2.0_8*field_in(i, j+1) )  
            else if (j==Ny-1) then
                field_out(i,j) = field_out(i,j) + cdiff_y*( -2.0_8*field_in(i, j)) +&
                cadv_y*(-2.0_8* field_in(i, j-1)) 
            else
                field_out(i,j) = field_out(i,j) + cdiff_y*(field_in(i, j+1) + field_in(i, j-1) -2.0_8*field_in(i, j)) +&
                cadv_y*(field_in(i, j+1) - field_in(i, j-1))  
            end if
        end do
    end do
end subroutine rhs_field

subroutine boundary(field)
! u(:,y_max) = u(:,0) = 0
! u(0,y) = u(x_max,0) = 0
    implicit none
real(kind=8),intent(in out)  :: field(:,:)
field(:,1) = -field(:,3)
field(:,Ny) = -field(:,Ny-2)
field(1,:) = -field(3,:)
field(Nx,:) = -field(Nx-2,:)
end subroutine boundary

subroutine rk_add(field_out, field_1, field_2, gamma)
    implicit none
    real(kind=8), intent(out)::field_out(:,:)
    real(kind=8), intent(in)::field_1(:,:)
    real(kind=8), intent(in)::field_2(:,:)
    real(kind=8), intent(in) ::gamma
    integer ::i,j 

    do i=1, Nx
    do j=1, Ny
            field_out(i, j) = field_1(i, j) + gamma*field_2(i,j)
        end do
    end do
    call boundary(field_out)
end subroutine rk_add

subroutine rk4(u_t, dt)
    implicit none
    real(kind=8), intent(in out)::u_t(:,:)
    real(kind=8), intent(in):: dt
    !TODO_add_body
    call init_ki(Nx, Ny)

    call rhs_field(k1, u_t)
    call rk_add(u_tmp, u_t, k1, .5_8*dt)

    call rhs_field( k2, u_tmp)
    call rk_add(u_tmp, u_t, k2, .5_8*dt)

    call rhs_field(k3, u_tmp)
    call rk_add(u_tmp, u_t, k3, dt)

    call rhs_field(k4, u_tmp)
    call boundary(k4)

    u_t(:,:) = u_t(:,:)+ dt6*(k1+2.0_8*(k2+k3)+k4)
    call boundary(u_t)

    call free_ki()
end subroutine rk4
end module fields