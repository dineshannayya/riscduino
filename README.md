```
  YiFive SOC


Permission to use, copy, modify, and/or distribute this soc for any
purpose with or without fee is hereby granted, provided that the above
copyright notice and this permission notice appear in all copies.

THE SOC IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
WITH REGARD TO THIS SOC INCLUDING ALL IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOC.
```

# YiFive SOC 

This is YiFive SOC Targeted for efebless Shuttle program. 
This project uses only open source tool set for simulation,synthesis and backend tools. 
The SOC flow follow the openlane methodology and SOC enviornment is compatible with efebless/carvel methodology.


## Key features

* Open sourced under SHL-license (see LICENSE file) - unrestricted commercial use allowed
* industry-grade and silicon-proven RISC-V core from syntacore 
    * Machine privilege mode only
    * 2 to 4 stage pipeline
    * Optional Integrated Programmable Interrupt Controller with 16 IRQ lines
    * Optional RISC-V Debug subsystem with JTAG interface
    * Optional on-chip Tightly-Coupled Memory
    * 32-bit AXI4/AHB-Lite external interface
* industry-graded 8 bit SDRAM controller
* Written in SystemVerilog
* Open source tool set
   * similation - verilator
   * synthesis  - yosys
   * backend/sta - openlane tool set
* Verification suite provided


## Repository contents

```
|verilog
|   ├─  rtl
|   |     |-  syntacore
|   |     |     |─  scr1
|   |     |     |    ├─ **docs**                           | **SCR1 documentation**
|   |     |     |    |      ├─ scr1_eas.pdf                | SCR1 External Architecture Specification
|   |     |     |    |      └─ scr1_um.pdf                 | SCR1 User Manual
|   |     |     |    |─  **src**                           | **SCR1 RTL source and testbench files**
|   |     |     |    |   ├─ includes                       | Header files
|   |     |     |    |   ├─ core                           | Core top source files
|   |     |     |    |   ├─ top                            | Cluster source files
|   |     |     |    |─  **synth**                         | **SCR1 RTL Synthesis files **
|   |     |- sdram_ctrl
|   |     |     |- **src**
|   |     |     |   |- **docs**                            | **SDRAM Controller Documentation**
|   |     |     |   |     |- sdram_controller_specs.pdf    | SDRAM Controller Design Specification
|   |     |     |   |             
|   |     |     |   |- core                                | SDRAM Core integration source files                          
|   |     |     |   |- defs                                | SDRAM Core defines
|   |     |     |   |- top                                 | SDRAM Top integration source files
|   |     |     |   |- wb2sdrc                             | SDRAM Wishbone source files
|   |     |- spi_master
|   |     |     |- src                                     | Qard SPI Master Source files
|   |     |-wb_interconnect
|   |     |     |- src                                     | 3x4 Wishbone Interconnect
|   |     |- digital_core
|   |     |     |- src                                     | Digital core Source files
|   |     |- lib                                           | common library source files
|   |- dv
|   |   |- la_test1                                        | carevel LA test
|   |   |- risc_boot                                       | user core risc boot test
|   |   |- wb_port                                         | user wishbone test
|   |   |- user_risc_boot                                  | user standalone test without carevel soc
|   |- gl                                                  | ** GLS Source files **
|
|- openlane
    |- sdram                                               | sdram openlane scripts   
    |- spi_master                                          | spi_master openlane scripts   
    |- syntacore                                           | Risc Core openlane scripts   
    |- yifive                                              | yifive digital core openlane scripts
    |- user_project_wrapper                                | carvel user project wrapper 

```


### Requirements

#### Environment setting

project need following environmental variable

* export CARAVEL_ROOT=<Carvel Installed Path>
* export OPENLANE_ROOT=<OpenLane Installed Path>
* export PDK_ROOT=<PDK Installed Path>
* export IMAGE_NAME=efabless/openlane:rc7


#### Project Tools

Currently supported simulators:

* Icarus Verilog version 12.0 (devel) (s20150603-1107-ga446c34d)
* Yosys 0.9+4081 (git sha1 b6721aa9, clang 10.0.0-4ubuntu1 -fPIC -Os)
* Rest of the tool are using openlane rc7 environment

Please note that RTL simulator executables should be in your $PATH variable.

#### Tests preparation

The simulation package includes the following tests:

* **risc_boot**      - Simple User Risc core boot 
* **wb_port**        - User Wishbone validation
* **user_risc_boot** - Standalone User Risc core boot


### Running Simuation

Examples:
``` sh
    make verify-wb_port  
    make verify-risc_hello
```



## Contacts

Report an issue: <https://github.com/dineshannayya/yifive_r0/issues>

