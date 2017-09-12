with Transforms;
with AMC_Utils;
with PID;
with Calmeas;

package body FOC is

   Kp_Param : aliased Float := 0.1;
   Iq_Log   : aliased Voltage_V;

   Is_Saturated : Boolean := False;

   PID_Iq : PID.Kpid := PID.Compose (Kp => Kp_Param,
                                     Ki => 0.0,
                                     Kd => 0.0);
   PID_Id : PID.Kpid := PID_Iq;

   function Calculate_Voltage (Iabc          : Abc;
                               I_Set_Point   : Dq;
                               Current_Angle : Angle_Erad;
                               Vmax          : Voltage_V;
                               Period        : Seconds)
                               return Abc
   is
      Angle_Obj : constant Angle :=
         Compose (Angle_Rad (Current_Angle));

      Idq : constant Dq :=
         Transforms.Park (Transforms.Clarke (Iabc), Angle_Obj);

      Vdq : Dq;
   begin
      PID_Iq.Kp := Kp_Param;
      PID_Id.Kp := Kp_Param;

      Iq_Log := Idq.Q;

      PID_Iq.Update (Setpoint => I_Set_Point.Q,
                     Actual   => Idq.Q,
                     Ts       => Period,
                     Is_Sat   => Is_Saturated);

      PID_Id.Update (Setpoint => I_Set_Point.D,
                     Actual   => Idq.D,
                     Ts       => Period,
                     Is_Sat   => Is_Saturated);

      Vdq := Dq'(D => PID_Id.Get_Output,
                 Q => PID_Iq.Get_Output);

      AMC_Utils.Saturate (X       => Vdq,
                          Maximum => Vmax,
                          Is_Sat  => Is_Saturated);

      return Transforms.Clarke_Inv (Transforms.Park_Inv (Vdq, Angle_Obj));
   end Calculate_Voltage;

begin

   Calmeas.Add (Symbol      => Kp_Param'Access,
                Name        => "Kp",
                Description => "PID proportional gain");

   Calmeas.Add (Symbol      => Iq_Log'Access,
                Name        => "Iq",
                Description => "Quadrature current [A]");

end FOC;
