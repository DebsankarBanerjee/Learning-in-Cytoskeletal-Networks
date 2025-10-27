!===============================================================
! Apply a time-dependent sawtooth-shaped driving force on the 
! target edge, to simulate active strain control during learning.
! This subroutine updates the global variables targetForcex and
! targetForcey to be used in relaxation routines.
!
! Input:
!   t  - current time
!   et - target extension added to equilibrium length
!
! The sawtooth protocol linearly ramps up and then down.
!===============================================================

subroutine sawtooth_step(t, et)
  use mod_param
  implicit none

  integer :: i, j, kk
  real(kind=8) :: t , et, Amp, avgStrain 
  real(kind=8) :: lt, ltstar, lsign

  ! Desired length of the target spring = original equilibrium + imposed extension
  ltstar = eqLength(Tnode1, Tnode2) + et

  ! Define amplitude of sawtooth oscillation and average strain level
  Amp = lmax
  avgStrain = lmax / 2.d0

  ! Loop over target edges (typically only one in this model)
  do kk = 1, nTarget
    i = Tnode(kk)
    j = Tneighbr(kk)
    idum = neighbors(i, j)  ! get neighbor node index

    ! Compute time-dependent strain lambda using sawtooth waveform
    if (t <= tauf) then
      ! Linearly increase lambda from avgStrain - Amp/2 to avgStrain + Amp/2
      lambda = avgStrain + (Amp / tauf) * t - (Amp / 2.d0)
    endif

    if (t > tauf .and. t <= taus + tauf) then
      ! Linearly decrease lambda from avgStrain + Amp/2 to avgStrain - Amp/2
      lambda = avgStrain + (Amp / 2.d0) - Amp * ((t - tauf) / taus)
    endif

    ! Compute current length of the target spring
    lt = sqrt( (positiony(idum+1) - positiony(i))**2 + &
               (positionx(idum+1) - positionx(i))**2 )

    ! Compute components of relative vector
    delx = positionx(idum+1) - positionx(i)
    dely = positiony(idum+1) - positiony(i)

    ! Determine the sign of force to apply based on direction
    if (delx > 0.d0) then
      lsign = -1.d0
    else
      lsign = 1.d0
    endif
    ! Compute x-component of target force
    targetForcex = lambda * (delx / lt) * (lt - ltstar)

    if (dely > 0.d0) then
      lsign = -1.d0
    else
      lsign = 1.d0
    endif
    ! Compute y-component of target force
    targetForcey = lambda * (dely / lt) * (lt - ltstar)

  end do

end subroutine sawtooth_step

