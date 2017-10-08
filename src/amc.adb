with Ada.Real_Time; use Ada.Real_Time;

with AMC_Board;
with AMC_ADC;
with AMC_PWM;
--  with AMC_Encoder;
with AMC_Hall;
with Position;
with AMC_Utils;
with Calmeas;

package body AMC is

   --  Variables available for measurement
   V_Bus_Log  : aliased Voltage_V;
   Iq_Ref_Log : aliased Float;

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
                                        return Dq;
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

         --  Log some data
         V_Bus_Log := Vbus;
         Iq_Ref_Log := Idq_Req.Q;

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

         when Speed =>
            raise Constraint_Error;
            --  Not Implemented

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
            Outputs.Current_Command :=
               Space_Vector'(Reference_Frame  => Rotor,
                             Rotor_Fixed      => Idq_Req);
            Enable_Gates := True;
            Is_Aligned := False;

         when Off =>
            Outputs.Current_Command :=
               Space_Vector'(Reference_Frame  => Rotor,
                             Rotor_Fixed      => Dq'(D => 0.0, Q => 0.0));
            Enable_Gates := False;
            Is_Aligned := False;

         when Alignment =>
            Outputs.Alignment_Angle := 0.0;
            Outputs.Current_Command :=
               Space_Vector'(Reference_Frame => Stator_Ab,
                             Stator_Fixed_Ab => Alfa_Beta'(Alfa => 12.0,
                                                           Beta => 0.0));
            Enable_Gates := True;

            Is_Aligned := Align_Tmr.Tick (Period);
            if Is_Aligned then
               Align_Tmr.Reset;
               Position.Set_Angle (0.0);
            end if;

         when Speed =>
            raise Constraint_Error;
            --  Not Implemented
      end case;

      Outputs.Mode := Mode;
   end Update_Outputs;

   function Get_Inverter_System_Output return Inverter_System_States is
      (Inverter_System_Outputs.Get);

   procedure Safe_State is
   begin
      AMC_PWM.Generate_Break_Event;
      AMC_Board.Set_Gate_Driver_Power (Enabled => False);
   end Safe_State;


   procedure Initialize
   is
   begin

      AMC_Board.Initialize;

      --  AMC_Encoder.Initialize;

      AMC_Hall.Initialize;

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
         --  AMC_Encoder.Is_Initialized;
         AMC_Hall.Is_Initialized;

      Inverter_System_Outputs.Set
         ((Current_Command => Space_Vector'(Reference_Frame  => Rotor,
                                            Rotor_Fixed      => (0.0, 0.0)),
           Vbus            => 0.0,
           Alignment_Angle => 0.0,
           Mode            => Off));

   end Initialize;

   function Is_Initialized
      return Boolean is (Initialized);

   procedure Wait_Until_Initialized is
      Period : constant Time_Span := Milliseconds (1);
      Next_Release : Time := Clock;
   begin
      loop
         exit when Is_Initialized;
         Next_Release := Next_Release + Period;
         delay until Next_Release;
      end loop;
   end Wait_Until_Initialized;

begin

   Initialize;

   Calmeas.Add (Symbol      => V_Bus_Log'Access,
                Name        => "V_Bus",
                Description => "Bus Voltage [V]");

   Calmeas.Add (Symbol      => Iq_Ref_Log'Access,
                Name        => "Iq_Ref",
                Description => "Quadrature current reference [A]");

end AMC;
