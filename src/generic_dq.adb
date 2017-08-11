with Cortex_M.FPU;

package body Generic_DQ is

   function "+"(X,Y : in Dq) return Dq is
   begin
      return Dq'(D => X.D + Y.D,
                 Q => X.Q + Y.Q);
   end "+";

   function "-"(X,Y : in Dq) return Dq is
   begin
      return Dq'(D => X.D - Y.D,
                 Q => X.Q - Y.Q);
   end "-";

   function "*"(X : in Dq; c : in Datatype) return Dq is
      (c * X);

   function "*"(c : in Datatype; X : in Dq) return Dq is
   begin
      return Dq'(D => c * X.D,
                 Q => c * X.Q);
   end "*";

   function "/"(X : in Dq; c : in Datatype) return Dq is
      (Datatype'(1.0)/c * X);

   function Magnitude(X : in Dq) return Datatype is
   begin
      --  Assumes Datatype can be converted to/from Float
      return Datatype (Cortex_M.FPU.Sqrt (Float (X.D * X.D + X.Q * X.Q)));
   end Magnitude;

   procedure Normalize(X : in out Dq)
   is
   begin
      if X.D /= Datatype'(0.0) or else
         X.Q /= Datatype'(0.0) then
         X := X / X.Magnitude;
      end if;
   end Normalize;

end Generic_DQ;
