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

#ifndef __YCR__SPECIFIC
#define __YCR__SPECIFIC

#define mcounten        0x7E0

// Memory-mapped registers
#define mtime_ctrl      0x0C490000
#define mtime_div       0x0C490004
#define mtime           0x0C490008
#define mtimeh          0x0C49000C
#define mtimecmp        0x0C490010
#define mtimecmph       0x0C490014

#define YCR_MTIME_CTRL_EN          0
#define YCR_MTIME_CTRL_CLKSRC      1

#define YCR_MTIME_CTRL_WR_MASK     0x3
#define YCR_MTIME_DIV_WR_MASK      0x3FF

#endif // _YCR1__SPECIFIC
