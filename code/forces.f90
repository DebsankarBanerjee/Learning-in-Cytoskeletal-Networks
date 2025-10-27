!---------------------------------------------------------------------
! Subroutine to compute spring forces and stresses in the network
!---------------------------------------------------------------------
subroutine compute_spring_forces()
  use mod_param
  implicit none

  integer :: i, j
  !real(kind=8) :: dx, dy, dist, theta, strain, straindot

  ! Zero out total forces before accumulating
  springForcex = 0.d0
  springForcey = 0.d0
  neighbrForcex = 0.d0
  neighbrForcey = 0.d0

  ! Loop through each node and its neighbors
  do i = 1, nNodes
    do j = 1, maxNeighbr
      idum = neighbors(i, j)
      if (idum .ge. 0) then
        idum = idum + 1  ! adjust 0-based index to 1-based

        ! Displacement between nodes
        dx = positionx(idum) - positionx(i)
        dy = positiony(idum) - positiony(i)

        dist = sqrt(dx*dx + dy*dy)
        theta = atan2(dy, dx)
        strain = (dist - eqLength(i,j))
        savestrain(i,j) = strain
        savedist(i,j) = dist

        straindot = (strain - savestrain0(i,j)) / dt
        savestraindot(i,j) = straindot

        ! Stress evolution equation
        stress(i,j) = stress(i,j) + (beta1 * straindot - beta2 * stress(i,j)) * dt

        ! Spring + stress force
        neighbrForcex(j) = springConstant(i,j)*(dist - eqLength(i,j)) + zeta * stress(i,j)
        neighbrForcey(j) = springConstant(i,j)*(dist - eqLength(i,j)) + zeta * stress(i,j)

        skipflag = 0
        call get_skipflag_source(i,j)
        if (skipflag .eq. 1) cycle

        ! Resolve force along spring direction and accumulate to node
        springForcex(i) = springForcex(i) + neighbrForcex(j) * (dx/dist)
        springForcey(i) = springForcey(i) + neighbrForcey(j) * (dy/dist)
      endif
    end do
  end do

end subroutine compute_spring_forces

