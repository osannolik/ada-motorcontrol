with AMC_Types;
with Generic_Queue;
with Config;

package Communication is

   type Port_Type is tagged limited private;

   package QP is new Generic_Queue (Item_Type => AMC_Types.UInt8, Items_Max => 8);

   A_Queue : QP.Protected_Queue (Config.Protected_Object_Prio);

private

   type Port_Type is tagged limited record
      X : Boolean;
   end record;


end Communication;
