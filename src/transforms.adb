with AMC_Math;
with AMC_Utils;

package body Transforms is

   function Clarke (X : in AMC_Types.Abc;
                    K : in Float := Factor_Default)
                    return AMC_Types.Alfa_Beta
   is
      pragma Unreferenced (K);
      use AMC_Utils;
   begin
      return AMC_Types.Alfa_Beta'
         (Alfa => X.A,
          Beta => One_Over_Sqrt3 * X.A + 2.0 * One_Over_Sqrt3 * X.B);
   end Clarke;

   function Clarke_Inv (X : in AMC_Types.Alfa_Beta;
                        K : in Float := Factor_Default)
                        return AMC_Types.Abc
   is
      pragma Unreferenced (K);
      use AMC_Utils;
      Tmp1 : constant Float := -0.5 * X.Alfa;
      Tmp2 : constant Float := Sqrt3_Over_Two * X.Beta;
   begin
      return AMC_Types.Abc'(A => X.Alfa,
                            B => Tmp1 + Tmp2,
                            C => Tmp1 - Tmp2);
   end Clarke_Inv;

   function Park (X : in AMC_Types.Alfa_Beta;
                  Angle : in AMC_Types.Angle_Rad)
                  return AMC_Types.Dq
   is
      s : constant Float := AMC_Math.Sin (Float (Angle));
      c : constant Float := AMC_Math.Cos (Float (Angle));
   begin
      return AMC_Types.Dq'(D =>  c * X.Alfa + s * X.Beta,
                           Q => -s * X.Alfa + c * X.Beta);
   end Park;

   function Park (X : in AMC_Types.Alfa_Beta;
                  Angle : in AMC_Types.Angle)
                  return AMC_Types.Dq
   is
   begin
      return AMC_Types.Dq'(D =>  Angle.Cos * X.Alfa + Angle.Sin * X.Beta,
                           Q => -Angle.Sin * X.Alfa + Angle.Cos * X.Beta);
   end Park;

   function Park_Inv (X : in AMC_Types.Dq;
                      Angle : in AMC_Types.Angle_Rad)
                      return AMC_Types.Alfa_Beta
   is
      s : constant Float := AMC_Math.Sin (Float (Angle));
      c : constant Float := AMC_Math.Cos (Float (Angle));
   begin
      return AMC_Types.Alfa_Beta'(Alfa => c * X.D - s * X.Q,
                                  Beta => s * X.D + c * X.Q);
   end Park_Inv;

   function Park_Inv (X : in AMC_Types.Dq;
                      Angle : in AMC_Types.Angle)
                      return AMC_Types.Alfa_Beta
   is
   begin
      return AMC_Types.Alfa_Beta'(Alfa => Angle.Cos * X.D - Angle.Sin * X.Q,
                                  Beta => Angle.Sin * X.D + Angle.Cos * X.Q);
   end Park_Inv;

end Transforms;
