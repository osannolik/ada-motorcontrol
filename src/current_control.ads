with AMC_Types; use AMC_Types;
with Config;
with Generic_PO;

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

   type Current_Control_States is record
      Alignment_Done : Boolean := False;
   end record;

   task type Current_Control (Algorithm : Control_Method) with
      Priority => Config.Current_Control_Prio,
      Storage_Size => (4 * 1024);

   function Get_Current_Control_Output return Current_Control_States;
   --  @return The outputs set by the current controller.

private

   Nominal_Period : constant AMC_Types.Seconds := 1.0 / Config.PWM_Frequency_Hz;

   Current_Controller : Current_Control (Config.Current_Control_Method);

   package Control_States_PO_Pack is new Generic_PO (Current_Control_States);

   subtype Current_Control_Output is
      Control_States_PO_Pack.Shared_Data (Config.Protected_Object_Prio);

   Current_Control_Outputs : Current_Control_Output;
   --  A protected object that is updated atomically by the Current_Control task.
   --  Any outputs from Current_Control shall be passed through this record.

end Current_Control;
