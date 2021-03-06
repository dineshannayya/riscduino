//========================================================================
// common-misc
//========================================================================

#ifndef COMMON_MISC_H
#define COMMON_MISC_H

#include <stdio.h>
#include <stdlib.h>

//------------------------------------------------------------------------
// Typedefs
//------------------------------------------------------------------------

typedef unsigned char byte;
typedef unsigned int  uint;

//------------------------------------------------------------------------
// exit
//------------------------------------------------------------------------
// exit the program with the given status code


inline
void exit( int i )
{
  int msg = 0x00010000 | i;
  asm ( "csrw 0x7C0, %0;" :: "r"(msg) );
}


//------------------------------------------------------------------------
// test_fail
//------------------------------------------------------------------------


inline
void test_fail( int index, int val, int ref )
{
  int status = 0x00020001;
  asm( "csrw 0x7C0, %0;"
       "csrw 0x7C0, %1;"
       "csrw 0x7C0, %2;"
       "csrw 0x7C0, %3;"
       :
       : "r" (status), "r" (index), "r" (val), "r" (ref)
  );
}


//------------------------------------------------------------------------
// test_pass
//------------------------------------------------------------------------


inline
void test_pass()
{
  int status = 0x00020000;
  asm( "csrw 0x7C0, %0;"
       :
       : "r" (status)
  );
}

//------------------------------------------------------------------------
// test_stats_on
//------------------------------------------------------------------------


inline
void test_stats_on()
{
  int status = 1;
  asm( "csrw 0x7C1, %0;"
       :
       : "r" (status)
  );
}


//------------------------------------------------------------------------
// test_stats_off
//------------------------------------------------------------------------

inline
void test_stats_off()
{
  int status = 0;
  asm( "csrw 0x7C1, %0;"
       :
       : "r" (status)
  );
}

#endif /* COMMON_MISC_H */

