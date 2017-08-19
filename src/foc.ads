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

       Current_Angle : Angle_Erad;
       --  Stator-rotor electrical angle in radians

       Vmax          : Voltage_V;
       --  Maximum allowed phase to neutral voltage

       Period        : Seconds)
       --  Time since last execution
       return Abc;

end FOC;
