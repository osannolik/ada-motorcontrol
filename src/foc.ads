with AMC_Types; use AMC_Types;

package FOC is
   --  Field Oriented Control

   function Calculate_Voltage
   --  Calculates the requested inverter phase voltages as per the
   --  FOC algorithm.
      (Iabc          : Abc;
       --  Measured phase currents

       I_Set_Point   : Dq;
       --  Requested current setpoint in the Dq-frame

       Current_Angle : Angle_Rad;
       --  Stator-rotor electrical angle in radians

       Vbus          : Voltage_V;
       --  DC bus voltage

       Vmax          : Voltage_V;
       --  Maximum allowed phase to neutral voltage

       Period        : Seconds)
       --  Time since last execution
       return Abc;

end FOC;