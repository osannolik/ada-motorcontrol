with AMC_Types; use AMC_Types;

package FOC is
   --  Field Oriented Control

   function Calculate_Voltage (Iabc : Abc;
                               I_Set_Point : Dq;
                               Current_Angle : Angle_Rad;
                               Vbus : Voltage_V)
                               return Abc;

end FOC;
