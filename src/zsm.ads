with AMC_Types;
private with AMC_Utils;

package ZSM is
   --  @summary
   --  Zero Sequence Modulation
   --
   --  @description
   --  This package implements various modulation (common mode injection) methods.
   --
   --  See http://microchipdeveloper.com/mct5001:start for a great tutorial.
   --

   type Modulation_Method is
      (Sinusoidal,
       --  Phase voltages are all sinusoidal.
       --  No common mode term is added.
       --  Line-to-line amplitudes above Vbus * sqrt(3)/2 cannot be achieved.
       Midpoint_Clamp,
       --  Gives the same result as space vector modulation.
       --  The maximum line-to-line amplitude reaches Vbus.
       Top_Clamp,
       --  Flat top.
       --  The output is offset such that the highest output amplitude is moved
       --  to Vbus.
       --  This reduces switching losses since 100% duty will be used for 120°
       --  per cycle of each output.
       --  Might not be recommended if bootstrapped gates drivers are used.
       Bottom_Clamp,
       --  Flat bottom
       --  The output is offset such that the lowest output amplitude is moved
       --  to lower bus rail.
       --  This reduces switching losses since 0% duty will be used for 120°
       --  per cycle of each output.
       Top_Bottom_Clamp
       --  Chooses from Top_Clamp or Bottom_Clamp the one that yields the smallest
       --  added common mode.
       --  This will spread the switching losses evenly over all switches.
       --  Might not be recommended if bootstrapped gates drivers are used.
      );

   function Modulation_Index_Max (Method : Modulation_Method) return Float;
   --  Defined according to:
   --  m = Vm / Vc, where
   --  Vm: peak value of the modulating wave,
   --  Vc: peak value of the achievable carrier wave, e.g. Vbus/2.
   --  @param Method The specified method of modulation.
   --  @return The corresponding modulation index.

   function Modulate (X : in AMC_Types.Abc;
                      Method : Modulation_Method)
                      return AMC_Types.Abc;
   --  Modulate X using the selected method.
   --  @param X Input vector.
   --  @param Method The method to use.
   --  @return A modulated version of X.

   function Sinusoidal (X : in AMC_Types.Abc)
                        return AMC_Types.Abc;
   --  No common mode term is added.
   --  @param X Input vector.
   --  @return X

   function Midpoint_Clamp (X : in AMC_Types.Abc)
                            return AMC_Types.Abc;
   --  Implements common mode injection according to the Midpoint_Clamp method.
   --  @param X Input vector.
   --  @return Modulated X

   function Top_Clamp (X : in AMC_Types.Abc)
                       return AMC_Types.Abc;
   --  Implements common mode injection according to the Top_Clamp method.
   --  @param X Input vector.
   --  @return Modulated X

   function Bottom_Clamp (X : in AMC_Types.Abc)
                          return AMC_Types.Abc;
   --  Implements common mode injection according to the Bottom_Clamp method.
   --  @param X Input vector.
   --  @return Modulated X

   function Top_Bottom_Clamp (X : in AMC_Types.Abc)
                              return AMC_Types.Abc;
   --  Implements common mode injection according to the Top_Bottom_Clamp method.
   --  @param X Input vector.
   --  @return Modulated X

private

   Modulation_Indicies_Max : constant array (Modulation_Method'Range) of Float :=
      (1.0,
       AMC_Utils.Two_Over_Sqrt3,
       AMC_Utils.Two_Over_Sqrt3,
       AMC_Utils.Two_Over_Sqrt3,
       AMC_Utils.Two_Over_Sqrt3);

end ZSM;
