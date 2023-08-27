
puts ""
puts "===="
puts "PnR INITIALIZATION"
puts "===="
puts ""

set systemTimeStart [clock seconds]
puts "...................."
puts "Starting at [clock format $systemTimeStart -format %H:%M:%S]"
puts "...................."


set sh_output_log_file "icc2_log_file_[clock format $systemTimeStart -format %d_%m_%Y_%H:%M].log"

source ../3_Scripts/11_Paths.tcl
source ${dir_scripts}/10_Parameters.tcl

# setting variables
# set FPL 83.172
# set FPH 82.8

set FPL [expr 790*0.116]
set FPH [expr 121*0.72]

set welltap_position [expr 395*0.116]

set_host_options -max_cores 16

set TIMING_DRIVEN yes

set lib_name PnR_all_gates_opt_10

set SIMPLE_GATES no

puts ""
puts "===="
puts "0 - READING LIBRARY DATA"
puts "===="
puts ""

if {$SIMPLE_GATES eq {no}} {
set search_path ""
    lappend search_path /users/atorrubia/WORK/cam-stdcell-design/0_designEnvironment/0_synth+PnR_original/5_Results/1_Synth_results/all_gates/
}

if {$SIMPLE_GATES eq {yes}} {
set search_path ""
    lappend search_path /users/atorrubia/WORK/cam-stdcell-design/0_designEnvironment/0_synth+PnR_original/5_Results/1_Synth_results/simple_gates/
}
    source ${dir_scripts}/12_Libraries_used.tcl

puts ""
puts "===="
puts "1 - READING DESIGN DATA"
puts "===="
puts ""
puts "READING NETLIST"

read_verilog cam.v

set_app_options -name place.coarse.continue_on_missing_scandef -value true


set_units -time ns

set_app_options -name file.tlup.max_preservation_size -value 550

puts ""
puts "===="
puts "SET UP CORNERS"
puts "===="
puts ""

## mode func:
create_mode func_mode

puts "TT CORNER"
## create TT scenario:
create_corner typ_corner


create_scenario -name TT_nominal -mode func_mode -corner typ_corner
set_operating_conditions -analysis_type on_chip_variation -library { \
    gf22nsdvlogl20hdl116a_TT_0P90V_0P00V_0P00V_0P00V_85C.db \
    }
set_process_number 1.0
set_temperature 85.0
set_voltage 0.90
read_tech_file $TECH_FILE
read_parasitic_tech -tlup $TLUPLUS_TYP_FILE -layermap $ITFMAP_FILE
set_parasitic_parameters -corner typ_corner -early_spec $TLUPLUS_TYP_FILE -late_spec $TLUPLUS_TYP_FILE
set_scenario_status TT_nominal -active true

puts "SS CORNER"
create_corner slow_corner

create_scenario -name slow -mode func_mode -corner slow_corner
set_operating_conditions -analysis_type on_chip_variation -library { \
    gf22nsdvlogl20hdl116a_SSG_0P81V_0P00V_0P00V_0P00V_125C.db \
    }
set_process_number 1.0
set_temperature 125.0
set_voltage 0.81
read_tech_file $TECH_FILE
read_parasitic_tech -tlup $TLUPLUS_MAX_FILE -layermap $ITFMAP_FILE
set_parasitic_parameters -corner slow_corner -early_spec $TLUPLUS_MAX_FILE -late_spec $TLUPLUS_MAX_FILE

set_scenario_status slow -active true


puts ""
puts "===="
puts "READING CONSTRAINTS"
puts "===="
puts ""

source ${file_sdc}

# Set antenna rules
source /technos/GF22FDX/standardCells/GF22FDX_SC9T_116CPP/globalfoundaries22nhsda/20hd/hdl/ulvt/6.01a/ndm/antenna/22FDSOI_10M_2Mx_6Cx_2Ix_LB_antenna_rules.tcl

puts ""
puts "===="
puts "2 - INITIALIZE DESIGN"
puts "===="
puts ""

set Dim(floorplan) {}
lappend Dim(floorplan) $FPL
lappend Dim(floorplan) $FPH
set sideLen $Dim(floorplan)

set_attribute [get_site_defs unit] symmetry Y


