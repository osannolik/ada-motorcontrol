with AMC_Types;
with System;
with ZSM;
with Position;

package Config is
   --  Ada Motor Controller configuration parameters

   PWM_Frequency_Hz : constant AMC_Types.Frequency_Hz := 20_000.0;

   PWM_Gate_Deadtime_S : constant AMC_Types.Seconds := 166.0e-9;

   Modulation_Method : constant ZSM.Modulation_Method := ZSM.Sinusoidal;

   Position_Sensor : constant Position.Position_Sensor := Position.Encoder;


   ADC_ISR_Prio : constant System.Interrupt_Priority := System.Interrupt_Priority'Last;

   Current_Control_Prio : constant System.Priority := System.Priority'Last;

   Inverter_System_Prio : constant System.Priority := System.Priority'Last - 2;

   Logger_Prio : constant System.Priority := System.Priority'Last - 4;

   Protected_Object_Prio : constant System.Priority := System.Priority'Last;
   --  Should be set to the highest prio of all object-using tasks


   Inverter_System_Period_Ms : constant Positive := 10;

   Logger_Period_Ms : constant Positive := 10;

end Config;
