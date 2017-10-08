with Position;
with PID;
with Transforms;
with ZSM;
with AMC_Utils;
with Calmeas;

package body Current_Control.FOC is

   Kp_Param : aliased Float := 0.1;
   Iq_Log   : aliased Voltage_V;

   Is_Saturated : Boolean := False;

   PID_Iq : PID.Kpid := PID.Compose (Kp => Kp_Param,
                                     Ki => 0.0,
                                     Kd => 0.0);
   PID_Id : PID.Kpid := PID_Iq;

   procedure Calculate_Voltage (Phase_Currents : in Abc;
                                Set_Point      : in Dq;
                                Current_Angle  : in Angle_Erad;
                                V_Max          : in Voltage_V;
                                Period         : in Seconds;
                                Voltage        : out Abc)
   --  Calculates the requested inverter phase voltages as per the FOC algorithm.
   --  @param Phase_Currents A three phase current
   --  @param Set_Point Current set-point given in a rotor fixed reference frame
   --  @param Current_Angle Stator-to-rotor fixed angle given in electrical radians
   --  @param V_Max Maximum allowed phase to neutral voltage
   --  @param Period Time since last execution
   --  @param Voltage A three phase voltage given in a stator fixed reference frame
   is
      Angle_Obj : constant Angle :=
         Compose (Angle_Rad (Current_Angle));

      Idq : constant Dq :=
         Transforms.Park (Transforms.Clarke (Phase_Currents), Angle_Obj);

      Vdq : Dq;
   begin
      PID_Iq.Kp := Kp_Param;
      PID_Id.Kp := Kp_Param;

      Iq_Log := Idq.Q;

      PID_Iq.Update (Setpoint => Set_Point.Q,
                     Actual   => Idq.Q,
                     Ts       => Period,
                     Is_Sat   => Is_Saturated);

      PID_Id.Update (Setpoint => Set_Point.D,
                     Actual   => Idq.D,
                     Ts       => Period,
                     Is_Sat   => Is_Saturated);

      Vdq := Dq'(D => PID_Id.Get_Output,
                 Q => PID_Iq.Get_Output);

      AMC_Utils.Saturate (X       => Vdq,
                          Maximum => V_Max,
                          Is_Sat  => Is_Saturated);

      Voltage := Transforms.Clarke_Inv (Transforms.Park_Inv (Vdq, Angle_Obj));
   end Calculate_Voltage;

   function Voltage_To_Duty (V     : in Abc;
                             V_Bus : in Voltage_V)
                             return Abc
   is
      Duty : constant Abc := (100.0 / V_Bus) * V + (50.0, 50.0, 50.0);
   begin
      return ZSM.Modulate (X      => Duty,
                           Method => Config.Modulation_Method);
   end Voltage_To_Duty;

   procedure Update (Phase_Currents : in Abc;
                     System_Outputs : in AMC.Inverter_System_States;
                     Duty           : out Abc)
   is
      V_Bus : constant Voltage_V := System_Outputs.Vbus;
      V_Max : constant Voltage_V :=
         0.5 * V_Bus * ZSM.Modulation_Index_Max (Config.Modulation_Method);
      Current_Angle : Angle_Erad;
      V_Ctrl        : Abc;
   begin

      if System_Outputs.Mode = Alignment then
         Current_Angle := System_Outputs.Alignment_Angle;
      else
         Current_Angle := Position.Get_Angle;
      end if;

      Calculate_Voltage
         (Phase_Currents => Phase_Currents,
          Set_Point      => To_Rotor_Fixed (X     => System_Outputs.Current_Command,
                                            Angle => Current_Angle),
          Current_Angle  => Current_Angle,
          V_Max          => V_Max,
          Period         => Nominal_Period,
          Voltage        => V_Ctrl);

      Duty := Voltage_To_Duty (V_Ctrl, V_Bus);
   end Update;

begin

   Calmeas.Add (Symbol      => Kp_Param'Access,
                Name        => "Kp",
                Description => "PID proportional gain");

   Calmeas.Add (Symbol      => Iq_Log'Access,
                Name        => "Iq",
                Description => "Quadrature current [A]");
end Current_Control.FOC;
