with AMC_Utils; use AMC_Utils;

with AMC_Types; use AMC_Types;

package body ZSM is

   function Modulation_Index_Max (Method : Modulation_Method) return Float is
      (Modulation_Indicies_Max (Method));

   function Modulate(X : in AMC_Types.Abc;
                     Method : Modulation_Method)
                     return AMC_Types.Abc
   is
      (case Method is
          when Sinusoidal       => Sinusoidal (X),
          when Midpoint_Clamp   => Midpoint_Clamp (X),
          when Top_Clamp        => Top_Clamp (X),
          when Bottom_Clamp     => Bottom_Clamp (X),
          when Top_Bottom_Clamp => Top_Bottom_Clamp (X),
          when others           => X);

   function Sinusoidal(X : in AMC_Types.Abc)
                       return AMC_Types.Abc
   is
   begin
      --  No common mode is added!
      return X;
   end Sinusoidal;

   function Midpoint_Clamp(X : in AMC_Types.Abc)
                           return AMC_Types.Abc
   is
      Offset : constant Float :=
         0.5 * (1.0 - (Min(Min(X.A, X.B), X.C) + Max(Max(X.A, X.B), X.C)));
   begin
      return X + Offset;
   end Midpoint_Clamp;

   function Top_Clamp(X : in AMC_Types.Abc)
                      return AMC_Types.Abc
   is
      Offset : constant Float := 1.0 - Max(Max(X.A, X.B), X.C);
   begin
      return X + Offset;
   end Top_Clamp;

   function Bottom_Clamp(X : in AMC_Types.Abc)
                         return AMC_Types.Abc
   is
      Offset : constant Float := 0.0 - Min(Min(X.A, X.B), X.C);
   begin
      return X + Offset;
   end Bottom_Clamp;

   function Top_Bottom_Clamp(X : in AMC_Types.Abc)
                             return AMC_Types.Abc
   is
   begin
      if X.A * X.B * X.C > 0.0 then
         return Top_Clamp (X);
      else
         return Bottom_Clamp (X);
      end if;
   end Top_Bottom_Clamp;

end ZSM;
