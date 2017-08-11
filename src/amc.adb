with Ada.Real_Time; use Ada.Real_Time;

with AMC.Board;
with AMC.Config;
with AMC.ADC;
with AMC.PWM;

pragma Elaborate(AMC.Board);
pragma Elaborate(AMC.PWM);
pragma Elaborate(AMC.ADC);





package body AMC is

   ADC_Peripheral : AMC.ADC.Object;
   PWM_Peripheral : AMC.PWM.Object;

   My_Dq : Dq_Voltage_Package.Dq;
   My_Dq_2 : Dq_Voltage_Package.Dq;

   My_Abc : Abc_Voltage_Package.Abc;

   procedure Initialize
   is
   begin

      My_Dq := (D=>0.0,Q=>0.0);
      My_Dq_2 := (D=>1.0,Q=>-1.0);

      My_Abc := Abc_Voltage_Package.Abc'(A => 1.0,
                                         B => 2.0,
                                         C => 3.0);

      declare
         use Dq_Voltage_Package;
         use Abc_Voltage_Package;
         Mag : constant Float := My_Dq_2.Magnitude;
         Mag_Abc : constant Float := My_Abc.Magnitude;
      begin
         My_Abc := 2.0 * My_Abc;
         My_Abc := My_Abc * 0.5;
         My_Abc := My_Abc + My_Abc;
         My_Abc := My_Abc - My_Abc;
         My_Abc.Normalize;

         My_Dq := My_Dq + My_Dq_2;
         My_Dq.Normalize;
         My_Dq := 2.0 * My_Dq;
         My_Dq := My_Dq * 0.5;
         My_Dq := My_Dq - My_Dq_2;
      end;

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
                                     Value => PWM_Peripheral.Get_Duty_Resolution);

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
         begin
            null;
         end;

         Inverter_System_Outputs.Idq_CC_Request.Set (Value => (Iq => 0.0,
                                                               Id => 0.0));

         Next_Release := Next_Release + Period;
         delay until Next_Release;
      end loop;
   end Inverter_System;

   task body Current_Control is
      Idq_Sp : AMC_Types.Idq;
      Samples : AMC.ADC.Injected_Samples_Array := (others => 0.0);
   begin
      loop
         AMC.ADC.Handler.Await_New_Samples (Injected_Samples => Samples);

         Idq_Sp := Inverter_System_Outputs.Idq_CC_Request.Get;

         AMC.Board.Turn_Off (AMC.Board.Led_Green);
      end loop;
   end Current_Control;

begin

   Initialize;

end AMC;
