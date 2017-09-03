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
with Communication; pragma Unreferenced (Communication);

package body AMC is

   Serial : aliased AMC_UART.UART_Stream;

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

      COBS : Serial_COBS.COBS_Stream;

      --  B : constant Byte_Array := (3, 2, 1);

   begin

      declare
         --  A : constant Communication.QP.Item_Array := Communication.QP.Item_Array (B);
         Empty, Full : Boolean := False;
         X : AMC_Types.UInt8 := 0;
         N_Occupied : Natural := 0;
         N_Available : Natural := 0;
         pragma Unreferenced (N_Available);
      begin
         Empty := Communication.A_Queue.Is_Empty;
         Full := Communication.A_Queue.Is_Full;
         N_Occupied := Communication.A_Queue.Occupied_Slots;
         N_Available := Communication.A_Queue.Empty_Slots;

         Communication.A_Queue.Push (Item => 0);

         Empty := Communication.A_Queue.Is_Empty;
         Full := Communication.A_Queue.Is_Full;
         N_Occupied := Communication.A_Queue.Occupied_Slots;
         N_Available := Communication.A_Queue.Empty_Slots;

         Communication.A_Queue.Push (Items => (1, 2, 3, 4, 5, 6, 7));

         Empty := Communication.A_Queue.Is_Empty;
         Full := Communication.A_Queue.Is_Full;
         N_Occupied := Communication.A_Queue.Occupied_Slots;
         N_Available := Communication.A_Queue.Empty_Slots;

         begin
            Communication.A_Queue.Push (Item => 8);
         exception
            when others =>
               null;
         end;

         begin
            Communication.A_Queue.Push (Items => (8, 9));
         exception
            when others =>
               null;
         end;

         Communication.A_Queue.Pull (Item => X);
         Communication.A_Queue.Pull (Item => X);

         declare
            X_Array : aliased Communication.QP.Item_Array := (0, 0);
         begin
            Communication.A_Queue.Pull (N            => 2,
                                        Items_Access => X_Array'Access);
         end;

         Empty := Communication.A_Queue.Is_Empty;
         Full := Communication.A_Queue.Is_Full;
         N_Occupied := Communication.A_Queue.Occupied_Slots;
         N_Available := Communication.A_Queue.Empty_Slots;


         begin
            Communication.A_Queue.Push (Items => (20, 21, 22));
         exception
            when others =>
               null;
         end;

         Empty := Communication.A_Queue.Is_Empty;
         Full := Communication.A_Queue.Is_Full;
         N_Occupied := Communication.A_Queue.Occupied_Slots;
         N_Available := Communication.A_Queue.Empty_Slots;

         X := Communication.A_Queue.Peek;
         X := Communication.A_Queue.Peek (N => 1);
         X := Communication.A_Queue.Peek (N => 2);
         X := Communication.A_Queue.Peek (N => N_Occupied);

         begin
            X := Communication.A_Queue.Peek (N => N_Occupied + 1);
         exception
            when others =>
               null;
         end;

         Communication.A_Queue.Flush (N => Communication.A_Queue.Occupied_Slots);

         Empty := Communication.A_Queue.Is_Empty;
         Full := Communication.A_Queue.Is_Full;
         N_Occupied := Communication.A_Queue.Occupied_Slots;
         N_Available := Communication.A_Queue.Empty_Slots;

         Empty := not Full;
         Full := Empty;
         Empty := not Full;
         pragma Unreferenced (Empty);
      end;

      declare
         C : aliased Communication.QP.Item_Array := (0, 0, 0);
      begin
         Communication.A_Queue.Pull (N            => 3,
                                     Items_Access => C'Access);
         Communication.A_Queue.Flush_All;
         null;
      end;

      COBS.Initialize (IO_Stream_Access => Serial'Access);

      AMC_Board.Turn_Off (AMC_Board.Led_Red);
      AMC_Board.Turn_Off (AMC_Board.Led_Green);

      loop

         declare
            N : Natural := 0;
         begin
            COBS.Write (Data => COBS.Read, Sent => N);
         end;

         --  Test simple loop-back
--           declare
--              N : Natural := 0;
--           begin
--              Serial.Write (Data => Serial.Read, Sent => N);
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

      AMC_UART.Initialize_Default (Stream => Serial);

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
         AMC_UART.Is_Initialized (Stream => Serial) and
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
