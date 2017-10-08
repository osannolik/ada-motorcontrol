with AMC;

package Current_Control.FOC is
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

   procedure Update (Phase_Currents : in Abc;
                     System_Outputs : in AMC.Inverter_System_States;
                     Duty           : out Abc);
   --  Calculates the requested inverter phase duty as per the FOC algorithm.

   --  @param Phase_Currents A three phase current
   --  @param System_Outputs Includes system variables such as the current set-point
   --  and the bus voltage etc.
   --  @param Duty A triplet of values representing the calculated duty cycles

end Current_Control.FOC;
