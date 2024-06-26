! ==============================================================================
! This file is part of GMCORE since 2019.
!
! GMCORE is a dynamical core for atmospheric model.
!
! GMCORE is distributed in the hope that it will be useful, but WITHOUT ANY
! WARRANTY. You may contact authors for helping or cooperation.
! ==============================================================================

module latlon_topo_mod

  use const_mod
  use namelist_mod
  use topo_reader_mod
  use block_mod
  use latlon_parallel_mod
  use process_mod
  use math_mod
  use filter_mod

  implicit none

  private

  public latlon_topo_regrid
  public latlon_topo_smooth

contains

  subroutine fill_grid(lon1, lon2, lat1, lat2, gzs, std, lnd, cnt)

    real(r8), intent(in) :: lon1
    real(r8), intent(in) :: lon2
    real(r8), intent(in) :: lat1
    real(r8), intent(in) :: lat2
    real(r8), intent(inout) :: gzs
    real(r8), intent(inout) :: std
    real(r8), intent(inout) :: lnd
    integer , intent(inout) :: cnt

    integer is, ie, js, je, i, j

    do is = 1, size(topo_lon)
      if (lon1 <= topo_lon(is)) exit
    end do
    do ie = size(topo_lon), 1, -1
      if (lon2 >= topo_lon(ie)) exit
    end do
    do js = 1, size(topo_lat)
      if (lat1 <= topo_lat(js)) exit
    end do
    do je = size(topo_lat), 1, -1
      if (lat2 >= topo_lat(je)) exit
    end do

    select case (planet)
    case ('earth')
      do j = js, je
        do i = is, ie
          if (topo_lon(i) < lon1 .or. topo_lon(i) > lon2 .or. topo_lat(j) < lat1 .or. topo_lat(j) > lat2) then
            stop 999
          end if
          if (allocated(topo_mask)) then
            if (topo_mask(i,j) == 1) then
              gzs = gzs + topo_gzs(i,j)
              std = std + topo_gzs(i,j)**2
            end if
          else
            if (topo_gzs(i,j) > 0) then
              gzs = gzs + topo_gzs(i,j)
              std = std + topo_gzs(i,j)**2
            end if
          end if
        end do
      end do
      lnd = lnd + count(topo_gzs(is:ie,js:je) > 0)
    case ('mars')
      gzs = gzs + sum(topo_gzs(is:ie,js:je))
      std = std + sum(topo_gzs(is:ie,js:je)**2)
      lnd = lnd + (ie - is + 1) * (je - js + 1)
    end select
    cnt = cnt + (ie - is + 1) * (je - js + 1)

  end subroutine fill_grid

  subroutine latlon_topo_regrid(block)

    type(block_type), intent(inout) :: block

    real(r8) min_lon, max_lon, min_lat, max_lat
    real(r8) lon1, lon2, lat1, lat2, pole_gzs, pole_std, pole_lnd
    integer i, j, pole_n
    integer n(block%mesh%full_ids:block%mesh%full_ide)

    associate (mesh => block%mesh           , &
               lnd  => block%static%landmask, &
               gzs  => block%static%gzs     , &
               std  => block%static%zs_std)
    lnd%d = 0; gzs%d = 0; std%d = 0
    do j = mesh%full_jds, mesh%full_jde
      lat1 = mesh%half_lat_deg(j-1); lat1 = merge(lat1, -90.0_r8, lat1 /= inf)
      lat2 = mesh%half_lat_deg(j  ); lat2 = merge(lat2,  90.0_r8, lat2 /= inf)
      n = 0
      do i = mesh%full_ids, mesh%full_ide
        lon1 = mesh%half_lon_deg(i-1)
        lon2 = mesh%half_lon_deg(i  )
        call fill_grid(lon1, lon2, lat1, lat2, gzs%d(i,j), std%d(i,j), lnd%d(i,j), n(i))
        if (.not. mesh%is_pole(j)) then
          gzs%d(i,j) = gzs%d(i,j) / n(i)
          std%d(i,j) = (std%d(i,j) - 2 * gzs%d(i,j)**2 * n(i) + gzs%d(i,j)**2) / n(i) / g
          lnd%d(i,j) = lnd%d(i,j) / n(i)
        end if
      end do
      if (mesh%is_pole(j)) then
        call zonal_sum(proc%zonal_circle, gzs%d(mesh%full_ids:mesh%full_ide,j), pole_gzs)
        call zonal_sum(proc%zonal_circle, std%d(mesh%full_ids:mesh%full_ide,j), pole_std)
        call zonal_sum(proc%zonal_circle, lnd%d(mesh%full_ids:mesh%full_ide,j), pole_lnd)
        call zonal_sum(proc%zonal_circle, n, pole_n)
        gzs%d(mesh%full_ids:mesh%full_ide,j) = pole_gzs / pole_n
        std%d(mesh%full_ids:mesh%full_ide,j) = (pole_std - 2 * pole_gzs**2 * pole_n + pole_gzs**2) / pole_n / g
        lnd%d(mesh%full_ids:mesh%full_ide,j) = pole_lnd / pole_n
      end if
    end do
    call fill_halo(gzs)
    call fill_halo(std)
    call fill_halo(lnd)
    end associate

  end subroutine latlon_topo_regrid

  subroutine latlon_topo_smooth(block)

    type(block_type), intent(inout) :: block

    real(r8) lat0, wgt
    integer i, j, cyc

    if (.not. use_topo_smooth) return
    if (proc%is_root()) call log_notice('Filter topography.')

    associate (mesh  => block%mesh         , &
               gzs   => block%static%gzs   , &
               gzs_f => block%dtend(1)%dmgs)   ! Borrow the array.
    lat0 = abs(global_mesh%full_lat_deg(2))
    do cyc = 1, topo_smooth_cycles
      call filter_run(block%big_filter, gzs, gzs_f)
      do j = mesh%full_jds_no_pole, mesh%full_jde_no_pole
        wgt = exp_two_values(1.0_r8, 0.0_r8, lat0, 45.0_r8, abs(mesh%full_lat_deg(j)))
        gzs%d(:,j) = wgt * gzs_f%d(:,j) + (1 - wgt) * gzs%d(:,j)
      end do
      call fill_halo(gzs)
    end do
    wgt = maxval(gzs%d / g)
    call global_max(proc%comm, wgt)
    if (proc%is_root()) call log_notice('Maximum zs is ' // to_str(wgt, 10) // '.')
    end associate

  end subroutine latlon_topo_smooth

end module latlon_topo_mod