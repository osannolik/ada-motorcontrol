with STM32.Timers;
with STM32.Device;

package AMC.Encoder is
   --  Quadrature Encoder
   --  Interfaces the mcu timer peripheral

   PPR : constant Positive := 2048;

   type Object is tagged limited record
      Initialized        : Boolean := False;
   end record;

   function Is_Initialized (This : Object)
      return Boolean;

   procedure Initialize
      (This : in out Object);

   function Get_Counter (This : in Object) return UInt32;

   function Get_Angle (This : in Object) return AMC_Types.Angle_Rad;

   function Get_Angle (This : in Object) return AMC_Types.Angle_Deg;

   function Get_Angle (This : in Object) return AMC_Types.Angle;

   function Get_Direction (This : in Object) return Float;

private

   Counting_Timer : STM32.Timers.Timer renames STM32.Device.Timer_4;

   Counts_Per_Revolution : constant Float := 4.0 * Float (PPR);
   --  x4 due to counting at all pulse edges

end AMC.Encoder;
