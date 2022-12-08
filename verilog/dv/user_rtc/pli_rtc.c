#include <stdlib.h> /* ANSI C standard library */
#include <stdio.h> /* ANSI C standard input/output library */
#include <time.h>  
#include <stdarg.h> /* ANSI C standard arguments library */
#include  "vpi_user.h"  /*  IEEE 1364 PLI VPI routine library  */

#define CMD_RTC_INIT        0
#define CMD_RTC_NEXT_SECOND 1
#define CMD_RTC_NEXT_DATE 2

/* prototypes of PLI application routine names */
PLI_INT32 PLIbook_RtcSizetf(PLI_BYTE8  *user_data);
PLI_INT32 PLIbook_RtcCalltf(PLI_BYTE8  *user_data);
PLI_INT32 PLIbook_RtcCompiletf(PLI_BYTE8  *user_data);
PLI_INT32 PLIbook_RtcStartOfSim(s_cb_data  *callback_data);

   /* tm structure */
   /* struct tm {
       int tm_sec;         // seconds,  range 0 to 59          
       int tm_min;         // minutes, range 0 to 59           
       int tm_hour;        // hours, range 0 to 23             
       int tm_mday;        // day of the month, range 1 to 31  
       int tm_mon;         // month, range 0 to 11             
       int tm_year;        // The number of years since 1900   
       int tm_wday;        // day of the week, range 0 to 6    
       int tm_yday;        // day in the year, range 0 to 365  
       int tm_isdst;       // daylight saving time             
    }; */
struct tm tm = {0};

/*******************************************
* Sizetf application
* *****************************************/
PLI_INT32  PLIbook_RtcSizetf(PLI_BYTE8  *user_data)
{
   return(32); /* $rtc returns 32-bit values */
}

/*********************************************
* compiletf application to verify valid systf args.
* *************************************************/
PLI_INT32  PLIbook_RtcCompiletf(PLI_BYTE8  *user_data)
{
   s_vpi_value value_s;
   vpiHandle systf_handle, arg_itr, arg_handle;
   PLI_INT32 tfarg_type;
   PLI_INT32 cmd;

   int err_flag = 0;
   do { /* group all tests, so can break out of group on error */
       systf_handle = vpi_handle(vpiSysTfCall, NULL);
       arg_itr = vpi_iterate(vpiArgument, systf_handle);
       if (arg_itr == NULL) {
           vpi_printf("ERROR: $c_rtc requires 7 arguments; has none\n");
           err_flag = 1;
           break;
      }
      arg_handle = vpi_scan(arg_itr);
      tfarg_type = vpi_get(vpiType, arg_handle);
      if ( (tfarg_type != vpiReg) &&
          (tfarg_type != vpiIntegerVar) &&
          (tfarg_type != vpiConstant) ) {
          vpi_printf("ERROR: $c_rtc arg1 must be number, variable or net\n");
          err_flag = 1;
          break;
      }
      value_s.format = vpiIntVal;
      vpi_get_value(arg_handle, &value_s);
      cmd = value_s.value.integer;
 
      // RTC Init has 7 Parameter 
      if(cmd == CMD_RTC_INIT) { 
          arg_handle = vpi_scan(arg_itr);
          tfarg_type = vpi_get(vpiType, arg_handle);
          if ( (tfarg_type != vpiReg) &&
              (tfarg_type != vpiIntegerVar) &&
              (tfarg_type != vpiConstant) ) {
              vpi_printf("ERROR: $c_rtc arg2 must be number, variable or net\n");
              err_flag = 1;
              break;
          }
          arg_handle = vpi_scan(arg_itr);
          tfarg_type = vpi_get(vpiType, arg_handle);
          if ( (tfarg_type != vpiReg) &&
              (tfarg_type != vpiIntegerVar) &&
              (tfarg_type != vpiConstant) ) {
              vpi_printf("ERROR: $c_rtc arg3 must be number, variable or net\n");
              err_flag = 1;
              break;
          }
          arg_handle = vpi_scan(arg_itr);
          tfarg_type = vpi_get(vpiType, arg_handle);
          if ( (tfarg_type != vpiReg) &&
              (tfarg_type != vpiIntegerVar) &&
              (tfarg_type != vpiConstant) ) {
              vpi_printf("ERROR: $c_rtc arg4 must be number, variable or net\n");
              err_flag = 1;
              break;
          }
          arg_handle = vpi_scan(arg_itr);
          tfarg_type = vpi_get(vpiType, arg_handle);
          if ( (tfarg_type != vpiReg) &&
              (tfarg_type != vpiIntegerVar) &&
              (tfarg_type != vpiConstant) ) {
              vpi_printf("ERROR: $c_rtc arg5 must be number, variable or net\n");
              err_flag = 1;
              break;
          }
          arg_handle = vpi_scan(arg_itr);
          tfarg_type = vpi_get(vpiType, arg_handle);
          if ( (tfarg_type != vpiReg) &&
              (tfarg_type != vpiIntegerVar) &&
              (tfarg_type != vpiConstant) ) {
              vpi_printf("ERROR: $c_rtc arg6 must be number, variable or net\n");
              err_flag = 1;
              break;
          }
          arg_handle = vpi_scan(arg_itr);
          tfarg_type = vpi_get(vpiType, arg_handle);
          if ( (tfarg_type != vpiReg) &&
              (tfarg_type != vpiIntegerVar) &&
              (tfarg_type != vpiConstant) ) {
              vpi_printf("ERROR: $c_rtc arg7 must be number, variable or net\n");
              err_flag = 1;
              break;
          }

          arg_handle = vpi_scan(arg_itr);
          if (arg_handle != NULL) {
              vpi_printf("ERROR: $c_rtc requires 7 arguments; has too many\n");
              vpi_free_object(arg_itr);
              err_flag = 1;
              break;
          }
        } else { // CMD_RTC_NEXT_SECOND & CMD_RTC_NEXT_DATE has only 1 arguments

          arg_handle = vpi_scan(arg_itr);
          if (arg_handle != NULL) {
              vpi_printf("ERROR: $c_rtc requires 1 arguments; has too many\n");
              vpi_free_object(arg_itr);
              err_flag = 1;
              break;
          }
       }
   } while (0 == 1); /* end of test group; only executed once */
   if (err_flag) {
      vpi_control(vpiFinish, 1);  /* abort simulation */
   }
   return(0);
}

