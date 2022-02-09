/*
//////////////////////////////////////////////////////////////////////////////
// SPDX-FileCopyrightText: 2021, Dinesh Annayya                           ////
//                                                                        ////
// Licensed under the Apache License, Version 2.0 (the "License");        ////
// you may not use this file except in compliance with the License.       ////
// You may obtain a copy of the License at                                ////
//                                                                        ////
//      http://www.apache.org/licenses/LICENSE-2.0                        ////
//                                                                        ////
// Unless required by applicable law or agreed to in writing, software    ////
// distributed under the License is distributed on an "AS IS" BASIS,      ////
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.///
// See the License for the specific language governing permissions and    ////
// limitations under the License.                                         ////
// SPDX-License-Identifier: Apache-2.0                                    ////
// SPDX-FileContributor: Dinesh Annayya <dinesha@opencores.org>           ////
//////////////////////////////////////////////////////////////////////////////
**/
/*
* @brief      bare metal tests' linker script
*/

OUTPUT_ARCH( "riscv" )
ENTRY(_start)

MEMORY {
  ROM (rxx) : ORIGIN = 0x0, LENGTH = 64K
  RAM (rwx) : ORIGIN = 0x08000000, LENGTH = 64K
  TCM (rwx) : ORIGIN = 0x0C480000, LENGTH = 2K
}

STACK_SIZE = 1024;

CL_SIZE = 32;

SECTIONS {

  /* code segment */
  .text.init 0 : { 
    FILL(0);
    . = 0x100 - 12;
    SIM_EXIT = .;
    LONG(0x13);
    SIM_STOP = .;
    LONG(0x6F);
    LONG(-1);
    . = 0x100;
    PROVIDE(__TEXT_START__ = .);
    *(.text.init) 
  } >ROM

  .text  : {
    *crt.o(.text .text.*)
    *(.text .text.*)
    *(sc_test_section)
    . = ALIGN(CL_SIZE);
     PROVIDE(__TEXT_END__ = .);
  } >ROM

  /* data segment */
  .data : {
    *(.data .data.*)
    . = ALIGN(CL_SIZE);
  } >RAM

  .sdata : {
    __global_pointer$ = . + 0x800;
    *(.srodata.cst16) *(.srodata.cst8) *(.srodata.cst4) *(.srodata.cst2) *(.srodata*)
    *(.sdata .sdata.* .gnu.linkonce.s.*)
    . = ALIGN(CL_SIZE);
  } >RAM

  /* thread-local data segment */
  .tdata : {
    PROVIDE(_tls_data = .);
    PROVIDE(_tdata_begin = .);
    *(.tdata .tdata.*)
    PROVIDE(_tdata_end = .);
    . = ALIGN(CL_SIZE);
  } >RAM

  .tbss : {
    PROVIDE(__BSS_START__ = .);
    *(.tbss .tbss.*)
    . = ALIGN(CL_SIZE);
    PROVIDE(_tbss_end = .);
  } >RAM

  /* bss segment */
  .sbss : {
    *(.sbss .sbss.* .gnu.linkonce.sb.*)
    *(.scommon)
  } >RAM

  .bss : {
    *(.bss .bss.*)
    . = ALIGN(CL_SIZE);
    PROVIDE(__BSS_END__ = .);
  } >RAM

  _end = .;
  PROVIDE(__end = .);

  /* End of uninitalized data segement */

  .stack ORIGIN(TCM) + LENGTH(TCM) - STACK_SIZE : {
    FILL(0);
    PROVIDE(__STACK_START__ = .);
    . += STACK_SIZE;
    PROVIDE(__C_STACK_TOP__ = .);
    PROVIDE(__STACK_END__ = .);
  } >TCM

  /DISCARD/ : {
    *(.eh_frame .eh_frame.*)
  }
}
