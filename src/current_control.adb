with AMC_ADC;
with AMC_PWM;
with AMC_Board;
with Current_Control.FOC;
with AMC;
package body Current_Control is

   task body Current_Control is
      V_Samples      : Abc;
      I_Samples      : Abc;
      System_Outputs : AMC.Inverter_System_States;
      Duty           : Abc;
   begin

      AMC.Wait_Until_Initialized;

      loop
         AMC_ADC.Handler.Await_New_Samples
            (Phase_Voltage_Samples => V_Samples,
             Phase_Current_Samples => I_Samples);

         AMC_Board.Turn_On (AMC_Board.Led_Green);

         System_Outputs := AMC.Get_Inverter_System_Output;

         if System_Outputs.Mode = Off then
            Duty := Abc'(50.0, 50.0, 50.0);
         else
            case Algorithm is
               when Field_Oriented =>
                  FOC.Update (Phase_Currents => AMC_Board.To_Phase_Currents (I_Samples),
                              System_Outputs => System_Outputs,
                              Duty           => Duty);

               when Six_Step =>
                  raise Constraint_Error; -- TODO

            end case;
         end if;

         AMC_PWM.Set_Duty_Cycle (Duty);

         AMC_Board.Turn_Off (AMC_Board.Led_Green);

      end loop;
   end Current_Control;

   function Get_Current_Control_Output return Current_Control_States is
      (Current_Control_Outputs.Get);

end Current_Control;
