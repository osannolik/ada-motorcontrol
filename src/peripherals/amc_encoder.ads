with STM32.Timers;
with STM32.Device;
with STM32.GPIO;
with AMC_Types;
with AMC_Board;

package AMC_Encoder is
   --  Quadrature Encoder
   --  Interfaces the mcu timer peripheral

   function Is_Initialized return Boolean;

   procedure Initialize;

   function Get_Counter return AMC_Types.UInt32;

   function Get_Angle return AMC_Types.Angle_Rad;
   --  Returns an angle related to mechanical rotations, i.e. it is not
   --  compensated for the motor's pole pairs

   function Get_Angle return AMC_Types.Angle_Deg;
   --  Returns an angle related to mechanical rotations, i.e. it is not
   --  compensated for the motor's pole pairs

   function Get_Angle return AMC_Types.Angle;
   --  Returns an angle related to mechanical rotations, i.e. it is not
   --  compensated for the motor's pole pairs

   procedure Set_Angle (Angle : in AMC_Types.Angle_Rad);
   --  Define the current sensor position as the specified angle

   function Get_Direction  return Float;

private

   Initialized : Boolean := False;

   PPR : constant Positive := 2048;

   Input_Pins : constant STM32.GPIO.GPIO_Points :=
      (AMC_Board.Encoder_A_Pin, AMC_Board.Encoder_B_Pin);

   Counting_Timer : STM32.Timers.Timer renames STM32.Device.Timer_4;

   Counts_Per_Revolution : constant Float := 4.0 * Float (PPR);
   --  x4 due to counting at all pulse edges

end AMC_Encoder;
