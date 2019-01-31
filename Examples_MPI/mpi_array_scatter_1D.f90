!  F90_MPI.f90 
!
!  FUNCTIONS:
!  F90_MPI - Entry point of console application.
!

!****************************************************************************
!
!  PROGRAM: F90_MPI
!
!  PURPOSE:  Entry point for the console application.
!
!****************************************************************************
program F90_MPI
  use MPI
  implicit none
  !real(kind=8), dimension(16)::base_array
  real(kind=8),allocatable, dimension(:)::local_array
  integer ::dummy, i, j
  integer ::ierr,myid, num_procs
  integer,parameter ::master = 0
  integer,parameter ::flat_size = 2*4
  real(kind=8), dimension(flat_size)::base_array
  integer ::flat_size_loc = 4
    
  call MPI_Init(ierr)

  ! find out process rank
  call MPI_Comm_rank(MPI_COMM_WORLD, myid, ierr)
  call MPI_Comm_size(MPI_COMM_WORLD, num_procs, ierr)          ! get number of procs
  if (myid .EQ. master) then
    base_array(:)=(/ (i,i=1,flat_size)/)
  else
    base_array(:)= 0.
  end if

  flat_size_loc = flat_size/num_procs
  allocate(local_array(flat_size_loc) )
  local_array(:)= -1.

  call MPI_SCATTER(base_array, flat_size_loc, MPI_DOUBLE_PRECISION, local_array, flat_size_loc, &
            MPI_DOUBLE_PRECISION, master , MPI_COMM_WORLD, ierr)
    
  print *,myid, " a recu :", local_array

  ! ajouter 1+id_proc à chaque élément local du tableau
  local_array(:) = local_array(:)*(1+myid) 
  call MPI_GATHER(local_array, flat_size_loc, MPI_DOUBLE_PRECISION, base_array, flat_size_loc, &
                  MPI_DOUBLE_PRECISION, master , MPI_COMM_WORLD, ierr)

  if (myid .EQ. master) print *,myid, " a reconstitue le tableau :", base_array
  deallocate(local_array)
  call MPI_FINALIZE(ierr)
end program F90_MPI

