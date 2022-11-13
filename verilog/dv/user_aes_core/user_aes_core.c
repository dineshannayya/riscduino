//////////////////////////////////////////////////////////////////////////////
// SPDX-FileCopyrightText: 2021, Dinesh Annayya
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// SPDX-License-Identifier: Apache-2.0
// SPDX-FileContributor: Dinesh Annayya <dinesha@opencores.org>
// //////////////////////////////////////////////////////////////////////////
#define SC_SIM_OUTPORT (0xf0000000)


#include <stdio.h>
#include <string.h>
#include <stdint.h>

// Enable ECB, CTR and CBC mode. Note this can be done before including aes.h or at compile-time.
// E.g. with GCC by using the -D flag: gcc -c aes.c -DCBC=0 -DCTR=1 -DECB=1
#define CBC 1
#define AES_BLOCKLEN 16

//#include "aes.h"
#include "int_reg_map.h"
#include "common_misc.h"
#include "common_bthread.h"

static const uint8_t key[]      = { 0x44, 0x69, 0x6e, 0x65, 0x73, 0x68, 0x20, 0x20, 0x20, 0x41, 0x6e, 0x6e, 0x61, 0x79, 0x79, 0x61 };
static const uint8_t enc_text[] = { 0xFE, 0x67, 0x23, 0x29, 0xDE, 0x2C, 0x41, 0xCE, 0x75, 0x79, 0x28, 0x12, 0xA0, 0x35, 0x66, 0xD0, 
                                    0xC4, 0xBB, 0x67, 0x66, 0xAC, 0x09, 0x5B, 0xF7, 0xA9, 0xAF, 0x5D, 0x1C, 0xEC, 0xCE, 0x44, 0x54, 
                                    0x44, 0x84, 0xCF, 0xBB, 0x0A, 0x37, 0x7A, 0xC4, 0x41, 0x3F, 0xD1, 0x86, 0x28, 0xBC, 0x18, 0x0C, 
                                    0x8D, 0x08, 0xB4, 0xAB, 0x58, 0x88, 0xC0, 0xBF, 0x3D, 0xBC, 0xDD, 0x15, 0xB2, 0x31, 0x98, 0x66, 
                                    0x00, 0xA9, 0x40, 0x2C, 0x88, 0x4C, 0xD4, 0x85, 0x1A, 0xF8, 0xD8, 0xB3, 0x42, 0xE4, 0xF3, 0x3D, 
                                    0xBC, 0xB2, 0x2A, 0x5A, 0x6A, 0x24, 0x93, 0x24, 0xAC, 0xC1, 0x05, 0xE7, 0xAE, 0x75, 0xD1, 0xB2, 
                                    0x90, 0x9A, 0xE8, 0xE5, 0xEF, 0x57, 0x24, 0x08, 0x74, 0xDA, 0x98, 0x85, 0x56, 0xF0, 0x38, 0xFB, 
                                    0xF2, 0x04, 0xD1, 0xE9, 0x77, 0x2B, 0x9F, 0x62, 0x37, 0x0B, 0x08, 0x0F, 0x40, 0xC1, 0x70, 0xC1, 
                                    0x11, 0x76, 0xC1, 0x61, 0xAF, 0x65, 0x57, 0x81, 0x31, 0x0C, 0xE9, 0x02, 0x9B, 0x75, 0x0F, 0x12 };

static const uint8_t plain_text[]= { 0x52, 0x69, 0x73, 0x63, 0x64, 0x75, 0x69, 0x6e, 0x6f, 0x20, 0x69, 0x73, 0x20, 0x61, 0x20, 0x53, 
                                    0x69, 0x6e, 0x67, 0x6c, 0x65, 0x20, 0x33, 0x32, 0x20, 0x62, 0x69, 0x74, 0x20, 0x52, 0x49, 0x53, 
                                    0x43, 0x20, 0x56, 0x20, 0x62, 0x61, 0x73, 0x65, 0x64, 0x20, 0x53, 0x4f, 0x43, 0x20, 0x64, 0x65, 
                                    0x73, 0x69, 0x67, 0x6e, 0x20, 0x70, 0x69, 0x6e, 0x20, 0x63, 0x6f, 0x6d, 0x70, 0x61, 0x74, 0x69, 
                                    0x62, 0x6c, 0x65, 0x20, 0x74, 0x6f, 0x20, 0x61, 0x72, 0x64, 0x75, 0x69, 0x6e, 0x6f, 0x20, 0x70, 
                                    0x6c, 0x61, 0x74, 0x66, 0x6f, 0x72, 0x6d, 0x20, 0x61, 0x6e, 0x64, 0x20, 0x74, 0x68, 0x69, 0x73, 
                                    0x20, 0x73, 0x6f, 0x63, 0x20, 0x74, 0x61, 0x72, 0x67, 0x65, 0x74, 0x65, 0x64, 0x20, 0x66, 0x6f, 
                                    0x72, 0x20, 0x65, 0x66, 0x61, 0x62, 0x6c, 0x65, 0x73, 0x73, 0x20, 0x53, 0x68, 0x75, 0x74, 0x74 };

