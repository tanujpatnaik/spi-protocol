# SPI Master-Slave (Verilog)

## Overview
This project implements a simple SPI (Serial Peripheral Interface) communication system using Verilog.

It includes:
- SPI Master
- SPI Slave
- 8-bit full-duplex data transfer
- Support for CPOL and CPHA modes

---

## Signals
- SCLK  : Serial Clock
- MOSI  : Master Out Slave In
- MISO  : Master In Slave Out
- SS    : Slave Select (Active Low)

---

## Working
1. Master sets SS = 0
2. Clock starts toggling
3. Data shifts bit-by-bit (8 bits)
4. Master and Slave exchange data simultaneously
5. After 8 bits, done signal becomes 1

---

## Features
- Supports all SPI modes (CPOL & CPHA)
- Full-duplex communication
- FSM-based design
- Configurable clock using clk_div

---

## Simulation
- Tool used: Vivado
- Verified signals:
  - SCLK
  - MOSI
  - MISO
  - SS
  - data_out

---

## Conclusion
This project demonstrates:
- SPI protocol implementation
- Shift register operation
- Clock edge-based data transfer
- FSM-based digital design
