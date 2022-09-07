# include  <vpi_user.h>

static int system_compiletf(char*user_data)
{
      return 0;
}

static int system_calltf(char*name)
{
      vpiHandle callh = vpi_handle(vpiSysTfCall, 0);
      vpiHandle argv  = vpi_iterate(vpiArgument, callh);
      vpiHandle arg_handle;
      s_vpi_value value_s;


      	/* Check that there are arguments. */
      if (argv == 0) {
	    vpi_printf("ERROR: %s:%d: ", vpi_get_str(vpiFile, callh),
	               (int)vpi_get(vpiLineNo, callh));
	    vpi_printf("%s requires two arguments.\n", name);
	    vpip_set_return_value(1);
	    vpi_control(vpiFinish, 1);
	    return 0;
      }

      /* Check that the first argument is a string. */
      arg_handle = vpi_scan(argv);
      vpi_free_object(argv); /* not calling scan until returns null */
      value_s.format = vpiStringVal; /* read as a string */
      vpi_get_value(arg_handle,  &value_s);
      vpi_printf("System Cmd: %s\n",value_s.value.str);
      system(value_s.value.str);
      return 0;
}

void system_register()
{
      s_vpi_systf_data tf_data;

      tf_data.type      = vpiSysTask;
      tf_data.tfname    = "$system";
      tf_data.calltf    = system_calltf;
      tf_data.compiletf = system_compiletf;
      tf_data.sizetf    = 0;
      tf_data.user_data = "$system";
      vpi_register_systf(&tf_data);
}

void (*vlog_startup_routines[])() = {
    system_register,
    0
};
