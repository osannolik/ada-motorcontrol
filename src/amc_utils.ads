package AMC_Utils is

   One_Over_Sqrt3 : constant Float := 0.577350269;

   Sqrt3_Over_Two : constant Float := 0.866025404;

   Two_Over_Sqrt3 : constant Float := 1.0 / Sqrt3_Over_Two;

   function Max (X,Y : in Float)
                 return Float
   with
      Inline;

   function Min (X,Y : in Float)
                 return Float
   with
      Inline;

   function Max (X,Y : in Integer)
                 return Integer
   with
      Inline;

   function Min (X,Y : in Integer)
                 return Integer
   with
      Inline;

end AMC_Utils;
