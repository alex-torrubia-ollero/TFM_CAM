    #Clock signal variables
    set clkRef clk
    set clkSig clk_core

    # Clock parameters
    set clkPer 1
    set clkUncertaintyH 0.03
    set clkUncertaintyS 0.03
    set inputSigDelay_percent 0.3
    set outputDelay_percent 0.3
    set inputClkDelay 0.0
    set maxTransData_percent 0.2
    set maxTransClk_percent 0.15

    # Define clock
    create_clock -name $clkSig -period $clkPer [get_ports $clkRef]

    # Timing Constraints
    set_input_delay -clock $clkSig [expr $inputSigDelay_percent*$clkPer] [all_inputs]
    set_input_delay -clock $clkSig $inputClkDelay [get_ports $clkRef]
    set_output_delay -clock $clkSig [expr $outputDelay_percent*$clkPer] [all_outputs]
    set_clock_uncertainty -hold $clkUncertaintyH $clkRef
    set_clock_uncertainty -setup $clkUncertaintyS $clkRef
    set_max_transition [expr $maxTransData_percent*$clkPer] [current_design]
    set_max_transition [expr $maxTransClk_percent*$clkPer] -clock_path $clkSig
    set_max_transition [expr $maxTransData_percent*$clkPer] -data_path $clkSig
    
    # Restrict complex gates usage
    if {$SIMPLE_GATES eq {yes}} {
        set_dont_use {gf22nsdvlogl20hdl116a_SSG_0P81V_0P00V_0P00V_0P00V_125C/HDBSLT20_AO* gf22nsdvlogl20hdl116a_SSG_0P81V_0P00V_0P00V_0P00V_125C/HDBSLT20_OA*}
    }

