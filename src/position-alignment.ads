with AMC_Utils;

package Position.Alignment is
   --  @summary
   --  Alignment of sensor to stator
   --
   --  @description
   --  Provides functionality to align the sensors to the stator/rotor reference frame.
   --
   --  - Hall: Map pin inputs to the corresponding hall sector.
   --  - Encoder: Define the sensor value that corresponds to the rotor angle.
   --

   type State_Type is (Not_Performed, Rotation, Probing, Done);

   type Alignment_Data (Sensor : AMC_Types.Position_Sensor) is record
      Timer   : AMC_Utils.Timer;
      Is_Done : Boolean := False;
      State   : State_Type := Not_Performed;

      case Sensor is
         when Hall =>
            To_Sector : Hall_Sector := Hall_Sector'First;

         when None | Encoder =>
            null;
      end case;
   end record;

   function Is_Done (Alignment : in Alignment_Data) return Boolean;
   --  Check if the alignment is done.
   --  @param Alignment Alignment data.
   --  @return True if done.

   procedure Align_To_Sensor_Update (Alignment         : in out Alignment_Data;
                                     Period            : in Seconds;
                                     To_Angle          : out Angle;
                                     Current_Set_Point : out Current_A);
   --  Handles the alignment. Should be called periodically until done.
   --  It outputs the angle to where the rotor should be fixed to, and the current
   --  to use.
   --  @param Alignment Keep track of current state etc.
   --  @param Period The time since last call, i.e. the call period.
   --  @param To_Angle The angle to force the rotor to. That is the caller's responsibility.
   --  @param Current_Set_Point Align the rotor using this maximum current.

end Position.Alignment;
