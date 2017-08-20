with Ada.Real_Time; use Ada.Real_Time;

with AMC_Board;
with AMC_ADC;
with AMC_PWM;
with AMC_Encoder;

with Current_Control; pragma Unreferenced (Current_Control);

package body AMC is

   task body Inverter_System is
      Period : constant Time_Span :=
         Milliseconds (Config.Inverter_System_Period_Ms);
      Next_Release : Time := Clock;

      Mode            : Ctrl_Mode := Off;
      Alignment_Angle : Angle_Erad := 0.0;
      Vbus            : Voltage_V := 0.0;
      Idq_CC_Request  : Dq := Dq'(D => 0.0, Q => 0.0);
      Enable_Gates    : Boolean := False;
   begin

      AMC_Board.Turn_Off (AMC_Board.Led_Red);
      AMC_Board.Turn_Off (AMC_Board.Led_Green);

      loop
         --  Get inputs dependent upon
         Vbus := AMC_Board.To_Vbus (AMC_ADC.Get_Sample (AMC_ADC.Bat_Sense)); --  TODO: filter

         --  Update current Mode
         if AMC_Board.Is_Pressed (AMC_Board.User_Button) then
            Mode := Alignment;
         else
            Mode := Off;
         end if;

         --  Perform actions based on inputs and Mode
         case Mode is
            when Off | Normal =>
               Idq_CC_Request := Dq'(D => 0.0, Q => 0.0);
               Enable_Gates := False;

            when Alignment =>
               Alignment_Angle := 0.0;
               Idq_CC_Request := Dq'(D => 12.0, Q => 0.0);
               Enable_Gates := True;
         end case;

         --  Atomically, set the task's outputs
         Inverter_System_Outputs.Set
            ((Idq_CC_Request  => Idq_CC_Request,
              Vbus            => Vbus,
              Alignment_Angle => Alignment_Angle,
              Mode            => Mode));

         AMC_Board.Set_Gate_Driver_Power (Enable_Gates);

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

      Inverter_System_Outputs.Set
         ((Idq_CC_Request  => Dq'(0.0, 0.0),
           Vbus            => 0.0,
           Alignment_Angle => 0.0,
           Mode            => Off));

   end Initialize;

   function Is_Initialized
      return Boolean is (Initialized);

begin

   Initialize;

end AMC;
