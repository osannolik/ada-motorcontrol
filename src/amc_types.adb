with AMC_Math;
with Transforms;

package body AMC_Types is

   procedure Set (X : in out Angle; Angle_In : in Angle_Rad) is
   begin
      X := (Angle => Angle_In,
            Sin   => AMC_Math.Sin (Float (Angle_In)),
            Cos   => AMC_Math.Cos (Float (Angle_In)));
   end Set;

   function Compose (Angle_In : in Angle_Rad) return Angle is
   begin
      return Angle'(Angle => Angle_In,
                    Sin   => AMC_Math.Sin (Float (Angle_In)),
                    Cos   => AMC_Math.Cos (Float (Angle_In)));
   end Compose;

   function "+"(X, Y : in Abc) return Abc is
   begin
      return Abc'(A => X.A + Y.A,
                  B => X.B + Y.B,
                  C => X.C + Y.C);
   end "+";

   function "+"(X : in Abc; c : in Float) return Abc is
   begin
      return Abc'(A => X.A + c,
                  B => X.B + c,
                  C => X.C + c);
   end "+";

   function "+"(c : in Float; X : in Abc) return Abc is
      (X + c);

   function "-"(X, Y : in Abc) return Abc is
   begin
      return Abc'(A => X.A - Y.A,
                  B => X.B - Y.B,
                  C => X.C - Y.C);
   end "-";

   function "*"(X : in Abc; c : in Float) return Abc is
      (c * X);

   function "*"(c : in Float; X : in Abc) return Abc is
   begin
      return Abc'(A => c * X.A,
                  B => c * X.B,
                  C => c * X.C);
   end "*";

   function "/"(X : in Abc; c : in Float) return Abc is
      (Float'(1.0) / c * X);

   function Magnitude (X : in Abc) return Float is
   begin
      return AMC_Math.Sqrt (X.A * X.A + X.B * X.B + X.C * X.C);
   end Magnitude;

   procedure Normalize (X : in out Abc)
   is
   begin
      if X.A /= Float'(0.0) or else
         X.B /= Float'(0.0) or else
         X.C /= Float'(0.0)
      then
         X := X / X.Magnitude;
      end if;
   end Normalize;

   function To_Alfa_Beta (X : in Abc'Class) return Alfa_Beta is
   begin
      return Transforms.Clarke (Abc (X));
   end To_Alfa_Beta;

   function To_Dq (X : in Abc'Class;
                   Angle : in Angle_Rad) return Dq is
   begin
      return X.To_Alfa_Beta.To_Dq (Angle);
   end To_Dq;


   function "+"(X, Y : in Alfa_Beta) return Alfa_Beta is
   begin
      return Alfa_Beta'(Alfa => X.Alfa + Y.Alfa,
                        Beta => X.Beta + Y.Beta);
   end "+";

   function "-"(X, Y : in Alfa_Beta) return Alfa_Beta is
   begin
      return Alfa_Beta'(Alfa => X.Alfa - Y.Alfa,
                        Beta => X.Beta - Y.Beta);
   end "-";

   function "*"(X : in Alfa_Beta; c : in Float) return Alfa_Beta is
      (c * X);

   function "*"(c : in Float; X : in Alfa_Beta) return Alfa_Beta is
   begin
      return Alfa_Beta'(Alfa => c * X.Alfa,
                        Beta => c * X.Beta);
   end "*";

   function "/"(X : in Alfa_Beta; c : in Float) return Alfa_Beta is
      (Float'(1.0) / c * X);

   function Magnitude (X : in Alfa_Beta) return Float is
   begin
      return AMC_Math.Sqrt (X.Alfa * X.Alfa + X.Beta * X.Beta);
   end Magnitude;

   procedure Normalize (X : in out Alfa_Beta)
   is
   begin
      if X.Alfa /= Float'(0.0) or else
         X.Beta /= Float'(0.0)
      then
         X := X / X.Magnitude;
      end if;
   end Normalize;

   function To_Abc (X : in Alfa_Beta'Class) return Abc is
   begin
      return Transforms.Clarke_Inv (Alfa_Beta (X));
   end To_Abc;

   function To_Dq (X : in Alfa_Beta'Class;
                   Angle : in Angle_Rad) return Dq is
   begin
      return Transforms.Park (Alfa_Beta (X), Angle);
   end To_Dq;

   function To_Dq (X : in Alfa_Beta'Class;
                   Angle_In : in Angle'Class) return Dq is
   begin
      return Transforms.Park (Alfa_Beta (X), Angle (Angle_In));
   end To_Dq;

   function "+"(X, Y : in Dq) return Dq is
   begin
      return Dq'(D => X.D + Y.D,
                 Q => X.Q + Y.Q);
   end "+";

   function "-"(X, Y : in Dq) return Dq is
   begin
      return Dq'(D => X.D - Y.D,
                 Q => X.Q - Y.Q);
   end "-";

   function "*"(X : in Dq; c : in Float) return Dq is
      (c * X);

   function "*"(c : in Float; X : in Dq) return Dq is
   begin
      return Dq'(D => c * X.D,
                 Q => c * X.Q);
   end "*";

   function "/"(X : in Dq; c : in Float) return Dq is
      (Float'(1.0) / c * X);

   function Magnitude (X : in Dq) return Float is
   begin
      return AMC_Math.Sqrt (X.D * X.D + X.Q * X.Q);
   end Magnitude;

   procedure Normalize (X : in out Dq)
   is
   begin
      if X.D /= Float'(0.0) or else
         X.Q /= Float'(0.0)
      then
         X := X / X.Magnitude;
      end if;
   end Normalize;

   function To_Abc (X : in Dq'Class;
                    Angle : in Angle_Rad) return Abc is
   begin
      return X.To_Alfa_Beta (Angle).To_Abc;
   end To_Abc;

   function To_Alfa_Beta (X : in Dq'Class;
                          Angle : in Angle_Rad) return Alfa_Beta is
   begin
      return Transforms.Park_Inv (Dq (X), Angle);
   end To_Alfa_Beta;

   function To_Alfa_Beta (X : in Dq'Class;
                          Angle_In : in Angle'Class) return Alfa_Beta is
   begin
      return Transforms.Park_Inv (Dq (X), Angle (Angle_In));
   end To_Alfa_Beta;

   function To_Rotor_Fixed (X     : in Space_Vector;
                            Angle : in Angle_Rad)
                            return Dq is
   begin
      case X.Reference_Frame is
         when Stator_Abc =>
            return To_Dq (X     => X.Stator_Fixed_Abc,
                          Angle => Angle);
         when Stator_Ab =>
            return To_Dq (X     => X.Stator_Fixed_Ab,
                          Angle => Angle);
         when Rotor =>
            return X.Rotor_Fixed;
      end case;
   end To_Rotor_Fixed;

   function To_Kelvin (DegC : in Temperature_DegC)
                       return Temperature_K is
      (Temperature_K (DegC + 273.15));

   function To_DegC (Kelvin : in Temperature_K)
                     return Temperature_DegC is
      (Temperature_DegC (Kelvin - 273.15));

end AMC_Types;
