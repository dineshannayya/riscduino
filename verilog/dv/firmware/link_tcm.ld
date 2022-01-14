/**
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
*/
/*
* @brief      bare metal tests' linker script
*/

OUTPUT_ARCH( "riscv" )
ENTRY(_start)

MEMORY {
  ROM (rxx) : ORIGIN = 0x0, LENGTH = 64K
  TCM (rwx) : ORIGIN = 0x00480000, LENGTH = 4K
}

STACK_SIZE = 256;

CL_SIZE = 32;

SECTIONS {

  /* code segment */
  .text.init ORIGIN(ROM) : { 
    FILL(0);
    . = 0x100 - 12;
    SIM_EXIT = .;
    LONG(0x13);
    SIM_STOP = .;
    LONG(0x6F);
    LONG(-1);
    . = 0x100;
    *crt_tcm.o(.text .text.*)
    *(.text.init)
    . = ALIGN(CL_SIZE);
  } >ROM

  __reloc_start = .;

  .text : {
    PROVIDE(__TEXT_START__ = .);
    *(.text .text.*)
    *(sc_test_section)
    . = ALIGN(CL_SIZE);
     PROVIDE(__TEXT_END__ = .);
  } >TCM AT>ROM


  .rodata ALIGN(CL_SIZE) : {
    __global_pointer$ = . + 0x800;
    *(.rodata) *(.rodata.*) *(.gnu.linkonce.r.*)
    . = ALIGN(CL_SIZE);
    LONG(0x13);
    . = ALIGN(CL_SIZE);
  } >TCM AT>ROM


  /* data segment */
  .data ALIGN(CL_SIZE) : {
    PROVIDE(__DATA_START__ = .);
    *(.data .data.*)
    . = ALIGN(CL_SIZE);
  } >TCM 
  
  .sdata ALIGN(CL_SIZE) : {
    *(.sdata .sdata.* .gnu.linkonce.s.*)
    . = ALIGN(CL_SIZE);
    PROVIDE(__DATA_END__ = .);
  } >TCM

  /* thread-local data segment */
  .tdata ALIGN(CL_SIZE) : {
    PROVIDE(_tls_data = .);
    PROVIDE(_tdata_begin = .);
    *(.tdata .tdata.*)
    PROVIDE(_tdata_end = .);
    . = ALIGN(CL_SIZE);
  } >TCM

  .tbss ALIGN(CL_SIZE) : {
    PROVIDE(_tbss_begin = .);
    *(.tbss .tbss.*)
    . = ALIGN(CL_SIZE);
    PROVIDE(_tbss_end = .);
  } >TCM

  /* bss segment */
  .sbss ALIGN(CL_SIZE) : {
    PROVIDE(__BSS_START__ = .);
    *(.sbss .sbss.* .gnu.linkonce.sb.*)
    *(.scommon)
    . = ALIGN(CL_SIZE);
  } >TCM

  .bss ALIGN(CL_SIZE) : {
    *(.dynbss) *(.bss .bss.* .gnu.linkonce.b.*) *(COMMON)
    . = ALIGN(CL_SIZE);
    PROVIDE(__BSS_END__ = .);
  } >TCM

  _end = .;
  PROVIDE(__end = .);

  /* End of uninitalized data segement */

  .stack ORIGIN(TCM) + LENGTH(TCM) - STACK_SIZE : {
    PROVIDE(__STACK_START__ = .);
    . += STACK_SIZE;
    PROVIDE(__C_STACK_TOP__ = .);
    PROVIDE(__STACK_END__ = .);
  } >TCM

  /DISCARD/ : {
    *(.eh_frame .eh_frame.*)
  }
}
