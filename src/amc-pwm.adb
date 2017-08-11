with AMC.Board;
with AMC.Config;
with STM32.Device;

package body AMC.PWM is

   function Deadtime_Value (Timer : STM32.Timers.Timer;
                            Time  : AMC_Types.Seconds)
                            return Uint8;
   --  Returns the DTG bit-field for timer register BDTR such that
   --  the requested deadtime Time is obtained.
   --  Please refer to STM32F4 reference manual for details.

   procedure Initialize_Gate
      (This       : in out Object;
       Gate       : Gates;
       Channel    : STM32.Timers.Timer_Channel;
       Pin_H      : STM32.GPIO.GPIO_Point;
       Pin_L      : STM32.GPIO.GPIO_Point;
       Pin_AF     : STM32.GPIO_Alternate_Function;
       Polarity   : STM32.Timers.Timer_Output_Compare_Polarity
          := STM32.Timers.High;
       Idle_State : STM32.Timers.Timer_Capture_Compare_State
          := STM32.Timers.Disable)
   is
      use STM32.Timers;
   begin
      This.Gates(Gate).Channel := Channel;

      if Complementary_Outputs_Supported (This    => This.Generator.all,
                                          Channel => Channel)
      then
         This.Gates(Gate).Modulator.Attach_PWM_Channel
            (Generator                => This.Generator,
             Channel                  => Channel,
             Point                    => Pin_H,
             Complementary_Point      => Pin_L,
             PWM_AF                   => Pin_AF,
             Polarity                 => Polarity,
             Idle_State               => Idle_State,
             Complementary_Polarity   => Polarity,
             Complementary_Idle_State => Idle_State);
      else
         This.Gates(Gate).Modulator.Attach_PWM_Channel
            (Generator => This.Generator,
             Channel   => Channel,
             Point     => Pin_H,
             PWM_AF    => Pin_AF,
             Polarity  => Polarity);
      end if;

      Set_Output_Preload_Enable (This    => This.Generator.all,
                                 Channel => Channel,
                                 Enabled => True);
   end Initialize_Gate;

   procedure Initialize_Gate
      (This       : in out Object;
       Gate       : Gates;
       Channel    : STM32.Timers.Timer_Channel;
       Polarity   : STM32.Timers.Timer_Output_Compare_Polarity
          := STM32.Timers.High;
       Idle_State : STM32.Timers.Timer_Capture_Compare_State
          := STM32.Timers.Disable)
   is
      use STM32.Timers;
   begin
      This.Gates(Gate).Channel := Channel;

      if Complementary_Outputs_Supported (This    => This.Generator.all,
                                          Channel => Channel)
      then
         This.Gates(Gate).Modulator.Attach_PWM_Channel
            (Generator                => This.Generator,
             Channel                  => Channel,
             Polarity                 => Polarity,
             Idle_State               => Idle_State,
             Complementary_Polarity   => Polarity,
             Complementary_Idle_State => Idle_State);
      else
         This.Gates(Gate).Modulator.Attach_PWM_Channel
            (Generator => This.Generator,
             Channel   => Channel,
             Polarity  => Polarity);
      end if;
   end Initialize_Gate;

   procedure Initialize
      (This      : in out Object;
       Generator : not null access STM32.Timers.Timer;
       Frequency : AMC_Types.Frequency_Hz;
       Deadtime  : AMC_Types.Seconds;
       Alignment : Pulse_Alignment)
   is
      use STM32.Timers;
      Counter_Mode : constant Timer_Counter_Alignment_Mode :=
         (case Alignment is
             when Edge   => Up,
             when Center => Center_Aligned3);
   begin
      This.Generator := Generator;

      STM32.PWM.Configure_PWM_Timer (Generator    => Generator,
                                     Frequency    => UInt32(Frequency),
                                     Counter_Mode => Counter_Mode);

      --  TODO: Make inactive state configurable.
      Configure_BDTR (This                          => Generator.all,
                      Automatic_Output_Enabled      => False,
                      Break_Polarity                => High,
                      Break_Enabled                 => True,
                      Off_State_Selection_Run_Mode  => 0,
                      Off_State_Selection_Idle_Mode => 0,
                      Lock_Configuration            => Level_1,
                      Deadtime_Generator            => Deadtime_Value(AMC.Board.PWM_Timer,
                                                                      Deadtime));

      Enable_Interrupt (This   => AMC.Board.PWM_Timer,
                        Source => Timer_Break_Interrupt);

      This.Initialized := True;
   end Initialize;

   procedure Enable
      (This : in out Object;
       Gate : Gates)
   is
   begin
      if STM32.Timers.Complementary_Outputs_Supported
         (This    => This.Generator.all,
          Channel => This.Gates(Gate).Channel)
      then
         This.Gates(Gate).Modulator.Enable_Complementary_Output;
      end if;

      This.Gates(Gate).Modulator.Enable_Output;
   end Enable;

   procedure Disable
      (This : in out Object;
       Gate : Gates)
   is
   begin
      if STM32.Timers.Complementary_Outputs_Supported
         (This    => This.Generator.all,
          Channel => This.Gates(Gate).Channel)
      then
         This.Gates(Gate).Modulator.Disable_Complementary_Output;
      end if;
      This.Gates(Gate).Modulator.Disable_Output;
   end Disable;

   function Get_Duty_Resolution
      (This : in out Object)
       return AMC_Types.Duty_Cycle
   is
      use STM32.Timers;
   begin
      return AMC_Types.Duty_Cycle
         (100.0 / Float(Current_Autoreload (This.Generator.all)));
   end Get_Duty_Resolution;

   procedure Set_Duty_Cycle
      (This  : in out Object;
       Gate  : Gates;
       Value : AMC_Types.Duty_Cycle)
   is
      use STM32.Timers;
      CCR : constant UInt16 :=
         UInt16(Value * Float(Current_Autoreload (This.Generator.all)) / 100.0);
   begin
      Set_Compare_Value
         (This    => This.Generator.all,
          Channel => This.Gates(Gate).Channel,
          Value   => CCR);
   end Set_Duty_Cycle;

   procedure Generate_Break_Event (This : Object) is
   begin
      STM32.Timers.Generate_Event (This.Generator.all, STM32.Timers.Event_Source_Break);
   end Generate_Break_Event;

   function Is_Initialized (This : Object)
      return Boolean is (This.Initialized);

   function Deadtime_Value (Timer : STM32.Timers.Timer;
                            Time  : AMC_Types.Seconds)
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
         T_DTS         : constant AMC_Types.Seconds :=
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
