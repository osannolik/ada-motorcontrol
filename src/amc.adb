with Ada.Real_Time; use Ada.Real_Time;

with AMC.Board;
with AMC.Config;
with AMC.ADC;
with AMC.PWM;
with AMC.Encoder;

pragma Elaborate(AMC.Board);
pragma Elaborate(AMC.PWM);
pragma Elaborate(AMC.ADC);
pragma Elaborate(AMC.Encoder);

with FOC;
with ZSM;

package body AMC is

   task body Inverter_System is
      Period       : constant Time_Span := Milliseconds (Inverter_System_Period_Ms);
      Next_Release : Time := Clock;

   begin

      AMC.Board.Turn_Off (AMC.Board.Led_Red);
      AMC.Board.Turn_Off (AMC.Board.Led_Green);

      loop
         AMC.Board.Set_Gate_Driver_Power
            (Enabled => AMC.Board.Is_Pressed (AMC.Board.User_Button));

         declare
            Bat_Sense_Data  : AMC_Types.Voltage_V :=
               AMC.ADC.Get_Sample (AMC.ADC.Bat_Sense);
            Board_Temp_Data : AMC_Types.Voltage_V :=
               AMC.ADC.Get_Sample (AMC.ADC.Board_Temp);
            BT : AMC_Types.Temperature_DegC :=
               AMC.Board.To_Board_Temp (Board_Temp_Data);

            Encoder_Counter : UInt32 := AMC.Encoder.Get_Counter;

            Encoder_Angle : AMC_Types.Angle_Rad := AMC.Encoder.Get_Angle;

            Encoder_Dir : Float := AMC.Encoder.Get_Direction;
         begin
            null;
         end;

         Inverter_System_Outputs.Vbus.Set
            (Value => AMC.Board.To_Vbus
                (ADC_Voltage => AMC.ADC.Get_Sample (AMC.ADC.Bat_Sense)));

         Inverter_System_Outputs.Idq_CC_Request.Set (Value => (D => 0.0,
                                                               Q => 0.0));

         Next_Release := Next_Release + Period;
         delay until Next_Release;
      end loop;
   end Inverter_System;

   task body Current_Control is
      use AMC_Types;

      Nominal_Period_s  : constant AMC_Types.Seconds :=
         1.0 / AMC.Config.PWM_Frequency_Hz;

      V_Samples  : Abc;
      I_Samples  : Abc;
      Vbus       : Voltage_V;
      Iabc_Raw   : Abc;
      V_Ctrl_Abc : Abc;
      Duty       : Abc;
   begin

      delay until Clock + Milliseconds(10);

      loop
         AMC.ADC.Handler.Await_New_Samples
            (Phase_Voltage_Samples => V_Samples,
             Phase_Current_Samples => I_Samples);

         AMC.Board.Turn_On (AMC.Board.Led_Green);

         Iabc_Raw := AMC.Board.To_Phase_Currents (ADC_Voltage => I_Samples);

         Vbus := Inverter_System_Outputs.Vbus.Get;

         V_Ctrl_Abc := FOC.Calculate_Voltage
            (Iabc          => Iabc_Raw,
             I_Set_Point   => Inverter_System_Outputs.Idq_CC_Request.Get,
             Current_Angle => AMC.Encoder.Get_Angle,
             Vbus          => Vbus,
             Vmax          => 0.5*Vbus*ZSM.Modulation_Index_Max(ZSM.Sinusoidal),
             Period        => Nominal_Period_s);

         --  Convert to corresponding duty cycle value, zsm etc
         Duty := (100.0 / Vbus) * V_Ctrl_Abc + (50.0, 50.0, 50.0);
         Duty := ZSM.Sinusoidal (Duty);


         AMC.PWM.Set_Duty_Cycle (Dabc => Duty);

         AMC.Board.Turn_Off (AMC.Board.Led_Green);

      end loop;
   end Current_Control;

   procedure Initialize
   is
   begin

      AMC.Board.Initialize;

      AMC.Encoder.Initialize;

      AMC.ADC.Initialize;

      AMC.PWM.Initialize (Frequency => AMC.Config.PWM_Frequency_Hz,
                                 Deadtime  => AMC.Config.PWM_Gate_Deadtime_S,
                                 Alignment => AMC_Types.Center);

      AMC.PWM.Set_Duty_Cycle (Dabc => AMC_Types.Abc'(A => 50.0,
                                                     B => 50.0,
                                                     C => 50.0));

      AMC.PWM.Set_Trigger_Cycle (AMC.PWM.Get_Duty_Resolution);

      AMC.PWM.Enable (AMC_Types.A);
      AMC.PWM.Enable (AMC_Types.B);
      AMC.PWM.Enable (AMC_Types.C);

      Initialized :=
         AMC.Board.Is_Initialized and
         AMC.ADC.Is_Initialized and
         AMC.PWM.Is_Initialized and
         AMC.Encoder.Is_Initialized;
      --  and AMC.Child.Is_initialized;

   end Initialize;

   procedure Safe_State is
   begin
      AMC.PWM.Generate_Break_Event;
      AMC.Board.Set_Gate_Driver_Power (Enabled => False);
   end Safe_State;


   function Is_Initialized
      return Boolean is (Initialized);

begin

   Initialize;

end AMC;
