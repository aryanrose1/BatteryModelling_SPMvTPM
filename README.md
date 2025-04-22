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

. ├── tpm_script.m # Script to run TPM-based simulation ├── spm_script.m # Script to run SPM-based simulation ├── spm_projectmod.slx # Simulink model for SPM ├── tpmsimulink0415.slx # Simulink model for TPM ├── battery_parameters.m # Initialization of all battery-related constants ├── README.md # Project documentation
