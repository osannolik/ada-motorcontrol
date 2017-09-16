with Generic_PO;
with AMC_Types; use AMC_Types;
with Config;


package AMC is
   --  @summary
   --  Ada Motor Controller
   --
   --  @description
   --  This package performs general system tasks, such as handling of the
   --  inverter modes, input control signal selection, filtering etc.
   --  Used peripherals (e.g. ADC, PWM) are initialized here.
   --

   procedure Initialize;
   --  Initializes used peripherals and sets the inverter in a default state.

   function Is_Initialized
      return Boolean;
   --  @return True when initialized.

   procedure Safe_State;
   --  Forces the inverter into a state that is considered safe.
   --  Typically this disables the PWM generation (all switches off), and
   --  turns off the power to the gate drivers.

   task Inverter_System with
      Priority => Config.Inverter_System_Prio,
      Storage_Size => (8 * 1024);
   --  This cyclic task performs the general system actions, such as reading the
   --  control inputs (e.g. requested torque/current/speed/mode) and commanding a
   --  current set-point for the current controller.

   --  A type that collects objects set by the Inverter_System task
   type Inverter_System_States is record
      Idq_CC_Request : Dq;
      --  Holds the Idq value that is used as set-point for the current controller
      Vbus : Voltage_V;
      --  DC bus voltage
      Alignment_Angle : Angle_Erad;
      --  In Alignment mode, the current controller aligns rotor to this angle
      Mode : Ctrl_Mode;
      --  Holds the current control mode
   end record;

   function Get_Inverter_System_Output return Inverter_System_States;
   --  Get the outputs from the Inverter_System task.
   --  @return A record of type Inverter_System_States

private

   Initialized : Boolean := False;

   package System_States_PO_Pack is new Generic_PO (Inverter_System_States);

   subtype Inverter_Output is
      System_States_PO_Pack.Shared_Data (Config.Protected_Object_Prio);

   Inverter_System_Outputs : Inverter_Output;
   --  A protected object that is updated atomically by the Inverter_System task.
   --  Any outputs from Inverter_System shall be passed through this record.

end AMC;
