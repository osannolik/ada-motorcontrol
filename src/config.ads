with AMC_Types; use AMC_Types;
with System;
with ZSM;

package Config is
   --  @summary
   --  Ada Motor Controller configuration parameters
   --
   --  @description
   --  Collects a set of parameters used to configure the controller.
   --  The user can e.g. select what type of position sensor or the method of
   --  modulationto to use.
   --

   PWM_Frequency_Hz : constant AMC_Types.Frequency_Hz := 20_000.0;

   PWM_Gate_Deadtime_S : constant AMC_Types.Seconds := 225.0e-9;

   Current_Control_Method : constant AMC_Types.Control_Method := AMC_Types.Field_Oriented;

   Modulation_Method : constant ZSM.Modulation_Method := ZSM.Sinusoidal;

   Position_Sensor : constant AMC_Types.Position_Sensor := AMC_Types.Hall;

   Position_Sensor_Offset : constant AMC_Types.Angle_Erad := 0.0;

   Hall_Sensor_Pin_Map : constant AMC_Types.Pattern_To_Sector_Map :=
      (2#001# => H3,
       2#010# => H1,
       2#011# => H2,
       2#100# => H5,
       2#101# => H4,
       2#110# => H6);

   ADC_ISR_Prio : constant System.Interrupt_Priority := System.Interrupt_Priority'Last;

   Hall_ISR_Prio : constant System.Interrupt_Priority := System.Interrupt_Priority'Last - 1;

   Current_Control_Prio : constant System.Priority := System.Priority'Last;

   Hall_Handler_Prio : constant System.Priority := System.Priority'Last - 1;

   Inverter_System_Prio : constant System.Priority := System.Priority'Last - 2;

   Logger_Prio : constant System.Priority := System.Priority'Last - 4;

   Protected_Object_Prio : constant System.Priority := System.Priority'Last;
   --  Should be set to the highest prio of all object-using tasks


   Inverter_System_Period_Ms : constant Positive := 10;

   Logger_Period_Ms : constant Positive := 1;

end Config;
