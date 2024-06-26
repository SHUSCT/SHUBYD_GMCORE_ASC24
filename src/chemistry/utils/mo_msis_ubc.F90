

      module mo_msis_ubc
!---------------------------------------------------------------
!	... msis upper bndy values
!---------------------------------------------------------------

      use shr_kind_mod,     only: r8 => shr_kind_r8
      use constituents,     only: pcnst

      use cam_abortutils,   only: endrun
      use cam_logfile,      only: iulog
      use cam_history,      only: addfld, horiz_only, outfld

      implicit none

      private
      public  :: msis_ubc_inti, get_msis_ubc, msis_timestep_init

      save

      integer                :: ndx_n, ndx_h, ndx_o, ndx_o2           ! n, h, o, o2 spc indicies
      integer                :: msis_cnt = 0                          ! count of msis species in simulation
      integer                :: ndx(PCNST) = -1
      real(r8), allocatable  :: msis_ubc(:,:,:)                       ! module array for msis ub values (kg/kg)

      logical                :: zonal_average         = .false.       ! use zonal averaged tgcm values

      contains

      subroutine msis_ubc_inti( zonal_avg )
!------------------------------------------------------------------
!	... initialize upper boundary values
!------------------------------------------------------------------

      use ppgrid,        only : pcols, begchunk, endchunk
      use constituents,  only : cnst_get_ind, cnst_fixed_ubc
      use physics_msis,  only : tselec

      implicit none

!------------------------------------------------------------------
!	... dummy args
!------------------------------------------------------------------
      logical, intent(in) :: &
        zonal_avg            ! zonal averaging switch

!------------------------------------------------------------------
!	... local variables
!------------------------------------------------------------------
      integer  :: astat
      real(r8) :: msis_switches(25) = 1._r8

      zonal_average = zonal_avg
!------------------------------------------------------------------
!	... check for msis species in simuation
!------------------------------------------------------------------
      call cnst_get_ind( 'H', ndx_h, abort=.false. )
      if( ndx_h > 0 ) then
         if( cnst_fixed_ubc(ndx_h) ) then
            ndx(ndx_h) = ndx_h
         end if
      end if
      call cnst_get_ind( 'N', ndx_n, abort=.false. )
      if( ndx_n > 0 ) then
         if( cnst_fixed_ubc(ndx_n) ) then
            ndx(ndx_n) = ndx_n
         end if
      end if
      call cnst_get_ind( 'O', ndx_o, abort=.false. )
      if( ndx_o > 0 ) then
         if( cnst_fixed_ubc(ndx_o) ) then
            ndx(ndx_o) = ndx_o
         end if
      end if
      call cnst_get_ind( 'O2', ndx_o2, abort=.false. )
      if( ndx_o2 > 0 ) then
         if( cnst_fixed_ubc(ndx_o2) ) then
            ndx(ndx_o2) = ndx_o2
         end if
      end if

!------------------------------------------------------------------
!	... allocate msis ubc array
!------------------------------------------------------------------
      msis_cnt = count( ndx(:) /= -1 )
      allocate( msis_ubc(pcols,6,begchunk:endchunk),stat=astat )
      if( astat /= 0 ) then
         write(iulog,*) 'msis_ubc_inti: failed to allocate msis_ubc; error = ',astat
         call endrun
      end if

      if( zonal_average ) then
         msis_switches(7:8)   = 0._r8
         msis_switches(10:14) = 0._r8
      end if

!------------------------------------------------------------------
!	... initialize msis switches
!------------------------------------------------------------------
      call tselec( msis_switches )

      call addfld( 'MSIS_T', horiz_only, 'A', 'K',     'T upper boundary condition from MSIS')
      call addfld( 'MSIS_H', horiz_only, 'A', 'kg/kg', 'H upper boundary condition from MSIS')
      call addfld( 'MSIS_O', horiz_only, 'A', 'kg/kg', 'O upper boundary condition from MSIS')
      call addfld( 'MSIS_O2',horiz_only, 'A', 'kg/kg', 'O2 upper boundary condition from MSIS')

      end subroutine msis_ubc_inti

      subroutine msis_timestep_init( ap, f107p_in, f107a_in )
