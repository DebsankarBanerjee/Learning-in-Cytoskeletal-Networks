program code
  use mod_param
  implicit none

  ! -------------------------------------------------------------------
  ! Main Program: code
  ! Purpose: Simulates learning in a spring network under cyclic driving.
  !          Uses a sawtooth signal applied to source-target edges and
  !          updates spring parameters to match target response.
  ! -------------------------------------------------------------------

  integer :: i, j, k, k1, k2
  real(kind=8) :: dumSnode1, dumSnode2, dumTnode1, dumTnode2

  ! ================================
  ! === Read Input Parameters ======
  ! ================================

  read(*,*) dumSnode1, dumSnode2, dumTnode1, dumTnode2
  Snode1 = nint(dumSnode1)
  Snode2 = nint(dumSnode2)
  Tnode1 = nint(dumTnode1)
  Tnode2 = nint(dumTnode2)
  write(*,*) "Source:", Snode1, Snode2, "Target:", Tnode1, Tnode2

  ! ================================
  ! === Open Output Files ==========
  ! ================================

  open(unit=301, file="../data/trained_network_k.txt")     ! Final spring constants
  open(unit=303, file="../data/trained_network_xy.txt")    ! Final node positions
  open(unit=304, file="../data/trained_network_l0.txt")    ! Final rest lengths
  open(unit=400, file="../data/time_error.txt")            ! Error over learning

  ! ================================
  ! === Initialization Phase =======
  ! ================================

  call initialize_all                       ! Set all arrays and variables to initial state
  call get_configuration                    ! Load initial spring network from file
  call create_source_target(source_strain, target_strain)  ! Tag source and target springs

  ! Generate the free state under only source strain
  call apply_source(nSteps)                ! Apply source cyclically for nSteps
  call relax_with_source(5*nSteps)         ! Relax to steady state with source only

  ! Print initial strain on target spring
  write(*,*) "Initial target strain:", savestrain(Tnode1, Tnode2)

  ! ================================
  ! === Learning Phase =============
  ! ================================

  time = 0.d0
  alpha = 0.d0

  do k1 = 1, Niter    ! Main learning loop over iteration steps

    ! Gradually increase learning parameter alpha
    if (time >= 2.d0 * (tauf + taus)) alpha = 10.d0

    tsaw = 0.d0

    ! Backup previous state before this sawtooth cycle
    savestrain_old = savestrain
    eqLength_old = eqLength

    do k2 = 1, Nsawtooth     ! Loop over steps in one sawtooth cycle

      tsaw = tsaw + dt
      time = time + dt

      ! Apply sawtooth input on source spring
      call sawtooth_step(tsaw, target_strain)

      ! Relax system with source + target clamped + update spring network
      call relax_with_source_target(iterSteps)

      ! Save relaxed positions (clamped state)
      xclamp = positionx
      yclamp = positiony

      ! Uncomment to trigger diagnostics near turning points of sawtooth
      ! if (tsaw > tauf - er .and. tsaw < tauf + er .and. k1 >= 25) call check_dstrain
      ! if (tsaw > (tauf + taus) - er .and. tsaw < (tauf + taus) + er .and. k1 >= 25) call check_dl0

      ! Optional: Save per-step sawtooth response
      ! call save_sawtooth(k2)

      ! Optional: Save specific edge evolution (e.g., source or target)
      ! call save_edge(6, 9)

    end do  ! End of sawtooth loop

    ! Save learning error for this iteration
    call save_error(k1)

    ! Optional: Save full network state
    ! call save_network(k1)

  end do  ! End of learning loop

  ! ================================
  ! === Final Output ===============
  ! ================================

  call save_trained_network    ! Save final spring network (positions, k, l0)

  call total_ldof              ! Compute total change in network parameters
  write(*,*) 'Total ldf change', totldf_l0, totldf_k

end program code

