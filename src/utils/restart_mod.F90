! ==============================================================================
! This file is part of GMCORE since 2019.
!
! GMCORE is a dynamical core for atmospheric model.
!
! GMCORE is distributed in the hope that it will be useful, but WITHOUT ANY
! WARRANTY. You may contact authors for helping or cooperation.
! ==============================================================================
! Description:
!
!   This module writes and reads restart files in NetCDF format.
!
!   When using Intel OneAPI 2021 or so, the sliced array arguments cause
!   segmentation fault, so I used allocated tmp array to avoid this problem.
!
! Authors:
!
!   - Li Dong (Institute of Atmospheric Physics, Chinese Academy of Sciences)
! ==============================================================================

module restart_mod

  use mpi
  use fiona
  use string
  use flogger
  use datetime
  use const_mod
  use namelist_mod
  use time_mod, old => old_time_idx
  use block_mod
  use tracer_mod
  use latlon_parallel_mod
  use process_mod, only: proc

  implicit none

  private

  public restart_init
  public restart_write
  public restart_read

contains

  subroutine restart_init()

    character(10) time_value, time_units
    real(r8) seconds

    if (restart_interval == 'N/A') then
      if (proc%is_root()) call log_warning('Parameter restart_interval is not set, so no restart file outputted.')
      return
    end if
    if (case_name == 'N/A') call log_error('Parameter case_name is not set!')

    time_value = split_string(restart_interval, ' ', 1)
    time_units = split_string(restart_interval, ' ', 2)
    read(time_value, *) seconds
    select case (time_units)
    case ('days', 'sol')
      seconds = seconds * 86400
    case ('hours')
      seconds = seconds * 3600
    case ('minutes')
      seconds = seconds * 60
    case ('seconds')
      seconds = seconds
    case default
      call log_error('Invalid restart interval ' // trim(restart_interval) // '!')
    end select

    call time_add_alert('restart_write', seconds=seconds)

  end subroutine restart_init

  subroutine restart_write(itime)

    integer, intent(in) :: itime

    integer iblk, is, ie, js, je, ks, ke, ierr, l, m, n
    integer start(3), count(3)
    character(4) lon_dims_3d(4), lat_dims_3d(4), lev_dims_3d(4), cell_dims_3d(4)
    character(4) lon_dims_2d(3), lat_dims_2d(3),                 cell_dims_2d(3)
    character(30) tag
    real(8) time1, time2
    real(r8), allocatable :: tmp(:,:,:)

    if (proc%is_root()) then
      call log_notice('Write restart.')
      time1 = MPI_WTIME()
    end if

     lon_dims_3d(1) = 'ilon';  lon_dims_3d(2) =  'lat';  lon_dims_3d(3) =  'lev';  lon_dims_3d(4) = 'time'
     lat_dims_3d(1) =  'lon';  lat_dims_3d(2) = 'ilat';  lat_dims_3d(3) =  'lev';  lat_dims_3d(4) = 'time'
     lev_dims_3d(1) =  'lon';  lev_dims_3d(2) =  'lat';  lev_dims_3d(3) = 'ilev';  lev_dims_3d(4) = 'time'
    cell_dims_3d(1) =  'lon'; cell_dims_3d(2) =  'lat'; cell_dims_3d(3) =  'lev'; cell_dims_3d(4) = 'time'
     lon_dims_2d(1) = 'ilon';  lon_dims_2d(2) =  'lat';  lon_dims_2d(3) = 'time'
     lat_dims_2d(1) =  'lon';  lat_dims_2d(2) = 'ilat';  lat_dims_2d(3) = 'time'
    cell_dims_2d(1) =  'lon'; cell_dims_2d(2) =  'lat'; cell_dims_2d(3) = 'time'

    call fiona_create_dataset('r0', desc=case_desc, file_prefix=trim(case_name) // '.' // trim(curr_time_str), &
      mpi_comm=proc%comm, ngroup=output_ngroup)

    call fiona_add_att('r0', 'time_step_size', dt_dyn)
    call fiona_add_att('r0', 'restart_interval', restart_interval)
    call fiona_add_dim('r0', 'time'     , add_var=.true.)
    call fiona_add_dim('r0', 'lon'      , size=global_mesh%full_nlon, add_var=.true., decomp=.true.)
    call fiona_add_dim('r0', 'lat'      , size=global_mesh%full_nlat, add_var=.true., decomp=.true.)
    call fiona_add_dim('r0', 'ilon'     , size=global_mesh%half_nlon, add_var=.true., decomp=.true.)
    call fiona_add_dim('r0', 'ilat'     , size=global_mesh%half_nlat, add_var=.true., decomp=.true.)
    call fiona_add_var('r0', 'time_step', long_name='', units='', dim_names=['time'], dtype='i4')
    if (baroclinic) then
      call fiona_add_dim('r0', 'lev'      , size=global_mesh%full_nlev, add_var=.true.)
      call fiona_add_dim('r0', 'ilev'     , size=global_mesh%half_nlev, add_var=.true.)
      call fiona_add_var('r0', 'u'        , long_name='U wind component'            , units='m s-1'     , dim_names=lon_dims_3d , dtype='r8')
      call fiona_add_var('r0', 'v'        , long_name='V wind component'            , units='m s-1'     , dim_names=lat_dims_3d , dtype='r8')
      call fiona_add_var('r0', 'mfx_lon'  , long_name='Zonal mass flux'             , units='Pa m s-1'  , dim_names=lon_dims_3d , dtype='r8')
      call fiona_add_var('r0', 'mfy_lat'  , long_name='Meridional mass flux'        , units='Pa m s-1'  , dim_names=lat_dims_3d , dtype='r8')
      call fiona_add_var('r0', 'mgs'      , long_name='Surface dry-air weight'      , units='Pa'        , dim_names=cell_dims_2d, dtype='r8')
      call fiona_add_var('r0', 'pt'       , long_name='Potential temperature'       , units='K'         , dim_names=cell_dims_3d, dtype='r8')
      if (nonhydrostatic) then
        call fiona_add_var('r0', 'gz_lev' , long_name='Geopotential height'         , units='m2 s-2'    , dim_names=lev_dims_3d , dtype='r8')
        call fiona_add_var('r0', 'w'      , long_name='Vertical velocity'           , units='m s-1'     , dim_names=lev_dims_3d , dtype='r8')
      end if
      call fiona_add_var('r0', 'we_lev'   , long_name='Vertical coordinate velocity', units='s-1'       , dim_names=lev_dims_3d , dtype='r8')
    else
      call fiona_add_var('r0', 'u'        , long_name='U wind component'            , units='m s-1'     , dim_names=lon_dims_2d , dtype='r8')
      call fiona_add_var('r0', 'v'        , long_name='V wind component'            , units='m s-1'     , dim_names=lat_dims_2d , dtype='r8')
      call fiona_add_var('r0', 'mfx_lon'  , long_name='Zonal mass flux'             , units='Pa m s-1'  , dim_names=lon_dims_2d , dtype='r8')
      call fiona_add_var('r0', 'mfy_lat'  , long_name='Meridional mass flux'        , units='Pa m s-1'  , dim_names=lat_dims_2d , dtype='r8')
      call fiona_add_var('r0', 'gz'       , long_name='Geopotential height'         , units='m2 s-2'    , dim_names=cell_dims_2d, dtype='r8')
    end if
    call fiona_add_var('r0', 'gzs'        , long_name='surface geopotential height' , units='m2 s-2'    , dim_names=cell_dims_2d, dtype='r8')

    if (allocated(blocks(1)%adv_batches)) then
      do m = 1, size(blocks(1)%adv_batches)
        tag = blocks(1)%adv_batches(m)%name
        do l = 1, blocks(1)%adv_batches(m)%ntracers
          n = blocks(1)%adv_batches(m)%idx(l)
          call fiona_add_var('r0', tracer_names(n), long_name=tracer_long_names(n), units=tracer_units(n), dim_names=cell_dims_3d, dtype='r8')
        end do
        call fiona_add_var('r0', trim(tag)//'_accum_mfx', long_name='', units='', dim_names= lon_dims_3d, dtype='r8')
        call fiona_add_var('r0', trim(tag)//'_accum_mfy', long_name='', units='', dim_names= lat_dims_3d, dtype='r8')
        call fiona_add_var('r0', trim(tag)//'_accum_mx' , long_name='', units='', dim_names= lon_dims_3d, dtype='r8')
        call fiona_add_var('r0', trim(tag)//'_accum_my' , long_name='', units='', dim_names= lat_dims_3d, dtype='r8')
        call fiona_add_var('r0', trim(tag)//'_accum_mz' , long_name='', units='', dim_names= lev_dims_3d, dtype='r8')
        call fiona_add_var('r0', trim(tag)//'_step'     , long_name='', units='', dim_names=    ['time'], dtype='i4')
        call fiona_add_var('r0', trim(tag)//'_last_time', long_name='', units='', dim_names=    ['time'], dtype='r8')
        call fiona_add_var('r0', trim(tag)//'_old_m'    , long_name='', units='', dim_names=cell_dims_3d, dtype='r8')
      end do
    end if

    if (physics_suite /= 'N/A') then
      call fiona_add_var('r0', 'phys_last_time', long_name='', units='', dim_names=['time'], dtype='r8')
    end if

    call fiona_start_output('r0', dble(elapsed_seconds), new_file=.true.)
    call fiona_output('r0', 'lon' , global_mesh%full_lon_deg(1:global_mesh%full_nlon))
    call fiona_output('r0', 'lat' , global_mesh%full_lat_deg(1:global_mesh%full_nlat))
    call fiona_output('r0', 'ilon', global_mesh%half_lon_deg(1:global_mesh%half_nlon))
    call fiona_output('r0', 'ilat', global_mesh%half_lat_deg(1:global_mesh%half_nlat))
    call fiona_output('r0', 'time_step', time_step)
    do iblk = 1, size(blocks)
      associate (mesh   => blocks(iblk)%mesh                , &
                 gzs    => blocks(iblk)%static%gzs          , &
                 mgs    => blocks(iblk)%dstate(itime)%mgs   , &
                 u_lon  => blocks(iblk)%dstate(itime)%u_lon , &
                 v_lat  => blocks(iblk)%dstate(itime)%v_lat , &
                 w_lev  => blocks(iblk)%dstate(itime)%w_lev , &
                 we_lev => blocks(iblk)%dstate(itime)%we_lev, &
                 pt     => blocks(iblk)%dstate(itime)%pt    , &
                 gz     => blocks(iblk)%dstate(itime)%gz    , &
                 gz_lev => blocks(iblk)%dstate(itime)%gz_lev, &
                 mfx_lon=> blocks(iblk)%aux%mfx_lon         , &
                 mfy_lat=> blocks(iblk)%aux%mfy_lat         , &
                 q      => tracers(iblk)%q                  )
      ! ------------------------------------------------------------------------
      if (allocated(blocks(1)%adv_batches)) then
        do m = 1, size(blocks(1)%adv_batches)
          associate (adv_batch => blocks(iblk)%adv_batches(m))
          tag = adv_batch%name
          call fiona_output('r0', trim(tag)//'_step'     , adv_batch%step)
          call fiona_output('r0', trim(tag)//'_last_time', time_get_alert_last_time_timestamp(adv_batch%name))
          end associate
        end do
      end if
      if (physics_suite /= 'N/A') then
        call fiona_output('r0', 'phys_last_time', time_get_alert_last_time_timestamp('phys'))
      end if
      ! ------------------------------------------------------------------------
      ! Location cell
      is = mesh%full_ids; ie = mesh%full_ide
      js = mesh%full_jds; je = mesh%full_jde
      ks = mesh%full_kds; ke = mesh%full_kde
      start = [is,js,ks]
      count = [mesh%full_nlon,mesh%full_nlat,mesh%full_nlev]
      allocate(tmp(is:ie,js:je,ks:ke))
      call fiona_output('r0', 'gzs', gzs%d(is:ie,js:je), start=start, count=count)
      if (baroclinic) then
        call fiona_output('r0', 'mgs', mgs%d(is:ie,js:je), start=start, count=count)
        call fiona_output('r0', 'pt', pt%d(is:ie,js:je,ks:ke), start=start, count=count)
      else
        call fiona_output('r0', 'gz', gz%d(is:ie,js:je,ks:ke), start=start, count=count)
      end if
      if (allocated(blocks(1)%adv_batches)) then
        do m = 1, size(blocks(1)%adv_batches)
          associate (adv_batch => blocks(iblk)%adv_batches(m))
          tag = adv_batch%name
          do l = 1, blocks(1)%adv_batches(m)%ntracers
            n = blocks(1)%adv_batches(m)%idx(l)
            tmp = q%d(is:ie,js:je,ks:ke,n)
            call fiona_output('r0', tracer_names(n), tmp, start=start, count=count)
          end do
          tmp = adv_batch%old_m%d(is:ie,js:je,ks:ke)
          call fiona_output('r0', trim(tag)//'_old_m', tmp, start=start, count=count)
          end associate
        end do
      end if
      deallocate(tmp)
      ! ------------------------------------------------------------------------
      ! Location lon edge
      is = mesh%half_ids; ie = mesh%half_ide
      js = mesh%full_jds; je = mesh%full_jde
      ks = mesh%full_kds; ke = mesh%full_kde
      start = [is,js,ks]
      count = [mesh%half_nlon,mesh%full_nlat,mesh%full_nlev]
      allocate(tmp(is:ie,js:je,ks:ke))
      tmp = u_lon  %d(is:ie,js:je,ks:ke); call fiona_output('r0', 'u'      , tmp, start=start, count=count)
      tmp = mfx_lon%d(is:ie,js:je,ks:ke); call fiona_output('r0', 'mfx_lon', tmp, start=start, count=count)
      if (allocated(blocks(1)%adv_batches)) then
        do m = 1, size(blocks(1)%adv_batches)
          associate (adv_batch => blocks(iblk)%adv_batches(m))
          tag = adv_batch%name
          if (adv_batch%step == -1) then
            tmp = adv_batch%mfx0%d(is:ie,js:je,ks:ke)
            call fiona_output('r0', trim(tag)//'_accum_mfx', tmp, start=start, count=count)
            tmp = adv_batch%mx0%d(is:ie,js:je,ks:ke)
            call fiona_output('r0', trim(tag)//'_accum_mx', tmp, start=start, count=count)
          else if (adv_batch%step >= 1) then
            tmp = adv_batch%mfx%d(is:ie,js:je,ks:ke)
            call fiona_output('r0', trim(tag)//'_accum_mfx', tmp, start=start, count=count)
            tmp = adv_batch%u%d(is:ie,js:je,ks:ke)
            call fiona_output('r0', trim(tag)//'_accum_mx', tmp, start=start, count=count)
          end if
          end associate
        end do
      end if
      deallocate(tmp)
      ! ------------------------------------------------------------------------
      ! Location lat edge
      is = mesh%full_ids; ie = mesh%full_ide
      js = mesh%half_jds; je = mesh%half_jde
      ks = mesh%full_kds; ke = mesh%full_kde
      start = [is,js,ks]
      count = [mesh%full_nlon,mesh%half_nlat,mesh%full_nlev]
      allocate(tmp(is:ie,js:je,ks:ke))
      tmp = v_lat  %d(is:ie,js:je,ks:ke); call fiona_output('r0', 'v'      , tmp, start=start, count=count)
      tmp = mfy_lat%d(is:ie,js:je,ks:ke); call fiona_output('r0', 'mfy_lat', tmp, start=start, count=count)
      if (allocated(blocks(1)%adv_batches)) then
        do m = 1, size(blocks(1)%adv_batches)
          associate (adv_batch => blocks(iblk)%adv_batches(m))
          tag = adv_batch%name
          if (adv_batch%step == -1) then
            tmp = adv_batch%mfy0%d(is:ie,js:je,ks:ke)
            call fiona_output('r0', trim(tag)//'_accum_mfy', tmp, start=start, count=count)
            tmp = adv_batch%my0%d(is:ie,js:je,ks:ke)
            call fiona_output('r0', trim(tag)//'_accum_my', tmp, start=start, count=count)
          else if (adv_batch%step >= 1) then
            tmp = adv_batch%mfy%d(is:ie,js:je,ks:ke)
            call fiona_output('r0', trim(tag)//'_accum_mfy', tmp, start=start, count=count)
            tmp = adv_batch%v%d(is:ie,js:je,ks:ke)
            call fiona_output('r0', trim(tag)//'_accum_my', tmp, start=start, count=count)
          end if
          end associate
        end do
      end if
      deallocate(tmp)
      ! ------------------------------------------------------------------------
      ! Location lev edge
      if (baroclinic) then
        is = mesh%full_ids; ie = mesh%full_ide
        js = mesh%full_jds; je = mesh%full_jde
        ks = mesh%half_kds; ke = mesh%half_kde
        start = [is,js,ks]
        count = [mesh%full_nlon,mesh%full_nlat,mesh%half_nlev]
        allocate(tmp(is:ie,js:je,ks:ke))
        tmp = we_lev  %d(is:ie,js:je,ks:ke); call fiona_output('r0', 'we_lev', tmp, start=start, count=count)
        if (nonhydrostatic) then
          tmp = gz_lev%d(is:ie,js:je,ks:ke); call fiona_output('r0', 'gz_lev', tmp, start=start, count=count)
          tmp = w_lev %d(is:ie,js:je,ks:ke); call fiona_output('r0', 'w_lev' , tmp, start=start, count=count)
        end if
        if (allocated(blocks(1)%adv_batches)) then
          do m = 1, size(blocks(1)%adv_batches)
            associate (adv_batch => blocks(iblk)%adv_batches(m))
            tag = adv_batch%name
            if (adv_batch%step == -1) then
              tmp = adv_batch%mz0%d(is:ie,js:je,ks:ke)
              call fiona_output('r0', trim(tag)//'_accum_mz', tmp, start=start, count=count)
            else if (adv_batch%step >= 1) then
              tmp = adv_batch%mz%d(is:ie,js:je,ks:ke)
              call fiona_output('r0', trim(tag)//'_accum_mz', tmp, start=start, count=count)
            end if
            end associate
          end do
        end if
        deallocate(tmp)
      end if
      end associate
    end do

    call fiona_end_output('r0')

    if (proc%is_root()) then
      time2 = MPI_WTIME()
      call log_notice('Done write restart cost ' // to_str(time2 - time1, 5) // ' seconds.')
    end if

  end subroutine restart_write

  subroutine restart_read()

    type(block_type), pointer :: block
    type(mesh_type), pointer :: mesh
    type(dstate_type), pointer :: dstate
    type(static_type), pointer :: static
    type(datetime_type) time
    integer iblk, is, ie, js, je, ks, ke, l, m, n
    integer start(3), count(3)
    real(r8) time_value, time1, time2
    real(r8), allocatable :: tmp(:,:,:)
    character(50) time_units, tag

    if (restart_file == 'N/A') then
      call log_error('Parameter restart_file is needed to restart!')
    end if

    if (proc%is_root()) then
      call log_notice('Read restart file ' // trim(restart_file) // '.')
      time1 = MPI_WTIME()
    end if

    call fiona_open_dataset('r0', file_path=restart_file, mpi_comm=proc%comm, ngroup=input_ngroup)
    call fiona_start_input('r0')

    call fiona_input('r0', 'time', time_value)
    call fiona_get_att('r0', 'time', 'units', time_units)
    call fiona_input('r0', 'time_step', time_step)

    call time_fast_forward(time_value, time_units)

    do iblk = 1, size(blocks)
      associate (block   => blocks(iblk)                   , &
                 mesh    => blocks(iblk)%mesh              , &
                 gzs     => blocks(iblk)%static%gzs        , &
                 mgs     => blocks(iblk)%dstate(old)%mgs   , &
                 u_lon   => blocks(iblk)%dstate(old)%u_lon , &
                 v_lat   => blocks(iblk)%dstate(old)%v_lat , &
                 w_lev   => blocks(iblk)%dstate(old)%w_lev , &
                 we_lev  => blocks(iblk)%dstate(old)%we_lev, &
                 gz      => blocks(iblk)%dstate(old)%gz    , &
                 gz_lev  => blocks(iblk)%dstate(old)%gz_lev, &
                 pt      => blocks(iblk)%dstate(old)%pt    , &
                 mfx_lon => blocks(iblk)%aux%mfx_lon       , &
                 mfy_lat => blocks(iblk)%aux%mfy_lat       , &
                 q       => tracers(iblk)%q                )
      ! ------------------------------------------------------------------------
      if (allocated(blocks(1)%adv_batches)) then
        do m = 1, size(blocks(1)%adv_batches)
          associate (adv_batch => block%adv_batches(m))
          tag = adv_batch%name
          call fiona_input('r0', trim(tag)//'_step', adv_batch%step)
          call fiona_input('r0', trim(tag)//'_last_time', time_value)
          call time_set_alert_last_time(adv_batch%name, time_value)
          end associate
        end do
      end if
      if (physics_suite /= 'N/A') then
        call fiona_input('r0', 'phys_last_time', time_value)
        call time_set_alert_last_time('phys', time_value)
      end if
      ! ------------------------------------------------------------------------
      ! Location cell
      is = mesh%full_ids; ie = mesh%full_ide
      js = mesh%full_jds; je = mesh%full_jde
      ks = mesh%full_kds; ke = mesh%full_kde
      start = [is,js,ks]
      count = [mesh%full_nlon,mesh%full_nlat,mesh%full_nlev]
      allocate(tmp(is:ie,js:je,ks:ke))
      call fiona_input('r0', 'gzs', gzs%d(is:ie,js:je), start=start, count=count)
      call fill_halo(gzs)
      if (baroclinic) then
        call fiona_input('r0', 'mgs', mgs%d(is:ie,js:je), start=start, count=count)
        call fill_halo(mgs)
        call fiona_input('r0', 'pt', tmp, start=start, count=count); pt%d(is:ie,js:je,ks:ke) = tmp
        call fill_halo(pt)
      else
        call fiona_input('r0', 'gz', tmp, start=start, count=count); gz%d(is:ie,js:je,ks:ke) = tmp
        call fill_halo(gz)
      end if
      if (allocated(blocks(1)%adv_batches)) then
        do m = 1, size(blocks(1)%adv_batches)
          associate (adv_batch => block%adv_batches(1))
          do l = 1, blocks(1)%adv_batches(m)%ntracers
            n = adv_batch%idx(l)
            call fiona_input('r0', tracer_names(n), tmp, start=start, count=count)
            q%d(is:ie,js:je,ks:ke,n) = tmp
            call fill_halo(q, n)
          end do
          call fiona_input('r0', trim(tag)//'_old_m', tmp, start=start, count=count)
          adv_batch%old_m%d(is:ie,js:je,ks:ke) = tmp
          end associate
        end do
      end if
      deallocate(tmp)
      ! ------------------------------------------------------------------------
      ! Location lon edge
      is = mesh%half_ids; ie = mesh%half_ide
      js = mesh%full_jds; je = mesh%full_jde
      ks = mesh%full_kds; ke = mesh%full_kde
      start = [is,js,ks]
      count = [mesh%half_nlon,mesh%full_nlat,mesh%full_nlev]
      allocate(tmp(is:ie,js:je,ks:ke))
      call fiona_input('r0', 'u'      , tmp, start=start, count=count); u_lon%d(is:ie,js:je,ks:ke) = tmp
      call fill_halo(u_lon)
      call fiona_input('r0', 'mfx_lon', tmp, start=start, count=count); mfx_lon%d(is:ie,js:je,ks:ke) = tmp
      call fill_halo(mfx_lon)
      if (allocated(blocks(1)%adv_batches)) then
        do m = 1, size(blocks(1)%adv_batches)
          associate (adv_batch => block%adv_batches(m))
          tag = adv_batch%name
          if (adv_batch%step == -1) then
            call fiona_input('r0', trim(tag)//'_accum_mfx', tmp, start=start, count=count)
            adv_batch%mfx0%d(is:ie,js:je,ks:ke) = tmp
            call fill_halo(adv_batch%mfx0)
            call fiona_input('r0', trim(tag)//'_accum_mx', tmp, start=start, count=count)
            adv_batch%mx0%d(is:ie,js:je,ks:ke) = tmp
            call fill_halo(adv_batch%mx0)
          else if (adv_batch%step >= 1) then
            call fiona_input('r0', trim(tag)//'_accum_mfx', tmp, start=start, count=count)
            adv_batch%mfx%d(is:ie,js:je,ks:ke) = tmp
            call fill_halo(adv_batch%mfx)
            call fiona_input('r0', trim(tag)//'_accum_mx', tmp, start=start, count=count)
            adv_batch%u%d(is:ie,js:je,ks:ke) = tmp
            call fill_halo(adv_batch%u)
          end if
          end associate
        end do
      end if
      deallocate(tmp)
      ! ------------------------------------------------------------------------
      ! Location lat edge
      is = mesh%full_ids; ie = mesh%full_ide
      js = mesh%half_jds; je = mesh%half_jde
      ks = mesh%full_kds; ke = mesh%full_kde
      start = [is,js,ks]
      count = [mesh%full_nlon,mesh%half_nlat,mesh%full_nlev]
      allocate(tmp(is:ie,js:je,ks:ke))
      call fiona_input('r0', 'v'      , tmp, start=start, count=count); v_lat%d(is:ie,js:je,ks:ke) = tmp
      call fill_halo(v_lat)
      call fiona_input('r0', 'mfy_lat', tmp, start=start, count=count); mfy_lat%d(is:ie,js:je,ks:ke) = tmp
      call fill_halo(mfy_lat)
      if (allocated(blocks(1)%adv_batches)) then
        do m = 1, size(blocks(1)%adv_batches)
          associate (adv_batch => block%adv_batches(1))
          tag = adv_batch%name
          if (adv_batch%step == -1) then
            call fiona_input('r0', trim(tag)//'_accum_mfy', adv_batch%mfy0%d(is:ie,js:je,ks:ke), start=start, count=count)
            call fill_halo(adv_batch%mfy0)
            call fiona_input('r0', trim(tag)//'_accum_my', adv_batch%my0%d(is:ie,js:je,ks:ke), start=start, count=count)
            call fill_halo(adv_batch%my0)
          else if (adv_batch%step >= 1) then
            call fiona_input('r0', trim(tag)//'_accum_mfy', adv_batch%mfy%d(is:ie,js:je,ks:ke), start=start, count=count)
            call fill_halo(adv_batch%mfy)
            call fiona_input('r0', trim(tag)//'_accum_my', adv_batch%v%d(is:ie,js:je,ks:ke), start=start, count=count)
            call fill_halo(adv_batch%v)
          end if
          end associate
        end do
      end if
      deallocate(tmp)
      ! ------------------------------------------------------------------------
      ! Location lev edge
      if (baroclinic) then
        is = mesh%full_ids; ie = mesh%full_ide
        js = mesh%full_jds; je = mesh%full_jde
        ks = mesh%half_kds; ke = mesh%half_kde
        start = [is,js,ks]
        count = [mesh%full_nlon,mesh%full_nlat,mesh%half_nlev]
        allocate(tmp(is:ie,js:je,ks:ke))
        call fiona_input('r0', 'we_lev', tmp, start=start, count=count); we_lev%d(is:ie,js:je,ks:ke) = tmp
        if (nonhydrostatic) then
          call fiona_input('r0', 'gz_lev', tmp, start=start, count=count); gz_lev%d(is:ie,js:je,ks:ke) = tmp
          call fill_halo(gz_lev)
          call fiona_input('r0', 'w_lev' , tmp, start=start, count=count); w_lev %d(is:ie,js:je,ks:ke) = tmp
          call fill_halo(w_lev)
        end if
        if (allocated(blocks(1)%adv_batches)) then
          do m = 1, size(blocks(1)%adv_batches)
            associate (adv_batch => block%adv_batches(m))
            tag = adv_batch%name
            if (adv_batch%step == -1) then
              call fiona_input('r0', trim(tag)//'_accum_mz', adv_batch%mz0%d(is:ie,js:je,ks:ke), start=start, count=count)
              call fill_halo(adv_batch%mz0)
            else if (adv_batch%step >= 1) then
              call fiona_input('r0', trim(tag)//'_accum_mz', adv_batch%mz%d(is:ie,js:je,ks:ke), start=start, count=count)
              call fill_halo(adv_batch%mz)
            end if
            end associate
          end do
        end if
        deallocate(tmp)
      end if
      end associate
    end do

    call fiona_end_input('r0')

    if (proc%is_root()) then
      time2 = MPI_WTIME()
      call log_notice('Restart to ' // trim(curr_time_str) // ' cost ' // to_str(time2 - time1, 5) // ' seconds.')
    end if

  end subroutine restart_read

end module restart_mod
