with AMC.Types; use AMC.Types;

package AMC.Config is
   --  Ada Motor Controller configuration parameters

   PWM_Frequency_Hz : constant Frequency_Hz := 20_000.0;

   PWM_Gate_Deadtime_S : constant Seconds := 166.0e-9;

end AMC.Config;
