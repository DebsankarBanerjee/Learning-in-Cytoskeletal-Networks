!===========================================================================
! Subroutine: config_energy
! Purpose   : Computes the total elastic energy of the current configuration
!             based on spring deformations from equilibrium lengths.
!===========================================================================
subroutine config_energy(posx, posy)
  use mod_param
  implicit none

  integer :: i, j, kk
  real(kind=8) :: posx(1:nNodes), posy(1:nNodes)

  ! Initialize total energy
  Etot = 0.d0

  ! Loop through each node and its neighbors
  do i = 1, nNodes
    do j = 1, maxNeighbr
      idum = neighbors(i, j)
      if (idum .ge. 0) then    ! If valid neighbor connection
        idum = idum + 1        ! Fortran 1-based index correction

        ! Compute distance between nodes
        dy = posy(idum) - posy(i)
        dx = posx(idum) - posx(i)
        dist = sqrt(dx*dx + dy*dy)

        ! Add spring energy contribution: (1/2) k (Δl)^2
        ! Factor of 0.5 to avoid double counting pairs
        Etot = Etot + 0.5d0 * 0.5d0 * springConstant(i, j) * (dist - eqLength(i, j))**2
      endif
    end do
  end do

end subroutine config_energy





!===========================================================================
! Subroutine: get_skipflag
! Purpose   : Sets 'skipflag' to 1 if the (i,j) edge is part of the source
!             or target. Used to exclude edges from learning updates.
!===========================================================================
subroutine get_skipflag(i, j)
  use mod_param
  implicit none

  integer :: i, j, kk

  ! Check if edge is in source list (forward direction)
  do kk = 1, nsource
    if (i == Snode(kk) .and. j == Sneighbr(kk)) skipflag = 1
  end do

  ! Check if edge is in source list (reverse direction)
  do kk = 1, nsource
    if (i == neighbors(Snode(kk), Sneighbr(kk)) + 1 .and. neighbors(i, j) + 1 == Snode(kk)) skipflag = 1
  end do

  ! Check if edge is in target list (forward direction)
  do kk = 1, ntarget
    if (i == Tnode(kk) .and. j == Tneighbr(kk)) skipflag = 1
  end do

  ! Check if edge is in target list (reverse direction)
  do kk = 1, ntarget
    if (i == neighbors(Tnode(kk), Tneighbr(kk)) + 1 .and. neighbors(i, j) + 1 == Tnode(kk)) skipflag = 1
  end do

end subroutine get_skipflag






!===========================================================================
! Subroutine: get_skipflag_source
! Purpose   : Same as get_skipflag, but only checks whether the edge is
!             in the source list. Used when only source needs exclusion.
!===========================================================================
subroutine get_skipflag_source(i, j)
  use mod_param
  implicit none

  integer :: i, j, kk

  ! Check if edge is in source list (forward direction)
  do kk = 1, nsource
    if (i == Snode(kk) .and. j == Sneighbr(kk)) skipflag = 1
  end do

  ! Check if edge is in source list (reverse direction)
  do kk = 1, nsource
    if (i == neighbors(Snode(kk), Sneighbr(kk)) + 1 .and. neighbors(i, j) + 1 == Snode(kk)) skipflag = 1
  end do

end subroutine get_skipflag_source





!===========================================================================
! Subroutine: total_ldof
! Purpose   : Computes the total learning DoF (LDF) changes by comparing
!             current equilibrium lengths and spring constants to their
!             initial values. Used to measure total network adaptation.
!===========================================================================
subroutine total_ldof
  use mod_param
  implicit none

  integer :: i, j, kk
  real(kind=8) :: posx(1:nNodes), posy(1:nNodes)

  totldf_l0 = 0.d0
  totldf_k = 0.d0

  ! Compute LDF for equilibrium length (L0-type learning)
  do i = 1, nNodes
    do j = 1, maxNeighbr
      idum = neighbors(i, j)
      if (idum .ge. 0) then
        idum = idum + 1
        totldf_l0 = totldf_l0 + 0.5d0 * abs(eqLength(i, j) - eqLength0(i, j))
      endif
    end do
  end do

  ! Compute LDF for spring constants (K-type learning)
  do i = 1, nNodes
    do j = 1, maxNeighbr
      idum = neighbors(i, j)
      if (idum .ge. 0) then
        idum = idum + 1
        totldf_k = totldf_k + 0.5d0 * abs(springConstant(i, j) - springConstant0(i, j))
      endif
    end do
  end do

  ! Optionally log Etot: write(600,*) time, Etot

end subroutine total_ldof




!===========================================================================
! Subroutine: get_centerofmass
! Purpose   : Computes center of mass of the entire network.
!===========================================================================
subroutine get_centerofmass
  use mod_param
  implicit none

  ! Average x and y positions over all nodes
  cmposx = sum(positionx) / nNodes
  cmposy = sum(positiony) / nNodes

end subroutine get_centerofmass




!===========================================================================
! Subroutine: get_max_myosin
! Purpose   : Calculates the maximum absolute value of stress (myosin-like
!             contractility proxy) in the network, excluding source/target.
!===========================================================================
subroutine get_max_myosin
  use mod_param
  implicit none

  integer :: i, j, kk

  ! Zero out stress for source/target edges
  do i = 1, nNodes
    do j = 1, maxNeighbr
      skipflag = 0
      call get_skipflag(i, j)
      if (skipflag == 1) stress(i, j) = 0.d0
    end do
  end do

  ! Find max absolute stress value across network
  maxmyosin = maxval(abs(stress))

end subroutine get_max_myosin