set_attribute -objects [get_layers {M1 M2 C2 C4 C6 IB}] -name routing_direction -value horizontal
set_attribute -objects [get_layers {C1 C3 C5 IA LB}] -name routing_direction -value vertical
set_ignored_layers -min_routing_layer M2 -max_routing_layer IA
report_ignored_layers


initialize_floorplan -site unit -side_length $Dim(floorplan)

puts ""
puts "===="
puts "3 - MACRO PLACEMENT"
puts "===="
puts ""
#No macros in this design
puts "NO MACROS IN THE DESIGN"


puts ""
puts "===="
puts "4 - SET APP OPTIONS"
puts "===="
puts ""
set_app_options -name route.auto_via_ladder.update_during_route -value true
set_app_options -name route.detail.optimize_partition_size_for_drc -value true
set_app_options -name route.common.debug_remove_extension_floating_shapes -value true
set_app_options -name route.common.optimize_for_pin_access -value true
set_app_options -name route.common.post_detail_route_fix_soft_violations -value true
set_app_options -name route.global.via_cut_modeling -value true
set_app_options -name route.common.connect_floating_shapes -value true
set_app_options -name route.detail.check_patchable_drc_from_fixed_shapes -value true
set_app_options -name route.detail.enable_fixing_selective_design_rule_violations_on_fixed_shapes -value true

if {$TIMING_DRIVEN eq {yes}} {
    set_app_options -name route.global.timing_driven -value true
    set_app_options -name route.track.timing_driven -value true
    set_app_options -name route.common.rc_driven_setup_effort_level -value high
    set_app_options -name opt.timing.effort -value high
}

set_app_options -name ccd.hold_control_effort -value ultra
#set_app_options -name clock_opt.hold.effort -value high




puts ""
puts "===="
puts "5 - PLACE BOUNDARY AND WELLTAP CELLS"
puts "===="
puts ""

# Create power nets
create_net -power VDD
create_net -ground VSS

## Physical cells
set CELL_PREFIX "HDBSLT20_"
set top_boundary_cells "*/${CELL_PREFIX}CAPT1"
set bottom_boundary_cells "*/${CELL_PREFIX}CAPB1"
set right_boundary_cell "*/${CELL_PREFIX}CAPR9_1"
set left_boundary_cell "*/${CELL_PREFIX}CAPL9_1"
set top_right_outside_corner_cell "*/${CELL_PREFIX}CAPTOUCR9_1"
set bottom_right_outside_corner_cell "*/${CELL_PREFIX}CAPBOUCR9_1"
set top_left_outside_corner_cell "*/${CELL_PREFIX}CAPTOUCL9_1"
set bottom_left_outside_corner_cell "*/${CELL_PREFIX}CAPBOUCL9_1"
set top_left_inside_corner_cells "*/${CELL_PREFIX}CAPTLINC9_1"
set top_right_inside_corner_cells "*/${CELL_PREFIX}CAPTRINC9_1"
set bottom_left_inside_corner_cells "*/${CELL_PREFIX}CAPBLINC9_1"
set bottom_right_inside_corner_cells "*/${CELL_PREFIX}CAPBRINC9_1"
create_boundary_cells \
    -top_boundary_cells $top_boundary_cells \
    -bottom_boundary_cells $bottom_boundary_cells \
    -left_boundary_cell $left_boundary_cell \
    -right_boundary_cell $right_boundary_cell \
    -top_right_outside_corner_cell $top_right_outside_corner_cell \
    -bottom_right_outside_corner_cell $bottom_right_outside_corner_cell \
    -top_left_outside_corner_cell $top_left_outside_corner_cell \
    -bottom_left_outside_corner_cell $bottom_left_outside_corner_cell \
    -top_left_inside_corner_cells $top_left_inside_corner_cells \
    -top_right_inside_corner_cells $top_right_inside_corner_cells \
    -bottom_left_inside_corner_cells $bottom_left_inside_corner_cells \
    -bottom_right_inside_corner_cells $bottom_right_inside_corner_cells                          

#set tap_distance [expr {35.032 * 2}]; #origen de la tap cell para 16x16
#set tap_distance [expr {20}]; #origen de la tap cell para 16x32 with bigger column gap

