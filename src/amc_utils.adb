package body AMC_Utils is

   function Max (X,Y : in Float)
                 return Float
   is
   begin
      if X > Y then
         return X;
      end if;

      return Y;
   end Max;

   function Min (X,Y : in Float)
                 return Float
   is
   begin
      if X < Y then
         return X;
      end if;

      return Y;
   end Min;

   function Max (X,Y : in Integer)
                 return Integer
   is
   begin
      if X > Y then
         return X;
      end if;

      return Y;
   end Max;

   function Min (X,Y : in Integer)
                 return Integer
   is
   begin
      if X < Y then
         return X;
      end if;

      return Y;
   end Min;

end AMC_Utils;
