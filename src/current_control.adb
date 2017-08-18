with Ada.Real_Time; use Ada.Real_Time;

with AMC_ADC;
with AMC_PWM;
with AMC_Encoder;
with AMC_Board;
with AMC;
with FOC;
with ZSM;

package body Current_Control is

   function Voltage_To_Duty (V    : in Abc;
                             Vbus : in Voltage_V)
                             return Abc
   is
      Duty : constant Abc := Float((100.0 / Vbus)) * V + (50.0, 50.0, 50.0);
   begin
      return ZSM.Modulate (X      => Duty,
                           Method => Config.Modulation_Method);
   end Voltage_To_Duty;


   task body Current_Control is
      V_Samples  : Abc;
      I_Samples  : Abc;
      Vbus       : Voltage_V;
      Vmax       : Voltage_V;
      Iabc_Raw   : Abc;
      V_Ctrl_Abc : Abc;
      Duty       : Abc;
   begin

      delay until Clock + Milliseconds(10);

      loop
         AMC_ADC.Handler.Await_New_Samples
            (Phase_Voltage_Samples => V_Samples,
             Phase_Current_Samples => I_Samples);

         AMC_Board.Turn_On (AMC_Board.Led_Green);

         Iabc_Raw := AMC_Board.To_Phase_Currents (I_Samples);

         Vbus := AMC.Inverter_System_Outputs.Vbus.Get;
         Vmax := 0.5 * Vbus * ZSM.Modulation_Index_Max(Config.Modulation_Method);

         V_Ctrl_Abc := FOC.Calculate_Voltage
            (Iabc          => Iabc_Raw,
             I_Set_Point   => AMC.Inverter_System_Outputs.Idq_CC_Request.Get,
             Current_Angle => AMC_Encoder.Get_Angle,
             Vbus          => Vbus,
             Vmax          => Vmax,
             Period        => Nominal_Period);

         Duty := Voltage_To_Duty (V_Ctrl_Abc, Vbus);

         AMC_PWM.Set_Duty_Cycle (Duty);

         AMC_Board.Turn_Off (AMC_Board.Led_Green);

      end loop;
   end Current_Control;

   procedure Initialize
   is
   begin

      Initialized := True;
   end Initialize;

   function Is_Initialized return Boolean is
      (Initialized);


end Current_Control;
