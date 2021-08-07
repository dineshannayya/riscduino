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

# Table of contents
- [Overview](#overview)
- [YiFive Block Diagram](#yifive-block-diagram)
- [Key Feature](#key-features)
- [Sub IP Feature](#sub-ip-features)
- [SOC Memory Map](#soc-memory-map)
- [Pin Mapping](#soc-pin-mapping)
- [Repository contents](#repository-contents)
- [Prerequisites](#prerequisites)
- [Tests preparation](#tests-preparation)
    - [Running Simuation](#running-simulation)
- [Tool sets](#tool-sets)
- [Documentation](#documentation)


# Overview

YiFive is a 32 bit RISC V based SOC design targeted for efabless Shuttle program.  This project uses only open source tool set for simulation,synthesis and backend tools.  The SOC flow follow the openlane methodology and SOC environment is compatible with efabless/carvel methodology.

# YiFive Block Diagram

<table>
  <tr>
    <td  align="center"><img src="./docs/source/_static/YiFive_Soc.png" ></td>
  </tr>

</table>


# Key features
```
    * Open sourced under Apache-2.0 License (see LICENSE file) - unrestricted commercial use allowed.
    * industry-grade and silicon-proven Open-Source RISC-V core from syntacore 
    * industry-graded and silicon-proven 8-bit SDRAM controller
    * Quad SPI Master
    * UART with 16Byte FIFO
    * I2C Master
    * Wishbone compatible design
    * Written in System Verilog
    * Open-source tool set
       * simulation - iverilog
       * synthesis  - yosys
       * backend/sta - openlane tool set
    * Verification suite provided.
```

# Sub IP features

## RISC V Core

YiFive SOC Integrated Syntacore SCR1 Open-source RISV-V compatible MCU-class core.
It is industry-grade and silicon-proven IP. Git link: https://github.com/syntacore/scr1

### Block Diagram
<table>
  <tr>
    <td  align="center"><img src="./docs/source/_static/syntacore_blockdiagram.svg" ></td>
  </tr>
</table>

### RISC V Core Key feature
```
   * RV32I or RV32E ISA base + optional RVM and RVC standard extensions
   * Machine privilege mode only
   * 2 to 4 stage pipeline
   * Optional Integrated Programmable Interrupt Controller with 16 IRQ lines
   * Optional RISC-V Debug subsystem with JTAG interface
   * Optional on-chip Tightly-Coupled Memory
```

### RISC V core customization YiFive SOC
  

* **Update**: Modified some of the system verilog syntax to basic verilog syntax to compile/synthesis in open source tool like simulator (iverilog) and synthesis (yosys).
* **Modification**: Modified the AXI/AHB interface to wishbone interface towards instruction & data memory interface

## 8bit SDRAM Controller
Due to number of pin limitation in carvel shuttle, YiFive SOC integrate 8bit SDRAM controller.
This is a silicon proven IP. IP Link: https://opencores.org/projects/sdr_ctrl

### Block Diagram
<table>
  <tr>
    <td  align="center"><img src="./docs/source/_static/sdram_controller.jpg" ></td>
  </tr>
</table>

### SDRAM Controller key Feature
```
    * 8/16/32 Configurable SDRAM data width
    * Wish Bone compatible
    * Application clock and SDRAM clock can be async
    * Programmable column address
    * Support for industry-standard SDRAM devices and modules
    * Supports all standard SDRAM functions.
    * Fully Synchronous; All signals registered on positive edge of system clock.
    * One chip-select signals
    * Support SDRAM with four banks
    * Programmable CAS latency
    * Data mask signals for partial write operations
    * Bank management architecture, which minimizes latency.
    * Automatic controlled refresh
```

# SOC Memory Map

<table>
  <tr>
    <td  align="center"> RISC IMEM</td> 
    <td  align="center"> RISC DMEM</td>
    <td  align="center"> EXT MAP</td>
    <td  align="center"> Target IP</td>
  </tr>
  <tr>
    <td  align="center"> 0x0000_0000 to 0x0FFF_FFFF  </td> 
    <td  align="center"> 0x0000_0000 to 0x0FFF_FFFF  </td>
    <td  align="center"> 0x4000_0000 to 0x4FFF_FFFF</td>
    <td  align="center"> SPI FLASH MEMORY</td>
  </tr>
  <tr>
    <td  align="center"> 0x1000_0000 to 0x1000_00FF</td> 
    <td  align="center"> 0x1000_0000 to 0x1000_00FF</td>
    <td  align="center"> 0x5000_0000 to 0x5000_00FF</td>
    <td  align="center"> SPI Config Reg</td>
  </tr>

  <tr>
    <td  align="center"> 0x2000_0000 to 0x2FFF_FFFF  </td> 
    <td  align="center"> 0x2000_0000 to 0x2FFF_FFFF  </td>
    <td  align="center"> 0x6000_0000 to 0x6FFF_FFFF</td>
    <td  align="center"> SDRAM</td>
  </tr>
  <tr>
    <td  align="center"> 0x3000_0000 to 0x3000_00FF</td> 
    <td  align="center"> 0x3000_0000 to 0x3000_00FF</td>
    <td  align="center"> 0x3000_0000 to 0x3000_00FF</td>
    <td  align="center"> Global Register</td>
  </tr>
</table>

# SOC Size

| Block       | Total Cell | Seq      | Combo   |
| ------      | ---------  | -------- | -----   |
| RISC        | 26642      | 3158     | 23484   |
| GLOBAL REG  | 2753       | 575      | 2178    |
| SDRAM       | 7198       | 1207     | 5991    |
| SPI         | 7607       | 1279     | 6328    |
| UART_I2C    | 3561       | 605      | 2956    |
| WB_HOST     | 3073       | 515      | 2558    |
| WB_INTC     | 1291       | 110      | 1181    |
|             |            |          |         |
| TOTAL       | 52125      | 7449     | 44676   |



# SOC Register Map
##### Register Map: Wishbone HOST

| Offset | Name       | Description   |
| ------ | ---------  | ------------- |
| 0x00   | GLBL_CTRL  | [RW] Global Wishbone Access Control Register |
| 0x04   | BANK_CTRL  | [RW] Bank Selection, MSB 8 bit Address |
| 0x08   | CLK_SKEW_CTRL1| [RW] Clock Skew Control2 |
| 0x0c   | CLK_SKEW_CTRL2 | [RW] Clock Skew Control2 |

##### Register: GLBL_CTRL

| Bits  | Name          | Description    |
| ----  | ----          | -------------- |
| 31:24 | Resevered     | Unsused |
| 23:20 | RTC_CLK_CTRL  | RTC Clock Div Selection |
| 19:16 | CPU_CLK_CTRL  | CPU Clock Div Selection |
| 15:12 | SDARM_CLK_CTRL| SDRAM Clock Div Selection |
| 10:8  | WB_CLK_CTRL   | Core Wishbone Clock Div Selection |
|   7   | UART_I2C_SEL  | 0 - UART , 1 - I2C Master IO Selection |
|   5   | I2C_RST       | I2C Reset Control |
|   4   | UART_RST      | UART Reset Control |
|   3   | SDRAM_RST     | SDRAM Reset Control |
|   2   | SPI_RST       | SPI Reset Control |
|   1   | CPU_RST       | CPU Reset Control |
|   0   | WB_RST        | Wishbone Core Reset Control |

##### Register: BANK_CTRL

| Bits  | Name          | Description    |
| ----  | ----          | -------------- |
| 31:24 | Resevered     | Unsused |
| 7:0   | BANK_SEL      | Holds the upper 8 bit address core Wishbone Address |

##### Register: CLK_SKEW_CTRL1

| Bits  | Name          | Description    |
| ----  | ----          | -------------- |
| 31:28 | Resevered     | Unsused |
| 27:24 | CLK_SKEW_WB   | WishBone Core Clk Skew Control |
| 23:20 | CLK_SKEW_GLBL | Glbal Register Clk Skew Control |
| 19:16 | CLK_SKEW_SDRAM| SDRAM Clk Skew Control |
| 15:12 | CLK_SKEW_SPI  | SPI Clk Skew Control |
| 11:8  | CLK_SKEW_UART | UART/I2C Clk Skew Control |
| 7:4   | CLK_SKEW_RISC | RISC Clk Skew Control |
| 3:0   | CLK_SKEW_WI   | Wishbone Clk Skew Control |

##### Register Map: SPI MASTER

| Offset | Name       | Description   |
| ------ | ---------  | ------------- |
| 0x00   | GLBL_CTRL  | [RW] Global SPI Access Control Register |
| 0x04   | DMEM_CTRL1 | [RW] Direct SPI Memory Access Control Register1 |
| 0x08   | DMEM_CTRL2 | [RW] Direct SPI Memory Access Control Register2 |
| 0x0c   | IMEM_CTRL1 | [RW] Indirect SPI Memory Access Control Register1 |
| 0x10   | IMEM_CTRL2 | [RW] Indirect SPI Memory Access Control Register2 |
| 0x14   | IMEM_ADDR  | [RW] Indirect SPI Memory Address  |
| 0x18   | IMEM_WDATA | [W]  Indirect SPI Memory Write Data |
| 0x1c   | IMEM_RDATA | [R]  Indirect SPI Memory Read Data |
| 0x20   | SPI_STATUS | [R] SPI Debug Status |

##### Register: GLBL_CTRL

| Bits  | Name        | Description    |
| ----  | ----        | -------------- |
| 31:16 | Resevered   | Unsused |
| 15:8  | SPI_CLK_DIV | SPI Clock Div Rato Selection |
| 7:4   | Reserved    | Unused |
| 3:2   | CS_LATE     | CS DE_ASSERTION CONTROL |
| 1:0   | CS_EARLY    | CS ASSERTION CONTROL |

##### Register: DMEM_CTRL1

| Bits | Name       | Description    |
| ---- | ----       | -------------- |
| 31:9 | Resevered  | Unsused        |
| 8    | FSM_RST    | Direct Mem State Machine Reset |
| 7:6  | SPI_SWITCH | Phase at which SPI Mode need to switch |
| 5:4  | SPI_MODE   | SPI Mode, 0 - Single, 1 - Dual, 2 - Quad, 3 - QDDR |
| 3:0  | CS_SELECT  | CHIP SELECT |

##### Register: DMEM_CTRL2

| Bits | Name       | Description    |
| ---- | ----       | -------------- |
| 31:24 | DATA_CNT  | Total Data Byte Count        |
| 23:22 | DUMMY_CNT | Total Dummy Byte Count |
| 21:20 | ADDR_CNT  | Total Address Byte Count |
| 19:16 | SPI_SEQ   | SPI Access Sequence |
| 15:8  | MODE_REG  | Mode Register Value |
| 7:0   | CMD_REG   | Command Register Value |

##### Register: IMEM_CTRL1

| Bits | Name       | Description    |
| ---- | ----       | -------------- |
| 31:9 | Resevered  | Unsused        |
| 8    | FSM_RST    | InDirect Mem State Machine Reset |
| 7:6  | SPI_SWITCH | Phase at which SPI Mode need to switch |
| 5:4  | SPI_MODE   | SPI Mode, 0 - Single, 1 - Dual, 2 - Quad, 3 - QDDR |
| 3:0  | CS_SELECT  | CHIP SELECT |

##### Register: IMEM_CTRL2

| Bits | Name       | Description    |
| ---- | ----       | -------------- |
| 31:24 | DATA_CNT  | Total Data Byte Count        |
| 23:22 | DUMMY_CNT | Total Dummy Byte Count |
| 21:20 | ADDR_CNT  | Total Address Byte Count |
| 19:16 | SPI_SEQ   | SPI Access Sequence |
| 15:8  | MODE_REG  | Mode Register Value |
| 7:0   | CMD_REG   | Command Register Value |

##### Register: IMEM_ADDR

| Bits | Name       | Description    |
| ---- | ----       | -------------- |
| 31:0 | ADDR       | Indirect Memory Address  |

##### Register: IMEM_WDATA

| Bits | Name       | Description    |
| ---- | ----       | -------------- |
| 31:0 | WDATA      | Indirect Memory Write Data  |

##### Register: IMEM_RDATA

| Bits | Name       | Description    |
| ---- | ----       | -------------- |
| 31:0 | RDATA      | Indirect Memory Read Data  |

##### Register: SPI_STATUS

| Bits | Name       | Description    |
| ---- | ----       | -------------- |
| 31:0 | DEBUG      | SPI Debug Status  |


##### Register Map: Global Register

| Offset | Name        | Description   |
| ------ | ---------   | ------------- |
| 0x00   | SOFT_REG0   | [RW] Software Register0 |
| 0x04   | RISC_FUSE   | [RW] Risc Fuse Value  |
| 0x08   | SOFT_REG2   | [RW] Software Register2 |
| 0x0c   | INTR_CTRL   | [RW] Interrupt Control |
| 0x10   | SDRAM_CTRL1 | [RW] Indirect SPI Memory Access Control Register2 |
| 0x14   | SDRAM_CTRL2 | [RW] Indirect SPI Memory Address  |
| 0x18   | SOFT_REG6   | [RW] Software Register6 |
| 0x1C   | SOFT_REG7   | [RW] Software Register7 |
| 0x20   | SOFT_REG8   | [RW] Software Register8 |
| 0x24   | SOFT_REG9   | [RW] Software Register9 |
| 0x28   | SOFT_REG10  | [RW] Software Register10 |
| 0x2C   | SOFT_REG11  | [RW] Software Register11 |
| 0x30   | SOFT_REG12  | [RW] Software Register12 |
| 0x34   | SOFT_REG13  | [RW] Software Register13 |
| 0x38   | SOFT_REG14  | [RW] Software Register14 |
| 0x3C   | SOFT_REG15  | [RW] Software Register15 |

##### Register: RISC_FUSE

| Bits  | Name        | Description    |
| ----  | ----        | -------------- |
| 31:0  | RISC_FUSE   | RISC Core Fuse Value |

##### Register: INTR_CTRL

| Bits  | Name        | Description    |
| ----  | ----        | -------------- |
| 31:20 | Reserved    | Unused         |
| 19:17 | USER_IRQ    | User Interrupt generation toward riscv         |
| 16    | SOFT_IRQ    | Software Interrupt generation toward riscv     |
| 15:0  | EXT_IRQ     | External Interrupt generation toward riscv     |

##### Register: SDRAM_CTRL1

| Bits  | Name        | Description    |
| ----  | ----        | -------------- |
| 31   | Reserved    | Unused         |
| 30   | SDRAM_INIT_DONE    | SDRAM init done indication         |
| 29   | SDR_EN    | SDRAM controller enable     |
| 28:26| SDR_CAS   | SDRAM CAS latency     |
| 25:24| SDR_REQ_DP| SDRAM Maximum Request accepted by SDRAM controller     |
| 23:20| SDR_TWR   | SDRAM Write Recovery delay    |
| 19:16| SDR_TRCAR | SDRAM Auto Refresh Period     |
| 15:12| SDR_TRCD  | SDRAM Active ti R/W delay     |
| 11:8 | SDR_TRP   | SDRAM Prechard to active delay     |
| 7:4  | SDR_TRAS  | SDRAM Active to precharge     |
| 3:2  | SDR_COL   | SDRAM Colum Address     |
| 1:0  | SDR_WD    | SDRAM Interface Width, 0 - 32bit, 1 - 16 bit, 2 - 8 bit     |

##### Register: SDRAM_CTRL2

| Bits  | Name        | Description    |
| ----  | ----        | -------------- |
| 31:28 | Reserved    | Unused         |
| 27:16 | SDRAM_REFRESH | SDRAM Refresh Rate per row  |
| 15:3  | SDR_MODE_REG  | SDRAM Mode Register     |
| 2:0   | SDR_MODE_REG  | Number of rows to rfsh at a time     |

# SOC Pin Mapping
Carvel SOC provides 38 GPIO pins for user functionality. YiFive SOC GPIO Pin Mapping as follows

<table>
  <tr>
    <td  align="center"> GPIO Pin Number</td> 
    <td  align="center"> Direction</td>
    <td  align="center"> Pad Name</td>
    <td  align="center"> Block Name</td>
  </tr>
  <tr>
    <td  align="center"> gpio[7:0]</td> 
    <td  align="center"> Inout</td>
    <td  align="center"> SDRAM Data [7:0]</td>
    <td  align="center"> SDRAM</td>
  </tr>
  <tr>
    <td  align="center"> gpio[20:8]</td> 
    <td  align="center"> Output</td>
    <td  align="center"> SDRAM Address [12:0]</td>
    <td  align="center"> SDRAM</td>
  </tr>
  <tr>
    <td  align="center"> gpio[22:21]</td> 
    <td  align="center"> Output</td>
    <td  align="center"> SDRAM Bank Select [1:0]</td>
    <td  align="center"> SDRAM</td>
  </tr>
  <tr>
    <td  align="center"> gpio[23]</td> 
    <td  align="center"> Output</td>
    <td  align="center"> SDRAM Byte Mask</td>
    <td  align="center"> SDRAM</td>
  </tr>
  <tr>
    <td  align="center"> gpio[24]</td> 
    <td  align="center"> Output</td>
    <td  align="center"> SDRAM Write Enable</td>
    <td  align="center"> SDRAM</td>
  </tr>
  <tr>
    <td  align="center"> gpio[25]</td> 
    <td  align="center"> Output</td>
    <td  align="center"> SDRAM CAS </td>
    <td  align="center"> SDRAM</td>
  </tr>
  <tr>
    <td  align="center"> gpio[26]</td> 
    <td  align="center"> Output</td>
    <td  align="center"> SDRAM RAS </td>
    <td  align="center"> SDRAM</td>
  </tr>
  <tr>
    <td  align="center"> gpio[27]</td> 
    <td  align="center"> Output</td>
    <td  align="center"> SDRAM Chip Select </td>
    <td  align="center"> SDRAM</td>
  </tr>
  <tr>
    <td  align="center"> gpio[28]</td> 
    <td  align="center"> Output</td>
    <td  align="center"> SDRAM CKE </td>
    <td  align="center"> SDRAM</td>
  </tr>
  <tr>
    <td  align="center"> gpio[29]</td> 
    <td  align="center"> Inout</td>
    <td  align="center"> SDRAM Clock</td>
    <td  align="center"> SDRAM</td>
  </tr>
  <tr>
    <td  align="center"> gpio[30]</td> 
    <td  align="center"> Output</td>
    <td  align="center"> SPI Clock</td>
    <td  align="center"> SPI</td>
  </tr>
  <tr>
    <td  align="center"> gpio[31]</td> 
    <td  align="center"> Output</td>
    <td  align="center"> SPI Chip Select</td>
    <td  align="center"> SPI</td>
  </tr>
  <tr>
    <td  align="center"> gpio[35:32]</td> 
    <td  align="center"> Inout</td>
    <td  align="center"> SPI Data</td>
    <td  align="center"> SPI</td>
  </tr>
  <tr>
    <td  align="center"> gpio[36]</td> 
    <td  align="center"> Inout</td>
    <td  align="center"> Uart TX/I2C CLK</td>
    <td  align="center"> UART/I2C</td>
  </tr>
  <tr>
    <td  align="center"> gpio[37]</td> 
    <td  align="center"> Inout</td>
    <td  align="center"> Uart RX/I2C Data</td>
    <td  align="center"> UART/I2C</td>
  </tr>
</table>


# Repository contents

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


# Prerequisites
   - Docker (ensure docker daemon is running) -- tested with version 19.03.12, but any recent version should suffice.

## Environment setting

```bash
    export CARAVEL_ROOT=<Carvel Installed Path>
    export OPENLANE_ROOT=<OpenLane Installed Path>
    export PDK_ROOT=<PDK Installed Path>
    export IMAGE_NAME=dineshannayya/openlane:rc7
```

# Tests preparation

The simulation package includes the following tests:

* **risc_boot**      - Simple User Risc core boot 
* **wb_port**        - User Wishbone validation
* **user_risc_boot** - Standalone User Risc core boot


# Running Simulation

Examples:
``` sh
    make verify-wb_port  
    make verify-risc_boot
    make verify-user_uart
    make verify-user_spi
    make verify-user_i2cm
    make verify-user_risc_boot
```

# Tool Sets

YiFive Soc flow uses Openlane tool sets.

1. **Synthesis**
    1. `yosys` - Performs RTL synthesis
    2. `abc` - Performs technology mapping
    3. `OpenSTA` - Pefroms static timing analysis on the resulting netlist to generate timing reports
2. **Floorplan and PDN**
    1. `init_fp` - Defines the core area for the macro as well as the rows (used for placement) and the tracks (used for routing)
    2. `ioplacer` - Places the macro input and output ports
    3. `pdn` - Generates the power distribution network
    4. `tapcell` - Inserts welltap and decap cells in the floorplan
3. **Placement**
    1. `RePLace` - Performs global placement
    2. `Resizer` - Performs optional optimizations on the design
    3. `OpenPhySyn` - Performs timing optimizations on the design
    4. `OpenDP` - Perfroms detailed placement to legalize the globally placed components
4. **CTS**
    1. `TritonCTS` - Synthesizes the clock distribution network (the clock tree)
5. **Routing**
    1. `FastRoute` - Performs global routing to generate a guide file for the detailed router
    2. `CU-GR` - Another option for performing global routing.
    3. `TritonRoute` - Performs detailed routing
    4. `SPEF-Extractor` - Performs SPEF extraction
6. **GDSII Generation**
    1. `Magic` - Streams out the final GDSII layout file from the routed def
    2. `Klayout` - Streams out the final GDSII layout file from the routed def as a back-up
7. **Checks**
    1. `Magic` - Performs DRC Checks & Antenna Checks
    2. `Klayout` - Performs DRC Checks
    3. `Netgen` - Performs LVS Checks
    4. `CVC` - Performs Circuit Validity Checks


## **important Note**

Following tools in openlane docker is older version, we need to update these tool set.
* Icarus Verilog version 12.0 (devel) (s20150603-1107-ga446c34d)
* Yosys 0.9+4081 (git sha1 b6721aa9, clang 10.0.0-4ubuntu1 -fPIC -Os)

We have modified these openlane changes in our git repo, you can use from these path
     git clone https://github.com/dineshannayya/openlane.git
    docker pull dineshannayya/openlane:rc7



## Contacts

Report an issue: <https://github.com/dineshannayya/yifive_r0/issues>

# Documentation
* **Syntacore Link** - https://github.com/syntacore/scr1
* **SDRAM Controller** - https://opencores.org/projects/sdr_ctrl




