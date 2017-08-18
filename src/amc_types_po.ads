with Generic_PO;
with AMC_Types;
with Config;

package AMC_Types_PO is
   --  Protected variants of various types

   package Dq_PO_Pack      is new Generic_PO (AMC_Types.Dq);
   package Voltage_PO_Pack is new Generic_PO (AMC_Types.Voltage_V);

   subtype Dq_PO is Dq_PO_Pack.Shared_Data(Config.Protected_Object_Prio);
   --  Provides mutually exclusive access to a Dq type

   subtype Voltage_PO is Voltage_PO_Pack.Shared_Data(Config.Protected_Object_Prio);
   --  Provides mutually exclusive access to a Voltage_V type

end AMC_Types_PO;