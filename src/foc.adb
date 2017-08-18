with Transforms;

package body FOC is

   function Calculate_Voltage (Iabc          : Abc;
                               I_Set_Point   : Dq;
                               Current_Angle : Angle_Rad;
                               Vmax          : Voltage_V;
                               Period        : Seconds)
                               return Abc
   is
      pragma Unreferenced (I_Set_Point, Vmax, Period);
      Angle_Obj : constant Angle :=
         Compose (Current_Angle);

      Idq : constant Dq :=
         Transforms.Park (Transforms.Clarke (Iabc), Angle_Obj);
      pragma Unreferenced (Idq);
      Vdq : Dq;
   begin

      --  PID
      Vdq := (0.0, 0.0);

      return Transforms.Clarke_Inv (Transforms.Park_Inv (Vdq, Angle_Obj));
   end Calculate_Voltage;

end FOC;
