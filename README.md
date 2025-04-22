# Battery Simulation and Evaluation using Three Parameter Model (TPM) and Single Particle Model (SPM)

This repository contains MATLAB scripts and Simulink models used to simulate the performance of lithium-ion batteries using the **Three Parameter Model (TPM)** and the **Single Particle Model (SPM)**. The goal of this project is to evaluate and compare the accuracy of both models against experimental data, using identical battery parameters.

## 📌 Objective

To simulate and analyze the discharge behavior of a lithium-ion cell using:
- TPM (Three Parameter Model)
- SPM (Single Particle Model)

Both models use the same battery specifications, and simulation results are compared against real-world discharge data to assess accuracy and model fidelity.

## 🧪 Experimental Context

An experimental discharge test was conducted on a lithium-ion cell, and the measured data serves as a benchmark for validating the models implemented in this study.

## 🔧 Features

- Parameter initialization based on physical battery properties
- Spatial discretization of active material particles
- State-space formulation for diffusion dynamics in SPM
- SOC-dependent open-circuit voltage curves
- Visual comparison of electrode surface concentrations and model outputs
- Simulink integration for dynamic simulation

## 📂 Project Structure




## 📈 Output

The simulation outputs:
- Time-series of surface concentrations for both electrodes
- Voltage curves over time
- (Optional) Animated visualization of internal diffusion

## 🚀 How to Run

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/battery-simulation.git
   cd battery-simulation
2. Open MATLAB and add the folder to your path.
3. Run either:
    tpm_script.m for the Three Parameter Model
    spm_script.m for the Single Particle Model
4. View results in generated plots or within Simulink scopes.

## 🧠 Credits

Developed by Zeinab Ismail, Noah Rimatzki, Aryan Rose and Jingxuan Wang as part of an evaluative study on lithium-ion battery modeling at the University of Michigan.
