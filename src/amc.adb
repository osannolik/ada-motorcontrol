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

   ADC_Peripheral : AMC.ADC.Object;
   PWM_Peripheral : AMC.PWM.Object;
   ENC_Peripheral : AMC.Encoder.Object;


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

            Encoder_Counter : UInt32 := ENC_Peripheral.Get_Counter;

            Encoder_Angle : AMC_Types.Angle_Rad := ENC_Peripheral.Get_Angle;

            Encoder_Dir : Float := ENC_Peripheral.Get_Direction;
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

      Samples    : AMC.ADC.Injected_Samples_Array := (others => 0.0);
      Vbus       : Voltage_V;
      Iabc_Raw   : Abc;
      V_Ctrl_Abc : Abc;
      Duty       : Abc;
      --  Vabc_Raw : Abc;
   begin

      delay until Clock + Milliseconds(10);

      loop
         AMC.ADC.Handler.Await_New_Samples (Injected_Samples => Samples);

         AMC.Board.Turn_On (AMC.Board.Led_Green);

--           Vabc_Raw := AMC.Board.To_Voltages_Abc
--              (ADC_Voltage_A => Samples (AMC.ADC.EMF_A),
--               ADC_Voltage_B => Samples (AMC.ADC.EMF_B),
--               ADC_Voltage_C => Samples (AMC.ADC.EMF_C));

         Iabc_Raw := AMC.Board.To_Currents_Abc
            (ADC_Voltage_A => Samples (AMC.ADC.I_A),
             ADC_Voltage_B => Samples (AMC.ADC.I_B),
             ADC_Voltage_C => Samples (AMC.ADC.I_C));

         Vbus := Inverter_System_Outputs.Vbus.Get;

         V_Ctrl_Abc := FOC.Calculate_Voltage
            (Iabc          => Iabc_Raw,
             I_Set_Point   => Inverter_System_Outputs.Idq_CC_Request.Get,
             Current_Angle => ENC_Peripheral.Get_Angle,
             Vbus          => Vbus,
             Vmax          => 0.5*Vbus*ZSM.Modulation_Index_Max(ZSM.Sinusoidal),
             Period        => Nominal_Period_s);

         --  Convert to corresponding duty cycle value, zsm etc
         Duty := (100.0 / Vbus) * V_Ctrl_Abc + (50.0, 50.0, 50.0);
         Duty := ZSM.Sinusoidal (Duty);


         PWM_Peripheral.Set_Duty_Cycle (Dabc => Duty);

         AMC.Board.Turn_Off (AMC.Board.Led_Green);

      end loop;
   end Current_Control;

   procedure Initialize
   is
   begin

      AMC.Board.Initialize;

      ENC_Peripheral.Initialize;

      ADC_Peripheral.Initialize;

      PWM_Peripheral.Initialize (Frequency => AMC.Config.PWM_Frequency_Hz,
                                 Deadtime  => AMC.Config.PWM_Gate_Deadtime_S,
                                 Alignment => AMC_Types.Center);

      PWM_Peripheral.Set_Duty_Cycle (Dabc => AMC_Types.Abc'(A => 50.0,
                                                            B => 50.0,
                                                            C => 50.0));

      PWM_Peripheral.Set_Trigger_Cycle (PWM_Peripheral.Get_Duty_Resolution);

      PWM_Peripheral.Enable (AMC_Types.A);
      PWM_Peripheral.Enable (AMC_Types.B);
      PWM_Peripheral.Enable (AMC_Types.C);

      Initialized :=
         AMC.Board.Is_Initialized and
         ADC_Peripheral.Is_Initialized and
         PWM_Peripheral.Is_Initialized and
         ENC_Peripheral.Is_Initialized;
      --  and AMC.Child.Is_initialized;

   end Initialize;

   procedure Safe_State is
   begin
      PWM_Peripheral.Generate_Break_Event;
      AMC.Board.Set_Gate_Driver_Power (Enabled => False);
   end Safe_State;


   function Is_Initialized
      return Boolean is (Initialized);

begin

   Initialize;

end AMC;
