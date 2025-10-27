!=================================================================================
! Subroutine: get_configuration
! Purpose: Reads the initial network configuration from input files, initializes
!          positions, neighbor lists, spring constants, and identifies boundary nodes.
!=================================================================================
subroutine get_configuration
  use mod_param
  implicit none

  integer :: i, j

  !------------------ Load node positions from file ------------------
  open(unit=101, file="../node_positions.txt", status="old", action="read")
  do i = 1, nNodes
    read(101, *) positionx(i), positiony(i)
  end do
  close(101)

  !------------------ Load neighbor indices from file ----------------
  open(unit=100, file="../node_neighbors.txt", status="old", action="read")
  do i = 1, nNodes
    read(100, *) (neighbors(i, j), j = 1, maxNeighbr)
  end do
  close(100)

  !------------------ Set spring parameters --------------------------
  do i = 1, nNodes
    do j = 1, maxNeighbr
      idum = neighbors(i, j)
      if (idum >= 0) then
        idum = idum + 1
        dist = sqrt((positionx(i) - positionx(idum))**2 + &
                    (positiony(i) - positiony(idum))**2)
        eqLength(i, j) = dist
        springConstant(i, j) = k0  ! baseline stiffness
        nlim(i, j) = 1.d0 + 9.d0 * rand()  ! randomized adaptation limit
        nelement = nelement + 1
      end if
    end do
  end do
  nelement = nelement / 2
  springConstant0 = springConstant
  springConstant_old = springConstant0

  !------------------ Read boundary nodes ----------------------------
  call execute_command_line('wc -l < ../boundary_nodes.txt > ../wc.txt')
  open(unit=900, file='../wc.txt')
  read(900, *) dum
  nboundary = int(dum)
  allocate(boundary_posx(nboundary), boundary_posy(nboundary))

  open(unit=103, file="../boundary_nodes.txt", status="old", action="read")
  do i = 1, nboundary
    read(103, *) dum, boundary_posx(i), boundary_posy(i)
  end do
  close(103)

  !------------------ Identify which nodes are on the boundary -------
  do i = 1, nNodes
    do j = 1, nboundary
      if (positionx(i) == boundary_posx(j) .and. positiony(i) == boundary_posy(j)) then
        boundary_nodes(i) = 1
      end if
    end do
  end do

  !------------------ Store initial values for comparison ------------
  x0 = positionx
  y0 = positiony
  eqLength0 = eqLength
  eqLength_old = eqLength0
  nlim0 = nlim

end subroutine get_configuration

