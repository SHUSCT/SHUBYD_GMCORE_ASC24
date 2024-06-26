! ==============================================================================
! This file is part of GMCORE since 2019.
!
! GMCORE is a dynamical core for atmospheric model.
!
! GMCORE is distributed in the hope that it will be useful, but WITHOUT ANY
! WARRANTY. You may contact authors for helping or cooperation.
! ==============================================================================

module latlon_halo_mod

  use mpi
  use flogger
  use const_mod
  use latlon_mesh_mod
  use latlon_parallel_types_mod

  implicit none

  private

  public latlon_halo_type

  integer, parameter :: cross_proc_halo = 1
  integer, parameter :: cross_comm_halo = 2
  integer, parameter :: inner_halo = 3
  integer, parameter :: nest_halo = 4

  type latlon_halo_type
    integer :: comm     = MPI_COMM_NULL
    integer :: host_id  = MPI_PROC_NULL
    integer :: proc_id  = MPI_PROC_NULL
    integer :: iblk     = 0
    integer :: orient   = 0
    integer :: dtype    = 0
    integer :: type     = 0
    integer :: lon_hw   = 0
    integer :: lat_hw   = 0
    ! (1,1): full_lon,full_lat (1,2): full_lon,half_lat
    ! (2,1): half_lon,full_lat (2,2): half_lon,half_lat
    integer :: send_type_2d(2,2) = MPI_DATATYPE_NULL
    integer :: recv_type_2d(2,2) = MPI_DATATYPE_NULL
    ! (1,1,1): full_lon,full_lat,full_lev (1,2,1): full_lon,half_lat,full_lev
    ! (2,1,1): half_lon,full_lat,full_lev (2,2,1): half_lon,half_lat,full_lev
    ! (1,1,2): full_lon,full_lat,half_lev (1,2,2): full_lon,half_lat,half_lev
    ! (2,1,2): half_lon,full_lat,half_lev (2,2,2): half_lon,half_lat,half_lev
    integer :: send_type_3d(2,2,2) = MPI_DATATYPE_NULL
    integer :: recv_type_3d(2,2,2) = MPI_DATATYPE_NULL
  contains
    procedure :: init => latlon_halo_init
    procedure :: init_nest => latlon_halo_init_nest
    procedure :: clear => latlon_halo_clear
    final latlon_halo_final
  end type latlon_halo_type

