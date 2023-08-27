 
#==============================================================================
set systemTimeStart [clock seconds]
puts "======================================================="
puts "Starting at [clock format $systemTimeStart -format %H:%M:%S]"
puts "======================================================="
#==============================================================================

source ../3_Scripts/10_Parameters.tcl
source ../3_Scripts/11_Paths.tcl

set_app_var hdlin_auto_save_templates true

set sh_output_log_file "dc_log_file_[clock format $systemTimeStart -format %d_%m_%Y_%H:%M].log"

set DESIGN vlsu_cam_top

set SIMPLE_GATES yes

set_host_options -max_cores 8


puts "Synthesizing ${DESIGN}"
puts ""
puts "========================="
puts "SETTING LIBRARIES"
puts "========================="

set search_path ""
    lappend search_path /technos/GF22FDX/standardCells/GF22FDX_SC9T_116CPP/globalfoundaries22nhsda/20hd/hdl/ulvt/6.01a/liberty/ccs_lvf/
    lappend search_path /users/atorrubia/WORK/cam-stdcell-design/src/rtl
    
set target_library ""
    lappend target_library gf22nsdvlogl20hdl116a_SSG_0P81V_0P00V_0P00V_0P00V_125C.db
    
set synthetic_library [list dw_foundation.sldb]
set link_library [concat  [concat  * $target_library] $synthetic_library]

puts "========================="
puts "READING .V FILES"
puts "========================="

read_file -format sverilog { vlsu_cam_top.sv \
    vlsu_cam_gate_level.sv }

    
puts "========================="
puts "ANALYZE .V FILES"
puts "========================="
analyze -format sverilog { vlsu_cam_top.sv \
    vlsu_cam_gate_level.sv
    }

find design -hierarchy

#report_cell

current_design $DESIGN

elaborate $DESIGN

puts "========================="
puts "LINKING DESIGN"
puts "========================="

link

find design -hierarchy


puts "========================="
puts "READING CONSTRAINTS"
puts "========================="
source ../2_Constraints/test.tcl

# Path Groups
group_path -name I2R -from [all_inputs]
group_path -name R2O -to [all_outputs]
group_path -name I2O -from [all_inputs] -to [all_outputs]
group_path -name R2R -from [all_registers] -to [all_registers]



# set_app_var ungroup_keep_original_design true
# set compile_seqmap_propagate_constants false

check_design -summary

puts "========================="
puts "COMPILE DESIGN"
puts "========================="
compile_ultra
#compile

find design -hierarchy

puts "========================="
puts "WRITE REPORTS"
puts "========================="

#prompt qor to easy check dir_synth_results
report_qor

if {$SIMPLE_GATES eq {yes}} {
    # save the reports
    report_cell                         > ${dir_synth_reports_simple_gates}/cells.txt 
    report_clock                        > ${dir_synth_reports_simple_gates}/clock.txt 
    report_clock_gating                 > ${dir_synth_reports_simple_gates}/clock_gatting.txt 
    report_clock_gating_check           > ${dir_synth_reports_simple_gates}/clock_gatting_checks.txt; #reports clock-gating timing checks
    report_clock_tree                   > ${dir_synth_reports_simple_gates}/clock_tree.txt
    report_constraints -all_violators   > ${dir_synth_reports_simple_gates}/constraints.txt
    report_design                       > ${dir_synth_reports_simple_gates}/design.txt
    report_net                          > ${dir_synth_reports_simple_gates}/nets.txt
    report_port                         > ${dir_synth_reports_simple_gates}/ports.txt
    report_qor                          > ${dir_synth_reports_simple_gates}/qor_summary.txt
    report_timing -max_paths 10         > ${dir_synth_reports_simple_gates}/timing.txt
    report_timing -path end             > ${dir_synth_reports_simple_gates}/timing2.txt
    report_area -hierarchy              > ${dir_synth_reports_simple_gates}/area.txt 
    report_power -hierarchy             > ${dir_synth_reports_simple_gates}/power.txt 

    check_design -summary
    check_design
    
    # WRITE FILES .DDC, NETLIST .v, STANDARD DELAY FORMAT .sdf
    write_file -format ddc -hierarchy -output ${dir_synth_results_simple_gates}/cam.ddc
    write_file -format verilog -output ${dir_synth_results_simple_gates}/cam.v -hierarchy
    write_sdf ${dir_synth_results_simple_gates}/synth_delays.sdf
}

if {$SIMPLE_GATES eq {no}} {
    # save the reports
    report_cell                         > ${dir_synth_reports_all_gates}/cells.txt 
    report_clock                        > ${dir_synth_reports_all_gates}/clock.txt 
    report_clock_gating                 > ${dir_synth_reports_all_gates}/clock_gatting.txt 
    report_clock_gating_check           > ${dir_synth_reports_all_gates}/clock_gatting_checks.txt; #reports clock-gating timing checks
    report_clock_tree                   > ${dir_synth_reports_all_gates}/clock_tree.txt
    report_constraints -all_violators   > ${dir_synth_reports_all_gates}/constraints.txt
    report_design                       > ${dir_synth_reports_all_gates}/design.txt
    report_net                          > ${dir_synth_reports_all_gates}/nets.txt
    report_port                         > ${dir_synth_reports_all_gates}/ports.txt
    report_qor                          > ${dir_synth_reports_all_gates}/qor_summary.txt
    report_timing -max_paths 10         > ${dir_synth_reports_all_gates}/timing.txt
    report_timing -path end             > ${dir_synth_reports_all_gates}/timing2.txt
    report_area -hierarchy              > ${dir_synth_reports_all_gates}/area.txt 
    report_power -hierarchy             > ${dir_synth_reports_all_gates}/power.txt 

    check_design -summary
    check_design
    
    # WRITE FILES .DDC, NETLIST .v, STANDARD DELAY FORMAT .sdf
    write_file -format ddc -hierarchy -output ${dir_synth_results_all_gates}/cam.ddc
    write_file -format verilog -output ${dir_synth_results_all_gates}/cam.v -hierarchy
    write_sdf ${dir_synth_results_all_gates}/synth_delays.sdf
}

#@EOF
