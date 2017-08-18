with STM32.Timers;
with STM32.Device;
with AMC_Types;

package AMC_Encoder is
   --  Quadrature Encoder
   --  Interfaces the mcu timer peripheral

   function Is_Initialized return Boolean;

   procedure Initialize;

   function Get_Counter return AMC_Types.UInt32;

   function Get_Angle return AMC_Types.Angle_Rad;

   function Get_Angle return AMC_Types.Angle_Deg;

   function Get_Angle return AMC_Types.Angle;

   function Get_Direction  return Float;

private

   Initialized : Boolean := False;

   PPR : constant Positive := 2048;

   Counting_Timer : STM32.Timers.Timer renames STM32.Device.Timer_4;

   Counts_Per_Revolution : constant Float := 4.0 * Float (PPR);
   --  x4 due to counting at all pulse edges

end AMC_Encoder;
