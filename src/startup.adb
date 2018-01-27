with AMC_Types;
with AMC_Board;
with Config;
with AMC_Encoder;
with AMC_Hall;
with AMC_ADC;
with AMC_PWM;

package body Startup is

   procedure Initialize is
      Position_Sensor_Initialized : Boolean := False;
   begin

      AMC_Board.Initialize;

      case Config.Position_Sensor is
         when AMC_Types.Encoder =>
            AMC_Encoder.Initialize;
            Position_Sensor_Initialized := AMC_Encoder.Is_Initialized;

         when AMC_Types.Hall =>
            AMC_Hall.Initialize;
            Position_Sensor_Initialized := AMC_Hall.Is_Initialized;

         when AMC_Types.None =>
            Position_Sensor_Initialized := True;
      end case;

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
         Position_Sensor_Initialized and
         AMC_Hall.Is_Initialized;
   end Initialize;

   function Is_Initialized
      return Boolean is (Initialized);

end Startup;
