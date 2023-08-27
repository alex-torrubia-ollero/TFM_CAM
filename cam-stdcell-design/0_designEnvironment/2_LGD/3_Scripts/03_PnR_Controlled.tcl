
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
set FPL [expr 554*0.116]
set FPH [expr 121*0.72]

set mem_core_x_offset [expr $FPL-528*0.116]
set mem_core_y_offset [expr 0.72*1]

set welltap_position [expr 0.116*256+$mem_core_x_offset]

set write_data_i_delayer_y_offset [expr 0.72*60]
set_host_options -max_cores 16

set TIMING_DRIVEN yes

set SIMPLE_GATES yes
set lib_name CAM_controlled_placement_util_opt


puts ""
puts "===="
puts "0 - READING LIBRARY DATA"
puts "===="
puts ""

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
puts "3 - PLACING BOUNDARY CELLS"
puts "===="
puts ""

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


create_tap_cells -lib_cell */*_TAPSS -offset $welltap_position -distance 300 -skip_fixed_cells -pattern every_row

connect_pg_net -net VDD [get_pins -physical_context *VDD*]
connect_pg_net -net VSS [get_pins -physical_context *VSS*]
connect_pg_net -net VSS [get_pins -physical_context *VNW_N]
connect_pg_net -net VSS [get_pins -physical_context *VPW_P]

get_voltage_areas
get_power_domains
report_voltage_areas

puts ""
puts "===="
puts "4 - PROJECT SETTINGS"
puts "===="
puts ""

set_app_options -name route.common.debug_remove_extension_floating_shapes -value true
set_app_options -name route.common.optimize_for_pin_access -value true
set_app_options -name route.common.post_detail_route_fix_soft_violations -value true
set_app_options -name route.global.via_cut_modeling -value true
set_app_options -name route.common.connect_floating_shapes -value true
set_app_options -name route.detail.check_patchable_drc_from_fixed_shapes -value true
set_app_options -name route.detail.enable_fixing_selective_design_rule_violations_on_fixed_shapes -value true

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
puts "5 - POWER PLANNING"
puts "===="
puts ""

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
puts "6 - CONTROLLED PLACEMENT OF STANDARD CELLS"
puts "===="
puts ""

source ${dir_scripts}/99_Controlled_placement.tcl


puts ""
puts "===="
puts "7 - PORT PLACEMENT"
puts "===="
puts ""

set_block_pin_constraints -self -allowed_layers "C1 C2 C3 C4 C5 C6"
set_block_pin_constraints -self -sides {1}
place_pins -ports [get_ports {write_data_i* write_addr_i* read_data_i* write_i read_i*}]
set_block_pin_constraints -self -sides {2}; 
place_pins -ports [get_ports {enable_i* head_i* match* clk rst arst_n}]

connect_pg_net -automatic

puts ""
puts "===="
puts "8 - LEGALIZE AND FIX CONTROLLED PLACEMENT CELLS"
puts "===="
puts ""

legalize_placement

set_attribute -objects [get_cells {asic_model_gen.memory_core/*/*}] -name physical_status -value fixed
set_attribute -objects [get_cells {filler*}] -name physical_status -value fixed
connect_pg_net -automatic


report_qor > ${dir_PnR_reports_controlled_placement}/1_place_qor.txt
report_timing -path_type full_clock -max_paths 5 -report_by scenario > ${dir_PnR_reports_controlled_placement}/1_place_timing.txt


puts ""
puts "===="
puts "PLACEMENT OPTIMIZATION"
puts "===="
puts ""

set_app_options -name place_opt.congestion.effort -value medium 
set_app_options -name place_opt.flow.do_path_opt -value true
set_app_options -name place.legalize.enable_advanced_legalizer -value true
set_app_options -name place.legalize.enable_advanced_legalizer_cellmap -value true

set_app_options -name place.legalize.enable_pin_color_alignment_check -value true
remove_cells filler*
place_opt

create_shape -shape_type rect -layer C5 -port VSS -boundary {{-1.5 1} {-1 1.5}}
create_shape -shape_type rect -layer C5 -port VDD -boundary {{-0.5 1} {0 1.5}}

connect_pg_net -automatic
connect_pg_net -net VDD [get_pins -physical_context *VDD*]
connect_pg_net -net VSS [get_pins -physical_context *VSS*]
connect_pg_net -net VSS [get_pins -physical_context *VNW_N]
connect_pg_net -net VSS [get_pins -physical_context *VPW_P]

report_qor -summary
#save_block -as test:cam_post_place_opt.design

puts ""
puts "===="
puts "9 - CTS"
puts "===="
puts ""


set cts_libcells [get_lib_cells {*HDBSLT20_BUF_S_*}]
set_dont_touch $cts_libcells false
set_lib_cell_purpose -exclude cts [get_lib_cells]
set_lib_cell_purpose -include cts $cts_libcells
derive_clock_cell_references -output cts_leq_cells.tcl
#.....................................................................

#set_app_options -name cts.common.max_fanout -value $fanout

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




puts ""
puts "===="
puts "10 - ROUTING"
puts "===="
puts ""

