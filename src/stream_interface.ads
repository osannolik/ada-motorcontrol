with AMC_Types;

package Stream_Interface is

   type Base_Stream is limited interface;

   type Base_Stream_Access is access all Base_Stream'Class;

   procedure Write (Stream : in out Base_Stream;
                    Data   : in AMC_Types.Byte_Array;
                    Sent   : out Natural) is abstract;

   function Read (Stream : in out Base_Stream)
                  return AMC_Types.Byte_Array is abstract;

end Stream_Interface;
