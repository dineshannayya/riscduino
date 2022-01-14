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


#ifndef RELOC_H
#define RELOC_H

#if (TCM == 1)
#define RELOC_PROC              \
    la    a0, __reloc_start;    \
    la    a1, __TEXT_START__;   \
    la    a2, __DATA_END__;     \
    beq   a0, a1, 21f;          \
    j     2f;                   \
1:  lw    a3, 0(a0);            \
    sw    a3, 0(a1);            \
    add   a0, a0, 4;            \
    add   a1, a1, 4;            \
2:  bne   a1, a2, 1b;           \
    /* clear bss */             \
    la    a2, __BSS_START__;    \
21: la    a1, __BSS_END__;      \
    j     4f;                   \
3:  sw    zero, 0(a2);          \
    add   a2, a2, 4;            \
4:  bne   a1, a2, 3b;           \
    /* init stack */            \
    la    sp, __C_STACK_TOP__;  \
    /* init hart0 TLS */        \
    la    a0, _tdata_begin;     \
    la    a2, _tbss_end;        \
    sub   a1, a2, a0;           \
    la    a4, __STACK_START__;  \
    sub   tp, a4, a1;   
#else  // #if TCM

#define RELOC_PROC

#endif  // #else #if TCM

#endif  // 
