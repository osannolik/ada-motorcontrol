with AMC_Types; use AMC_Types;
with Config;

package Current_Control is
   --  @summary
   --  Current controller
   --
   --  @description
   --  This package is responsible for calculating and setting the switching
   --  duty cycle, typically in order to achieve the set-point stator currents.
   --
   --  Contained is a task that is triggered when new samples of the
   --  phase currents and voltages are available. This is typically triggered by
   --  the ADC. The current controller will take the ADC readings and, depending
   --  on the specific control algorithm, control the stator current by commanding
   --  a new triplet of duty cycles to the PWM peripheral. The current set-point,
   --  control mode etc. is read from the Inverter_System task.
   --

   task Current_Control with
      Priority => Config.Current_Control_Prio,
      Storage_Size => (4 * 1024);

private

   Nominal_Period : constant AMC_Types.Seconds := 1.0 / Config.PWM_Frequency_Hz;

end Current_Control;
