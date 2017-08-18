with AMC_Types; use AMC_Types;

package body AMC_Utils is

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

   function To_Kelvin (DegC : in AMC_Types.Temperature_DegC)
                       return AMC_Types.Temperature_K is
      (Temperature_K (DegC + 273.15));

   function To_DegC (Kelvin : in AMC_Types.Temperature_K)
                       return AMC_Types.Temperature_DegC is
      (Temperature_DegC (Kelvin - 273.15));

end AMC_Utils;