/******************************************************************
* calltf to calculate floating point addr
* ******************************************************************/
#include <stdio.h> 
#include <time.h>  
#include <stdlib.h>

PLI_INT32  PLIbook_RtcCalltf(PLI_BYTE8  *user_data)
{
   s_vpi_value value_s;
   vpiHandle systf_handle,  arg_itr,  arg_handle;
   PLI_INT32 cmd,year, month, date, hour,minute,second;
   float result;
   systf_handle = vpi_handle(vpiSysTfCall, NULL);
   arg_itr = vpi_iterate(vpiArgument, systf_handle);
   if (arg_itr == NULL) {
       vpi_printf("ERROR:  $c_rtc failed to obtain systf arg handles\n");
       return(0);
   }
   /* read cmd from systf arg 1 (compiletf has already verified) */
   arg_handle = vpi_scan(arg_itr);
   value_s.format = vpiIntVal;
   vpi_get_value(arg_handle, &value_s);
   cmd = value_s.value.integer;


   if(cmd == CMD_RTC_INIT) {
      /* read input1 from systf arg 6 (compiletf has already verified) */
      arg_handle = vpi_scan(arg_itr);
      vpi_get_value(arg_handle,  &value_s);
      year = value_s.value.integer;

      /* read input2 from systf arg 6 (compiletf has already verified) */
      arg_handle = vpi_scan(arg_itr);
      vpi_get_value(arg_handle,  &value_s);
      month = value_s.value.integer;

      /* read input2 from systf arg 6 (compiletf has already verified) */
      arg_handle = vpi_scan(arg_itr);
      vpi_get_value(arg_handle,  &value_s);
      date = value_s.value.integer;

      /* read input3 from systf arg 6 (compiletf has already verified) */
      arg_handle = vpi_scan(arg_itr);
      vpi_get_value(arg_handle,  &value_s);
      hour = value_s.value.integer;

      /* read input4 from systf arg 6 (compiletf has already verified) */
      arg_handle = vpi_scan(arg_itr);
      vpi_get_value(arg_handle,  &value_s);
      minute = value_s.value.integer;

      /* read input5 from systf arg 6 (compiletf has already verified) */
      arg_handle = vpi_scan(arg_itr);
      vpi_get_value(arg_handle,  &value_s);
      second = value_s.value.integer;

      // initialize the Structure
      tm.tm_year = year-1900;
      tm.tm_mon  = month-1; /* C Month start from 0 to 11 and RTL 1 to 12 */
      tm.tm_mday = date;
      tm.tm_hour = hour;
      tm.tm_min  = minute;
      tm.tm_sec  = second;
    }

   // vpi_printf("c_func: year: %d; month: %d; day: %d;hour: %d; minute: %d; second: %d;week day: %d; year day: %d\n",
   //          tm.tm_year + 1900, tm.tm_mon, tm.tm_mday,
   //          tm.tm_hour, tm.tm_min, tm.tm_sec,
   //          tm.tm_wday, tm.tm_yday);

   if(cmd == CMD_RTC_NEXT_SECOND)
      tm.tm_sec  = tm.tm_sec + 1;
   else if(cmd == CMD_RTC_NEXT_DATE)
      tm.tm_mday  = tm.tm_mday + 1;
   mktime(&tm);

   //vpi_printf("c_func: year: %d; month: %d; day: %d;hour: %d; minute: %d; second: %d;week day: %d; year day: %d\n",
   //         tm.tm_year + 1900, tm.tm_mon, tm.tm_mday,
   //         tm.tm_hour, tm.tm_min, tm.tm_sec,
   //         tm.tm_wday, tm.tm_yday);

   char str[80];
   if(cmd == CMD_RTC_NEXT_SECOND)
      sprintf(str,"%02d%02d%02d%02d",tm.tm_mday,tm.tm_hour,tm.tm_min,tm.tm_sec);
   else if(cmd == CMD_RTC_NEXT_DATE)
      sprintf(str,"%04d%02d%02d",tm.tm_year+1900,tm.tm_mon+1,tm.tm_mday);

   vpi_printf("c_func: year: %d; month: %d; day: %d;hour: %d; minute: %d; second: %d;week day: %d; year day: %d\n",
            tm.tm_year + 1900, tm.tm_mon+1, tm.tm_mday,
            tm.tm_hour, tm.tm_min, tm.tm_sec,
            tm.tm_wday, tm.tm_yday);

   ///* write result to simulation as return value $fpu_add */
   int c = (int)strtol(str, NULL, 16); 

   value_s.value.integer =  (PLI_INT32)c;
   vpi_put_value(systf_handle,  &value_s, NULL, vpiNoDelay);
   return(0);
}


