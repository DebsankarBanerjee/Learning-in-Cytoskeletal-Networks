subroutine create_source_target(es, et)
  use mod_param
  implicit none

  integer :: i, j, kk
  real(kind=8) :: es, et  ! Input strains for source and target

  ! -------------------------------------------------------------------
  ! Setup source and target nodes and their strain values
  ! -------------------------------------------------------------------

  Snode(1)     = Snode1
  Sneighbr(1)  = Snode2
  Sstrain(1)   = es

  Tnode(1)     = Tnode1
  Tneighbr(1)  = Tnode2
  Tstrain(1)   = et

  ! -------------------------------------------------------------------
  ! Zero out spring constants, stress, and nlim for source and target edges
  ! This prevents learning on these specific edges
  ! -------------------------------------------------------------------
  do i = 1, nNodes
    do j = 1, maxNeighbr

      ! Source edge (forward direction)
      do kk = 1, nsource
        if (i == Snode(kk) .and. j == Sneighbr(kk)) then
          springConstant(i, j) = 0.d0
          nlim(i, j)           = 0.d0
          stress(i, j)         = 0.d0
        end if
      end do

      ! Source edge (reverse direction)
      do kk = 1, nsource
        if (i == neighbors(Snode(kk), Sneighbr(kk)) + 1 .and. &
            neighbors(i, j) + 1 == Snode(kk)) then
          springConstant(i, j) = 0.d0
          nlim(i, j)           = 0.d0
          stress(i, j)         = 0.d0
        end if
      end do

      ! Target edge (forward direction) – constant is NOT zeroed
      do kk = 1, ntarget
        if (i == Tnode(kk) .and. j == Tneighbr(kk)) then
          nlim(i, j)   = 0.d0
          stress(i, j) = 0.d0
        end if
      end do

      ! Target edge (reverse direction)
      do kk = 1, ntarget
        if (i == neighbors(Tnode(kk), Tneighbr(kk)) + 1 .and. &
            neighbors(i, j) + 1 == Tnode(kk)) then
          nlim(i, j)   = 0.d0
          stress(i, j) = 0.d0
        end if
      end do

    end do
  end do

  ! Store modified spring constants
  springConstant_old = springConstant
  springConstant0    = springConstant
end subroutine create_source_target

