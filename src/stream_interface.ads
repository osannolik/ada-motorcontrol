with AMC_Types;

package Stream_Interface is
   --  @summary
   --  Stream Interface Specification
   --
   --  @description
   --  Defines an interface with abstract subprograms that can be used to
   --  standardize how data shall be send and received.
   --

   type Base_Stream is limited interface;

   type Base_Stream_Access is access all Base_Stream'Class;

   procedure Write (Stream : in out Base_Stream;
                    Data   : in AMC_Types.Byte_Array;
                    Sent   : out Natural) is abstract;
   --  Write Data using the provided stream. Shall be overriden by packages
   --  inheriting the Base_Stream.
   --  @param Stream The stream object.
   --  @param Data The data to be sent.
   --  @param Sent The number of bytes successfully sent.

   function Read (Stream : in out Base_Stream)
                  return AMC_Types.Byte_Array is abstract;
   --  Read new data from the provided stream. Shall be overriden by packages
   --  inheriting the Base_Stream.
   --  @param Stream The stream object.
   --  @return The new data.

end Stream_Interface;
