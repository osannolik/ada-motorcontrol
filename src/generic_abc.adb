with Cortex_M.FPU;

package body Generic_ABC is

   function "+"(X,Y : in Abc) return Abc is
   begin
      return Abc'(A => X.A + Y.A,
                  B => X.B + Y.B,
                  C => X.C + Y.C);
   end "+";

   function "-"(X,Y : in Abc) return Abc is
   begin
      return Abc'(A => X.A - Y.A,
                  B => X.B - Y.B,
                  C => X.C - Y.C);
   end "-";

   function "*"(X : in Abc; c : in Datatype) return Abc is
      (c * X);

   function "*"(c : in Datatype; X : in Abc) return Abc is
   begin
      return Abc'(A => c * X.A,
                  B => c * X.B,
                  C => c * X.C);
   end "*";

   function "/"(X : in Abc; c : in Datatype) return Abc is
      (Datatype'(1.0)/c * X);

   function Magnitude(X : in Abc) return Datatype is
   begin
      --  Assumes Datatype can be converted to/from Float
      return Datatype
         (Cortex_M.FPU.Sqrt (Float (X.A * X.A + X.B * X.B + X.C * X.C)));
   end Magnitude;

   procedure Normalize(X : in out Abc)
   is
   begin
      if X.A /= Datatype'(0.0) or else
         X.B /= Datatype'(0.0) or else
         X.C /= Datatype'(0.0) then
         X := X / X.Magnitude;
      end if;
   end Normalize;

end Generic_ABC;