#create_tap_cells -lib_cell */*_TAPSS -distance $tap_distance -skip_fixed_cells 
create_tap_cells -lib_cell */*_TAPSS -offset 40 -distance 300 -skip_fixed_cells -pattern every_row

connect_pg_net -net VSS [get_pins -hierarchical *VPW_P]
connect_pg_net -net VSS [get_pins -hierarchical *VNW_N]

get_voltage_areas
get_power_domains
report_voltage_areas



set_app_options -name route.auto_via_ladder.update_during_route -value true
set_app_options -name route.detail.optimize_partition_size_for_drc -value true

set_app_options -name route.common.debug_remove_extension_floating_shapes -value true
set_app_options -name route.common.optimize_for_pin_access -value true
set_app_options -name route.common.post_detail_route_fix_soft_violations -value true
set_app_options -name route.global.via_cut_modeling -value true
set_app_options -name route.common.connect_floating_shapes -value true
set_app_options -name route.detail.check_patchable_drc_from_fixed_shapes -value true
set_app_options -name route.detail.enable_fixing_selective_design_rule_violations_on_fixed_shapes -value true

# prepare for macros proper routing
#set c2_macro_pins [get_flat_pins -of_objects [get_flat_cells -filter "design_type==macro"] -filter "layer_name=~*C2"]
#set_attribute -objects [get_terminals -of_objects $c2_macro_pins] -name port.connect_within_pin -value via_wire
set_app_options -name route.common.derive_connect_within_pin_via_region -value true

if {$TIMING_DRIVEN eq {yes}} {
    set_app_options -name route.global.timing_driven -value true
    set_app_options -name route.track.timing_driven -value true
    set_app_options -name route.common.rc_driven_setup_effort_level -value high
    set_app_options -name opt.timing.effort -value high
}

set_app_options -name ccd.hold_control_effort -value ultra
#set_app_options -name clock_opt.hold.effort -value high

puts ""
puts "===="
puts "6 - POWER PLANNING"
puts "===="
puts ""




# No VDD/VSS pins
# connect_pg_net -net VDD [get_pins */VDD]
# connect_pg_net -net VSS [get_pins */VSS]

#================================================================================================
# Ring core
#================================================================================================
# Create the power and ground ring pattern
create_pg_ring_pattern ring_pattern -horizontal_layer @hlayer \
-horizontal_width {@hwidth} -horizontal_spacing {@hspace} \
-vertical_layer @vlayer -vertical_width {@vwidth} \
-vertical_spacing {@vspace} -corner_bridge @cbridge \
-parameters {hlayer hwidth hspace
vlayer vwidth vspace cbridge}

# Set the ring strategy to apply the ring_pattern
# pattern to the core area and set the width
# and spacing parameters
set_pg_strategy ring_strat -core \
-pattern {{name: ring_pattern} {nets: {VDD VSS}}
{offset: {0 0}} {parameters: {C6 0.5 0.5 C5 0.5 0.5 true}}} \
-extension {{stop: design_boundary}}

# Create the ring in the design
compile_pg -strategies ring_strat
connect_pg_net -automatic
connect_pg_net -net VDD [get_pins -physical_context *VDD*]
connect_pg_net -net VSS [get_pins -physical_context *VSS*]
connect_pg_net -net VSS [get_pins -physical_context *VNW_N]
connect_pg_net -net VSS [get_pins -physical_context *VPW_P]
#================================================================================================
# Power stripes
#================================================================================================
# Create the power and ground stripes pattern

create_pg_mesh_pattern mesh -parameters {layer_h width_h pitch_h off_h layer_v width_v pitch_v off_v} -layers {{{vertical_layer: @layer_v}{width: @width_v} {spacing: minimum}{pitch: @pitch_v} {offset: @off_v}} {{horizontal_layer: @layer_h}{width: @width_h} {spacing: minimum} {pitch: @pitch_h} {offset: @off_h}}}

set_pg_strategy smesh -pattern {{pattern: mesh}{nets: VDD VSS} {parameters: C6 0.5 15 2 C5 0.5 15 2}} -core -extension {{stop: outermost_ring}}

compile_pg -strategies smesh
connect_pg_net -automatic
connect_pg_net -net VDD [get_pins -physical_context *VDD*]
connect_pg_net -net VSS [get_pins -physical_context *VSS*]
connect_pg_net -net VSS [get_pins -physical_context *VNW_N]
connect_pg_net -net VSS [get_pins -physical_context *VPW_P]
#================================================================================================
# Power rails
#================================================================================================
# Create the power and ground rails pattern for the Standard cells

