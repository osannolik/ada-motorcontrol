with AMC.Board;
with AMC.Config;
with AMC.Types;
with STM32.Device;
with STM32.Timers;

package body AMC.PWM is

   function Deadtime_Value (Timer : STM32.Timers.Timer;
                            Time  : AMC.Types.Seconds)
                            return Uint8;
   --  Returns the DTG bit-field for timer register BDTR such that
   --  the requested deadtime Time is obtained.
   --  Please refer to STM32F4 reference manual for details.

   procedure Initialize
   is
      use STM32.Timers;

      Polarity : constant Timer_Output_Compare_Polarity := High;
      Idle_State : constant Timer_Capture_Compare_State := Disable;
   begin
      STM32.PWM.Configure_PWM_Timer (Generator => AMC.Board.PWM_Timer'Access,
                                     Frequency => UInt32(AMC.Config.PWM_Frequency_Hz));

      PWM_A.Attach_PWM_Channel (Generator                => AMC.Board.PWM_Timer'Access,
                                Channel                  => AMC.Board.PWM_Gate_A_Ch,
                                Point                    => AMC.Board.PWM_Gate_H_A_Pin,
                                Complementary_Point      => AMC.Board.PWM_Gate_L_A_Pin,
                                PWM_AF                   => AMC.Board.PWM_Gate_GPIO_AF,
                                Polarity                 => Polarity,
                                Idle_State               => Idle_State,
                                Complementary_Polarity   => Polarity,
                                Complementary_Idle_State => Idle_State);

      PWM_B.Attach_PWM_Channel (Generator                => AMC.Board.PWM_Timer'Access,
                                Channel                  => AMC.Board.PWM_Gate_B_Ch,
                                Point                    => AMC.Board.PWM_Gate_H_B_Pin,
                                Complementary_Point      => AMC.Board.PWM_Gate_L_B_Pin,
                                PWM_AF                   => AMC.Board.PWM_Gate_GPIO_AF,
                                Polarity                 => Polarity,
                                Idle_State               => Idle_State,
                                Complementary_Polarity   => Polarity,
                                Complementary_Idle_State => Idle_State);

      PWM_C.Attach_PWM_Channel (Generator                => AMC.Board.PWM_Timer'Access,
                                Channel                  => AMC.Board.PWM_Gate_C_Ch,
                                Point                    => AMC.Board.PWM_Gate_H_C_Pin,
                                Complementary_Point      => AMC.Board.PWM_Gate_L_C_Pin,
                                PWM_AF                   => AMC.Board.PWM_Gate_GPIO_AF,
                                Polarity                 => Polarity,
                                Idle_State               => Idle_State,
                                Complementary_Polarity   => Polarity,
                                Complementary_Idle_State => Idle_State);

      Configure_BDTR (This                          => AMC.Board.PWM_Timer,
                      Automatic_Output_Enabled      => False,
                      Break_Polarity                => High,
                      Break_Enabled                 => True,
                      Off_State_Selection_Run_Mode  => 0,
                      Off_State_Selection_Idle_Mode => 0,
                      Lock_Configuration            => Level_1,
                      Deadtime_Generator            => Deadtime_Value(AMC.Board.PWM_Timer,
                                                                      AMC.Config.PWM_Gate_Deadtime_S));

      Enable_Interrupt (This   => AMC.Board.PWM_Timer,
                        Source => Timer_Break_Interrupt);

      PWM_A.Enable_Output;
      PWM_A.Enable_Complementary_Output;

      PWM_B.Enable_Output;
      PWM_B.Enable_Complementary_Output;

      PWM_C.Enable_Output;
      PWM_C.Enable_Complementary_Output;

      PWM_A.Set_Duty_Cycle (50);
      PWM_B.Set_Duty_Cycle (50);
      PWM_C.Set_Duty_Cycle (50);

      Initialized := True;
   end Initialize;

   procedure Generate_Break_Event is
   begin
      STM32.Timers.Generate_Event (AMC.Board.PWM_Timer, STM32.Timers.Event_Source_Break);
   end Generate_Break_Event;

   function Is_Initialized
      return Boolean is (Initialized);

   function Deadtime_Value (Timer : STM32.Timers.Timer;
                            Time  : AMC.Types.Seconds)
                            return Uint8
   is
      use STM32.Timers;

      Clock_Divisor   : Float;
      Timer_Frequency : UInt32;
      Clocks          : constant STM32.Device.RCC_System_Clocks := STM32.Device.System_Clock_Frequencies;
   begin

      if STM32.Device.Has_APB1_Frequency (Timer) then
         Timer_Frequency := Clocks.TIMCLK1;
      else
         Timer_Frequency := Clocks.TIMCLK2;
      end if;

      Clock_Divisor := (case Current_Clock_Division(Timer) is
                           when Div1 => 1.0,
                           when Div2 => 2.0,
                           when Div4 => 4.0);

      declare
         Tmp           : Float;
         T_DTS         : constant AMC.Types.Seconds :=
           Clock_Divisor / Float(Timer_Frequency);
         S_To_Ns       : constant Float := 1.0e+9;
         DT_Max_Factor : constant array(0 .. 3) of Float :=
           (2.0**7-1.0, (64.0+2.0**6-1.0)*2.0, (32.0+2.0**5-1.0)*8.0, (32.0+2.0**5-1.0)*16.0);
      begin
         for I in DT_Max_Factor'Range loop
            if Time <= DT_Max_Factor(I) * T_DTS then
               case I is
                  when 0 =>
                     Tmp := Time/T_DTS;
                     return UInt8(UInt7(Tmp));

                  when 1 =>
                     Tmp := Time/T_DTS/2.0 - 64.0;
                     return 16#80# + UInt8(UInt6(Tmp));

                  when 2 =>
                     Tmp := Time/T_DTS/8.0 - 32.0;
                     return 16#C0# + UInt8(UInt5(Tmp));

                  when 3 =>
                     Tmp := Time/T_DTS/16.0 - 32.0;
                     return 16#E0# + UInt8(UInt5(Tmp));
               end case;
            end if;
         end loop;
      end;

      return 0;
   end Deadtime_Value;


   protected body Break is

      procedure Break_ISR is
      begin
         STM32.Timers.Clear_Pending_Interrupt (AMC.Board.PWM_Timer, STM32.Timers.Timer_Break_Interrupt);
      end Break_ISR;

   end Break;

end AMC.PWM;
