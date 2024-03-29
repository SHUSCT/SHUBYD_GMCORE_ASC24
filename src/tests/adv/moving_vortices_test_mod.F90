module moving_vortices_test_mod

  use const_mod
  use namelist_mod, dt => dt_adv
  use sphere_geometry_mod
  use latlon_parallel_mod
  use history_mod
  use block_mod
  use adv_mod
  use tracer_mod

  implicit none

  private

  public moving_vortices_test_init
  public moving_vortices_test_set_ic
  public moving_vortices_test_set_uv

  real(8), parameter :: period = 12 * 86400    ! Rotation period
  real(8), parameter :: rho0   = 3             !
  real(8), parameter :: gamma  = 5             ! Field stiffness parameter
  real(8), parameter :: alpha  = pi05          ! Angle between Rotation axis and the equator
  real(8), parameter :: lonp0  = pi            ! Rotation north pole longitude
  real(8), parameter :: latp0  = pi05 - alpha  ! Rotation north pole latitude
  real(8), parameter :: lonv0  = pi * 1.5_r8   ! Initial vortex longitude
  real(8), parameter :: latv0  = 0             ! Initial vortex latitude
  real(8) u0                                   ! Velocity amplitude
  real(8) lonvr0                               ! Initial vortex longitude in rotated coordinate
  real(8) lonvr                                ! Vortex longitude in rotated coordinate
  real(8) latvr                                ! Vortex latitude  in rotated coordinate
  real(8) lonv                                 ! Vortex longitude
  real(8) latv                                 ! Vortex latitude

