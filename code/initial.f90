!=================================================================================
! Subroutine: initialize_all
! Purpose: Initialize all relevant arrays and variables to zero or default values.
! This is typically called at the beginning of the simulation.
!=================================================================================
subroutine initialize_all
  use mod_param
  implicit none

  ! Initialize source and target node indices
  Snode = 0; Sneighbr = 0
  Tnode = 0; Tneighbr = 0

  ! Initialize position and displacement arrays
  positionx = 0.d0; positiony = 0.d0
  x0 = 0.d0; y0 = 0.d0
  xfree = 0.d0; yfree = 0.d0
  xclamp = 0.d0; yclamp = 0.d0
  xcheck = 0.d0; ycheck = 0.d0

  ! Initialize force arrays
  springForcex = 0.d0; springForcey = 0.d0
  neighbrForcex = 0.d0; neighbrForcey = 0.d0

  ! Initialize spring-related quantities
  eqLength = 0.d0; eqLength0 = 0.d0; eqLength_old = 0.d0
  springConstant = 0.d0; springConstant0 = 0.d0; springConstant_old = 0.d0
  stress = 0.d0; scheck = 0.d0

  ! Initialize strain-related variables
  savestrain = 0.d0; savestrain0 = 0.d0; savestrain_old = 0.d0
  savedist = 0.d0; Fstrain = 0.d0; savestraindot = 0.d0

  ! Initialize learning limits
  nlim0 = 0.d0; nlim = 0.d0; ncheck = 0.d0

  ! Time variables
  time = 0.d0; tsaw = 0.d0

  ! Temporary scalar variables
  dx = 0.d0; dy = 0.d0; theta = 0.d0
  dist = 0.d0; strain = 0.d0; free_strain = 0.d0; straindot = 0.d0
  delx = 0.d0; dely = 0.d0; deqLength = 0.d0; dspringConst = 0.d0
  distclamp = 0.d0; distfree = 0.d0

  ! Error and performance tracking
  Lerror = 0.d0; lambda = 0.d0; Etot = 0.d0
  cmposx = 0.d0; cmposy = 0.d0
  totldf_l0 = 0.d0; totldf_k = 0.d0; maxmyosin = 0.d0

  ! Source and target strain values
  Sstrain = 0.d0; Tstrain = 0.d0

  ! Target force placeholders
  targetForcex = 0.d0; targetForcey = 0.d0

  ! Miscellaneous
  neighbors = 0; boundary_nodes = 0
  nboundary = 0; nelement = 0
  nk = 0
  idum = 0; dumel = 0; nl0update = 0
  skipflag = 0
  dum = 0.d0

end subroutine initialize_all

