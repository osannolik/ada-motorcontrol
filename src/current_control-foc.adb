with Position;
with Position.Alignment;
with PID;
with Transforms;
with ZSM;
with AMC_Utils;
with Calmeas;

package body Current_Control.FOC is

   Kp_Param : aliased Float := 0.1;
   Iq_Log   : aliased Voltage_V;

   Rotor_Angle_Log : aliased Float;

   Is_Saturated : Boolean := False;

   PID_Iq : PID.Kpid := PID.Compose (Kp => Kp_Param,
                                     Ki => 0.0,
                                     Kd => 0.0);
   PID_Id : PID.Kpid := PID_Iq;

   Align_Data : Position.Alignment.Alignment_Data (Sensor => Config.Position_Sensor);

   procedure Calculate_Voltage (Phase_Currents : in Abc;
                                Set_Point      : in Dq;
                                Rotor_Angle    : in Angle;
                                V_Max          : in Voltage_V;
                                Voltage        : out Abc)
   --  Calculates the requested inverter phase voltages as per the FOC algorithm.
   --  @param Phase_Currents A three phase current
   --  @param Set_Point Current set-point given in a rotor fixed reference frame
   --  @param Rotor_Angle Stator-to-rotor fixed angle given in electrical radians
   --  @param V_Max Maximum allowed phase to neutral voltage
   --  @param Voltage A three phase voltage given in a stator fixed reference frame
   is
      Idq : constant Dq :=
         Transforms.Park (Transforms.Clarke (Phase_Currents), Rotor_Angle);

      Vdq : Dq;
   begin
      PID_Iq.Kp := Kp_Param;
      PID_Id.Kp := Kp_Param;

      Iq_Log := Idq.Q;

      PID_Iq.Update (Setpoint => Set_Point.Q,
                     Actual   => Idq.Q,
                     Ts       => Nominal_Period,
                     Is_Sat   => Is_Saturated);

      PID_Id.Update (Setpoint => Set_Point.D,
                     Actual   => Idq.D,
                     Ts       => Nominal_Period,
                     Is_Sat   => Is_Saturated);

      Vdq := Dq'(D => PID_Id.Get_Output,
                 Q => PID_Iq.Get_Output);

      AMC_Utils.Saturate (X       => Vdq,
                          Maximum => V_Max,
                          Is_Sat  => Is_Saturated);

      Voltage := Transforms.Clarke_Inv (Transforms.Park_Inv (Vdq, Rotor_Angle));
   end Calculate_Voltage;

   function Voltage_To_Duty (V     : in Abc;
                             V_Bus : in Voltage_V)
                             return Abc
   is
      Duty : constant Abc := (100.0 / V_Bus) * V + (50.0, 50.0, 50.0);
   begin
      return ZSM.Modulate (Duty, Config.Modulation_Method);
   end Voltage_To_Duty;

   procedure Update (Phase_Currents : in Abc;
                     System_Outputs : in AMC.Inverter_System_States;
                     Duty           : out Abc)
   is
      V_Bus : constant Voltage_V :=
         System_Outputs.Vbus;

      V_Max : constant Voltage_V :=
         0.5 * V_Bus * ZSM.Modulation_Index_Max (Config.Modulation_Method);

      V_Ctrl : Abc;
      Rotor_Angle : Angle;
      Current_Command : Space_Vector;
      Align_Current : Current_A;
   begin

      case System_Outputs.Mode is
         when Normal | Speed =>
            Rotor_Angle     := Compose (Position.Get_Angle);
            Current_Command := System_Outputs.Current_Command;

         when Alignment =>
            Position.Alignment.Align_To_Sensor_Update
               (Alignment         => Align_Data,
                Period            => Nominal_Period,
                To_Angle          => Rotor_Angle,
                Current_Set_Point => Align_Current);

            Current_Command :=
               Space_Vector'(Reference_Frame  => Rotor,
                             Rotor_Fixed      => (D => Align_Current, Q => 0.0));

            Current_Control_Outputs.Set
               ((Alignment_Done => Position.Alignment.Is_Done (Align_Data)));

         when Off =>
            Duty := Abc'(50.0, 50.0, 50.0);
            return;
      end case;

      Rotor_Angle_Log := Float (Rotor_Angle.Angle);

      Calculate_Voltage
         (Phase_Currents => Phase_Currents,
          Set_Point      => To_Rotor_Fixed (Current_Command, Rotor_Angle),
          Rotor_Angle    => Rotor_Angle,
          V_Max          => V_Max,
          Voltage        => V_Ctrl);

      Duty := Voltage_To_Duty (V_Ctrl, V_Bus);

   end Update;

begin

   Calmeas.Add (Symbol      => Rotor_Angle_Log'Access,
                Name        => "Rotor_Angle",
                Description => "");

   Calmeas.Add (Symbol      => Kp_Param'Access,
                Name        => "Kp",
                Description => "PID proportional gain");

   Calmeas.Add (Symbol      => Iq_Log'Access,
                Name        => "Iq",
                Description => "Quadrature current [A]");
end Current_Control.FOC;
