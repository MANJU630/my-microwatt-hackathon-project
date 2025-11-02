# my-microwatt-hackathon-project

This repository contains my entry for the ChipFoundry Microwatt Momentum Hackathon.

## Sensor Data Accelerator for Microwatt

### Project Overview

This project implements a hardware accelerator module designed to efficiently preprocess sensor data in real time, offloading intensive filtering and event detection tasks from the Microwatt CPU. The accelerator features a moving average digital filter, threshold-based event detection, and a fully compliant Wishbone slave bus interface for seamless integration. Programmable registers and support for hardware interrupts allow dynamic configuration and robust event notification. All RTL, testbenches, and flow scripts are open-sourced for reproducibility on the SkyWater SKY130 platform.

### Objectives

- Develop a Wishbone-compatible Verilog accelerator for use with Microwatt.
- Implement moving average filtering and programmable event detection.
- Provide configurable registers for run-time control of accelerator parameters.
- Generate hardware interrupts on sensor events for efficient CPU notification.
- Verify all functionalities through self-checking testbenches and waveform analysis.
- Achieve timing closure, synthesis, and layout for tapeout using OpenLane/SKY130.
- Document the full design flow and release all materials under an open-source license.

### Motivation

Modern embedded systems demand real-time, reliable sensor data processing without increasing main CPU workload. This project demonstrates how a dedicated accelerators enables significant CPU offloading, supports event-driven system designs, and lays a foundation for scalable, open-source hardware solutions in automotive and IoT domains.

### Planned Approach

- Study Microwatt CPU and Wishbone bus interface specifications.
- Design and model the hardware accelerator at the RTL (Verilog) level.
- Create thorough testbenches to simulate Wishbone transactions and core functionality.
- Synthesize, implement, and verify design compatibility for the SkyWater SKY130 process with OpenLane.
- Perform static timing analysis (STA) and post-layout SDF simulation.
- Prepare project documentation, AI usage logs, and reproducibility guides.
- Tapeout submission and community publication.

### Features

- Moving average filter for sensor input smoothing.
- Threshold event detection and interrupt generation.
- Programmable filter coefficients, thresholds, and scale factors.
- Complete Wishbone slave protocol implementation.
- Open-source RTL, test environments, and documentation.

### Project Status

RTL design, simulation testbenches, Wishbone interface, timing constraints, OpenLane synthesis, and documentation are completed. Tapeout submission materials and reproducibility guides are prepared. The project is open for community review and extension.

### License

This project is released under the MIT License. 


