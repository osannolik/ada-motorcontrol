with AMC_Utils;

package Position.Alignment is

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

   procedure Align_To_Sensor_Update (Alignment         : in out Alignment_Data;
                                     Period            : in Seconds;
                                     To_Angle          : out Angle;
                                     Current_Set_Point : out Space_Vector);

end Position.Alignment;
