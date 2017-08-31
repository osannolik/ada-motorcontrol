with AMC_Types;

package Serial_COBS is
   --  Consistent Overhead Byte Stuffing

   Data_Length_Max : constant Natural := 253;
   --  COBS always adds 1 byte to the message length.
   --  Additionally, for longer packets of length n,
   --  it may add floor(n/254) additional bytes to the encoded packet size.
   --  Hence, by setting data len to max 253, the stuffing size is always 1 byte.

   subtype Buffer_Index is Natural range 0 .. Data_Length_Max;

   type COBS_Object is tagged limited record
      Buffer_Incomplete : AMC_Types.Byte_Array (Buffer_Index'Range);
      Idx_Buffer        : Natural := Buffer_Index'First;
   end record;


   function Is_Delimiter (X : in AMC_Types.UInt8) return Boolean
   with Inline;

   function COBS_Encode (Input : access AMC_Types.Byte_Array)
                         return AMC_Types.Byte_Array
   with
      Pre => Input'Length <= Data_Length_Max,
      Post => (if Input'Length > 0 then
                  COBS_Encode'Result'Length = Input'Length + 1
               else
                  Input'Length = COBS_Encode'Result'Length);

   function COBS_Decode (Encoded_Data : access AMC_Types.Byte_Array)
                         return AMC_Types.Byte_Array
   with
      Pre => Encoded_Data'Length <= Data_Length_Max + 1,
      Post => (if Encoded_Data'Length > 0 then
                  COBS_Decode'Result'Length = Encoded_Data'Length - 1
               else
                  Encoded_Data'Length = COBS_Decode'Result'Length);

   function Receive_Handler (Obj : in out COBS_Object;
                             Encoded_Rx : in AMC_Types.Byte_Array)
                             return AMC_Types.Byte_Array;

private

   Delimiter : constant := AMC_Types.UInt8'(0);

end Serial_COBS;