create_pg_std_cell_conn_pattern cells_pg_patt -parameters {my_metal w} \
   -layers {@my_metal} \
   -rail_width {@w @w} -check_std_cell_drc true 
set_pg_strategy scells -core -pattern {{name : cells_pg_patt} {nets : {VDD VSS}}{parameters: {M1 0.08}}} -extension {{stop: outermost_ring}} 
compile_pg -strategies scells

connect_pg_net -automatic
connect_pg_net -net VDD [get_pins -physical_context *VDD*]
connect_pg_net -net VSS [get_pins -physical_context *VSS*]
connect_pg_net -net VSS [get_pins -physical_context *VNW_N]
connect_pg_net -net VSS [get_pins -physical_context *VPW_P]

puts ""
puts "===="
puts "7 - PERFORM PLACEMENT OF STANDARD CELLS"
puts "===="
puts ""

create_placement -floorplan
report_design -all


puts ""
puts "===="
puts "8 - PORT PLACEMENT"
puts "===="
puts ""
set_block_pin_constraints -self -allowed_layers "C1 C2 C3 C4 C5 C6"
set_block_pin_constraints -self -sides {1}
place_pins -ports [get_ports {write_data_i* write_addr_i* read_data_i* write_i read_i*}]
set_block_pin_constraints -self -sides {2}; 
place_pins -ports [get_ports {enable_i* head_i* match* clk}]

connect_pg_net -automatic

#remove_redundant_shapes

connect_pg_net -automatic
connect_pg_net -net VDD [get_pins -physical_context *VDD*]
connect_pg_net -net VSS [get_pins -physical_context *VSS*]
connect_pg_net -net VSS [get_pins -physical_context *VNW_N]
connect_pg_net -net VSS [get_pins -physical_context *VPW_P]
#connect_pg_net -tie [get_nets -hierarchical -filter "net_type=*tie"]

puts ""
puts "===="
puts "8 - LEGALIZE AND OPTIMIZE PLACEMENT"
puts "===="
puts ""

legalize_placement

connect_pg_net -automatic
connect_pg_net -net VDD [get_pins -physical_context *VDD*]
connect_pg_net -net VSS [get_pins -physical_context *VSS*]
connect_pg_net -net VSS [get_pins -physical_context *VNW_N]
connect_pg_net -net VSS [get_pins -physical_context *VPW_P]


report_qor

#===========================================================
#    PLACEMENT OPTIMIZATION
#===========================================================
puts ""
puts "===="
puts "PLACEMENT OPTIMIZATION"
puts "===="
puts ""
#uncomented 10/05/2023
set_app_options -name place_opt.congestion.effort -value medium 
set_app_options -name place_opt.flow.do_path_opt -value true
set_app_options -name place.legalize.enable_advanced_legalizer -value true
set_app_options -name place.legalize.enable_advanced_legalizer_cellmap -value true
#uncomented 10/05/2023
set_app_options -name place.legalize.enable_pin_color_alignment_check -value true
set_app_options -name opt.timing.effort -value high


place_opt
report_qor -summary
create_shape -shape_type rect -layer LB -port VSS -boundary {{-1.5 1} {-1 1.5}}
create_shape -shape_type rect -layer LB -port VDD -boundary {{-0.5 1} {0 1.5}}

#connect_pg_net -net VDD [get_pins */VDD]
#connect_pg_net -net VSS [get_pins */VSS]
#connect_pg_net -net VDD [get_pins -physical_context *VDD*]
#connect_pg_net -net VSS [get_pins -physical_context *VSS*]

connect_pg_net -automatic

#no se si esto dejarlo o quitarlo 14/12/2022
#connect_pg_net -net VSS [get_pins -hierarchical */VPW_P]
#connect_pg_net -net VSS [get_pins -hierarchical */VNW_N]

connect_pg_net -automatic
connect_pg_net -net VDD [get_pins -physical_context *VDD*]
connect_pg_net -net VSS [get_pins -physical_context *VSS*]
connect_pg_net -net VSS [get_pins -physical_context *VNW_N]
connect_pg_net -net VSS [get_pins -physical_context *VPW_P]