static void phex(uint8_t* str,uint8_t len);
static int test_encrypt(void);
static int test_decrypt(void);

int main(void)
{
    int exit;

   //printf("\nTesting AES128\n\n");

   reg_glbl_cfg0 |= 0x1F;       // Remove Reset for UART
   reg_glbl_multi_func &=0x7FFFFFFF; // Disable UART Master Bit[31] = 0
   reg_glbl_multi_func |=0x100; // Enable UART Multi func
   reg_gpio_dsel  =0xFF00; // Enable PORT B As output
   reg_uart0_ctrl = 0x07;       // Enable Uart Access {3'h0,2'b00,1'b1,1'b1,1'b1}

   //// GLBL_CFG_MAIL_BOX used as mail box, each core update boot up handshake at 8 bit
   //// bit[7:0]   - core-0
   //// bit[15:8]  - core-1
   //// bit[23:16] - core-2
   //// bit[31:24] - core-3

    reg_glbl_mail_box = 0x1 << (bthread_get_core_id() * 8); // Start of Main 

    reg_gpio_odata  = 0x00000100; 
    reg_glbl_soft_reg_0  = 0x00000000; 
    exit = test_encrypt();
    reg_gpio_odata  = 0x00000200; 

    reg_glbl_soft_reg_0  = exit;
    exit += test_decrypt();
    reg_gpio_odata  = 0x00000300; 
    reg_glbl_soft_reg_0  = exit;

    if(exit == 0) {
        reg_gpio_odata  = 0x00001800; 
    } else {
        reg_gpio_odata  = 0x0000A800; 
    }

    return exit;
}


// prints string as hex
static void phex(uint8_t* str,uint8_t len )
{

    uint32_t iPayload;
    unsigned char i,j;
    for (i = 0; i < len; ++i)
        printf("%.2x", str[i]);

    printf("\n");

    for (i = 0; i < len/4; ++i) {
        iPayload = 0x00;
        for (j = 0; j < 4; ++j) {
           iPayload = (iPayload << 8) | str[(i*4)+j];
        }
        printf("%0x", iPayload);
    }
           
    printf("\n");
}

static int test_decrypt(void)
{

    uint8_t ErrCnt = 0x00;
    unsigned char i,j;


   for (i = 0; i < 8; i += 1) {
        // Write 16B Encryption Text and Key
        for (j = 0; j < 16; ++j) {
          *(&reg_aes_dec_key_bptr-j) = key[j];
          *(&reg_aes_dec_text_in_bptr-j) = enc_text[(i*AES_BLOCKLEN)+j];

        }
        // Enable the Decrption Engine and Wait for completion
        reg_aes_dec_ctrl = 0x1;
        while(reg_aes_dec_ctrl);

        // Validate the 16B of Encrypted Data
        for (j = 0; j < 16; ++j) {
           if(plain_text[(i*AES_BLOCKLEN)+j] != *(&reg_aes_dec_text_out_bptr-j)) {
             ErrCnt++;
           }

        }
   }
   

    if (ErrCnt == 0) {
      //printf("SUCCESS!\n");
	  return(0);
    } else {
      //printf("FAILURE!\n");
	  return(1);
    }
}

static int test_encrypt(void)
{
    uint8_t ErrCnt = 0x00;
    unsigned char i,j;


   for (i = 0; i < 8; i += 1) {
        // Write 16B Plan Text and Key
        for (j = 0; j < 16; ++j) {
          *(&reg_aes_enc_key_bptr-j) = key[j];
          *(&reg_aes_enc_text_in_bptr-j) = plain_text[(i*AES_BLOCKLEN)+j];

        }
        // Enable the Encryption Engine and Wait for completion
        reg_aes_enc_ctrl = 0x1;
        while(reg_aes_enc_ctrl);

        // Validate the 16B of Encrypted Data
        for (j = 0; j < 16; ++j) {
           if(enc_text[(i*AES_BLOCKLEN)+j] != *(&reg_aes_enc_text_out_bptr-j)) {
             ErrCnt++;
           }

        }
     }

    if (ErrCnt == 0) {
        //printf("SUCCESS!\n");
	return(0);
    } else {
        //printf("FAILURE!\n");
	return(1);
    }
}





