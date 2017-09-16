with AMC_Types; use AMC_Types;

package FOC is
   --  @summary
   --  Field Oriented Control
   --
   --  @description
   --  Implements a controller using state vector representation.
   --
   --  The algorithm is divided into three parts:
   --
   --  - Transform the values into a rotor fixed reference frame.
   --    Uses Clarke Park transformation assuming a given stator-to-rotor angle
   --
   --  - Based on the requested current, calculate a new set of phase voltages
   --    Uses two PID controllers, one controlling the field flux linkage component
   --    (Id) and one controlling the torque component (Iq).
   --
   --  - Transform back to the stator's reference frame
   --    Uses Park Clarke transformation assuming a given stator-to-rotor angle
   --
   --  For more information, see https://en.wikipedia.org/wiki/Vector_control_(motor)
   --

   function Calculate_Voltage
      (Iabc          : Abc;
       I_Set_Point   : Dq;
       Current_Angle : Angle_Erad;
       Vmax          : Voltage_V;
       Period        : Seconds)
       return Abc;
   --  Calculates the requested inverter phase voltages as per the FOC algorithm.
   --  @param Iabc A three phase current
   --  @param I_Set_Point Current set-point given in a rotor fixed reference frame
   --  @param Current_Angle Stator-to-rotor fixed angle given in electrical radians
   --  @param Vmax Maximum allowed phase to neutral voltage
   --  @param Period Time since last execution
   --  @return A three phase voltage given in a stator fixed reference frame

end FOC;
