with Ada.Real_Time; use Ada.Real_Time;
with AMC_Board;
with AMC_ADC;
with AMC_Utils;
with Watchdog.Manager;
with Calmeas;
with Current_Control;
with Startup;

package body AMC is

   --  Variables available for measurement
   V_Bus_Log  : aliased Voltage_V;
   Iq_Ref_Log : aliased Float;

   procedure Update_Mode (Current_Mode   : in out Ctrl_Mode;
                          Button_Pressed : in Boolean;
                          Period         : in AMC_Types.Seconds;
                          Is_Aligned     : in Boolean);

   procedure Update_Outputs (Outputs      : out Inverter_System_States;
                             Enable_Gates : out Boolean;
                             Mode         : in Ctrl_Mode;
                             Idq_Req      : in Dq);

   --  Temporary for test
   function External_Voltage_To_Iq_Req (ADC_Voltage : in Voltage_V)
                                        return Dq
   is
      Iq : constant Float := (Float (ADC_Voltage) - 1.65) * 20.0 / 1.65;
   begin
      if abs Iq < 2.0 then
         return Dq'(0.0, 0.0);
      end if;

      return Dq'(D => 0.0, Q => AMC_Utils.Saturate (X       => Iq,
                                                    Maximum => 20.0,
                                                    Minimum => -20.0));
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
      Mode         : Ctrl_Mode := Normal;

      Wdg_Checkpoint : Watchdog.Checkpoint_Id;
   begin

      AMC_Board.Turn_Off (AMC_Board.Led_Red);
      AMC_Board.Turn_Off (AMC_Board.Led_Green);

      Watchdog.Manager.Instance.Initialize_Checkpoint
         (Checkpoint         => Wdg_Checkpoint,
          Period_Factor      => Config.Inverter_System_Period_Ms / Watchdog.Manager.Base_Period_Ms,
          Minimum_Nof_Visits => 1,
          Allowed_Misses     => 1);

      if AMC_Board.Is_Pressed (AMC_Board.User_Button) then
         Mode := Off;
      end if;

--        if AMC_Board.Get_Startup_Reason = Watchdog_Reset then
--           AMC_Board.Turn_On (AMC_Board.Led_Red);
--        end if;

      loop
         --  Get inputs dependent upon
         Vbus := AMC_Board.To_Vbus
            (AMC_ADC.Get_Sample (AMC_ADC.Bat_Sense)); --  TODO: filter
         Idq_Req := External_Voltage_To_Iq_Req
            (AMC_ADC.Get_Sample (AMC_ADC.Ext_V));
         Is_Aligned := Current_Control.Get_Current_Control_Output.Alignment_Done;

         --  Update current Mode
         Update_Mode (Current_Mode   => Mode,
                      Button_Pressed => AMC_Board.Is_Pressed (AMC_Board.User_Button),
                      Period         => Period_s,
                      Is_Aligned     => Is_Aligned);

         --  Perform actions based on inputs and Mode
         Update_Outputs (Outputs      => Outputs,
                         Enable_Gates => Enable_Gates,
                         Mode         => Mode,
                         Idq_Req      => Idq_Req);
         Outputs.Vbus := Vbus;

         --  Atomically, set the task's outputs
         Inverter_System_Outputs.Set (Outputs);

         AMC_Board.Set_Gate_Driver_Power (Enable_Gates);

         --  Log some data
         V_Bus_Log := Vbus;
         Iq_Ref_Log := Idq_Req.Q;

         Watchdog.Manager.Instance.Visit (Wdg_Checkpoint);

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
            if Mode_Tmr.Tick (Period) and Button_Pressed then
               Mode_Tmr.Reset;
               Current_Mode := Off;
            end if;

         when Speed =>
            raise Constraint_Error;
            --  Not Implemented

      end case;
   end Update_Mode;

   procedure Update_Outputs (Outputs      : out Inverter_System_States;
                             Enable_Gates : out Boolean;
                             Mode         : in Ctrl_Mode;
                             Idq_Req      : in Dq) is
   begin
      case Mode is
         when Normal =>
            Outputs.Current_Command :=
               Space_Vector'(Reference_Frame  => Rotor,
                             Rotor_Fixed      => Idq_Req);
            Enable_Gates := True;

         when Off =>
            Outputs.Current_Command :=
               Space_Vector'(Reference_Frame  => Rotor,
                             Rotor_Fixed      => Dq'(D => 0.0, Q => 0.0));
            Enable_Gates := False;

         when Alignment =>
            Outputs.Current_Command :=
               Space_Vector'(Reference_Frame  => Rotor,
                             Rotor_Fixed      => Dq'(D => 0.0, Q => 0.0));
            Enable_Gates := True;

         when Speed =>
            raise Constraint_Error;
            --  Not Implemented
      end case;

      Outputs.Mode := Mode;
   end Update_Outputs;

   function Get_Inverter_System_Output return Inverter_System_States is
      (Inverter_System_Outputs.Get);

   procedure Initialize is
   begin
      Inverter_System_Outputs.Set
         ((Current_Command =>
                 Space_Vector'(Reference_Frame  => Rotor,
                               Rotor_Fixed      => (0.0, 0.0)),
           Vbus            => 0.0,
           Mode            => Off));

      Startup.Initialize;

      Initialized := Startup.Is_Initialized;
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