!--------------------------------------------------------------------
!	... get the upper boundary values for h, n, o, o2 and temp
!--------------------------------------------------------------------

      use ppgrid,       only : pcols, begchunk, endchunk
      use constituents, only : cnst_mw
      use time_manager, only : get_curr_date, get_calday, get_curr_calday
      use phys_grid,    only : get_ncols_p, get_rlon_all_p, get_rlat_all_p
      use ref_pres,     only : ptop_ref
      use spmd_utils,   only : masterproc
      use physconst,    only : pi
      use cam_control_mod,only : lambm0, eccen, mvelpp, obliqr
      use shr_orb_mod,    only : shr_orb_decl
      use physics_msis, only: ghp7

      implicit none

!--------------------------------------------------------------------
!	... dummy args
!--------------------------------------------------------------------
      real(r8), intent(in)    ::  ap
      real(r8), intent(in)    ::  f107p_in ! previous day
      real(r8), intent(in)    ::  f107a_in

!--------------------------------------------------------------------
!	... local variables
!--------------------------------------------------------------------
      real(r8), parameter :: mass_switch = 48._r8
      real(r8), parameter :: pa2mb       = 1.e-2_r8       ! pascal to mb
      real(r8), parameter :: amu_fac     = 1.65979e-24_r8 ! g/amu
      real(r8), parameter :: r2d         = 180._r8/pi
      integer  ::  i, c, ncol
      integer  ::  yr, mon, day, tod
      integer  ::  yrday
      integer  ::  date
      real(r8) ::  alt, solar_time, ut, rtod, doy
      real(r8) ::  msis_press
      real(r8) ::  msis_ap(7)
      real(r8) ::  msis_temp(2)
      real(r8) ::  msis_conc(9)
      real(r8) ::  rlons(pcols)
      real(r8) ::  rlats(pcols)
      real(r8) ::  dnom(pcols)
      real(r8) ::  pint(pcols)       ! top interface pressure (Pa)
      real(r8) ::  calday, delta, esfact
      real(r8) ::  f107p, f107a

      !--------------------------------------------------------------------
      !	... get values from msis
      !--------------------------------------------------------------------

      call get_curr_date( yr, mon, day, tod )
      tod = 0
      rtod       = tod
      ut         = rtod/3600._r8
      date       = 10000*yr + 100*mon + day
      doy        = get_calday( date, tod )
      msis_ap(:) = 0._r8
      msis_ap(1) = ap
      pint(:)    = ptop_ref

      calday = get_curr_calday()

      esfact = 1._r8
      call shr_orb_decl( calday, eccen, mvelpp, lambm0, obliqr, delta, esfact )

      f107p = esfact*f107p_in
      f107a = esfact*f107a_in

#ifdef MSIS_DIAGS
      if( masterproc ) then
         write(iulog,*) '===================================='
         write(iulog,*) 'msis_timestep_init: diagnostics'
         write(iulog,*) 'yr,mon,day,tod,date,ut,doy,esfact = ', yr, mon, day, tod, date, ut, doy, esfact
         write(iulog,*) '===================================='
      end if
#endif
      chunk_loop : do c = begchunk,endchunk
         ncol = get_ncols_p( c )
         call get_rlat_all_p( c, ncol, rlats )
         call get_rlon_all_p( c, ncol, rlons )
         rlons(:ncol) = r2d * rlons(:ncol)
         rlats(:ncol) = r2d * rlats(:ncol)
         yrday = mod( yr,100 ) * 1000 + int( doy )
         column_loop : do i = 1,ncol
            solar_time = ut + rlons(i)/15._r8
            msis_press = pint(i)*pa2mb
            call ghp7( yrday, rtod, alt, rlats(i), rlons(i), &
                 solar_time, f107a, f107p, msis_ap, msis_conc, &
                 msis_temp, msis_press )
            msis_ubc(i,1,c) = msis_temp(2)              ! temp (K)
#ifdef MSIS_DIAGS
            write(iulog,*) '===================================='
            write(iulog,*) 'msis_timestep_init: diagnostics for col,chnk = ',i,c
            write(iulog,*) 'yrday, rtod, alt,press = ',yrday,rtod,alt,msis_press
            write(iulog,*) 'msis_temp = ',msis_temp(2)
