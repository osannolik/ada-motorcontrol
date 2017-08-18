with Transforms;
with AMC_Utils;

package body FOC is

   Is_Saturated : Boolean := False;

   function Calculate_Voltage (Iabc          : Abc;
                               I_Set_Point   : Dq;
                               Current_Angle : Angle_Rad;
                               Vmax          : Voltage_V;
                               Period        : Seconds)
                               return Abc
   is
      pragma Unreferenced (I_Set_Point, Period);
      Angle_Obj : constant Angle :=
         Compose (Current_Angle);

      Idq : constant Dq :=
         Transforms.Park (Transforms.Clarke (Iabc), Angle_Obj);
      pragma Unreferenced (Idq);
      Vdq : Dq;
   begin

      --  PID
      Vdq := (0.0, 0.0);

      AMC_Utils.Saturate (X       => Vdq,
                          Maximum => Vmax,
                          Is_Sat  => Is_Saturated);

      return Transforms.Clarke_Inv (Transforms.Park_Inv (Vdq, Angle_Obj));
   end Calculate_Voltage;

end FOC;
