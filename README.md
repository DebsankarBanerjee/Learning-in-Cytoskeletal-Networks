# Learning-in-Cytoskeletal-Networks

## Usage Instructions

### Requirements

To compile and run this code, you need:

| Dependency | Description | Tested Version |
|-------------|--------------|----------------|
| **GNU Fortran (`gfortran`)** | Fortran compiler | 10.3 or newer |
| **GNU Make** | Build automation tool | 4.2 or newer |
| **Bash shell** | For running the provided script | Default on Linux/macOS |
| *(Optional)* Python 3 + Matplotlib | For post-analysis and visualization (coming soon) | 3.10+ |

---

### Compilation

Compile the modular Fortran code using the provided Makefile in the `code/` directory:
```bash
cd code
make
```

This creates the executable:
```
result.exe
```

Clean build artifacts with:
```bash
make clean
```

---

### Running a Single Simulation

The executable requires a file `parameter.txt` specifying source–target indices and simulation parameters.

Run it manually:
```bash
cd code
./result.exe < parameter.txt
```

Simulation output files will be saved to the `../data/` directory:
- `time_error.txt` — Time evolution of learning error  
- `trained_network_k.txt` — Final spring constants
- `trained_network_l0.txt` — Final rest lengths  
- `trained_network_xy.txt` — Node positions of the trained network  

---

### Batch Simulations with the Shell Script

The `run_modular_code.sh` script automates compilation and runs multiple simulations for each source–target configuration listed in `stdata.txt`.

#### Steps:

1. Prepare `stdata.txt` in the main directory with each line listing one source–target pair:
   ```
   3 8 15 20
   2 6 9 12
   ```

2. Run the batch process:
   ```bash
   bash run_modular_code.sh
   ```

   The script will:
   - Create a `data/` directory (if missing)
   - Compile and execute the Fortran code for each line in `stdata.txt`
   - Save outputs as:
     - `data/te_<count>.txt` — time vs. error
     - `data/tr_k_<count>.txt` — trained spring constants
     - `data/tr_l0_<count>.txt` — trained rest length
     - `data/tr_net_<count>.txt` — final network configuration

3. Track progress in real time; each simulation’s duration is printed using the `time` command.

---

### Output Directory Structure

Example layout after running the full batch:
```
data/
├── te_1.txt
├── tr_k_1.txt
├── tr_net_1.txt
├── te_2.txt
├── tr_k_2.txt
└── tr_net_2.txt
```

---

### Notes

- All simulation parameters (e.g., `dt`, `alpha`, `zeta`, `taus`, `tauf`) are defined in `mod_param.f90`.  
  Modify them before compiling to change physical or learning behavior.
- Ensure the `Makefile` correctly compiles all `.f90` modules in order.
- The shell script assumes a Unix-like environment (Linux/macOS).  
  Windows users can run it via **WSL** or **Git Bash**.

---

### Example Full Workflow

```bash
# Create data directory
mkdir -p data

# Run all simulations
bash run_modular_code.sh

# View first few lines of an output file
head data/te_1.txt
```

This completes one full learning cycle for all source–target configurations defined in `stdata.txt`.

---


---

## Core Program Files

### **`main_code`**
- **Program:** `code`
- **Description:** Central driver that reads parameters, initializes the network, applies source strain, performs relaxation and learning cycles, and saves outputs.
- **Key Calls:**  
  - `initialize_all` — sets up arrays and constants  
  - `get_configuration` — reads initial node and connection data  
  - `create_source_target` — defines source and target edges  
  - `apply_source` — imposes external deformation  
  - `relax_with_source`, `relax_with_source_target` — relaxation under applied strain  
  - `calculate_error` — computes strain or energy errors  
  - `save_trained_network`, `save_error` — output functions  

---

## Functional Modules

### **`initialize_all`**
Initializes arrays, constants, node positions, spring constants, and time variables.

### **`get_configuration`**
Reads network topology and geometry (nodes, neighbors, and rest lengths) from input files.

### **`create_source_target`**
Specifies which edges are **source** (driven) and **target** (learned) links.

### **`apply_source`**
Applies an initial static deformation or source strain before dynamic learning begins.

### **`compute_spring_forces`**
Computes elastic forces on each node using current positions, rest lengths, and spring constants.  
Called by all relaxation routines.

### **`relax_with_source`**
Iteratively relaxes the system with only the source strain applied (used to create a free equilibrium state).

### **`relax_with_source_target`**
Performs relaxation while both source and target constraints are applied, including learning updates.

### **`calculate_error`**
Computes the instantaneous and cumulative error (difference between target and achieved strain).

---

## Learning Modules

### **`learning_update_l0`**
Updates the **rest lengths (`l₀`)** of springs according to local stress feedback.  
Skips source and target edges to avoid direct modification.

### **`learning_update_k`**
Updates the **spring constants (`k`)** based on product of local stress and strain.  
Implements adaptive reinforcement or weakening.

---

## Strain Driving and Dynamics

### **`sawtooth_step`**
Implements a **time-dependent sawtooth strain** on the target edge:
- During ramp-up: strain increases linearly with time (`t ≤ tauf`)
- During ramp-down: strain decreases (`tauf < t ≤ tauf + taus`)
Computes and stores target forces for both `x` and `y` components.

---

## Energy and Diagnostics

### **`config_energy`**
Computes total network elastic energy:
\[
E = \frac{1}{2} \sum k_{ij}(l_{ij} - l_{0,ij})^2
\]

### **`total_ldof`**
Calculates total change in learning degrees of freedom (LDFs), both in `l₀` and `k`.

### **`get_centerofmass`**
Computes center-of-mass coordinates of the network.

### **`get_max_myosin`**
Finds the maximum internal stress (akin to maximum “myosin” activity) in the system.

---

## Utility Routines

### **`get_skipflag`**
Marks edges that should not be updated during learning (e.g., source or target edges).

### **`get_skipflag_source`**
Simplified version of the above, checking only for source edges.

---

## Parameter and Control Module

### **`mod_param`**
Contains all global variables and parameters:
- Simulation constants (`dt`, `Niter`, etc.)
- Network arrays (`positionx`, `springConstant`, `eqLength`, etc.)
- Source and target node indices
- Learning parameters (`alpha`, `zeta`, `taus`, `tauf`, etc.)
Acts as the shared data environment for all subroutines.

---

## Shell Script

### **`run_modular_code.sh`**
Main automation script:
- Loops over all source-target pairs from `stdata.txt`
- Compiles and runs the Fortran code for each case
- Saves simulation outputs (`te_*.txt`, `tr_k_*.txt`, `tr_net_*.txt`) in the `data/` directory  
This enables batch training over multiple configurations.

---

## 🗂️ Data Files

### **`stdata.txt`**
Lists source-target node pairs for each simulation run (one per line).

### **`data/` Directory**
Contains all generated output:
- `te_*.txt` — time evolution of learning error  
- `tr_k_*.txt` — final trained spring constants
- `tr_l0_*.txt` — final trained rest length  
- `tr_net_*.txt` — final network geometry and positions  

---

## Next Steps

The next phase will include:
- **Data analysis scripts (Python/Matplotlib)**
- **Visualization tools** for strain, force, and learning patterns
- Optional **parameter sweep automation** for systematic studies

---

## 🧑‍🔬 Author
Developed by **Deb Sankar Banerjee**  
For research on **self-organization and physical learning in mechanical networks**.

