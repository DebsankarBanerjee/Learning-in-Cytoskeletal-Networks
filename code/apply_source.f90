subroutine apply_source(numSteps)
  use mod_param
  implicit none

  integer :: i, j, k, kk, numSteps
  real(kind=8) :: Cstrain

  ! -------------------------------------------------------------------
  ! Apply the source strain gradually over `numSteps` time steps
  ! This deforms the network and sets the initial (source) configuration
  ! -------------------------------------------------------------------
  do k = 1, numSteps

    ! === Loop through each source edge ===
    do kk = 1, nsource
      i = Snode(kk)
      j = Sneighbr(kk)
      idum = neighbors(i, j)

      ! Apply incremental strain
      Cstrain = (Sstrain(kk) * eqLength(i, j)) / dfloat(numSteps)

      ! Determine orientation angle of the spring
      theta = atan2(abs(positiony(idum + 1) - positiony(i)), &
                    abs(positionx(idum + 1) - positionx(i)))

      delx = 0.5d0 * Cstrain * dcos(theta)
      dely = 0.5d0 * Cstrain * dsin(theta)

      ! Adjust node positions symmetrically to apply the strain
      if (positionx(idum + 1) > positionx(i)) then
        positionx(i)       = positionx(i) - delx
        positionx(idum + 1)= positionx(idum + 1) + delx
      else
        positionx(i)       = positionx(i) + delx
        positionx(idum + 1)= positionx(idum + 1) - delx
      end if

      if (positiony(idum + 1) > positiony(i)) then
        positiony(i)       = positiony(i) - dely
        positiony(idum + 1)= positiony(idum + 1) + dely
      else
        positiony(i)       = positiony(i) + dely
        positiony(idum + 1)= positiony(idum + 1) - dely
      end if
    end do

    ! === Recompute forces due to spring deformation ===
    springForcex = 0.d0; springForcey = 0.d0
    neighbrForcex = 0.d0; neighbrForcey = 0.d0

    do i = 1, nNodes
      do j = 1, maxNeighbr
        idum = neighbors(i, j)
        if (idum >= 0) then
          idum = idum + 1
          dy = positiony(idum) - positiony(i)
          dx = positionx(idum) - positionx(i)
          theta = atan2(dy, dx)
          dist = sqrt(dx*dx + dy*dy)

          strain = dist - eqLength(i, j)
          savestrain(i, j) = strain
          savedist(i, j)   = dist

          straindot = (strain - savestrain0(i, j)) / dt

          ! Update stress using relaxation dynamics
          stress(i, j) = stress(i, j) + (beta1 * straindot - beta2 * stress(i, j)) * dt

          ! Force magnitude = elastic + active (via stress)
          neighbrForcex(j) = springConstant(i, j) * strain + zeta * stress(i, j)
          neighbrForcey(j) = springConstant(i, j) * strain + zeta * stress(i, j)

          skipflag = 0
          call get_skipflag_source(i, j)
          if (skipflag == 1) cycle

          springForcex(i) = springForcex(i) + neighbrForcex(j) * (dx / dist)
          springForcey(i) = springForcey(i) + neighbrForcey(j) * (dy / dist)
        end if
      end do
    end do

    ! Store updated strains
    savestrain0 = savestrain

    ! === Fix source edges to prevent movement ===
    do kk = 1, nsource
      i = Snode(kk)
      j = Sneighbr(kk)
      idum = neighbors(i, j)
      springForcex(i) = 0.d0
      springForcey(i) = 0.d0
      springForcex(idum + 1) = 0.d0
      springForcey(idum + 1) = 0.d0
      stress(i, j) = 0.d0
    end do

    ! === Update positions using Euler integration ===
    do i = 1, nNodes
      positionx(i) = positionx(i) + springForcex(i) * dt
      positiony(i) = positiony(i) + springForcey(i) * dt
    end do

  end do ! End of main time loop
end subroutine apply_source