contains

  subroutine latlon_halo_init(this, mesh, orient, dtype, host_id, ngb_proc_id, iblk, &
                              lon_hw, lat_hw, at_south_pole, at_north_pole)

    class(latlon_halo_type), intent(out) :: this
    type(latlon_mesh_type), intent(in) :: mesh
    integer, intent(in) :: orient
    integer, intent(in) :: dtype
    integer, intent(in) :: host_id
    integer, intent(in), optional :: ngb_proc_id
    integer, intent(in), optional :: iblk
    integer, intent(in), optional :: lon_hw
    integer, intent(in), optional :: lat_hw
    logical, intent(in), optional :: at_south_pole
    logical, intent(in), optional :: at_north_pole

    logical at_south_pole_opt
    logical at_north_pole_opt
    integer full_ids, full_ide
    integer full_jds, full_jde
    integer half_ids, half_ide
    integer half_jds, half_jde
    integer array_size(3,2,2)
    integer send_subarray_size(3,2,2)
    integer recv_subarray_size(3,2,2)
    integer send_subarray_start(3,2,2)
    integer recv_subarray_start(3,2,2)
    integer nlev(2)
    integer i, j, k, ierr

    at_south_pole_opt = .false.; if (present(at_south_pole)) at_south_pole_opt = at_south_pole
    at_north_pole_opt = .false.; if (present(at_north_pole)) at_north_pole_opt = at_north_pole

    if (present(ngb_proc_id)) then
      this%proc_id = ngb_proc_id
    else if (present(iblk)) then
      call log_error('Handle internal halo!', __FILE__, __LINE__)
    end if

    this%host_id = host_id
    this%dtype = dtype

    this%lon_hw = mesh%lon_hw; if (present(lon_hw)) this%lon_hw = lon_hw
    this%lat_hw = mesh%lat_hw; if (present(lat_hw)) this%lat_hw = lat_hw
    ! Calculate the start and end indices of halo for MPI.
    ! NOTE: MPI array index starts from zero.
    select case (orient)
    case (south, north)
      full_ids = mesh%lon_hw
      full_ide = mesh%full_nlon + mesh%lon_hw - 1
    case (west)
      full_ids = 0
      full_ide = mesh%lon_hw - 1
    case (east)
      full_ids = mesh%full_nlon + mesh%lon_hw
      full_ide = full_ids + mesh%lon_hw - 1
    end select
    half_ids = full_ids
    half_ide = full_ide
    select case (orient)
    case (west, east)
      full_jds = mesh%lat_hw
      full_jde = mesh%full_nlat + mesh%lat_hw - 1
    case (south)
      full_jds = 0
      full_jde = mesh%lat_hw - 1
    case (north)
      full_jds = mesh%full_nlat + mesh%lat_hw
      full_jde = full_jds + mesh%lat_hw - 1
    end select
    half_jds = merge(full_jds - 1, full_jds, mesh%has_north_pole() .and. orient == north)
    half_jde = merge(full_jde - 1, full_jde, mesh%has_north_pole() .and. orient /= south)

    !                          wx                          nx                          wx
    !                          |                           |                           |
    !                  |---------------|---------------------------------------|---------------|
    !                  |_______________|_______________________________________|_______________|__
    !                  |\\\\\\\|\\\\\\\|\\\\\\\|\\\\\\\|\\\\\\\|\\\\\\\|\\\\\\\|\\\\\\\|\\\\\\\|  |
    !         wy + ny -|\\\\\\\|\\\\\\\|\\\\\\\|\\\\\\\|\\\\\\\|\\\\\\\|\\\\\\\|\\\\\\\|\\\\\\\|  |- wy
    !                  |\\\\\\\|\\\\\\\|\\\\\\\|\\\\\\\|\\\\\\\|\\\\\\\|\\\\\\\|\\\\\\\|\\\\\\\|  |
    !                  |_______|_______|_______________________________________|_______________|__|
    !                  |///////|///////|       |       |       |       |       |///////|///////|  |
    !     wy + ny - 1 -|///////|///////|       |       |       |       |       |///////|///////|  |
    !                  |///////|///////|       |       |       |       |       |///////|///////|  |
    !                  |_______|_______|_______|_______|_______|_______|_______|_______|_______|  |
    !                  |///////|///////|       |       |       |       |       |///////|///////|  |
    !                  |///////|///////|       |       |       |       |       |///////|///////|  |- ny
    !                  |///////|///////|       |       |       |       |       |///////|///////|  |
    !                  |_______|_______|_______|_______|_______|_______|_______|_______|_______|  |
    !                  |///////|///////|       |       |       |       |       |///////|///////|  |
    !              wy -|///////|///////|       |       |       |       |       |///////|///////|  |
    !                  |///////|///////|       |       |       |       |       |///////|///////|  |
    !                  |_______|_______|_______|_______|_______|_______|_______|_______|_______|__|
    !                  |\\\\\\\|\\\\\\\|\\\\\\\|\\\\\\\|\\\\\\\|\\\\\\\|\\\\\\\|\\\\\\\|\\\\\\\|  |
    !               0 -|\\\\\\\|\\\\\\\|\\\\\\\|\\\\\\\|\\\\\\\|\\\\\\\|\\\\\\\|\\\\\\\|\\\\\\\|  |- wy
    !                  |\\\\\\\|\\\\\\\|\\\\\\\|\\\\\\\|\\\\\\\|\\\\\\\|\\\\\\\|\\\\\\\|\\\\\\\|  |
    !                  |_______|_______|_______|_______|_______|_______|_______|_______|_______|__|
    !                      |               |                       |       |       |
    !                      0               wx                      | wx + nx - 1   |
    !                                                              |            wx + nx
    !                                                              nx

    this%orient = orient
    this%type = cross_proc_halo
    nlev = [mesh%full_kme-mesh%full_kms+1,mesh%half_kme-mesh%half_kms+1]

    if (orient == south .or. orient == north) then
      full_ids = full_ids - this%lon_hw
      full_ide = full_ide + this%lon_hw
      half_ids = half_ids - this%lon_hw
      half_ide = half_ide + this%lon_hw
    end if

    do k = 1, 2 ! From full level to half level
      array_size(:,1,1) = [mesh%full_nlon+2*mesh%lon_hw,mesh%full_nlat+2*mesh%lat_hw,nlev(k)]
      array_size(:,2,1) = [mesh%half_nlon+2*mesh%lon_hw,mesh%full_nlat+2*mesh%lat_hw,nlev(k)]
      array_size(:,1,2) = [mesh%full_nlon+2*mesh%lon_hw,mesh%half_nlat+2*mesh%lat_hw,nlev(k)]
      array_size(:,2,2) = [mesh%half_nlon+2*mesh%lon_hw,mesh%half_nlat+2*mesh%lat_hw,nlev(k)]
      send_subarray_size(:,1,1) = [full_ide-full_ids+1,full_jde-full_jds+1,nlev(k)]
      recv_subarray_size(:,1,1) = send_subarray_size(:,1,1)
      send_subarray_size(:,2,1) = [half_ide-half_ids+1,full_jde-full_jds+1,nlev(k)]
      recv_subarray_size(:,2,1) = send_subarray_size(:,2,1)
      send_subarray_size(:,1,2) = [full_ide-full_ids+1,half_jde-half_jds+1,nlev(k)]
      recv_subarray_size(:,1,2) = send_subarray_size(:,1,2)
      send_subarray_size(:,2,2) = [half_ide-half_ids+1,half_jde-half_jds+1,nlev(k)]
      recv_subarray_size(:,2,2) = send_subarray_size(:,2,2)
      select case (orient)
      case (west)
        ! full_lon + full_lat
        send_subarray_start(:,1,1) = [full_ide+1,full_jds,0]
        recv_subarray_start(:,1,1) = [full_ids  ,full_jds,0]
        ! half_lon + full_lat
        send_subarray_start(:,2,1) = [half_ide+1,full_jds,0]
        recv_subarray_start(:,2,1) = [half_ids  ,full_jds,0]
        ! full_lon + half_lat
        send_subarray_start(:,1,2) = [full_ide+1,half_jds,0]
        recv_subarray_start(:,1,2) = [full_ids  ,half_jds,0]
        ! half_lon + half_lat
        send_subarray_start(:,2,2) = [half_ide+1,half_jds,0]
        recv_subarray_start(:,2,2) = [half_ids  ,half_jds,0]
      case (east)
        ! full_lon + full_lat
        send_subarray_start(:,1,1) = [full_ids-this%lon_hw,full_jds,0]
        recv_subarray_start(:,1,1) = [full_ids            ,full_jds,0]
        ! half_lon + full_lat
        send_subarray_start(:,2,1) = [half_ids-this%lon_hw,full_jds,0]
        recv_subarray_start(:,2,1) = [half_ids            ,full_jds,0]
        ! full_lon + half_lat
        send_subarray_start(:,1,2) = [full_ids-this%lon_hw,half_jds,0]
        recv_subarray_start(:,1,2) = [full_ids            ,half_jds,0]
        ! half_lon + half_lat
        send_subarray_start(:,2,2) = [half_ids-this%lon_hw,half_jds,0]
        recv_subarray_start(:,2,2) = [half_ids            ,half_jds,0]
      case (south)
        if (at_south_pole_opt) then
          ! full_lon + full_lat
          send_subarray_start(:,1,1) = [full_ids,full_jde+2,0]
          recv_subarray_start(:,1,1) = [full_ids,full_jds  ,0]
          ! half_lon + full_lat
          send_subarray_start(:,2,1) = [half_ids,full_jde+2,0]
          recv_subarray_start(:,2,1) = [half_ids,full_jds  ,0]
          ! full_lon + half_lat
          send_subarray_start(:,1,2) = [full_ids,half_jde+1,0]
          recv_subarray_start(:,1,2) = [full_ids,half_jds  ,0]
          ! half_lon + half_lat
          send_subarray_start(:,2,2) = [half_ids,half_jde+1,0]
          recv_subarray_start(:,2,2) = [half_ids,half_jds  ,0]
        else
          ! full_lon + full_lat
          send_subarray_start(:,1,1) = [full_ids,full_jde+1,0]
          recv_subarray_start(:,1,1) = [full_ids,full_jds  ,0]
          ! half_lon + full_lat
          send_subarray_start(:,2,1) = [half_ids,full_jde+1,0]
          recv_subarray_start(:,2,1) = [half_ids,full_jds  ,0]
          ! full_lon + half_lat
          send_subarray_start(:,1,2) = [full_ids,half_jde+1,0]
          recv_subarray_start(:,1,2) = [full_ids,half_jds  ,0]
          ! half_lon + half_lat
          send_subarray_start(:,2,2) = [half_ids,half_jde+1,0]
          recv_subarray_start(:,2,2) = [half_ids,half_jds  ,0]
        end if
      case (north)
        if (at_north_pole_opt) then
          ! full_lon + full_lat
          send_subarray_start(:,1,1) = [full_ids,full_jds-this%lat_hw-1,0]
          recv_subarray_start(:,1,1) = [full_ids,full_jds              ,0]
          ! half_lon + full_lat
          send_subarray_start(:,2,1) = [half_ids,full_jds-this%lat_hw-1,0]
          recv_subarray_start(:,2,1) = [half_ids,full_jds              ,0]
          ! full_lon + half_lat
          send_subarray_start(:,1,2) = [full_ids,half_jds-this%lat_hw  ,0]
          recv_subarray_start(:,1,2) = [full_ids,half_jds              ,0]
          ! half_lon + half_lat
          send_subarray_start(:,2,2) = [half_ids,half_jds-this%lat_hw  ,0]
          recv_subarray_start(:,2,2) = [half_ids,half_jds              ,0]
        else
          ! full_lon + full_lat
          send_subarray_start(:,1,1) = [full_ids,full_jds-this%lat_hw  ,0]
          recv_subarray_start(:,1,1) = [full_ids,full_jds              ,0]
          ! half_lon + full_lat
          send_subarray_start(:,2,1) = [half_ids,full_jds-this%lat_hw  ,0]
          recv_subarray_start(:,2,1) = [half_ids,full_jds              ,0]
          ! full_lon + half_lat
          send_subarray_start(:,1,2) = [full_ids,half_jds-this%lat_hw  ,0]
          recv_subarray_start(:,1,2) = [full_ids,half_jds              ,0]
          ! half_lon + half_lat
          send_subarray_start(:,2,2) = [half_ids,half_jds-this%lat_hw  ,0]
          recv_subarray_start(:,2,2) = [half_ids,half_jds              ,0]
        end if
      end select
      do j = 1, 2
        do i = 1, 2
          call MPI_TYPE_CREATE_SUBARRAY(3, array_size(:,i,j), send_subarray_size(:,i,j), &
                                        send_subarray_start(:,i,j), MPI_ORDER_FORTRAN, dtype, &
                                        this%send_type_3d(i,j,k), ierr)
          call MPI_TYPE_COMMIT(this%send_type_3d(i,j,k), ierr)
          call MPI_TYPE_CREATE_SUBARRAY(3, array_size(:,i,j), recv_subarray_size(:,i,j), &
                                        recv_subarray_start(:,i,j), MPI_ORDER_FORTRAN, dtype, &
                                        this%recv_type_3d(i,j,k), ierr)
          call MPI_TYPE_COMMIT(this%recv_type_3d(i,j,k), ierr)
        end do
      end do
    end do

    do j = 1, 2
      do i = 1, 2
        call MPI_TYPE_CREATE_SUBARRAY(2, array_size(1:2,i,j), send_subarray_size(1:2,i,j), &
                                      send_subarray_start(1:2,i,j), MPI_ORDER_FORTRAN, dtype, &
                                      this%send_type_2d(i,j), ierr)
        call MPI_TYPE_COMMIT(this%send_type_2d(i,j), ierr)
        call MPI_TYPE_CREATE_SUBARRAY(2, array_size(1:2,i,j), recv_subarray_size(1:2,i,j), &
                                      recv_subarray_start(1:2,i,j), MPI_ORDER_FORTRAN, dtype, &
                                      this%recv_type_2d(i,j), ierr)
        call MPI_TYPE_COMMIT(this%recv_type_2d(i,j), ierr)
      end do
    end do

  end subroutine latlon_halo_init

  subroutine latlon_halo_init_nest(this, parent_mesh, parent_proc_id)

    class(latlon_halo_type), intent(inout) :: this
    type(latlon_mesh_type), intent(in) :: parent_mesh
    integer, intent(in) :: parent_proc_id

  end subroutine latlon_halo_init_nest

  subroutine latlon_halo_clear(this)

    class(latlon_halo_type), intent(inout) :: this

    integer i, j, k
    integer ierr

    do k = 1, 2
      do j = 1, 2
        do i = 1, 2
          if (this%send_type_3d(i,j,k) /= MPI_DATATYPE_NULL) call MPI_TYPE_FREE(this%send_type_3d(i,j,k), ierr)
          if (this%recv_type_3d(i,j,k) /= MPI_DATATYPE_NULL) call MPI_TYPE_FREE(this%recv_type_3d(i,j,k), ierr)
        end do
      end do
    end do

    do j = 1, 2
      do i = 1, 2
        if (this%send_type_2d(i,j) /= MPI_DATATYPE_NULL) call MPI_TYPE_FREE(this%send_type_2d(i,j), ierr)
        if (this%recv_type_2d(i,j) /= MPI_DATATYPE_NULL) call MPI_TYPE_FREE(this%recv_type_2d(i,j), ierr)
      end do
    end do

  end subroutine latlon_halo_clear

  subroutine latlon_halo_final(this)

    type(latlon_halo_type), intent(inout) :: this

    call this%clear()

  end subroutine latlon_halo_final

end module latlon_halo_mod
