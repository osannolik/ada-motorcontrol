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

      Samples    : AMC.ADC.Injected_Samples_Array := (others => 0.0);
      Vbus       : Voltage_V;
      V_Ctrl_Abc : Abc;
      Duty       : Abc;
      --  Vabc_Raw : Abc;
   begin
      loop
         AMC.ADC.Handler.Await_New_Samples (Injected_Samples => Samples);

         AMC.Board.Turn_On (AMC.Board.Led_Green);

--           Vabc_Raw := AMC.Board.To_Voltages_Abc
--              (ADC_Voltage_A => Samples (AMC.ADC.EMF_A),
--               ADC_Voltage_B => Samples (AMC.ADC.EMF_B),
--               ADC_Voltage_C => Samples (AMC.ADC.EMF_C));

         Vbus := Inverter_System_Outputs.Vbus.Get;

         V_Ctrl_Abc := FOC.Calculate_Voltage
            (Iabc          => AMC.Board.To_Currents_Abc
                (ADC_Voltage_A => Samples (AMC.ADC.I_A),
                 ADC_Voltage_B => Samples (AMC.ADC.I_B),
                 ADC_Voltage_C => Samples (AMC.ADC.I_C)),
             I_Set_Point   => Inverter_System_Outputs.Idq_CC_Request.Get,
             Current_Angle => ENC_Peripheral.Get_Angle,
             Vbus          => Vbus);

         --  Convert to corresponding duty cycle value, zsm etc
         Duty := V_Ctrl_Abc + (50.0, 50.0, 50.0);
         Duty := ZSM.Sinusoidal (Duty);


         PWM_Peripheral.Set_Duty_Cycle (Gate  => AMC.PWM.Gate_A,
                                        Value => Duty.A);

         PWM_Peripheral.Set_Duty_Cycle (Gate  => AMC.PWM.Gate_B,
                                        Value => Duty.B);

         PWM_Peripheral.Set_Duty_Cycle (Gate  => AMC.PWM.Gate_C,
                                        Value => Duty.C);


         AMC.Board.Turn_Off (AMC.Board.Led_Green);

      end loop;
   end Current_Control;

   procedure Initialize
   is
   begin

      AMC.Board.Initialize;

      ENC_Peripheral.Initialize;

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
                                     Value => PWM_Peripheral.Get_Duty_Resolution);

      PWM_Peripheral.Enable (Gate => AMC.PWM.Gate_A);
      PWM_Peripheral.Enable (Gate => AMC.PWM.Gate_B);
      PWM_Peripheral.Enable (Gate => AMC.PWM.Gate_C);

      PWM_Peripheral.Enable (Gate => AMC.PWM.Sample_Trigger);

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
