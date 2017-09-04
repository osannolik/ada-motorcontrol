with Generic_Queue;
with AMC_Types;

package Byte_Queue is new Generic_Queue (Item_Type => AMC_Types.UInt8,
                                         Items_Max => 1023);
