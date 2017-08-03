with AMC.Board;
with AMC.Config;
with AMC.Types;
--  with AMC.ADC;
with AMC.PWM;

pragma Elaborate(AMC.Board);
pragma Elaborate(AMC.PWM);

package body AMC is

   PWM_Peripheral : AMC.PWM.Object;

   procedure Initialize
   is
   begin
      AMC.Board.Initialize;
      --  AMC.ADC.Initialize;
      --  AMC.PWM.Initialize;

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
                                     Value => 25.0);

      PWM_Peripheral.Set_Duty_Cycle (Gate  => AMC.PWM.Gate_B,
                                     Value => 50.0);

      PWM_Peripheral.Set_Duty_Cycle (Gate  => AMC.PWM.Gate_C,
                                     Value => 75.0);

      PWM_Peripheral.Set_Duty_Cycle (Gate  => AMC.PWM.Sample_Trigger,
                                     Value => 1.0);

      PWM_Peripheral.Enable (Gate => AMC.PWM.Gate_A);
      PWM_Peripheral.Enable (Gate => AMC.PWM.Gate_B);
      PWM_Peripheral.Enable (Gate => AMC.PWM.Gate_C);

      PWM_Peripheral.Enable (Gate => AMC.PWM.Sample_Trigger);

      Initialized :=
        AMC.Board.Is_Initialized and
        --  AMC.ADC.Is_Initialized and
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

begin

   Initialize;

end AMC;
