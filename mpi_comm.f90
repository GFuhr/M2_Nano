module mpicomm
    use mpi
    use geometry
    use field, only u_t

    implicit none

    integer ::num_procs
    integer ::status(mpi_status_size)
    integer ::myid, comm
    integer ::tag = 2
    integer ::ierr
    integer, parameter :: master = 0
    integer, parameter:: ndims = 2

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
  if (myid .EQ. 0) then
  starttime =  MPI_WTIME()
  else
    starttime = -1
  end if
end subroutine init_mpi

subroutine MPI_boundary(field)
    real(kind=8), intent(in out), dimension(:,:)::field

end subroutine MPI_boundary

subroutine mpi_end
if (myid .EQ. 0)
endtime=  MPI_WTIME()
print *, "total time", endtime - starttime
end if
call MPI_Finalize(ierr)
end subroutine mpi_end
end module mpicomm