report_qor -summary
save_block -as $lib_name:cam_post_place_opt.design

puts ""
puts "===="
puts "9 - CTS"
puts "===="
puts ""
#.....................................................................
## Specifying cells for CTS
set cts_libcells [get_lib_cells {*HDBSLT20_BUF_S_*}]
set_dont_touch $cts_libcells false
set_lib_cell_purpose -exclude cts [get_lib_cells]
set_lib_cell_purpose -include cts $cts_libcells
derive_clock_cell_references -output cts_leq_cells.tcl
#.....................................................................
set_app_options -name cts.common.max_fanout -value 10

#Pre-CTS Sanity Check
report_clock_settings
report_clock_routing_rules
check_clock_trees
check_legality

clock_opt -from build_clock -to build_clock
insert_via_ladders \
        -allow_patching true \
        -shift_vias_on_transition_layers true \
        -allow_drcs false \
        -ignore_rippable_shapes false \
        -relax_pin_layer_metal_spacing_rules false \
        -relax_line_end_via_enclosure_rule false \
        -strictly_honor_cut_table false \

clock_opt -from build_clock -to route_clock

connect_pg_net -automatic
connect_pg_net -net VDD [get_pins -physical_context *VDD*]
connect_pg_net -net VSS [get_pins -physical_context *VSS*]
connect_pg_net -net VSS [get_pins -physical_context *VNW_N]
connect_pg_net -net VSS [get_pins -physical_context *VPW_P]


report_qor -summary
#===========================================================
#    ROUTING
#===========================================================
puts ""
puts "===="
puts "10 - ROUTING"
puts "===="
puts ""


set_app_options -name route.auto_via_ladder.update_during_route -value true
set_app_options -name time.enable_ccs_rcv_cap -value true
set_app_options -name time.si_enable_analysis -value true

check_routes
connect_pg_net -automatic
#adding on 31/Enero/2022
remove_routing_blockages -all
#remove_keepout_margin -type 

optimize_routability -check_drc_rules
optimize_routability
#optimize_routability -check_drc_rules

connect_pg_net -automatic
connect_pg_net -net VSS [get_pins -physical_context */VPW_P]
connect_pg_net -net VSS [get_pins -physical_context */VNW_N]

puts "GLOBAL ROUTING"
route_global -reuse_existing_global_route false
puts "ROUTE TRACK"
route_track
puts "DETAIL ROUTING"
route_detail -max_number_iterations 100

set_app_options -name route_opt.flow.enable_ccd -value true; #add on 10/05/2023

report_qor -summary

puts "ROUTING OPTIMIZATION"
set_app_options -name route_opt.flow.enable_ccd -value true

route_opt

connect_pg_net -automatic
connect_pg_net -net VDD [get_pins -physical_context *VDD]
connect_pg_net -net VSS [get_pins -physical_context *VSS]
connect_pg_net -net VSS [get_pins -physical_context *VNW_N]
connect_pg_net -net VSS [get_pins -physical_context *VPW_P]

report_qor -summary

 set route_opt_for_TNS_decrease 10
for {set i 0} {$i < $route_opt_for_TNS_decrease} {incr i} {
    route_opt
    report_qor -summary
}


set route_detail_it_for_drc 10
for {set i 0} {$i < $route_detail_it_for_drc} {incr i} {
    route_detail -incremental true
    optimize_routability -check_drc_rules
    report_qor -summary
}

#===========================================================
#    ADDING CORE FILLERS
#===========================================================

puts ""
puts "===="
puts "ADDING CORE FILLERS"
puts "===="
puts ""

set_app_options -name place.rules.min_od_filler_size -value 1

create_stdcell_fillers -continue_on_error -lib_cells { HDBSLT20_FILL256 HDBSLT20_FILL128 HDBSLT20_FILL64 HDBSLT20_FILL32 HDBSLT20_FILL16 HDBSLT20_FILL8 HDBSLT20_FILL5 HDBSLT20_FILL4 HDBSLT20_FILL3 HDBSLT20_FILL2 HDBSLT20_FILL1 } 
connect_pg_net -automatic
connect_pg_net -net VDD [get_pins -physical_context *VDD]
connect_pg_net -net VSS [get_pins -physical_context *VSS]
connect_pg_net -net VSS [get_pins -physical_context *VNW_N]
connect_pg_net -net VSS [get_pins -physical_context *VPW_P]

