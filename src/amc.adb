with Ada.Real_Time; use Ada.Real_Time;

with AMC_Board;
with AMC_UART;
with AMC_ADC;
with AMC_PWM;
with AMC_Encoder;
with Position;
with AMC_Utils;

with Current_Control; pragma Unreferenced (Current_Control);

with Serial_COBS;

package body AMC is

   procedure Update_Mode (Current_Mode   : in out Ctrl_Mode;
                          Button_Pressed : in Boolean;
                          Period         : in AMC_Types.Seconds;
                          Is_Aligned     : in Boolean);

   procedure Update_Outputs (Outputs      : in out Inverter_System_States;
                             Enable_Gates : out Boolean;
                             Is_Aligned   : out Boolean;
                             Mode         : in Ctrl_Mode;
                             Idq_Req      : in Dq;
                             Period       : in AMC_Types.Seconds);

   --  Temporary for test
   function External_Voltage_To_Iq_Req (ADC_Voltage : in Voltage_V)
                                        return Dq
   is
      Iq : constant Float := Float (ADC_Voltage) * 20.0 / 3.3;
   begin
      if Iq < 2.0 then
         return Dq'(0.0, 0.0);
      end if;

      return Dq'(D => 0.0, Q => AMC_Utils.Saturate (X       => Iq,
                                                    Maximum => 20.0,
                                                    Minimum => 0.0));
   end External_Voltage_To_Iq_Req;

   task body Inverter_System is
      Period_s : constant AMC_Types.Seconds :=
         AMC_Types.Seconds (Float (Config.Inverter_System_Period_Ms) / 1000.0);
      Period : constant Time_Span :=
         Milliseconds (Config.Inverter_System_Period_Ms);
      Next_Release : Time := Clock;

      Idq_Req      : Dq := Dq'(D => 0.0, Q => 0.0);
      Vbus         : Voltage_V := 0.0;
      Enable_Gates : Boolean := False;
      Outputs      : Inverter_System_States;
      Is_Aligned   : Boolean := False;
      Mode         : Ctrl_Mode := Off;
   begin

      AMC_Board.Turn_Off (AMC_Board.Led_Red);
      AMC_Board.Turn_Off (AMC_Board.Led_Green);

      loop
         AMC_Board.Turn_On (AMC_Board.Led_Red);
         for I in 1 .. 100 loop
            declare
               D1 : aliased Serial_COBS.Data := (1 => 16#00#);
               Dout1 : constant Serial_COBS.Data := Serial_COBS.COBS_Encode (D1'Access);
               D2 : aliased Serial_COBS.Data := (16#00#, 16#00#);
               Dout2 : constant Serial_COBS.Data := Serial_COBS.COBS_Encode (D2'Access);
               D3 : aliased Serial_COBS.Data := (16#11#, AMC_Types.UInt8 (I), 16#00#, 16#33#);
               Dout3 : constant Serial_COBS.Data := Serial_COBS.COBS_Encode (D3'Access);
               D4 : aliased Serial_COBS.Data := (16#11#, 16#22#, 16#33#, 16#44#);
               Dout4 : constant Serial_COBS.Data := Serial_COBS.COBS_Encode (D4'Access);
               D5 : aliased Serial_COBS.Data := (16#11#, 16#00#, 16#00#, 16#00#);
               Dout5 : constant Serial_COBS.Data := Serial_COBS.COBS_Encode (D5'Access);
               pragma Unreferenced (Dout1, Dout2, Dout3, Dout4, Dout5);
            begin
               null;
            end;
         end loop;

         AMC_Board.Turn_Off (AMC_Board.Led_Red);

         declare
            D1 : aliased Serial_COBS.Data := (16#03#, 16#2F#, 16#A2#, 16#04#, 16#92#, 16#73#, 16#26#);
            Dout1 : constant Serial_COBS.Data := Serial_COBS.COBS_Decode (D1'Access);
            D2 : aliased Serial_COBS.Data := (16#01#, 16#01#);
            Dout2 : constant Serial_COBS.Data := Serial_COBS.COBS_Decode (D2'Access);
            D3 : aliased Serial_COBS.Data := (16#01#, 16#01#, 16#01#);
            Dout3 : constant Serial_COBS.Data := Serial_COBS.COBS_Decode (D3'Access);
            D4 : aliased Serial_COBS.Data := (16#05#, 16#11#, 16#22#, 16#33#, 16#44#);
            Dout4 : constant Serial_COBS.Data := Serial_COBS.COBS_Decode (D4'Access);
            D5 : aliased Serial_COBS.Data := (16#02#, 16#11#, 16#01#, 16#01#, 16#01#);
            Dout5 : constant Serial_COBS.Data := Serial_COBS.COBS_Decode (D5'Access);
            pragma Unreferenced (Dout1, Dout2, Dout3, Dout4, Dout5);
         begin
            null;
         end;

         --  Serial_COBS.Receive_Handler;

         --  Test simple loop-back
--           declare
--              D : aliased AMC_UART.Data_TxRx := AMC_UART.Receive_Data;
--           begin
--              AMC_UART.Send_Data (D'Access);
--           end;

         --  Get inputs dependent upon
         Vbus := AMC_Board.To_Vbus
            (AMC_ADC.Get_Sample (AMC_ADC.Bat_Sense)); --  TODO: filter
         Idq_Req := External_Voltage_To_Iq_Req
            (AMC_ADC.Get_Sample (AMC_ADC.Ext_V));

         --  Update current Mode
         Update_Mode (Current_Mode   => Mode,
                      Button_Pressed => AMC_Board.Is_Pressed (AMC_Board.User_Button),
                      Period         => Period_s,
                      Is_Aligned     => Is_Aligned);

         --  Perform actions based on inputs and Mode
         Update_Outputs (Outputs      => Outputs,
                         Enable_Gates => Enable_Gates,
                         Is_Aligned   => Is_Aligned,
                         Mode         => Mode,
                         Idq_Req      => Idq_Req,
                         Period       => Period_s);
         Outputs.Vbus := Vbus;

         --  Atomically, set the task's outputs
         Inverter_System_Outputs.Set (Outputs);

         AMC_Board.Set_Gate_Driver_Power (Enable_Gates);

         Next_Release := Next_Release + Period;
         delay until Next_Release;
      end loop;
   end Inverter_System;

   Mode_Tmr : AMC_Utils.Timer := AMC_Utils.Create (2.0);

   procedure Update_Mode (Current_Mode   : in out Ctrl_Mode;
                          Button_Pressed : in Boolean;
                          Period         : in AMC_Types.Seconds;
                          Is_Aligned     : in Boolean) is
   begin
      case Current_Mode is
         when Off =>
            if Button_Pressed then
               if Mode_Tmr.Tick (Period) then
                  Mode_Tmr.Reset;
                  Current_Mode := Alignment;
               end if;
            else
               Mode_Tmr.Reset;
            end if;

         when Alignment =>
            if Is_Aligned then
               Current_Mode := Normal;
            end if;

         when Normal =>
            if Button_Pressed then
               Current_Mode := Off;
            end if;

      end case;
   end Update_Mode;

   Align_Tmr : AMC_Utils.Timer := AMC_Utils.Create (2.0);

   procedure Update_Outputs (Outputs      : in out Inverter_System_States;
                             Enable_Gates : out Boolean;
                             Is_Aligned   : out Boolean;
                             Mode         : in Ctrl_Mode;
                             Idq_Req      : in Dq;
                             Period       : in AMC_Types.Seconds) is
   begin
      case Mode is
         when Normal =>
            Outputs.Idq_CC_Request := Idq_Req;
            Enable_Gates := True;
            Is_Aligned := False;

         when Off =>
            Outputs.Idq_CC_Request := Dq'(D => 0.0, Q => 0.0);
            Enable_Gates := False;
            Is_Aligned := False;

         when Alignment =>
            Outputs.Alignment_Angle := 0.0;
            Outputs.Idq_CC_Request := Dq'(D => 12.0, Q => 0.0);
            Enable_Gates := True;

            Is_Aligned := Align_Tmr.Tick (Period);
            if Is_Aligned then
               Align_Tmr.Reset;
               Position.Set_Angle (0.0);
            end if;
      end case;

      Outputs.Mode := Mode;
   end Update_Outputs;

   procedure Safe_State is
   begin
      AMC_PWM.Generate_Break_Event;
      AMC_Board.Set_Gate_Driver_Power (Enabled => False);
   end Safe_State;


   procedure Initialize
   is
   begin

      AMC_Board.Initialize;

      AMC_UART.Initialize;

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
         AMC_UART.Is_Initialized and
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
