module cpl_comp_mod

  use esmf

  implicit none

  private

  public cpl_comp_SetServices

contains

  subroutine cpl_comp_SetServices(comp, rc)

    type(ESMF_GridComp), intent(inout) :: comp
    integer, intent(out) :: rc

    call ESMF_GridCompSetEntryPoint(comp, ESMF_METHOD_INITIALIZE, userRoutine=cpl_comp_init, rc=rc)
    call ESMF_GridCompSetEntryPoint(comp, ESMF_METHOD_RUN, userRoutine=cpl_comp_run, rc=rc)
    call ESMF_GridCompSetEntryPoint(comp, ESMF_METHOD_FINALIZE, userRoutine=cpl_comp_final, rc=rc)

    rc = ESMF_SUCCESS

  end subroutine cpl_comp_SetServices

  subroutine cpl_comp_init(comp, importState, exportState, clock, rc)

    type(ESMF_GridComp) comp
    type(ESMF_State) importState
    type(ESMF_State) exportState
    type(ESMF_Clock) clock
    integer, intent(out) :: rc

    rc = ESMF_SUCCESS

  end subroutine cpl_comp_init

  subroutine cpl_comp_run(comp, importState, exportState, clock, rc)

    type(ESMF_GridComp) comp
    type(ESMF_State) importState
    type(ESMF_State) exportState
    type(ESMF_Clock) clock
    integer, intent(out) :: rc

    rc = ESMF_SUCCESS

  end subroutine cpl_comp_run

  subroutine cpl_comp_final(comp, importState, exportState, clock, rc)

    type(ESMF_GridComp) comp
    type(ESMF_State) importState
    type(ESMF_State) exportState
    type(ESMF_Clock) clock
    integer, intent(out) :: rc

    rc = ESMF_SUCCESS

  end subroutine cpl_comp_final

end module cpl_comp_mod
