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
/// Architecture specific CSR's defs and inlines

#ifndef YCR_CSR_H
#define YCR_CSR_H

#include <stdint.h>
#include <stdbool.h>

#define __xstringify(s) __stringify(s)
#define __stringify(s) #s

#ifdef read_csr
#undef read_csr
#endif

#ifdef write_csr
#undef write_csr
#endif

#ifdef swap_csr
#undef swap_csr
#endif

#ifdef set_csr
#undef set_csr
#endif

#ifdef clear_csr
#undef clear_csr
#endif

#ifdef rdtime
#undef rdtime
#endif

#ifdef rdcycle
#undef rdcycle
#endif

#ifdef rdinstret
#undef rdinstret
#endif

#define read_csr(reg)                                               \
    ({                                                              \
        unsigned long __tmp;                                        \
        asm volatile ("csrr %0, " __xstringify(reg) : "=r"(__tmp)); \
        __tmp;                                                      \
    })

#define write_csr(reg, val)                                             \
    do {                                                                \
        if (__builtin_constant_p(val) && (val) == 0)                    \
            asm volatile ("csrw " __xstringify(reg) ", zero" ::);       \
        else if (__builtin_constant_p(val) && (unsigned long)(val) < 32) \
            asm volatile ("csrw " __xstringify(reg) ", %0" :: "i"(val)); \
        else                                                            \
            asm volatile ("csrw " __xstringify(reg) ", %0" :: "r"(val)); \
    } while (0)

#define swap_csr(reg, val)                                              \
    ({                                                                  \
        unsigned long __tmp;                                            \
        if (__builtin_constant_p(val) && (val) == 0)                    \
            asm volatile ("csrrw %0, " __xstringify(reg) ", zero" :  "=r"(__tmp) :); \
        else if (__builtin_constant_p(val) && (unsigned long)(val) < 32) \
            asm volatile ("csrrw %0, " __xstringify(reg) ", %1" : "=r"(__tmp) : "i"(val)); \
        else                                                            \
            asm volatile ("csrrw %0, " __xstringify(reg) ", %1" : "=r"(__tmp) : "r"(val)); \
        __tmp;                                                          \
    })

#define set_csr(reg, bit)                                               \
    ({                                                                  \
        unsigned long __tmp;                                            \
        if (__builtin_constant_p(bit) && (bit) < 32)                    \
            asm volatile ("csrrs %0, " __xstringify(reg) ", %1" : "=r"(__tmp) : "i"(bit)); \
        else                                                            \
            asm volatile ("csrrs %0, " __xstringify(reg) ", %1" : "=r"(__tmp) : "r"(bit)); \
        __tmp;                                                          \
    })

#define clear_csr(reg, bit)                                             \
    ({                                                                  \
        unsigned long __tmp;                                            \
        if (__builtin_constant_p(bit) && (bit) < 32)                    \
            asm volatile ("csrrc %0, " __xstringify(reg) ", %1" : "=r"(__tmp) : "i"(bit)); \
        else                                                            \
            asm volatile ("csrrc %0, " __xstringify(reg) ", %1" : "=r"(__tmp) : "r"(bit)); \
        __tmp;                                                          \
    })

#define rdtime() read_csr(time)
#define rdcycle() read_csr(cycle)
#define rdinstret() read_csr(instret)

static inline unsigned long __attribute__((const)) cpuid()
{
  unsigned long res;
  asm ("csrr %0, mcpuid" : "=r"(res));
  return res;
}

static inline unsigned long __attribute__((const)) impid()
{
  unsigned long res;
  asm ("csrr %0, mimpid" : "=r"(res));
  return res;
}

#endif // YCR_CSR_H
