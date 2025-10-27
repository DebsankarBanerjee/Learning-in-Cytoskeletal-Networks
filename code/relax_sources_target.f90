!---------------------------------------------------------------------
! Relax network under source strain while applying force at target edge.
! Learning rule updates eqLength or spring constants during iteration.
!---------------------------------------------------------------------
subroutine relax_with_source_target(numSteps)
  use mod_param
  implicit none

  integer :: i, j, k, kk
  integer :: numSteps

  !*********************************************************************
  !                        GENERATE CLAMPED STATE
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

    ! Add driving force to target edge
    do kk = 1, nTarget
      i = Tnode(kk)
      j = Tneighbr(kk)
      idum = neighbors(i, j)
      springForcex(i) = springForcex(i) + targetForcex
      springForcey(i) = springForcey(i) + targetForcey
      springForcex(idum+1) = springForcex(idum+1) - targetForcex
      springForcey(idum+1) = springForcey(idum+1) - targetForcey
    end do

    ! Update positions
    do i = 1, nNodes
      positionx(i) = positionx(i) + springForcex(i)*dt
      positiony(i) = positiony(i) + springForcey(i)*dt
    end do

    ! Learn
    call learning_update_l0
    ! call learning_update_k

  end do  ! time loop ends

end subroutine relax_with_source_target

