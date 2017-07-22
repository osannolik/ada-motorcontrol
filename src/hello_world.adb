with Ada.Real_Time; use Ada.Real_Time;

with STM32.GPIO;    use STM32.GPIO;
with STM32.Device;  use STM32.Device;

package body Hello_World is

   Led_Red   : GPIO_Point := PC10;
   Led_Green : GPIO_Point := PB10;

   procedure Initialize_LEDs;

   procedure Initialize_LEDs is
      Configuration : GPIO_Port_Configuration;
   begin
      declare
         All_Leds : constant GPIO_Points := (Led_Red, Led_Green);
      begin
         Enable_Clock (All_Leds);

         Configuration.Mode        := Mode_Out;
         Configuration.Output_Type := Push_Pull;
         Configuration.Speed       := Speed_100MHz;
         Configuration.Resistors   := Floating;
         Configure_IO (All_Leds, Configuration);
      end;
   end Initialize_LEDs;

   task body Blinker is
      Period       : constant Time_Span := Milliseconds (500);
      Next_Release : Time := Clock;
   begin
      Initialize_LEDs;

      Set (Led_Red);

      loop
         Toggle (Led_Red);
         Toggle (Led_Green);

         Next_Release := Next_Release + Period;
         delay until Next_Release;
      end loop;
   end Blinker;

end Hello_World;
