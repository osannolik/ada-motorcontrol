with Generic_PO;
with AMC_Types;
with Config;

package AMC_Types_PO is
   --  Protected variants of various types

   pragma Pure;

   package Dq_PO_Pack         is new Generic_PO (AMC_Types.Dq);
   package Voltage_PO_Pack    is new Generic_PO (AMC_Types.Voltage_V);
   package Angle_Erad_PO_Pack is new Generic_PO (AMC_Types.Angle_Erad);
   package Mode_PO_Pack       is new Generic_PO (AMC_Types.Mode);

   subtype Dq_PO is Dq_PO_Pack.Shared_Data (Config.Protected_Object_Prio);
   --  Provides mutually exclusive access to a Dq type

   subtype Voltage_PO is Voltage_PO_Pack.Shared_Data (Config.Protected_Object_Prio);
   --  Provides mutually exclusive access to a Voltage_V type

   subtype Angle_Erad_PO is Angle_Erad_PO_Pack.Shared_Data (Config.Protected_Object_Prio);
   --  Provides mutually exclusive access to an Angle_Erad type

   subtype Mode_PO is Mode_PO_Pack.Shared_Data (Config.Protected_Object_Prio);
   --  Provides mutually exclusive access to a Mode type

end AMC_Types_PO;