check_empty_space; 

#remove_stdcell_fillers_with_violation
route_detail -incremental true
optimize_routability -check_drc_rules

report_qor -summary


puts ""
puts "===="
puts "11 - REPORTING AND SAVING"
puts "===="
puts ""

if {$SIMPLE_GATES eq {no}} {
    report_qor -summary                                             > $dir_PnR_reports_all_gates/qor_summary.txt
    report_design -all                                              > $dir_PnR_reports_all_gates/design.txt
    report_constraints -all_violators                               > $dir_PnR_reports_all_gates/constraints.txt
    report_utilization                                              > $dir_PnR_reports_all_gates/utilization.txt
    report_placement                                                > $dir_PnR_reports_all_gates/placement.txt
    report_ports                                                    > $dir_PnR_reports_all_gates/ports.txt  
    report_path_groups                                              > $dir_PnR_reports_all_gates/path_groups.txt
    report_timing -max_paths 50                                     > $dir_PnR_reports_all_gates/timing.txt
    report_timing -max_paths 50 -report_by scenario                 > $dir_PnR_reports_all_gates/timing_2.txt
    report_timing -delay_type min -max_paths 50 -report_by scenario > $dir_PnR_reports_all_gates/timing_hold.txt
    report_clock_qor                                                > $dir_PnR_reports_all_gates/clock_qor.txt
    report_power                                                    > $dir_PnR_reports_all_gates/power.txt
    report_power -scenario typ                                      > $dir_PnR_reports_all_gates/power_typ.txt
    report_congestion                                               > $dir_PnR_reports_all_gates/congestion.txt
    check_routes                                                      
    optimize_routability -check_drc_rules                           > $dir_PnR_reports_all_gates/drc.txt
    check_empty_space; #REVISA SI FALTAN FILLERS                      
    report_net_fanout                                               > $dir_PnR_reports_all_gates/fanout.txt
puts "====saving===="
print_message_info -ids * -summary

save_block -as $lib_name:cam_post_filler_all_gates.design

write_sdf                       $dir_PnR_results_all_gates/PnR_delays.sdf
write_verilog -hierarchy all   -split_bus  $dir_PnR_results_all_gates/PnR_netlist.v
}

if {$SIMPLE_GATES eq {yes}} {
    report_qor -summary                                             > $dir_PnR_reports_simple_gates/qor_summary.txt
    report_design -all                                              > $dir_PnR_reports_simple_gates/design.txt
    report_constraints -all_violators                               > $dir_PnR_reports_simple_gates/constraints.txt
    report_utilization                                              > $dir_PnR_reports_simple_gates/utilization.txt
    report_placement                                                > $dir_PnR_reports_simple_gates/placement.txt
    report_ports                                                    > $dir_PnR_reports_simple_gates/ports.txt  
    report_path_groups                                              > $dir_PnR_reports_simple_gates/path_groups.txt
    report_timing -max_paths 50                                     > $dir_PnR_reports_simple_gates/timing.txt
    report_timing -max_paths 50 -report_by scenario                 > $dir_PnR_reports_simple_gates/timing_2.txt
    report_timing -delay_type min -max_paths 50 -report_by scenario > $dir_PnR_reports_simple_gates/timing_hold.txt
    report_clock_qor                                                > $dir_PnR_reports_simple_gates/clock_qor.txt
    report_power                                                    > $dir_PnR_reports_simple_gates/power.txt
    report_power -scenario typ                                      > $dir_PnR_reports_simple_gates/power_typ.txt
    report_congestion                                               > $dir_PnR_reports_simple_gates/congestion.txt
    check_routes                                                      
    optimize_routability -check_drc_rules                           > $dir_PnR_reports_simple_gates/drc.txt
    check_empty_space; #REVISA SI FALTAN FILLERS                      
    report_net_fanout                                               > $dir_PnR_reports_simple_gates/fanout.txt
puts "====saving===="
print_message_info -ids * -summary

save_block -as $lib_name:cam_post_filler_all_gates.design

write_sdf                       $dir_PnR_results_simple_gates/PnR_delays.sdf
write_verilog -hierarchy all    $dir_PnR_results_simple_gates/PnR_netlist.v
}


exit