contains

  subroutine moving_vortices_test_init()

    u0 = pi2 * radius / (12.0_r8 * 86400.0_r8)

    call rotate(lonp0, latp0, lonv0, latv0, lonvr, latvr)
    lonv = lonv0
    latv = latv0
    lonvr0 = lonvr

    call tracer_add('moving_vortices', dt, 'q0', 'background tracer')
    call tracer_add('moving_vortices', dt, 'q1', 'vortex tracer'    )

  end subroutine moving_vortices_test_init

  subroutine moving_vortices_test_set_ic()

    integer iblk, i, j
    real(8) lon, lat, lonr, latr

    do iblk = 1, size(blocks)
      associate (block => blocks(iblk)     , &
                 mesh  => blocks(iblk)%mesh, &
                 q     => tracers(iblk)%q  )
      ! Background tracer
      q%d(:,:,:,1) = 1
      ! Vortex tracer
      do j = mesh%full_jds, mesh%full_jde
        lat = mesh%full_lat(j)
        do i = mesh%full_ids, mesh%full_ide
          lon = mesh%full_lon(i)
          call rotate(lonv0, latv0, lon, lat, lonr, latr)
          q%d(i,j,1,2) = 1 - tanh(rho(latr) / gamma * sin(lonr))
        end do
      end do
      call fill_halo(q, 2)
      end associate
    end do

  end subroutine moving_vortices_test_set_ic

  subroutine moving_vortices_test_set_uv(time_in_seconds, itime)

    real(r8), intent(in) :: time_in_seconds
    integer, intent(in) :: itime
    real(8), allocatable :: clat(:), clon(:), slat(:), slon(:),dlon(:),cdlon(:),sdlon(:)
    real(8) calpha, salpha, slatv, clatv

    integer iblk, i, j
    real(8) lon, lat, latr
    integer len1,len2,full_jds_no_pole,full_jde_no_pole,half_ids,half_ide,full_ids,full_ide,half_jds,half_jde

    lonvr = lonvr0 + u0 / radius * time_in_seconds
    if (lonvr > pi2) lonvr = lonvr - pi2
    call rotate_back(lonp0, latp0, lonv, latv, lonvr, latvr)

    do iblk = 1, size(blocks)
      associate (block   => blocks(iblk)                    , &
                 mesh    => blocks(iblk)%mesh               , &
                 dmg     => blocks(iblk)%dstate(itime)%dmg  , &
                 dmg_lon => blocks(iblk)%aux%dmg_lon        , &
                 dmg_lat => blocks(iblk)%aux%dmg_lat        , &
                 u       => blocks(iblk)%dstate(itime)%u_lon, &
                 v       => blocks(iblk)%dstate(itime)%v_lat, &
                 mfx     => blocks(iblk)%aux%mfx_lon        , &
                 mfy     => blocks(iblk)%aux%mfy_lat        )
      dmg%d = 1; dmg_lon%d = 1; dmg_lat%d = 1
      full_jds_no_pole = mesh%full_jds_no_pole
      full_jde_no_pole = mesh%full_jde_no_pole
      half_ids = mesh%half_ids
      half_ide = mesh%half_ide
      len1 = full_jde_no_pole - full_jds_no_pole + 1
      len2 = half_ide - half_ids + 1
      ! Using Intel OneAPI Math Kernel Library
      allocate(clat(full_jds_no_pole:full_jde_no_pole))
      allocate(clon(half_ids:half_ide))
      allocate(slat(full_jds_no_pole:full_jde_no_pole))
      allocate(slon(half_ids:half_ide))
      allocate(dlon(half_ids:half_ide))
      allocate(cdlon(half_ids:half_ide))
      allocate(sdlon(half_ids:half_ide))
      call vdcos(len1, mesh%full_lat(full_jds_no_pole:full_jde_no_pole), clat)
      call vdcos(len2, mesh%half_lon(half_ids:half_ide), clon)
      call vdsin(len1, mesh%full_lat(full_jds_no_pole:full_jde_no_pole), slat)
      call vdsin(len2, mesh%half_lon(half_ids:half_ide), slon)
      call vdsub(len2, mesh%half_lon(half_ids:half_ide), lonv, dlon)
      call vdcos(len2, dlon(half_ids:half_ide), cdlon)
      calpha = cos(alpha)
      salpha = sin(alpha)
      slatv = sin(latv)
      clatv = cos(latv)
      do j = full_jds_no_pole, full_jde_no_pole
        do i = half_ids, half_ide
          ! u%d(i,j,1) = u0 * (cos(lat) * cos(alpha) + sin(lat) * cos(lon) * sin(alpha)) + &
          !              a_omg(latr) * (sin(latv) * cos(lat) - cos(latv) * cos(dlon) * sin(lat))
          u%d(i,j,1) = u0 * clat(j) * calpha + slat(j) * clon(i) * salpha + &
                       a_omg(latr) * (slatv * clat(j) - clatv * cdlon(i) * slat(j))
        end do
      end do
      deallocate(clat,clon,slat,slon,dlon,cdlon,sdlon)
      call fill_halo(u)
      mfx%d = u%d * dmg_lon%d
      len1 = mesh%half_jde - mesh%half_jds + 1
      len2 = mesh%full_ide - mesh%full_ids + 1
      full_ids = mesh%full_ids
      full_ide = mesh%full_ide
      half_jds = mesh%half_jds
      half_jde = mesh%half_jde
      ! Using Intel OneAPI Math Kernel Library
      allocate(slon(full_ids:full_ide))
      allocate(dlon(full_ids:full_ide))
      allocate(sdlon(full_ids:full_ide))
      call vdsin(len2,mesh%full_lon(full_ids:full_ide),slon)
      call vdsub(len2,mesh%full_lon(full_ids:full_ide),lonv,dlon)
      call vdsin(len2,dlon(full_ids:full_ide),sdlon)
      do j = half_jds, half_jde
        lat = mesh%half_lat(j)
        do i = full_ids, full_ide
          lon = mesh%full_lon(i)
          call rotate(lonv, latv, lon, lat, lat_r=latr)
          ! v%d(i,j,1) = -u0 * sin(lon) * sin(alpha) + a_omg(latr) * cos(latv) * sin(dlon)
          v%d(i,j,1) = -u0 * slon(i) * salpha + a_omg(latr) * clatv * sdlon(i)
        end do
      end do
      deallocate(slon,dlon,sdlon)
      call fill_halo(v)
      mfy%d = v%d * dmg_lat%d
      end associate
    end do

  end subroutine moving_vortices_test_set_uv

  real(r8) function rho(lat) result(res)

    real(8), intent(in) :: lat

    res = rho0 * cos(lat)

  end function rho

  real(r8) function a_omg(latr) result(res)

    real(8), intent(in) :: latr

    real(r8), parameter :: c = 1.5_r8 * sqrt(3.0_r8)
    real(r8) r

    r = rho(latr)
    if (abs(r) < eps) then
      res = 0
    else
      res = u0 * c / cosh(r)**2 * tanh(r) / r
    end if

  end function a_omg

end module moving_vortices_test_mod
