module mpicomm
    use mpi
    use geometry
    use fields, only:u_t

    implicit none

    integer ::num_procs
    integer ::status(mpi_status_size)
    integer ::myid, comm
    integer ::tag = 2
    integer ::ierr
    integer, parameter :: master = 0
    integer, parameter:: ndims = 2
    integer ::nxlocal, nylocal
    real(kind=8) ::starttime, endtime
    integer, dimension(2) :: voisins

contains 
subroutine init_mpi

    call MPI_INIT(ierr)
    
    comm = MPI_COMM_WORLD                          ! starts MPI
    call MPI_Comm_rank(comm, myid, ierr)      ! get current proc ID
    call MPI_Comm_size(comm, num_procs, ierr)          ! get number of procs


    ! get neighbours for current proc
    voisins(:)=MPI_PROC_NULL


    ! compute local size
    

    ! start timer
  if (myid .EQ. master) then
  starttime =  MPI_WTIME()
  else
    starttime = -1
  end if
end subroutine init_mpi

! if you need to send data between processors during RK scheme computation, you can uncomment and call this subroutine
!subroutine MPI_boundary(field)
!    real(kind=8), intent(in out), dimension(:,:)::field
!
!end subroutine MPI_boundary

subroutine mpi_end
if (myid .EQ. master) then
endtime=  MPI_WTIME()
print *, "total time", endtime - starttime
end if
call MPI_Finalize(ierr)
end subroutine mpi_end
end module mpicomm