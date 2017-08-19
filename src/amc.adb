with Ada.Real_Time; use Ada.Real_Time;
with AMC_Types; use AMC_Types;

with AMC_Board;
with AMC_ADC;
with AMC_PWM;
with AMC_Encoder;

with Current_Control; pragma Unreferenced (Current_Control);
with AMC_Utils;
with Position;

package body AMC is

   task body Inverter_System is
      Period : constant Time_Span :=
         Milliseconds (Config.Inverter_System_Period_Ms);
      Next_Release : Time := Clock;
      M : Float := 0.0 with Volatile; pragma Unreferenced (M);
      A : Angle_Deg := 0.0 with Volatile; pragma Unreferenced (A);
   begin

      A := Position.Wrap_To_180 (0.0);
      A := Position.Wrap_To_180 (10.0);
      A := Position.Wrap_To_180 (180.0);
      A := Position.Wrap_To_180 (181.0);
      A := Position.Wrap_To_180 (360.0);
      A := Position.Wrap_To_180 (361.0);
      A := Position.Wrap_To_180 (-10.0);
      A := Position.Wrap_To_180 (-180.0);
      A := Position.Wrap_To_180 (-181.0);
      A := Position.Wrap_To_180 (-360.0);
      A := Position.Wrap_To_180 (-361.0);

      M := AMC_Utils.Fmod (X => 0.0,
                           Y => 360.0);

      M := AMC_Utils.Fmod (X => 10.0,
                           Y => 360.0);

      M := AMC_Utils.Fmod (X => 350.0,
                           Y => 360.0);

      M := AMC_Utils.Fmod (X => 360.0,
                           Y => 360.0);

      M := AMC_Utils.Fmod (X => 370.0,
                           Y => 360.0);


      M := AMC_Utils.Fmod (X => -10.0,
                           Y => 360.0);

      M := AMC_Utils.Fmod (X => -350.0,
                           Y => 360.0);

      M := AMC_Utils.Fmod (X => -360.0,
                           Y => 360.0);

      M := AMC_Utils.Fmod (X => -370.0,
                           Y => 360.0);

      AMC_Board.Turn_Off (AMC_Board.Led_Red);
      AMC_Board.Turn_Off (AMC_Board.Led_Green);

      loop
         AMC_Board.Set_Gate_Driver_Power
            (Enabled => AMC_Board.Is_Pressed (AMC_Board.User_Button));

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
