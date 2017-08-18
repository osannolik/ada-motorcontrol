with AMC_Types; use AMC_Types;
with Config;

package Current_Control is
   --  Implementation of a phase current controller

   function Is_Initialized return Boolean;

   procedure Initialize;

   task Current_Control with
      Priority => Config.Current_Control_Prio,
      Storage_Size => (4 * 1024);

private

   Nominal_Period : constant AMC_Types.Seconds := 1.0 / Config.PWM_Frequency_Hz;

   Initialized : Boolean := False;

end Current_Control;