set_app_options -name route.auto_via_ladder.update_during_route -value true; 
set_app_options -name time.enable_ccs_rcv_cap -value true
set_app_options -name time.si_enable_analysis -value true

check_routes
connect_pg_net -automatic
#adding on 31/Enero/2022
remove_routing_blockages -all
optimize_routability -check_drc_rules
optimize_routability
#optimize_routability -check_drc_rules

    connect_pg_net -automatic
    connect_pg_net -net VDD [get_pins -physical_context *VDD*]
    connect_pg_net -net VSS [get_pins -physical_context *VSS*]
    connect_pg_net -net VSS [get_pins -physical_context *VNW_N]
    connect_pg_net -net VSS [get_pins -physical_context *VPW_P]

puts "GLOBAL ROUTING"
route_global
puts "ROUTE TRACK"
route_track
puts "DETAIL ROUTING"
route_detail -incremental true -initial_drc_from_input true
#route_detail -max_number_iterations 10
route_detail -max_number_iterations 100
report_qor -summary
set_app_options -name route_opt.flow.enable_ccd -value true
puts "ROUTING OPTIMIZATION"
route_opt

connect_pg_net -net VDD [get_pins -physical_context *VDD]
connect_pg_net -net VSS [get_pins -physical_context *VSS]
connect_pg_net -net VSS [get_pins -physical_context *VNW_N]
connect_pg_net -net VSS [get_pins -physical_context *VPW_P]

report_qor -summary
    
 set route_opt_for_TNS_decrease 15
for {set i 0} {$i < $route_opt_for_TNS_decrease} {incr i} {
    route_opt
    report_qor -summary
}


set route_detail_it_for_drc 15
for {set i 0} {$i < $route_detail_it_for_drc} {incr i} {
    route_detail -incremental true
    optimize_routability -check_drc_rules
    report_qor -summary
}

puts ""
puts "===="
puts "ADDING CORE FILLERS"
puts "===="
puts ""

set_app_options -name place.rules.min_od_filler_size -value 1

create_stdcell_fillers -continue_on_error -lib_cells { HDBSLT20_FILL256 HDBSLT20_FILL128 HDBSLT20_FILL64 HDBSLT20_FILL32 HDBSLT20_FILL16 HDBSLT20_FILL8 HDBSLT20_FILL5 HDBSLT20_FILL4 HDBSLT20_FILL3 HDBSLT20_FILL2 HDBSLT20_FILL1 } 
connect_pg_net -automatic
connect_pg_net -net VDD [get_pins -physical_context *VDD*]
connect_pg_net -net VSS [get_pins -physical_context *VSS*]
connect_pg_net -net VSS [get_pins -physical_context *VNW_N]
connect_pg_net -net VSS [get_pins -physical_context *VPW_P]

#remove_stdcell_fillers_with_violation
check_empty_space; 

optimize_routability -check_drc_rules

report_qor -summary
check_empty_space; 
    
    


puts ""
puts "===="
puts "11 - REPORTING AND SAVING"
puts "===="
puts ""

report_qor -summary                                             > $dir_PnR_reports_controlled_placement/qor_summary.txt
report_design -all                                              > $dir_PnR_reports_controlled_placement/design.txt
report_constraints -all_violators                               > $dir_PnR_reports_controlled_placement/violations.txt
report_constraints -all_violators -corners slow_corner          > $dir_PnR_reports_controlled_placement/violations_slow_corner.txt
report_utilization                                              > $dir_PnR_reports_controlled_placement/utilization.txt
report_placement                                                > $dir_PnR_reports_controlled_placement/placement.txt
report_ports                                                    > $dir_PnR_reports_controlled_placement/ports.txt  
report_path_groups                                              > $dir_PnR_reports_controlled_placement/path_groups.txt
report_timing -max_paths 50                                     > $dir_PnR_reports_controlled_placement/timing.txt
report_timing -max_paths 50 -report_by scenario                 > $dir_PnR_reports_controlled_placement/timing_2.txt
report_timing -delay_type min -max_paths 50 -report_by scenario > $dir_PnR_reports_controlled_placement/timing_hold.txt
report_clock_qor                                                > $dir_PnR_reports_controlled_placement/clock_qor.txt
report_power                                                    > $dir_PnR_reports_controlled_placement/power.txt
report_power -scenario typ                                      > $dir_PnR_reports_controlled_placement/power_typ.txt
report_congestion                                               > $dir_PnR_reports_controlled_placement/congestion.txt
check_routes                                                      
optimize_routability -check_drc_rules                           > $dir_PnR_reports_controlled_placement/drc.txt
check_empty_space; #REVISA SI FALTAN FILLERS                      $dir_PnR_reports
report_net_fanout                             > $dir_PnR_reports_controlled_placement/fanout.txt
puts "====saving===="
print_message_info -ids * -summary
save_block -as $lib_name:cam_backup_controlled_placement.design



    write_sdf $dir_PnR_results_controlled_placement/PnR_delays.sdf
write_verilog -hierarchy all $dir_PnR_results_controlled_placement/PnR_netlist.v -split_bus

    
    