#endif
            if( msis_cnt > 0 ) then
               msis_ubc(i,2,c) = msis_conc(7)           ! h (molec/cm^3)
               msis_ubc(i,3,c) = msis_conc(8)           ! n (molec/cm^3)
               msis_ubc(i,4,c) = msis_conc(2)           ! o (molec/cm^3)
               msis_ubc(i,5,c) = msis_conc(4)           ! o2 (molec/cm^3)
               msis_ubc(i,6,c) = msis_conc(6)           ! total atm dens (g/cm^3)
            end if
#ifdef MSIS_DIAGS
            write(iulog,*) 'msis h,n,o,o2,m = ',msis_ubc(i,2:6,c)
            write(iulog,*) '===================================='
#endif
         end do column_loop
         !--------------------------------------------------------------------
         !	... transform from molecular density to mass mixing ratio
         !--------------------------------------------------------------------
         if( msis_cnt > 0 ) then
            dnom(:ncol) = amu_fac/msis_ubc(:ncol,6,c)
            if( ndx(ndx_h) > 0 ) then
               msis_ubc(:ncol,2,c) = cnst_mw(ndx_h)*msis_ubc(:ncol,2,c)*dnom(:ncol)
            end if
            if( ndx(ndx_n) > 0 ) then
               msis_ubc(:ncol,3,c) = cnst_mw(ndx_n)*msis_ubc(:ncol,3,c)*dnom(:ncol)
            end if
            if( ndx(ndx_o) > 0 ) then
               msis_ubc(:ncol,4,c) = cnst_mw(ndx_o)*msis_ubc(:ncol,4,c)*dnom(:ncol)
            end if
            if( ndx(ndx_o2) > 0 ) then
               msis_ubc(:ncol,5,c) = cnst_mw(ndx_o2)*msis_ubc(:ncol,5,c)*dnom(:ncol)
            end if
         end if
      end do chunk_loop

      end subroutine msis_timestep_init

      subroutine get_msis_ubc( lchunk, ncol, temp, mmr )
!--------------------------------------------------------------------
!	... get the upper boundary values for h, n, o, o2 and temp
!--------------------------------------------------------------------

      use ppgrid,       only : pcols

      implicit none

!--------------------------------------------------------------------
!	... dummy args
!--------------------------------------------------------------------
      integer, intent(in)     :: lchunk            ! chunk id
      integer, intent(in)     :: ncol              ! columns in chunk
      real(r8), intent(inout) :: temp(pcols)       ! msis temperature at top interface (K)
      real(r8), intent(inout) :: mmr(pcols,pcnst)  ! msis concentrations at top interface (kg/kg)

!--------------------------------------------------------------------
!	... set model ubc values from msis
!--------------------------------------------------------------------
      temp(:ncol) = msis_ubc(:ncol,1,lchunk)

      call outfld( 'MSIS_T', msis_ubc(:ncol,1,lchunk), ncol, lchunk)
      call outfld( 'MSIS_H', msis_ubc(:ncol,2,lchunk), ncol, lchunk)
      call outfld( 'MSIS_O', msis_ubc(:ncol,3,lchunk), ncol, lchunk)
      call outfld( 'MSIS_O2',msis_ubc(:ncol,4,lchunk), ncol, lchunk)

      if( msis_cnt > 0 ) then
         if( ndx(ndx_h) > 0 ) then
            mmr(:ncol,ndx_h) = msis_ubc(:ncol,2,lchunk)
         end if
         if( ndx(ndx_n) > 0 ) then
            mmr(:ncol,ndx_n) = msis_ubc(:ncol,3,lchunk)
         end if
         if( ndx(ndx_o) > 0 ) then
            mmr(:ncol,ndx_o) = msis_ubc(:ncol,4,lchunk)
         end if
         if( ndx(ndx_o2) > 0 ) then
            mmr(:ncol,ndx_o2) = msis_ubc(:ncol,5,lchunk)
         end if
      end if

      end subroutine get_msis_ubc

      end module mo_msis_ubc
