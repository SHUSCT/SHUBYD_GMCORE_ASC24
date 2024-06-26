module tvd_mod

  use const_mod
  use namelist_mod
  use process_mod
  use block_mod
  use adv_batch_mod

  implicit none

  private

  public tvd_init
  public tvd

  interface
    pure real(r8) function flux_limiter_interface(r)
      import r8
      real(r8), intent(in) :: r
    end function flux_limiter_interface
  end interface

  procedure(flux_limiter_interface), pointer :: flux_limiter => null()

contains

  subroutine tvd_init()

    select case (tvd_limiter_type)
    case ('none')
      flux_limiter => flux_limiter_none
    case ('van_leer')
      flux_limiter => flux_limiter_van_leer
    case ('mc')
      flux_limiter => flux_limiter_mc
    case default
      call log_error('Invalid tvd_limiter_type ' // trim(tvd_limiter_type) // '!', pid=proc%id)
    end select

  end subroutine tvd_init

  pure real(r8) function tvd(cfl, fm1, f, fp1, fp2) result(res)

    real(r8), intent(in) :: cfl
    real(r8), intent(in) :: fm1
    real(r8), intent(in) :: f
    real(r8), intent(in) :: fp1
    real(r8), intent(in) :: fp2

    real(r8), parameter :: eps = 1.0e-6
    real(r8) r, C

    if (cfl >= 0) then
      C = flux_limiter((f   - fm1 + eps) / (fp1 - f + eps))
      res = f   + 0.5_r8 * (1 - cfl) * (fp1 - f)
    else
      C = flux_limiter((fp2 - fp1 + eps) / (fp1 - f + eps))
      res = fp1 - 0.5_r8 * (1 + cfl) * (fp1 - f)
    end if

  end function tvd

  pure real(r8) function flux_limiter_none(r) result(res)

    real(r8), intent(in) :: r

    res = 1

  end function flux_limiter_none

  pure real(r8) function flux_limiter_van_leer(r) result(res)

    real(r8), intent(in) :: r

    res = (r + abs(r)) / (1 + abs(r))

  end function flux_limiter_van_leer

  pure real(r8) function flux_limiter_mc(r) result(res)

    real(r8), intent(in) :: r

    res = max(0.0_r8, min(2.0_r8 * r, 0.5_r8 * (1 + r), 2.0_r8))

  end function flux_limiter_mc

end module tvd_mod
