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

   function Sign (X : in Float)
                  return Float
   is
   begin
      if X > 0.0 then
         return 1.0;
      elsif X < 0.0 then
         return -1.0;
      else
         return 0.0;
      end if;
   end Sign;

   function Fmod (X, Y : in Float)
                   return Float
   is
   begin
      return X - Float'Floor (X / Y) * Y;
   end Fmod;

   function Wrap_To (X     : in Float;
                     Upper : in Float)
                     return Float
   is
      Y : constant Float := Fmod (X, Upper);
   begin

      if Y = 0.0 and then
         X > 0.0
      then
         return Upper;
      end if;

      return Y;

   end Wrap_To;

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
