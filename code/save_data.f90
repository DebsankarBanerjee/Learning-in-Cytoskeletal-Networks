subroutine save_network(k)
  use mod_param
  implicit none

  integer :: i, j, k

  ! Save data every `delt` iterations, offset by nk * delt
  if (float(k) / (delt + nk * delt) >= 1.d0) then
    call calculate_error(nSteps)
    call get_centerofmass

    write(fname, '(a,i4.4,a)') '../data/net_', nk, '.txt'
    open(unit=500, file=fname)

    do i = 1, nNodes
      do j = 1, maxNeighbr
        idum = neighbors(i, j)
        if (idum >= 0) then
          ! Save pairwise node data: positions, forces, strain, stress, change in rest length
          write(500, *) positionx(i), positiony(i), springForcex(i), springForcey(i), &
                        abs(savestrain(i, j)), stress(i, j), abs(eqLength(i, j) - eqLength0(i, j))
          write(500, *) positionx(idum+1), positiony(idum+1), springForcex(idum+1), springForcey(idum+1), &
                        abs(savestrain(i, j)), stress(i, j), abs(eqLength(i, j) - eqLength0(i, j))
          write(500, *) ''
        end if
      end do
    end do

    close(500)
    nk = nk + 1
  end if
end subroutine save_network





subroutine save_edge(nid1, nid2)
  use mod_param
  implicit none

  integer :: j, idxn
  integer :: nid1, nid2

  ! Find the neighbor index `j` of nid2 in nid1’s list
  do j = 1, maxNeighbr
    idum = neighbors(nid1, j)
    if (idum+1 == nid2) idxn = j
  end do

  ! Save: time, node1 pos, strain, stress, nlim, rest length diff, spring constant change, lambda
  write(403, *) time, positionx(nid1), positiony(nid1), savestrain(nid1, idxn), stress(nid1, idxn), &
                nlim(nid1, idxn), eqLength(nid1, idxn) - eqLength0(nid1, idxn), &
                springConstant(nid1, idxn) - springConstant0(nid1, idxn), lambda
end subroutine save_edge






subroutine save_sawtooth(k)
  use mod_param
  implicit none

  integer :: i, j, k, dumidx
  real*8 :: deltdum, dumr, dumrx, dumry

  deltdum = Nsawtooth / nsave

  if (float(k) / (deltdum + nk * deltdum) >= 1.d0) then
    call get_centerofmass
    call calculate_error(nSteps)

    write(fname, '(a,i4.4,a)') '../data/net_', nk, '.txt'
    open(unit=500, file=fname)

    do i = 1, nNodes
      do j = 1, maxNeighbr
        idum = neighbors(i, j)
        if (idum >= 0) then
          write(500, *) positionx(i), positiony(i), springForcex(i), springForcey(i), abs(savestrain(i, j)), &
                        stress(i, j), abs(eqLength(i, j) - eqLength0(i, j))
          write(500, *) positionx(idum+1), positiony(idum+1), springForcex(idum+1), springForcey(idum+1), &
                        abs(savestrain(i, j)), stress(i, j), abs(eqLength(i, j) - eqLength0(i, j))
          write(500, *) ''
        end if
      end do
    end do

    close(500)
    nk = nk + 1

    ! Save details of the target node pair
    dumidx = neighbors(Tnode(1), Tneighbr(1)) + 1
    dumrx = positionx(Tnode1) - positionx(dumidx)
    dumry = positiony(Tnode1) - positiony(dumidx)
    dumr = sqrt(dumrx**2 + dumry**2) - eqLength(Tnode1, Tnode2)

    write(404, *) time, positionx(Tnode1), positiony(Tnode1), targetForcex, targetForcey, &
                  springForcex(Tnode1), springForcey(Tnode1), savestrain(Tnode1, Tnode2), dumr
    write(404, *) time, positionx(dumidx), positiony(dumidx), -targetForcex, -targetForcey, &
                  springForcex(dumidx), springForcey(dumidx), savestrain(Tnode1, Tnode2), dumr
  end if
end subroutine save_sawtooth




subroutine save_error(k)
  use mod_param
  implicit none

  integer :: k

  if (float(k) / (delt + nk * delt) >= 1.d0) then
    call calculate_error(nSteps)
    nk = nk + 1
  end if
end subroutine save_error



subroutine save_trained_network
  use mod_param
  implicit none

  integer :: i, j

  ! Save learned spring constants
  do i = 1, nNodes
    do j = 1, maxNeighbr
      idum = neighbors(i, j)
      if (idum >= 0) then
        write(301, *) i, neighbors(i, j)+1, springConstant(i, j), springConstant0(i, j)
      end if
    end do
  end do

  ! Save learned rest lengths
  do i = 1, nNodes
    do j = 1, maxNeighbr
      idum = neighbors(i, j)
      if (idum >= 0) then
        write(304, *) i, neighbors(i, j)+1, eqLength(i, j), eqLength0(i, j)
      end if
    end do
  end do

  ! Save node positions
  do i = 1, nNodes
    write(303, *) positionx(i), positiony(i)
  end do
end subroutine save_trained_network