/**
* Start-of-simulation application
****/
PLI_INT32  PLIbook_RtcStartOfSim(s_cb_data  *callback_data)
{
   vpi_printf("\n$c_rtc PLI application is being used.\n\n");
   return(0);
}

/**********************************************************
    $fpu_add Registration Data
(add this function name to the vlog_startup_routines array)
***********************************************************/
void  PLIbook_fpu_add_register()
{
    s_vpi_systf_data tf_data;
    s_cb_data cb_data_s;
    vpiHandle callback_handle;
    
    tf_data.type = vpiSysFunc;
    tf_data.sysfunctype = vpiSysFuncSized;
    tf_data.tfname =  "$c_rtc";
    tf_data.calltf = PLIbook_RtcCalltf;
    tf_data.compiletf = PLIbook_RtcCompiletf;
    tf_data.sizetf = PLIbook_RtcSizetf;
    tf_data.user_data = NULL;
    vpi_register_systf(&tf_data);
    cb_data_s.reason = cbStartOfSimulation;
    cb_data_s.cb_rtn = PLIbook_RtcStartOfSim;
    cb_data_s.obj = NULL;
    cb_data_s.time = NULL;
    cb_data_s.value = NULL;
    cb_data_s.user_data = NULL;
    callback_handle = vpi_register_cb(&cb_data_s);
    vpi_free_object(callback_handle); /* don’t need callback handle */
}

void (*vlog_startup_routines[])() = {
    PLIbook_fpu_add_register,
    0
};

