with AMC_Types;
private with AMC_Utils;

package ZSM is
   --  Zero Sequence Modulation
   --  See http://microchipdeveloper.com/mct5001:start for a tutorial.

   type Modulation_Method is (Sinusoidal,
                              Midpoint_Clamp,
                              Top_Clamp,
                              Bottom_Clamp,
                              Top_Bottom_Clamp);

   function Modulation_Index_Max (Method : Modulation_Method) return Float;
   --  Defined according to:
   --  m = Vm / Vc, where
   --  Vm: peak value of the modulating wave,
   --  Vc: peak value of the achievable carrier wave, e.g. Vbus/2.

   function Modulate (X : in AMC_Types.Abc;
                      Method : Modulation_Method)
                      return AMC_Types.Abc;
   --  Modulate by using the selected method.

   function Sinusoidal (X : in AMC_Types.Abc)
                        return AMC_Types.Abc;
   --  Phase voltages are all sinusoidal.
   --  No common mode term is added.
   --  Line-to-line amplitudes above Vbus * sqrt(3)/2 cannot be achieved.

   function Midpoint_Clamp (X : in AMC_Types.Abc)
                            return AMC_Types.Abc;
   --  Gives the same result as space vector modulation.
   --  The maximum line-to-line amplitude reaches Vbus.

   function Top_Clamp (X : in AMC_Types.Abc)
                       return AMC_Types.Abc;
   --  Flat top.
   --  The output is offset such that the highest output amplitude is moved
   --  to Vbus.
   --  This reduces switching losses since 100% duty will be used for 120°
   --  per cycle of each output.
   --  Might not be recommended if bootstrapped gates drivers are used.

   function Bottom_Clamp (X : in AMC_Types.Abc)
                          return AMC_Types.Abc;
   --  Flat bottom
   --  The output is offset such that the lowest output amplitude is moved
   --  to lower bus rail.
   --  This reduces switching losses since 0% duty will be used for 120°
   --  per cycle of each output.

   function Top_Bottom_Clamp (X : in AMC_Types.Abc)
                              return AMC_Types.Abc;
   --  Chooses from Top_Clamp or Bottom_Clamp the one that yields the smallest
   --  added common mode.
   --  This will spread the switching losses evenly over all switches.
   --  Might not be recommended if bootstrapped gates drivers are used.

private

   Modulation_Indicies_Max : constant array (Modulation_Method'Range) of Float :=
      (1.0,
       AMC_Utils.Two_Over_Sqrt3,
       AMC_Utils.Two_Over_Sqrt3,
       AMC_Utils.Two_Over_Sqrt3,
       AMC_Utils.Two_Over_Sqrt3);

end ZSM;
