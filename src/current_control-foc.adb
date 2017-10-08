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

   Alignment_Timer : AMC_Utils.Timer := AMC_Utils.Create (2.0);

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

   procedure Align_To_Sensor_Update (To_Angle          : out Angle;
                                     Current_Set_Point : out Space_Vector;
                                     Is_Done           : out Boolean)
   is
   begin
      case Config.Position_Sensor is
         when None | Hall =>
            raise Constraint_Error; --  TODO

         when Encoder =>
            To_Angle := Compose (0.0);
            Current_Set_Point :=
               Space_Vector'(Reference_Frame  => Stator_Ab,
                             Stator_Fixed_Ab  => (Alfa => 12.0,
                                                  Beta => 0.0));
            Is_Done := Alignment_Timer.Tick (Nominal_Period);
            if Is_Done then
               Position.Set_Angle (To_Angle.Angle);
            end if;

      end case;
   end Align_To_Sensor_Update;

   procedure Update (Phase_Currents : in Abc;
                     System_Outputs : in AMC.Inverter_System_States;
                     Duty           : out Abc)
   is
      V_Bus : constant Voltage_V :=
         System_Outputs.Vbus;

      V_Max : constant Voltage_V :=
         0.5 * V_Bus * ZSM.Modulation_Index_Max (Config.Modulation_Method);

      V_Ctrl : Abc;
      Alignment_Done : Boolean;
      Rotor_Angle : Angle;
      Current_Command : Space_Vector;
   begin

      case System_Outputs.Mode is
         when Normal | Speed =>
            Rotor_Angle     := Compose (Position.Get_Angle);
            Current_Command := System_Outputs.Current_Command;

         when Alignment =>
            Align_To_Sensor_Update
               (To_Angle          => Rotor_Angle,
                Current_Set_Point => Current_Command,
                Is_Done           => Alignment_Done);

            Current_Control_Outputs.Set
               (Current_Control_States'(Alignment_Done => Alignment_Done));

         when Off =>
            Duty := Abc'(50.0, 50.0, 50.0);
            return;
      end case;

      Calculate_Voltage
         (Phase_Currents => Phase_Currents,
          Set_Point      => To_Rotor_Fixed (Current_Command, Rotor_Angle),
          Rotor_Angle    => Rotor_Angle,
          V_Max          => V_Max,
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
