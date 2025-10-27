module mod_param
  implicit none
  save

  ! ---------------------------------------------------------------------------
  ! Module: mod_param
  ! Purpose: Contains all global parameters and variables used in the spring 
  !          network learning simulation.
  !           - Defines geometry, time integration, learning, and spring data.
  !           - Maintains both dynamic and equilibrium state variables.
  ! ---------------------------------------------------------------------------

  ! ==============================
  ! === Simulation Parameters ===
  ! ==============================

  integer, parameter :: nNodes = 108               ! Number of nodes in the spring network
  integer, parameter :: maxNeighbr = 8             ! Max number of neighbors per node

  real(kind=8), parameter :: dt = 1.d-2            ! Time step for integration
  real(kind=8), parameter :: runtime = 1000.d0     ! Total simulation time

  integer, parameter :: nSteps = int(runtime/dt)   ! Total number of simulation steps

  ! =============================
  ! === Learning Parameters ====
  ! =============================

  real(kind=8), parameter :: tauf = 20.d0          ! "On" time of sawtooth signal
  real(kind=8), parameter :: taus = 800.d0         ! "Off" time of sawtooth signal

  integer, parameter :: Nsawtooth = int((tauf + taus) / dt)  ! Period of sawtooth modulation

  integer, parameter :: Niter = 700                ! Number of learning iterations
  integer, parameter :: iterSteps = 1              ! Time steps per learning iteration

  integer, parameter :: nsave = 50                 ! Number of times data is saved
  real(kind=8), parameter :: delt = Niter / nsave  ! Interval between saves

  real(kind=8), parameter :: er = 1.d-6            ! Numerical tolerance for convergence
  real(kind=8), parameter :: gcut = 1.d-6          ! Strain cutoff for learning (hyperparameter - depends on the network parameter, ldof and driving)
  real(kind=8), parameter :: lmax = 0.5d0          ! Clamping limit

  real(kind=8), parameter :: k0 = 1.d0             ! Initial spring constant
  real(kind=8), parameter :: beta1 = 0.1d0         ! Learning rate parameter 1
  real(kind=8), parameter :: beta2 = 0.5d0         ! Learning rate parameter 2
  real(kind=8), parameter :: zeta = 0.5d0          ! Strain filtering parameter

  real(kind=8), parameter :: source_strain = 1.d0     ! Prescribed strain for source
  real(kind=8), parameter :: target_strain = -0.25d0  ! Desired strain for target

  real(kind=8) :: alpha                            ! Additional parameter for strain rule

  ! ==========================
  ! === Node Connectivity ===
  ! ==========================

  integer :: neighbors(nNodes, maxNeighbr)         ! Neighbor index list for each node
  integer :: boundary_nodes(nNodes)                ! Flags for boundary nodes
  integer :: nboundary                             ! Number of boundary nodes
  integer :: nelement                              ! Total number of springs (inferred)
  integer :: nk                                    ! Number of spring elements?

  ! ==================================
  ! === Source and Target Nodes ===
  ! ==================================

  integer, parameter :: nsource = 1, ntarget = 1   ! Number of source/target pairs

  integer :: Snode(nsource), Sneighbr(nsource)     ! Source node and neighbor index
  integer :: Tnode(ntarget), Tneighbr(ntarget)     ! Target node and neighbor index

  real(kind=8) :: Sstrain(nsource), Tstrain(ntarget) ! Current strain values

  ! =============================
  ! === Position & Geometry ====
  ! =============================

  real(kind=8) :: positionx(nNodes), positiony(nNodes)    ! Current positions
  real(kind=8) :: x0(nNodes), y0(nNodes)                  ! Initial positions

  real(kind=8) :: xfree(nNodes), yfree(nNodes)            ! Displacement with free BCs
  real(kind=8) :: xclamp(nNodes), yclamp(nNodes)          ! Displacement with clamped BCs
  real(kind=8) :: xcheck(nNodes), ycheck(nNodes)          ! Used for consistency check?

  real(kind=8), allocatable :: boundary_posx(:), boundary_posy(:)  ! Positions of boundary nodes (for plotting)

  ! ===========================
  ! === Spring Properties ====
  ! ===========================

  real(kind=8) :: eqLength(nNodes, maxNeighbr)            ! Current rest lengths
  real(kind=8) :: eqLength0(nNodes, maxNeighbr)           ! Initial rest lengths
  real(kind=8) :: eqLength_old(nNodes, maxNeighbr)        ! Previous step lengths

  real(kind=8) :: springConstant(nNodes, maxNeighbr)      ! Current spring constants
  real(kind=8) :: springConstant0(nNodes, maxNeighbr)     ! Initial spring constants
  real(kind=8) :: springConstant_old(nNodes, maxNeighbr)  ! Previous step spring constants

  ! =================================
  ! === Force and Stress Vectors ===
  ! =================================

  real(kind=8) :: springForcex(nNodes), springForcey(nNodes)  ! Net spring forces on each node
  real(kind=8) :: neighbrForcex(maxNeighbr), neighbrForcey(maxNeighbr)  ! Forces from neighbors

  real(kind=8) :: stress(nNodes, maxNeighbr)               ! Spring stress
  real(kind=8) :: scheck(nNodes, maxNeighbr)               ! For validation/checking

  ! ==========================
  ! === Learning Dynamics ===
  ! ==========================

  real(kind=8) :: savestrain(nNodes, maxNeighbr)           ! Cumulative strain
  real(kind=8) :: savestrain_old(nNodes, maxNeighbr)       ! Previous cumulative strain
  real(kind=8) :: savestrain0(nNodes, maxNeighbr)          ! Initial strain
  real(kind=8) :: savestraindot(nNodes, maxNeighbr)        ! Time derivative of strain
  real(kind=8) :: savedist(nNodes, maxNeighbr)             ! Spring distance

  real(kind=8) :: Fstrain(nNodes, maxNeighbr)              ! Filtered strain

  real(kind=8) :: nlim(nNodes, maxNeighbr), nlim0(nNodes, maxNeighbr)  ! Clamping mask
  real(kind=8) :: ncheck(nNodes, maxNeighbr)               ! Check if clamping applied

  real(kind=8) :: Lerror                                   ! Learning error (loss function)
  real(kind=8) :: lambda                                   ! Lagrange multiplier (unused?)

  ! ================================
  ! === Auxiliary Variables ========
  ! ================================

  real(kind=8) :: time, tsaw                               ! Simulation time and sawtooth time
  real(kind=8) :: dx, dy, theta                            ! Local displacements and orientation
  real(kind=8) :: dist, strain, free_strain, straindot     ! Spring values (local)
  real(kind=8) :: delx, dely, deqLength, dspringConst      ! Differences used in updates
  real(kind=8) :: distclamp, distfree                      ! Spring lengths under BCs

  real(kind=8) :: Etot                                     ! Total energy
  real(kind=8) :: cmposx, cmposy                           ! Center-of-mass positions
  real(kind=8) :: totldf_l0, totldf_k                      ! Learning cost terms?
  real(kind=8) :: maxmyosin                                ! Possibly unused?

  real(kind=8) :: targetForcex, targetForcey               ! Force applied at target (for feedback?)
  real(kind=8) :: dum                                      ! Temporary variable

  integer :: Snode1, Snode2, Tnode1, Tnode2                ! Alternate way to specify source/target edges?

  integer :: idum, dumel, nl0update                        ! Misc. counters, update flags
  integer :: skipflag                                      ! Conditional skipping flag

  character*30 :: fname                                    ! For file output

end module mod_param

