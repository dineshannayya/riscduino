
void	InitTimers         ();
void	InitTimersSafe     ();     //doesn't init timers responsible for time keeping functions
void	pwmWrite           (uint8_t pin, uint8_t val);
void	pwmWriteHR         (uint8_t pin, uint16_t val);   //accepts a 16 bit value and maps it down to the timer for maximum resolution
bool	SetPinFrequency    (int8_t pin, uint32_t frequency);
bool	SetPinFrequencySafe(int8_t pin, uint32_t frequency);	//does not set timers responsible for time keeping functions
float	GetPinResolution(uint8_t pin);  //gets the PWM resolution of a pin in base 2, 0 is returned if the pin is not connected to a timer
