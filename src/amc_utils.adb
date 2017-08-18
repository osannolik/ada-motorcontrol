package body AMC_Utils is

   procedure Saturate (X       : in out Dq;
                       Maximum : in Float;
                       Is_Sat  : out Boolean)
   is
      Magnitude : constant Float := AMC_Types.Magnitude (X);
      Scaling : Float;
   begin
      Is_Sat := Magnitude > Maximum;

      if Is_Sat then
         Scaling := Maximum / Max (Magnitude, Float'Succ (0.0));
         X := Scaling * X;
      end if;

   end Saturate;

   function Max (X, Y : in Float)
                 return Float
   is
   begin
      if X > Y then
         return X;
      end if;

      return Y;
   end Max;

   function Min (X, Y : in Float)
                 return Float
   is
   begin
      if X < Y then
         return X;
      end if;

      return Y;
   end Min;

   function Max (X, Y : in Integer)
                 return Integer
   is
   begin
      if X > Y then
         return X;
      end if;

      return Y;
   end Max;

   function Min (X, Y : in Integer)
                 return Integer
   is
   begin
      if X < Y then
         return X;
      end if;

      return Y;
   end Min;

   function To_Kelvin (DegC : in Temperature_DegC)
                       return Temperature_K is
      (Temperature_K (DegC + 273.15));

   function To_DegC (Kelvin : in Temperature_K)
                     return Temperature_DegC is
      (Temperature_DegC (Kelvin - 273.15));

end AMC_Utils;
