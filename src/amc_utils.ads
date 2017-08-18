with AMC_Types; use AMC_Types;

package AMC_Utils is

   One_Over_Sqrt3 : constant Float := 0.577350269;

   Sqrt3_Over_Two : constant Float := 0.866025404;

   Two_Over_Sqrt3 : constant Float := 1.0 / Sqrt3_Over_Two;

   procedure Saturate (X       : in out Dq;
                       Maximum : in Float;
                       Is_Sat  : out Boolean);

   function Max (X, Y : in Float)
                 return Float
   with
      Inline;

   function Min (X, Y : in Float)
                 return Float
   with
      Inline;

   function Max (X, Y : in Integer)
                 return Integer
   with
      Inline;

   function Min (X, Y : in Integer)
                 return Integer
   with
      Inline;

   function To_Kelvin (DegC : in Temperature_DegC)
                       return Temperature_K
   with
      Inline;

   function To_DegC (Kelvin : in Temperature_K)
                     return Temperature_DegC
   with
      Inline;

end AMC_Utils;
