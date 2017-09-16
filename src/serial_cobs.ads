with AMC_Types;
with Stream_Interface;

package Serial_COBS is
   --  @summary
   --  Consistent Overhead Byte Stuffing
   --
   --  @description
   --  This package defines an implementation of COBS encoding decoding.
   --  Read and write interfaces override the Stream_Interface.Base_Stream type.
   --

   type COBS_Stream is limited new Stream_Interface.Base_Stream with private;

   Data_Length_Max      : constant Natural := 253;
   COBS_Overhead_Size   : constant Natural := 1;
   --  COBS always add 1 byte to the message length.
   --  Additionally, for longer packets of length n,
   --  it may add floor(n/254) additional bytes to the encoded packet size.
   --  Hence, by setting data len to max 253, the stuffing size is always 1 byte.

   procedure Initialize (Stream : in out COBS_Stream;
                         IO_Stream_Access : in Stream_Interface.Base_Stream_Access);
   --  Initializes and resets the COBS object to use the specified stream for IO.
   --  @param Stream The COBS object
   --  @param IO_Stream_Access The stream to use for IO when calling Read and Write.

   function COBS_Encode (Input : in AMC_Types.Byte_Array)
                         return AMC_Types.Byte_Array
   with
      Pre => Input'Length <= Data_Length_Max,
      Post => (if Input'Length > 0 then
                  COBS_Encode'Result'Length = Input'Length + 1
               else
                  Input'Length = COBS_Encode'Result'Length);
   --  Encode input data array.
   --  @param Input The raw intput data array.
   --  @return The input array encoded by COBS.

   function COBS_Decode (Encoded_Data : in AMC_Types.Byte_Array)
                         return AMC_Types.Byte_Array
   with
      Pre => Encoded_Data'Length <= Data_Length_Max + 1,
      Post => (if Encoded_Data'Length > 0 then
                  COBS_Decode'Result'Length = Encoded_Data'Length - 1
               else
                  Encoded_Data'Length = COBS_Decode'Result'Length);
   --  Decode input array.
   --  @param Encoded_Data An array containing encoded data.
   --  @return Decoded data.

   overriding
   procedure Write (Stream : in out COBS_Stream;
                    Data   : in AMC_Types.Byte_Array;
                    Sent   : out Natural)
   with
      Pre => Data'Length <= Data_Length_Max;
   --  Encodes Data and sends it to the IO_Stream. Delimiter is appended.
   --  @param Stream The COBS object.
   --  @param Data Raw data that shall be encoded and sent to IO_Stream.
   --  @param Sent The number of bytes in Data that was sent.

   overriding
   function Read (Stream : in out COBS_Stream)
                  return AMC_Types.Byte_Array;
   --  Reads encoded data from IO_Stream and returns decoded data.
   --  @param Stream The COBS object.
   --  @return Decoded data.

private

   subtype Delimiter_Type is AMC_Types.UInt8;
   Delimiter : constant := Delimiter_Type'(0);

   Total_Overhead_Size : constant Natural := Delimiter_Type'Size / 8 + COBS_Overhead_Size;

   subtype Buffer_Index is Natural range 0 .. Data_Length_Max;

   type COBS_Stream is limited new Stream_Interface.Base_Stream with record
      Buffer_Incomplete : AMC_Types.Byte_Array (Buffer_Index'Range);
      Idx_Buffer        : Natural := Buffer_Index'First;
      IO_Stream_Access  : Stream_Interface.Base_Stream_Access;
   end record;

end Serial_COBS;
