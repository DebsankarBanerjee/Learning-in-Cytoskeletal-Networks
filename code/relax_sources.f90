!---------------------------------------------------------------------
! Relax the spring network with fixed source strain.
! Updates positions iteratively based on spring forces.
!---------------------------------------------------------------------
subroutine relax_with_source(numSteps)
  use mod_param
  implicit none

  integer :: i, j, k, kk
  integer :: numSteps

  !*********************************************************************
  !                        GENERATE FREE STATE
  !*********************************************************************

  do k = 1, numSteps

    call compute_spring_forces

    savestrain0 = savestrain

    ! Keep source strain fixed
    do kk = 1, nSource
      i = Snode(kk)
      j = Sneighbr(kk)
      idum = neighbors(i, j)
      springForcex(i) = 0.d0
      springForcey(i) = 0.d0
      springForcex(idum+1) = 0.d0
      springForcey(idum+1) = 0.d0
    end do

    ! Update positions
    do i = 1, nNodes
      positionx(i) = positionx(i) + springForcex(i)*dt
      positiony(i) = positiony(i) + springForcey(i)*dt
    end do

  end do  ! time loop ends

end subroutine relax_with_source

