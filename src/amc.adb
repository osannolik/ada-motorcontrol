with Ada.Real_Time; use Ada.Real_Time;

with AMC.Board;
with AMC.Config;
with AMC.Types;
with AMC.ADC;
with AMC.PWM;

pragma Elaborate(AMC.Board);
pragma Elaborate(AMC.PWM);
pragma Elaborate(AMC.ADC);

package body AMC is

   ADC_Peripheral : AMC.ADC.Object;
   PWM_Peripheral : AMC.PWM.Object;

   procedure Initialize
   is
   begin
      AMC.Board.Initialize;

      ADC_Peripheral.Initialize;

      PWM_Peripheral.Initialize (Generator => AMC.Board.PWM_Timer'Access,
                                 Frequency => AMC.Config.PWM_Frequency_Hz,
                                 Deadtime  => AMC.Config.PWM_Gate_Deadtime_S,
                                 Alignment => AMC.PWM.Center);

      PWM_Peripheral.Initialize_Gate (Gate    => AMC.PWM.Gate_A,
                                      Channel => AMC.Board.PWM_Gate_A_Ch,
                                      Pin_H   => AMC.Board.PWM_Gate_H_A_Pin,
                                      Pin_L   => AMC.Board.PWM_Gate_L_A_Pin,
                                      Pin_AF  => AMC.Board.PWM_Gate_GPIO_AF);

      PWM_Peripheral.Initialize_Gate (Gate    => AMC.PWM.Gate_B,
                                      Channel => AMC.Board.PWM_Gate_B_Ch,
                                      Pin_H   => AMC.Board.PWM_Gate_H_B_Pin,
                                      Pin_L   => AMC.Board.PWM_Gate_L_B_Pin,
                                      Pin_AF  => AMC.Board.PWM_Gate_GPIO_AF);

      PWM_Peripheral.Initialize_Gate (Gate    => AMC.PWM.Gate_C,
                                      Channel => AMC.Board.PWM_Gate_C_Ch,
                                      Pin_H   => AMC.Board.PWM_Gate_H_C_Pin,
                                      Pin_L   => AMC.Board.PWM_Gate_L_C_Pin,
                                      Pin_AF  => AMC.Board.PWM_Gate_GPIO_AF);

      PWM_Peripheral.Initialize_Gate (Gate    => AMC.PWM.Sample_Trigger,
                                      Channel => AMC.Board.PWM_Trigger_Ch);

      PWM_Peripheral.Set_Duty_Cycle (Gate  => AMC.PWM.Gate_A,
                                     Value => 50.0);

      PWM_Peripheral.Set_Duty_Cycle (Gate  => AMC.PWM.Gate_B,
                                     Value => 50.0);

      PWM_Peripheral.Set_Duty_Cycle (Gate  => AMC.PWM.Gate_C,
                                     Value => 50.0);

      PWM_Peripheral.Set_Duty_Cycle (Gate  => AMC.PWM.Sample_Trigger,
                                     Value => 1.0);

      PWM_Peripheral.Enable (Gate => AMC.PWM.Gate_A);
      PWM_Peripheral.Enable (Gate => AMC.PWM.Gate_B);
      PWM_Peripheral.Enable (Gate => AMC.PWM.Gate_C);

      PWM_Peripheral.Enable (Gate => AMC.PWM.Sample_Trigger);

      Initialized :=
        AMC.Board.Is_Initialized and
        ADC_Peripheral.Is_Initialized and
        PWM_Peripheral.Is_Initialized;
        --  and AMC.Child.Is_initialized;

   end Initialize;

   procedure Safe_State is
   begin
      PWM_Peripheral.Generate_Break_Event;
      AMC.Board.Set_Gate_Driver_Power (Enabled => False);
   end Safe_State;


   function Is_Initialized
      return Boolean is (Initialized);

   task body Inverter_System is
      Period       : constant Time_Span := Milliseconds (100);
      Next_Release : Time := Clock;
   begin

      AMC.Board.Turn_Off (AMC.Board.Led_Red);
      AMC.Board.Turn_Off (AMC.Board.Led_Green);

      loop
         AMC.Board.Set_Gate_Driver_Power
            (Enabled => AMC.Board.Is_Pressed (AMC.Board.User_Button));

         if AMC.Board.Is_Pressed (AMC.Board.User_Button) then
            --  AMC.Board.Turn_On (AMC.Board.Led_Red);
            --  AMC.Board.Turn_Off (AMC.Board.Led_Green);
            null;
         else
            --  AMC.Board.Turn_Off (AMC.Board.Led_Red);
            --  AMC.Board.Turn_On (AMC.Board.Led_Green);
            null;
         end if;

         Next_Release := Next_Release + Period;
         delay until Next_Release;
      end loop;
   end Inverter_System;

   task body Sampler is
      Dummy_Stuff : Boolean := False;
      Samples : AMC.ADC.Injected_Samples_Array := (others => 0);
      Bat_Sense_Data : UInt16 := 0;
      Board_Temp_Data : UInt16 := 0;
   begin
      loop
         AMC.ADC.Handler.Await_New_Samples (Injected_Samples => Samples);

         AMC.Board.Turn_Off (AMC.Board.Led_Green);

         Bat_Sense_Data := AMC.ADC.Get_Sample (AMC.ADC.Bat_Sense);
         Board_Temp_Data := AMC.ADC.Get_Sample (AMC.ADC.Board_Temp);

         Dummy_Stuff := not Dummy_Stuff;
--           if Dummy_Stuff then
--              AMC.PWM.Set_Duty_Cycle (AMC.PWM_Peripheral,
--                                      Gate  => AMC.PWM.Gate_C,
--                                      Value => 50.0);
--           else
--              AMC.PWM.Set_Duty_Cycle (AMC.PWM_Peripheral,
--                                      Gate  => AMC.PWM.Gate_C,
--                                      Value => 75.0);
--           end if;

      end loop;
   end Sampler;

begin

   Initialize;

end AMC;
