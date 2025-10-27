!---------------------------------------------------------------------
! Measure how well the network has learned the desired target strain.
! Error = deviation from target strain at target edge.
! Restores system to pre-measurement state.
!---------------------------------------------------------------------
subroutine calculate_error(numSteps)
  use mod_param
  implicit none

  integer :: i, j, k, kk
  integer :: numSteps

  !*********************************************************************
  !                        CALCULATE ERROR IN TRAINING
  !*********************************************************************

  ! Save previous state
  xcheck = positionx
  ycheck = positiony
  scheck = stress

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

  ! Compute error
  Lerror = 0.d0
  do kk = 1, nTarget
    i = Tnode(kk)
    j = Tneighbr(kk)
    Lerror = Lerror + abs(Tstrain(kk) - savestrain(i,j))
  end do

  write(400,*) time, Lerror, savestrain(Snode1,Snode2), savestrain(Tnode1,Tnode2)

  ! Restore original state
  positionx = xcheck
  positiony = ycheck
  stress = scheck

end subroutine calculate_error

