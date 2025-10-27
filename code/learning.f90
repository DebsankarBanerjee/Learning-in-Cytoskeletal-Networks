!==========================================================================
! Subroutine: learning_update_l0
! Purpose   : Updates equilibrium length (eqLength) of springs
!             using stress-based feedback if above a threshold (gcut).
!             This is a form of physical learning rule (L0 learning).
!==========================================================================
subroutine learning_update_l0
  use mod_param
  implicit none
  
  integer :: i, j, kk, l0cnt

  l0cnt = 0  ! Counter for number of updated learning DoFs

  ! Loop through all node pairs
  do i = 1, nNodes
    do j = 1, maxNeighbr

      skipflag = 0
      call get_skipflag(i, j)  ! Skip source and target edges from learning

      ! Check if stress magnitude is below threshold
      if (abs(zeta * stress(i, j)) < gcut) skipflag = 1

      if (skipflag == 1) cycle  ! Skip update if flag set

      ! Proceed if neighbor exists
      idum = neighbors(i, j)
      if (idum >= 0) then

        ! Compute update in equilibrium length proportional to stress
        deqLength = alpha * zeta * stress(i, j)
        eqLength(i, j) = eqLength(i, j) + 0.5d0 * deqLength * dt

        l0cnt = l0cnt + 1  ! Increment number of updates

      endif  ! Connection check

    end do
  end do

  ! Update global counter of learning updates
  nl0update = nl0update + l0cnt

end subroutine learning_update_l0





!==========================================================================
! Subroutine: learning_update_k
! Purpose   : Updates spring constants (springConstant) based on the 
!             product of stress and strain. Represents adaptive stiffening/
!             softening rule in the network (k-learning).
!==========================================================================
subroutine learning_update_k
  use mod_param
  implicit none

  integer :: i, j, kk

  ! Store current spring constants
  springConstant_old = springConstant

  ! Loop through all node pairs
  do i = 1, nNodes
    do j = 1, maxNeighbr

      skipflag = 0
      call get_skipflag(i, j)  ! Skip source and target edges

      ! Skip if stress × strain is below the update threshold
      if (abs(stress(i, j) * savestrain(i, j)) < gcut) skipflag = 1

      if (skipflag == 1) cycle  ! Skip update if not learning-eligible

      ! Proceed only if connection exists
      idum = neighbors(i, j)
      if (idum >= 0) then

        ! Compute update in spring constant (force × displacement rule)
        dspringConst = -alpha * stress(i, j) * savestrain(i, j)
        springConstant(i, j) = springConstant(i, j) + 0.5d0 * dspringConst * dt

        ! Optionally log the updates
        ! write(666,*) time, i, idum+1, dspringConst, stress(i,j)*savestrain(i,j), gcut

      endif  ! Connection check

    end do
  end do

end subroutine learning_update_k

