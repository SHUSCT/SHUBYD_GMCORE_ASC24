! ==============================================================================
! This file is part of GMCORE since 2019.
!
! GMCORE is a dynamical core for atmospheric model.
!
! GMCORE is distributed in the hope that it will be useful, but WITHOUT ANY
! WARRANTY. You may contact authors for helping or cooperation.
! ==============================================================================

program gmcore_driver

  use flogger
  use namelist_mod
  use const_mod
  use block_mod
  use latlon_parallel_mod
  use initial_mod
  use restart_mod
  use gmcore_mod
  use steady_state_test_mod
  use rossby_haurwitz_wave_3d_test_mod
  use mountain_wave_test_mod
  use baroclinic_wave_test_mod
  use held_suarez_test_mod
  use steady_state_pgf_test_mod
  use ksp15_test_mod
  use dcmip31_test_mod
  use mars_cold_run_mod
  use tropical_cyclone_test_mod
  use prepare_mod

  implicit none

  interface
    subroutine set_ic_interface(block)
      import block_type
      type(block_type), intent(inout), target :: block
    end subroutine set_ic_interface
  end interface
  procedure(set_ic_interface), pointer :: set_ic

  character(256) namelist_path
  integer iblk

  call get_command_argument(1, namelist_path)
  if (namelist_path == '') then
    call log_error('You should give a namelist file path!')
  end if

  call parse_namelist(namelist_path)

  call gmcore_init_stage0()

  select case (test_case)
  case ('ksp15_01', 'ksp15_02')
    call ksp15_test_set_params()
  case ('steady_state_pgf')
    call steady_state_pgf_test_set_params()
  case ('dcmip31')
    call dcmip31_test_set_params()
  end select

  call gmcore_init_stage1(namelist_path)

  if (initial_file == 'N/A' .and. test_case == 'N/A' .and. .not. restart) then
    call prepare_topo()
    if (planet == 'earth' .and. idx_qv == 0) then
      ! When reading from bkg_file, add water vapor tracer.
      call tracer_add('moist', dt_adv, 'qv', 'Water vapor', 'kg kg-1')
    end if
  end if

  call gmcore_init_stage2(namelist_path)

  if (restart) then
    call restart_read()
  else if (initial_file /= 'N/A') then
    call initial_read()
  else if (topo_file /= 'N/A' .and. bkg_file /= 'N/A') then
    call prepare_bkg()
    call prepare_final() ! Release memory for preparation.
  else
    select case (test_case)
    case ('steady_state')
      set_ic => steady_state_test_set_ic
    case ('steady_state_pgf')
      set_ic => steady_state_pgf_test_set_ic
    case ('rossby_haurwitz_wave')
      set_ic => rossby_haurwitz_wave_3d_test_set_ic
    case ('mountain_wave')
      set_ic => mountain_wave_test_set_ic
    case ('baroclinic_wave')
      set_ic => baroclinic_wave_test_set_ic
    case ('held_suarez')
      set_ic => held_suarez_test_set_ic
    case ('ksp15_01')
      set_ic => ksp15_01_test_set_ic
    case ('ksp15_02')
      set_ic => ksp15_02_test_set_ic
    case ('dcmip31')
      set_ic => dcmip31_test_set_ic
    case ('mars_cold_run')
      set_ic => mars_cold_run_set_ic
    case ('tropical_cyclone')
      set_ic => tropical_cyclone_test_set_ic
    case default
      call log_error('Unknown test case ' // trim(test_case) // '!', pid=proc%id)
    end select

    do iblk = 1, size(blocks)
      call set_ic(blocks(iblk))
    end do
  end if

  call gmcore_init_stage3()

  call gmcore_run()

  call gmcore_final()

end program gmcore_driver
