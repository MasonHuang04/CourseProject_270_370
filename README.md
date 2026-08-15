# FPGA and Processor Design Projects

This repository contains complete Vivado project directories for several FPGA designs and a five-stage RISC-V processor. The original project layouts are intentionally preserved so each design can be opened directly in Vivado.

## Projects

| Project | Vivado project file | Description |
| --- | --- | --- |
| Counter | `FPGA_Projects/Lab4/Lab4_/lab4.xpr` | Counter and seven-segment display control |
| Digital clock | `FPGA_Projects/Lab5/Lab5/digital_clock/digital_clock.xpr` | Clock division, time counting, and display control |
| Keypad scanner | `FPGA_Projects/project_6/project_6/project_6.xpr` | Matrix-keypad scanning and seven-segment display |
| Display adder | `FPGA_Projects/project_7/project_7/project_7.xpr` | Arithmetic, overflow indication, and rolling display |
| Five-stage RISC-V processor | `Processor_Project/lab4/lab4.xpr` | Final pipelined processor with forwarding and hazard handling |

## Opening a project

1. Clone or download the repository.
2. Open the corresponding `.xpr` file in Vivado.
3. Allow Vivado to update local path metadata or upgrade the project if prompted.
4. Run simulation, synthesis, implementation, or bitstream generation as needed.

The project folders are kept intact, including `.srcs`, `.runs`, `.cache`, `.sim`, reports, waveforms, and generated bitstreams. This is deliberate so the original Vivado configuration and available results remain visible.

Only the final integrated five-stage processor project is included; earlier processor project directories are omitted.
