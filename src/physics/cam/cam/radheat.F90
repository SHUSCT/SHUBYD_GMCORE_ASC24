
module radheat
!-----------------------------------------------------------------------
!
! Purpose:  Provide an interface to convert shortwave and longwave
!           radiative heating terms into net heating.
!
!           This module provides a hook to allow incorporating additional
!           radiative terms (eUV heating and nonLTE longwave cooling).
!
! Original version: B.A. Boville
!-----------------------------------------------------------------------

use shr_kind_mod,  only: r8 => shr_kind_r8
use ppgrid,        only: pcols, pver
use physics_types, only: physics_state, physics_ptend, physics_ptend_init

use physics_buffer, only : physics_buffer_desc

implicit none
private
save

! Public interfaces
public  &
   radheat_readnl,        &!
   radheat_init,          &!
   radheat_timestep_init, &!
   radheat_tend            ! return net radiative heating

public :: radheat_disable_waccm ! disable waccm heating in the upper atm

!===============================================================================
contains
!===============================================================================

subroutine radheat_readnl(nlfile)

  character(len=*), intent(in) :: nlfile  ! filepath for file containing namelist input

  ! No options for this version of radheat; this is just a stub.

end subroutine radheat_readnl

!================================================================================================

subroutine radheat_init(pref_mid)

   use pmgrid, only: plev
   use physics_buffer, only : physics_buffer_desc

   real(r8), intent(in) :: pref_mid(plev)


end subroutine radheat_init

!================================================================================================

subroutine radheat_timestep_init (state, pbuf2d)
    use physics_types,only : physics_state
    use ppgrid,       only : begchunk, endchunk
    use physics_buffer, only : physics_buffer_desc

    type(physics_state), intent(in):: state(begchunk:endchunk)
    type(physics_buffer_desc), pointer :: pbuf2d(:,:)


end subroutine radheat_timestep_init

!================================================================================================

subroutine radheat_tend(state, pbuf,  ptend, qrl, qrs, fsns, &
                        fsnt, flns, flnt, asdir, net_flx)
#if ( defined OFFLINE_DYN )
   use metdata, only: met_rlx, met_srf_feedback
#endif
!-----------------------------------------------------------------------
! Compute net radiative heating from qrs and qrl, and the associated net
! boundary flux.
!-----------------------------------------------------------------------

! Arguments
   type(physics_state), intent(in)  :: state             ! Physics state variables

   type(physics_buffer_desc), pointer :: pbuf(:)
   type(physics_ptend), intent(out) :: ptend             ! indivdual parameterization tendencie
   real(r8),            intent(in)  :: qrl(pcols,pver)   ! longwave heating
   real(r8),            intent(in)  :: qrs(pcols,pver)   ! shortwave heating
   real(r8),            intent(in)  :: fsns(pcols)       ! Surface solar absorbed flux
   real(r8),            intent(in)  :: fsnt(pcols)       ! Net column abs solar flux at model top
   real(r8),            intent(in)  :: flns(pcols)       ! Srf longwave cooling (up-down) flux
   real(r8),            intent(in)  :: flnt(pcols)       ! Net outgoing lw flux at model top
   real(r8),            intent(in)  :: asdir(pcols)      ! shortwave, direct albedo
   real(r8),            intent(out) :: net_flx(pcols)


! Local variables
   integer :: i, k
   integer :: ncol
!-----------------------------------------------------------------------

   ncol = state%ncol

   call physics_ptend_init(ptend,state%psetcols, 'radheat', ls=.true.)

#if ( defined OFFLINE_DYN )
   ptend%s(:ncol,:) = 0._r8
   do k = 1,pver
     if (met_rlx(k) < 1._r8 .or. met_srf_feedback) then
       ptend%s(:ncol,k) = (qrs(:ncol,k) + qrl(:ncol,k))
     endif
   enddo
#else
   ptend%s(:ncol,:) = (qrs(:ncol,:) + qrl(:ncol,:))
#endif

   do i = 1, ncol
      net_flx(i) = fsnt(i) - fsns(i) - flnt(i) + flns(i)
   end do

end subroutine radheat_tend

!================================================================================================
  subroutine radheat_disable_waccm()
  end subroutine radheat_disable_waccm
end module radheat
