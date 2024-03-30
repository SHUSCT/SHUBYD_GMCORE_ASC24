module solid_rotation_test_mod

  use const_mod
  use namelist_mod, dt => dt_adv
  use sphere_geometry_mod
  use latlon_parallel_mod
  use block_mod
  use adv_mod
  use tracer_mod

  implicit none

  public solid_rotation_test_init
  public solid_rotation_test_set_ic
  public solid_rotation_test_set_uv

  real(8), parameter :: period = 12 * 86400
  real(8), parameter :: h0     = 1000 ! m
  real(8), parameter :: lon0   = 3 * pi / 2.0_r8
  real(8), parameter :: lat0   = 0
  real(8), parameter :: alpha  = 90.0_r8 * rad
  real(8) u0

contains

  subroutine solid_rotation_test_init()

    u0 = pi2 * radius / period

    call tracer_add('solid_rotation', dt, 'q0', 'background tracer' )
    call tracer_add('solid_rotation', dt, 'q1', 'cosine bell tracer')

  end subroutine solid_rotation_test_init

  subroutine solid_rotation_test_set_ic()

    integer iblk, i, j
    real(8) lon, lat, r, R0

    R0 = radius / 3.0_r8

    do iblk = 1, size(blocks)
      associate (block => blocks(iblk)     , &
                 mesh  => blocks(iblk)%mesh, &
                 q     => tracers(iblk)%q  )
      ! Background
      q%d(:,:,:,1) = 1
      ! Cosine bell
      do j = mesh%full_jds, mesh%full_jde
        lat = mesh%full_lat(j)
        do i = mesh%full_ids, mesh%full_ide
          lon = mesh%full_lon(i)
          r = great_circle(radius, lon0, lat0, lon, lat)
          if (r < R0) then
            q%d(i,j,1,2) = h0 / 2.0_r8 * (1 + cos(pi * r / R0))
          else
            q%d(i,j,1,2) = 0
          end if
        end do
      end do
      call fill_halo(q, 2)
      end associate
    end do

  end subroutine solid_rotation_test_set_ic

  subroutine solid_rotation_test_set_uv(time_in_seconds, itime)

    real(r8), intent(in) :: time_in_seconds
    integer, intent(in) :: itime
    real(8), allocatable :: coslat(:), sinlat(:), coslon(:), sinlon(:)
    real(8) cosalpha, sinalpha

    integer iblk, i, j
    real(r8) lon, lat
    integer len1, len2, len3, full_jds_no_pole, full_jde_no_pole, half_ids, half_ide, half_jds, half_jde, full_ids, full_ide

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
      half_jds = mesh%half_jds
      half_jde = mesh%half_jde
      full_ids = mesh%full_ids
      full_ide = mesh%full_ide
      len1 = full_jde_no_pole - full_jds_no_pole + 1
      len2 = half_ide - half_ids + 1
      len3 = half_jde - half_jds + 1
      len4 = full_ide - full_ids + 1
      
      ! do j = mesh%full_jds_no_pole, mesh%full_jde_no_pole
      !   lat = mesh%full_lat(j)
      !   do i = mesh%half_ids, mesh%half_ide
      !     lon = mesh%half_lon(i)
      !     u%d(i,j,1) = u0 * (cos(lat) * cos(alpha) + sin(lat) * cos(lon) * sin(alpha))
      !   end do
      ! end do

      allocate(coslat(full_jds_no_pole:full_jde_no_pole))
      allocate(sinlat(full_jds_no_pole:full_jde_no_pole))
      allocate(coslon(half_ids:half_ide))
      allocate(sinlon(half_ids:half_ide))

      call vdcos(len1, mesh%full_lat(full_jds_no_pole:full_jde_no_pole), coslat)
      call vdcos(len2, mesh%half_lon(half_ids:half_ide), coslon)
      call vdsin(len1, mesh%full_lat(full_jds_no_pole:full_jde_no_pole), sinlat)
      call vdsin(len2, mesh%half_lon(half_ids:half_ide), sinlon)
      cosalpha = cos(alpha)
      sinalpha = sin(alpha)

      do j = full_jds_no_pole, full_jde_no_pole
        do i = half_ids, half_ide
          u%d(i,j,1) = u0 * (coslat(j) * cosalpha + sinlat(j) * coslon(i) * sinalpha)
        end do
      end do

      deallocate(coslat, sinlat, coslon, sinlon)

      allocate(coslon(full_ids:full_ide))
      allocate(sinlon(full_ids:full_ide))
      
      call vdsin(len3, mesh%half_lat(half_jds:half_jde), sinlat)
      call vdsin(len4, mesh%full_lon(full_ids:full_ide), sinlon)

      call fill_halo(u)
      mfx%d = u%d
      do j = half_jds, half_jde
        do i = full_ids, full_ide
          v%d(i,j,1) = -u0 * sinlon(i) * sinalpha
        end do
      end do
      call fill_halo(v)
      mfy%d = v%d
      end associate
      deallocate(coslon, sinlon)
    end do

  end subroutine solid_rotation_test_set_uv

end module solid_rotation_test_mod
