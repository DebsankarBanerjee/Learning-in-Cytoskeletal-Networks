# Learning-in-Cytoskeletal-Networks


---

## ⚙️ Core Program Files

### **`main_code.f90`**
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

## 🧩 Functional Modules

### **`initialize_all.f90`**
Initializes arrays, constants, node positions, spring constants, and time variables.

### **`get_configuration.f90`**
Reads network topology and geometry (nodes, neighbors, and rest lengths) from input files.

### **`create_source_target.f90`**
Specifies which edges are **source** (driven) and **target** (learned) links.

### **`apply_source.f90`**
Applies an initial static deformation or source strain before dynamic learning begins.

### **`compute_spring_forces.f90`**
Computes elastic forces on each node using current positions, rest lengths, and spring constants.  
Called by all relaxation routines.

### **`relax_with_source.f90`**
Iteratively relaxes the system with only the source strain applied (used to create a free equilibrium state).

### **`relax_with_source_target.f90`**
Performs relaxation while both source and target constraints are applied, including learning updates.

### **`calculate_error.f90`**
Computes the instantaneous and cumulative error (difference between target and achieved strain).

---

## 🔄 Learning Modules

### **`learning_update_l0.f90`**
Updates the **rest lengths (`l₀`)** of springs according to local stress feedback.  
Skips source and target edges to avoid direct modification.

### **`learning_update_k.f90`**
Updates the **spring constants (`k`)** based on product of local stress and strain.  
Implements adaptive reinforcement or weakening.

---

## ⚡ Strain Driving and Dynamics

### **`sawtooth_step.f90`**
Implements a **time-dependent sawtooth strain** on the target edge:
- During ramp-up: strain increases linearly with time (`t ≤ tauf`)
- During ramp-down: strain decreases (`tauf < t ≤ tauf + taus`)
Computes and stores target forces for both `x` and `y` components.

---

## 🧮 Energy and Diagnostics

### **`config_energy.f90`**
Computes total network elastic energy:
\[
E = \frac{1}{2} \sum k_{ij}(l_{ij} - l_{0,ij})^2
\]

### **`total_ldof.f90`**
Calculates total change in learning degrees of freedom (LDFs), both in `l₀` and `k`.

### **`get_centerofmass.f90`**
Computes center-of-mass coordinates of the network.

### **`get_max_myosin.f90`**
Finds the maximum internal stress (akin to maximum “myosin” activity) in the system.

---

## 🧩 Utility Routines

### **`get_skipflag.f90`**
Marks edges that should not be updated during learning (e.g., source or target edges).

### **`get_skipflag_source.f90`**
Simplified version of the above, checking only for source edges.

---

## 🧠 Parameter and Control Module

### **`mod_param.f90`**
Contains all global variables and parameters:
- Simulation constants (`dt`, `Niter`, etc.)
- Network arrays (`positionx`, `springConstant`, `eqLength`, etc.)
- Source and target node indices
- Learning parameters (`alpha`, `zeta`, `taus`, `tauf`, etc.)
Acts as the shared data environment for all subroutines.

---

## 🧾 Shell Script

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
- `tr_net_*.txt` — final network geometry and positions  

---

## 🧭 Next Steps

The next phase will include:
- **Data analysis scripts (Python/Matplotlib)**
- **Visualization tools** for strain, force, and learning patterns
- Optional **parameter sweep automation** for systematic studies

---

## 🧑‍🔬 Author
Developed by **Deb Sankar Banerjee**  
For research on **self-organization and physical learning in mechanical networks**.

