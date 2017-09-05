with HAL; use HAL;

package body CRC is

   function Calculate (Crc_Init : in AMC_Types.UInt8;
                       Data     : in AMC_Types.Byte_Array)
                       return UInt8 is
      Tmp : AMC_Types.UInt8 := Crc_Init;
   begin
      for D of Data loop
         Tmp := Crc8_Table (Table_Index (D xor Tmp));
      end loop;

      return Tmp;
   end Calculate;

   function Calculate (Data : in AMC_Types.Byte_Array)
                       return AMC_Types.UInt8 is
      Tmp : AMC_Types.UInt8 := Crc8_Init;
   begin
      for D of Data loop
         Tmp := Crc8_Table (Table_Index (D xor Tmp));
      end loop;

      return Tmp;
   end Calculate;

end CRC;
