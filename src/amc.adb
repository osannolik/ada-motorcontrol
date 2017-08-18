with Ada.Real_Time; use Ada.Real_Time;

with AMC_Board;
with Config;
with AMC_ADC;
with AMC_PWM;
with AMC_Encoder;

with Current_Control;

package body AMC is

   task body Inverter_System is
      Period : constant Time_Span :=
         Milliseconds (Config.Inverter_System_Period_Ms);
      Next_Release : Time := Clock;

   begin

      AMC_Board.Turn_Off (AMC_Board.Led_Red);
      AMC_Board.Turn_Off (AMC_Board.Led_Green);

      loop
         AMC_Board.Set_Gate_Driver_Power
            (Enabled => AMC_Board.Is_Pressed (AMC_Board.User_Button));

         declare
            Bat_Sense_Data  : AMC_Types.Voltage_V :=
               AMC_ADC.Get_Sample (AMC_ADC.Bat_Sense);
            Board_Temp_Data : AMC_Types.Voltage_V :=
               AMC_ADC.Get_Sample (AMC_ADC.Board_Temp);
            BT : AMC_Types.Temperature_DegC :=
               AMC_Board.To_Board_Temp (Board_Temp_Data);

            Encoder_Counter : UInt32 := AMC_Encoder.Get_Counter;

            Encoder_Angle : AMC_Types.Angle_Rad := AMC_Encoder.Get_Angle;

            Encoder_Dir : Float := AMC_Encoder.Get_Direction;
         begin
            null;
         end;

         Inverter_System_Outputs.Vbus.Set
            (Value => AMC_Board.To_Vbus
                (ADC_Voltage => AMC_ADC.Get_Sample (AMC_ADC.Bat_Sense)));

         Inverter_System_Outputs.Idq_CC_Request.Set (Value => (D => 0.0,
                                                               Q => 0.0));

         Next_Release := Next_Release + Period;
         delay until Next_Release;
      end loop;
   end Inverter_System;


   procedure Safe_State is
   begin
      AMC_PWM.Generate_Break_Event;
      AMC_Board.Set_Gate_Driver_Power (Enabled => False);
   end Safe_State;


   procedure Initialize
   is
   begin

      AMC_Board.Initialize;

      AMC_Encoder.Initialize;

      AMC_ADC.Initialize;

      AMC_PWM.Initialize (Frequency => Config.PWM_Frequency_Hz,
                                 Deadtime  => Config.PWM_Gate_Deadtime_S,
                                 Alignment => AMC_Types.Center);

      AMC_PWM.Set_Duty_Cycle (Dabc => AMC_Types.Abc'(A => 50.0,
                                                     B => 50.0,
                                                     C => 50.0));

      AMC_PWM.Set_Trigger_Cycle (AMC_PWM.Get_Duty_Resolution);

      AMC_PWM.Enable (AMC_Types.A);
      AMC_PWM.Enable (AMC_Types.B);
      AMC_PWM.Enable (AMC_Types.C);

      Initialized :=
         AMC_Board.Is_Initialized and
         AMC_ADC.Is_Initialized and
         AMC_PWM.Is_Initialized and
         AMC_Encoder.Is_Initialized;

   end Initialize;


   function Is_Initialized
      return Boolean is (Initialized);

begin

   Initialize;

end AMC;
