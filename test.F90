include 'mkl_vml.f90'

program main
    

    real(r8), allocatable:: a(:), b(:

    allocate(a(1:10))
    allocate(b(1:10))

    a = -1.0_r8

    call vdabs(10, a, b)

    print *, a
    print *, b
    
end program main