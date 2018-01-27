with STM32.Timers;
with STM32.GPIO;
with AMC_Types;
with AMC_Board;

package AMC_Encoder is
   --  @summary
   --  Quadrature Encoder
   --
   --  @description
   --  Interfaces the encoder using common AMC types.
   --

   function Is_Initialized return Boolean;
   --  @return True if initialized.

   procedure Initialize;
   --  Initialize the encoder, i.e. timer peripheral.

   function Get_Angle return AMC_Types.Angle_Rad;
   --  Get the angle related to mechanical rotations, i.e. it is not
   --  compensated for the motor's pole pairs
   --  @return Mechanical angle in radians.

   function Get_Angle return AMC_Types.Angle_Deg;
   --  Get the angle related to mechanical rotations, i.e. it is not
   --  compensated for the motor's pole pairs
   --  @return Mechanical angle in degrees.

   function Get_Angle return AMC_Types.Angle;
   --  Get the angle related to mechanical rotations, i.e. it is not
   --  compensated for the motor's pole pairs
   --  @return Mechanical angle object.

   procedure Set_Angle (Angle : in AMC_Types.Angle_Rad);
   --  Define the current sensor position as the specified angle.
   --  @param Angle Set angle in radians.

   function Get_Direction return Float;
   --  @return 1.0 if forward, else -1.0

private

   Initialized : Boolean := False;

   PPR : constant Positive := 2048;

   Input_Pins : constant STM32.GPIO.GPIO_Points :=
      (AMC_Board.Encoder_A_Pin, AMC_Board.Encoder_B_Pin);

   Counting_Timer : STM32.Timers.Timer renames AMC_Board.Pos_Timer;

   Counts_Per_Revolution : constant Float := 4.0 * Float (PPR);
   --  x4 due to counting at all pulse edges

end AMC_Encoder;
