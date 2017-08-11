package AMC.Config is
   --  Ada Motor Controller configuration parameters

   PWM_Frequency_Hz : constant AMC_Types.Frequency_Hz := 20_000.0;

   PWM_Gate_Deadtime_S : constant AMC_Types.Seconds := 166.0e-9;

end AMC.Config;
