#Nombre del grupo
set memory memory                 
set tot_col 320
set tot_row 103

set delayer_lower delayer_lower
set delayer_upper delayer_upper
set delayer_col 1
set delayer_row 50

proc rp_groupCR {name_rp listC listR nameinst init} {
    set index $init
    set sum 0
    foreach y $listC {                  
      foreach x $listR {   
                set cellIns [lindex $nameinst $index]
                puts $cellIns
                set command "add_to_rp_group $name_rp -cells \[get_cells -hierarchical * -filter \"@full_name==$cellIns\"\] -column $y -row $x"  
        puts $command
        eval $command
        incr index
        }
    }
}

   
create_cell {filler_w2[0] filler_w2[2] filler_w2[4] filler_w2[6] filler_w2[8] filler_w2[10] filler_w2[12] filler_w2[14] filler_w2[16] filler_w2[18] filler_w2[20] filler_w2[22] filler_w2[24] filler_w2[26] filler_w2[28] filler_w2[30] filler_w2[32]} *FILL2*

create_cell {filler_w2_2[0] filler_w2_2[2] filler_w2_2[4] filler_w2_2[6] filler_w2_2[8] filler_w2_2[10] filler_w2_2[12] filler_w2_2[14] filler_w2_2[16] filler_w2_2[18] filler_w2_2[20] filler_w2_2[22] filler_w2_2[24] filler_w2_2[26] filler_w2_2[28] filler_w2_2[30] filler_w2_2[32]} *FILL2*

create_cell {filler_w8_1[0] filler_w8_1[2] filler_w8_1[4] filler_w8_1[6] filler_w8_1[8] filler_w8_1[10] filler_w8_1[12] filler_w8_1[14] filler_w8_1[16] filler_w8_1[18] filler_w8_1[20] filler_w8_1[22] filler_w8_1[24] filler_w8_1[26] filler_w8_1[28] filler_w8_1[30] filler_w8_1[32]} *FILL8*
create_cell {filler_w8_2[0] filler_w8_2[2] filler_w8_2[4] filler_w8_2[6] filler_w8_2[8] filler_w8_2[10] filler_w8_2[12] filler_w8_2[14] filler_w8_2[16] filler_w8_2[18] filler_w8_2[20] filler_w8_2[22] filler_w8_2[24] filler_w8_2[26] filler_w8_2[28] filler_w8_2[30] filler_w8_2[32]} *FILL8*
create_cell {filler_w8_3[0] filler_w8_3[2] filler_w8_3[4] filler_w8_3[6] filler_w8_3[8] filler_w8_3[10] filler_w8_3[12] filler_w8_3[14] filler_w8_3[16] filler_w8_3[18] filler_w8_3[20] filler_w8_3[22] filler_w8_3[24] filler_w8_3[26] filler_w8_3[28] filler_w8_3[30] filler_w8_3[32]} *FILL8*
create_cell {filler_w4[0] filler_w4[2] filler_w4[4] filler_w4[6] filler_w4[8] filler_w4[10] filler_w4[12] filler_w4[14] filler_w4[16] filler_w4[18] filler_w4[20] filler_w4[22] filler_w4[24] filler_w4[26] filler_w4[28] filler_w4[30] filler_w4[32]} *FILL4*
remove_rp_groups -all

# DATA DELAYER GROUP
puts "========================"
puts " DATA DELAYER PLACEMENT "
puts "========================"
create_rp_group -name $delayer_lower -columns $delayer_col -rows $delayer_row
create_rp_group -name $delayer_upper -columns $delayer_col -rows $delayer_row

set column_FFs_low {}
    for {set bit_position 49} {$bit_position >= 25} {incr bit_position -1} {
        lappend column_FFs_low asic_model_gen.write_data_ffs/write_data_middle_reg[0][$bit_position]
        lappend column_FFs_low asic_model_gen.write_data_ffs/data_delayed_reg[0][$bit_position]
    }
    set listR [list 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49]
    
    set delayer_cell [rp_groupCR $delayer_lower 0 $listR $column_FFs_low 0]
    
set column_FFs_up {}
    for {set bit_position 24} {$bit_position >= 0} {incr bit_position -1} {
        lappend column_FFs_up asic_model_gen.write_data_ffs/write_data_middle_reg[0][$bit_position]
        lappend column_FFs_up asic_model_gen.write_data_ffs/data_delayed_reg[0][$bit_position]
    }
    set listR [list 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49]
    
    set delayer_cell [rp_groupCR $delayer_upper 0 $listR $column_FFs_up 0]
    
        
set_rp_group_options $delayer_lower -anchor_corner bottom_left \
    -x_offset 1.044 -y_offset 0.72 -tiling_type horizontal_compression -place_around_fixed_cells none -allow_non_rp_cells_on_blockages -optimization_restriction no_opt -move_effort low

set_rp_group_options $delayer_upper -anchor_corner bottom_left \
    -x_offset 1.044 -y_offset $write_data_i_delayer_y_offset -tiling_type horizontal_compression -place_around_fixed_cells none -allow_non_rp_cells_on_blockages -optimization_restriction no_opt -move_effort low
    
    

    
puts "========================"
puts "    MEMORY PLACEMENT    "
puts "========================"    
    
create_rp_group -name $memory -columns $tot_col -rows $tot_row 

for {set column_iterator 0} {$column_iterator < 32} {incr column_iterator 2} {

    set col0 {}

    for {set bit_position 49} {$bit_position >= 25} {incr bit_position -1} {
        lappend col0 asic_model_gen.memory_core/word[$column_iterator].word_bits[$bit_position].memory_cell/genblk1[1].XNOR_comparator
        lappend col0 asic_model_gen.memory_core/word[$column_iterator].word_bits[$bit_position].memory_cell/cam_latch
    }

    lappend col0 asic_model_gen.memory_core/word[$column_iterator].clkgate/SC_clockgate

    for {set bit_position 24} {$bit_position >= 0} {incr bit_position -1} {
        lappend col0 asic_model_gen.memory_core/word[$column_iterator].word_bits[$bit_position].memory_cell/genblk1[1].XNOR_comparator
        lappend col0 asic_model_gen.memory_core/word[$column_iterator].word_bits[$bit_position].memory_cell/cam_latch
    }
    lappend col0 asic_model_gen.memory_core/word[$column_iterator].match_word[0].match_enabler_gate/match_enable_gate
    lappend col0 asic_model_gen.memory_core/word[$column_iterator].match_word[1].match_enabler_gate/match_enable_gate
    
    puts $col0

    set listR [list 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 101 102]
    
    set column_placement [expr $column_iterator*9]
    set celda1 [rp_groupCR $memory $column_placement $listR $col0 0]

    set col1 {}
    for {set bit_position 49} {$bit_position >= 25} {incr bit_position -1} {
        lappend col1 asic_model_gen.memory_core/word[$column_iterator].word_bits[$bit_position].memory_cell/genblk1[2].XNOR_comparator
        lappend col1 asic_model_gen.memory_core/word[$column_iterator].word_bits[$bit_position].memory_cell/genblk1[0].XNOR_comparator
        }
    
        lappend col1 asic_model_gen.memory_core/word[$column_iterator].clkgate/TIELO_CKGT
        
    for {set bit_position 24} {$bit_position >= 0} {incr bit_position -1} {
        lappend col1 asic_model_gen.memory_core/word[$column_iterator].word_bits[$bit_position].memory_cell/genblk1[2].XNOR_comparator
        lappend col1 asic_model_gen.memory_core/word[$column_iterator].word_bits[$bit_position].memory_cell/genblk1[0].XNOR_comparator 
        }
        
        lappend col1 asic_model_gen.memory_core/word[$column_iterator].match_word[2].match_enabler_gate/match_enable_gate
        lappend col1 filler_w8_1[$column_iterator] 
    set listR [list 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 101 102]
    
    set column_placement [expr $column_iterator*9+1]
    set celda1 [rp_groupCR $memory $column_placement $listR $col1 0]

    set col2 {}

    lappend col2 filler_w2[$column_iterator] 
    lappend col2 asic_model_gen.memory_core/word[$column_iterator].match_word[0].word_match_logic/genblk1.first_stage_nand4[0].NAND4_STAGE_1
    lappend col2 filler_w8_2[$column_iterator] 
    set listR [list 50 101 102]

        set column_placement [expr $column_iterator*9+2]
    set celda1 [rp_groupCR $memory $column_placement $listR $col2 0]

    set col_match {}
    for {set port_iterator 2} {$port_iterator >= 0} {incr port_iterator -1} {
        for {set word_iterator [expr $column_iterator+1]} {$word_iterator >= $column_iterator} {incr word_iterator -1} {
        lappend col_match asic_model_gen.memory_core/word[$word_iterator].match_word[$port_iterator].word_match_logic/genblk3.first_stage_nand2[0].NAND2_STAGE_1
        }
    }

    for {set cell_iterator 11} {$cell_iterator >= 10} {incr cell_iterator -1} {
        for {set port_iterator 2} {$port_iterator >= 0} {incr port_iterator -1} {
            for {set word_iterator [expr $column_iterator+1]} {$word_iterator >= $column_iterator} {incr word_iterator -1} {
                lappend col_match asic_model_gen.memory_core/word[$word_iterator].match_word[$port_iterator].word_match_logic/genblk1.first_stage_nand4[$cell_iterator].NAND4_STAGE_1
            }
        }
    }

    for {set cell_iterator 2} {$cell_iterator >= 2} {incr cell_iterator -1} {
        for {set port_iterator 2} {$port_iterator >= 0} {incr port_iterator -1} {
            for {set word_iterator [expr $column_iterator+1]} {$word_iterator >= $column_iterator} {incr word_iterator -1} {
                lappend col_match asic_model_gen.memory_core/word[$word_iterator].match_word[$port_iterator].word_match_logic/genblk6.second_stage_nor4[$cell_iterator].NOR4_STAGE_2
            }
        }
    }

    for {set cell_iterator 9} {$cell_iterator >= 6} {incr cell_iterator -1} {
        for {set port_iterator 2} {$port_iterator >= 0} {incr port_iterator -1} {
            for {set word_iterator [expr $column_iterator+1]} {$word_iterator >= $column_iterator} {incr word_iterator -1} {
                lappend col_match asic_model_gen.memory_core/word[$word_iterator].match_word[$port_iterator].word_match_logic/genblk1.first_stage_nand4[$cell_iterator].NAND4_STAGE_1
            }
        }
    }
                
            
            lappend col_match  asic_model_gen.memory_core/word[[expr $column_iterator+1]].match_word[2].word_match_logic/genblk10.third_stage_nand4[0].NAND4_STAGE_3
            lappend col_match  asic_model_gen.memory_core/word[$column_iterator].match_word[2].word_match_logic/genblk10.third_stage_nand4[0].NAND4_STAGE_3
            lappend col_match  asic_model_gen.memory_core/word[[expr $column_iterator+1]].match_word[1].word_match_logic/genblk10.third_stage_nand4[0].NAND4_STAGE_3
            lappend col_match  asic_model_gen.memory_core/word[[expr $column_iterator]].match_word[1].word_match_logic/genblk10.third_stage_nand4[0].NAND4_STAGE_3
            lappend col_match  asic_model_gen.memory_core/word[[expr $column_iterator+1]].match_word[0].word_match_logic/genblk10.third_stage_nand4[0].NAND4_STAGE_3
            lappend col_match  asic_model_gen.memory_core/word[$column_iterator].match_word[0].word_match_logic/genblk10.third_stage_nand4[0].NAND4_STAGE_3
            
            
    for {set cell_iterator 1} {$cell_iterator >= 1} {incr cell_iterator -1} {
        for {set port_iterator 2} {$port_iterator >= 0} {incr port_iterator -1} {
            for {set word_iterator [expr $column_iterator+1]} {$word_iterator >= $column_iterator} {incr word_iterator -1} {
                lappend col_match asic_model_gen.memory_core/word[$word_iterator].match_word[$port_iterator].word_match_logic/genblk6.second_stage_nor4[$cell_iterator].NOR4_STAGE_2
            }
        }
    }

    for {set cell_iterator 5} {$cell_iterator >= 2} {incr cell_iterator -1} {
        for {set port_iterator 2} {$port_iterator >= 0} {incr port_iterator -1} {
            for {set word_iterator [expr $column_iterator+1]} {$word_iterator >= $column_iterator} {incr word_iterator -1} {
                lappend col_match asic_model_gen.memory_core/word[$word_iterator].match_word[$port_iterator].word_match_logic/genblk1.first_stage_nand4[$cell_iterator].NAND4_STAGE_1
            }
        }
    }

    for {set cell_iterator 0} {$cell_iterator <= 0} {incr cell_iterator 1} {
        for {set port_iterator 2} {$port_iterator >= 0} {incr port_iterator -1} {
            for {set word_iterator [expr $column_iterator+1]} {$word_iterator >= $column_iterator} {incr word_iterator -1} {
                lappend col_match asic_model_gen.memory_core/word[$word_iterator].match_word[$port_iterator].word_match_logic/genblk6.second_stage_nor4[$cell_iterator].NOR4_STAGE_2
            }
        }
    }

    for {set cell_iterator 1} {$cell_iterator >= 0} {incr cell_iterator -1} {
        for {set port_iterator 2} {$port_iterator >= 0} {incr port_iterator -1} {
            for {set word_iterator [expr $column_iterator+1]} {$word_iterator >= $column_iterator} {incr word_iterator -1} {
                lappend col_match asic_model_gen.memory_core/word[$word_iterator].match_word[$port_iterator].word_match_logic/genblk1.first_stage_nand4[$cell_iterator].NAND4_STAGE_1
            }
        }
    }
        
    set listR [list 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 101]
    
    
        set column_placement [expr $column_iterator*9+4]
    set celda1 [rp_groupCR $memory $column_placement $listR $col_match 0]

    set col_match_2 {}
        lappend col_match_2 asic_model_gen.memory_core/word[[expr $column_iterator+1]].match_word[2].word_match_logic/genblk9.second_stage_inv[0].INV_STAGE_2
        lappend col_match_2 asic_model_gen.memory_core/word[$column_iterator].match_word[2].word_match_logic/genblk9.second_stage_inv[0].INV_STAGE_2
        lappend col_match_2 asic_model_gen.memory_core/word[[expr $column_iterator+1]].match_word[1].word_match_logic/genblk9.second_stage_inv[0].INV_STAGE_2
        lappend col_match_2 asic_model_gen.memory_core/word[$column_iterator].match_word[1].word_match_logic/genblk9.second_stage_inv[0].INV_STAGE_2
        lappend col_match_2 asic_model_gen.memory_core/word[[expr $column_iterator+1]].match_word[0].word_match_logic/genblk9.second_stage_inv[0].INV_STAGE_2
        lappend col_match_2 asic_model_gen.memory_core/word[$column_iterator].match_word[0].word_match_logic/genblk9.second_stage_inv[0].INV_STAGE_2
        lappend col_match_2 asic_model_gen.memory_core/word[[expr $column_iterator+1]].match_word[2].match_enabler_gate/match_enable_gate
        lappend col_match_2 filler_w8_3[$column_iterator] 
    set listR [list 0 1 2 3 4 5 101 102]
    
    
        set column_placement [expr $column_iterator*9+5]
    set celda1 [rp_groupCR $memory $column_placement $listR $col_match_2 0]

    #### Second word

    set col_1_0 {}

    for {set bit_position 49} {$bit_position >= 25} {incr bit_position -1} {
        lappend col_1_0 asic_model_gen.memory_core/word[[expr $column_iterator+1]].word_bits[$bit_position].memory_cell/genblk1[2].XNOR_comparator   
        lappend col_1_0 asic_model_gen.memory_core/word[[expr $column_iterator+1]].word_bits[$bit_position].memory_cell/genblk1[0].XNOR_comparator         
    }
    
    lappend col_1_0 asic_model_gen.memory_core/word[[expr $column_iterator+1]].clkgate/TIELO_CKGT

    for {set bit_position 24} {$bit_position >= 0} {incr bit_position -1} {
        lappend col_1_0 asic_model_gen.memory_core/word[[expr $column_iterator+1]].word_bits[$bit_position].memory_cell/genblk1[2].XNOR_comparator   
        lappend col_1_0 asic_model_gen.memory_core/word[[expr $column_iterator+1]].word_bits[$bit_position].memory_cell/genblk1[0].XNOR_comparator 
    }
    lappend col_1_0 asic_model_gen.memory_core/word[[expr $column_iterator+1]].match_word[1].match_enabler_gate/match_enable_gate
    lappend col_1_0 filler_w4[$column_iterator] 
    puts $col_1_0

    set listR [list 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 101 102]
    
    
        set column_placement [expr $column_iterator*9+6]
    set celda1 [rp_groupCR $memory $column_placement $listR $col_1_0 0]

    set col_1_1 {}
    
    for {set bit_position 49} {$bit_position >= 25} {incr bit_position -1} {
        lappend col_1_1 asic_model_gen.memory_core/word[[expr $column_iterator+1]].word_bits[$bit_position].memory_cell/cam_latch
        lappend col_1_1 asic_model_gen.memory_core/word[[expr $column_iterator+1]].word_bits[$bit_position].memory_cell/genblk1[1].XNOR_comparator
        
    }
    
    lappend col_1_1 asic_model_gen.memory_core/word[[expr $column_iterator+1]].clkgate/SC_clockgate

    for {set bit_position 24} {$bit_position >= 0} {incr bit_position -1} {
        lappend col_1_1 asic_model_gen.memory_core/word[[expr $column_iterator+1]].word_bits[$bit_position].memory_cell/cam_latch
        lappend col_1_1 asic_model_gen.memory_core/word[[expr $column_iterator+1]].word_bits[$bit_position].memory_cell/genblk1[1].XNOR_comparator
    }
        
    lappend col_1_1 asic_model_gen.memory_core/word[[expr $column_iterator+1]].match_word[0].match_enabler_gate/match_enable_gate
    
    set listR [list 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 101]

    
        set column_placement [expr $column_iterator*9+7]
    set celda1 [rp_groupCR $memory $column_placement $listR $col_1_1 0]

    set col_filler {}

    lappend col_filler filler_w2_2[$column_iterator] 

    set listR [list 101]
    
    
        set column_placement [expr $column_iterator*9+8]
    set celda1 [rp_groupCR $memory $column_placement $listR $col_filler 0]

    
}



set_rp_group_options $memory -anchor_corner bottom_left \
    -x_offset $mem_core_x_offset -y_offset $mem_core_y_offset  -tiling_type horizontal_compression -place_around_fixed_cells none -allow_non_rp_cells_on_blockages -optimization_restriction no_opt -move_effort low

set_app_options -name plan.place.timing_driven_mode -value std_cell
#create_placement -floorplan

create_placement -floorplan -timing_driven -effort high
create_placement -floorplan -timing_driven -effort high -incremental
#remove_cells filler* 
# remove_cells filler*





# 
# for {set i 0} {$i <= 49} {incr i} {
#     puts "set_individual_pin_constraints -ports write_data_i[$i]"
#     set y_loc [expr $FPH-0.72-0.72*3-1.44*$i]
#     set_individual_pin_constraints -ports write_data_i[$i] -location {0, $y_loc}
# }


# #Next function is to add gaps in rows/columns
# proc gapMem {Group Blockage type pitch} {
#     for {set i 0} {$i < [llength $Blockage]} {incr i} {
#         if {$type=="col"} {
#             set block [lindex $Blockage $i]
#             set res [add_to_rp_group $Group -blockage blk$Group\_$block -column $block -width [expr {int($pitch) -1}]]
#             puts $res
#             eval $res 
#         } else {
#             set block [lindex $Blockage $i]
#             set res [add_to_rp_group $Group -blockage blk$Group\_$block -row $block -height [expr {int($pitch) -1}]]
#             puts $res
#             eval $res   
#         }
#     
#     }
# }
# 
# 
# 
# 
# set site_height [get_attribute [ get_site_defs -filter " is_default == true " ] height ]
# set site_width [get_attribute  [ get_site_defs -filter " is_default == true " ] width]
# 
# set h [get_attribute [get_lib_cells gf22nsdvlogl20hdl116a_TT_0P80V_0P00V_0P00V_0P00V_25C/HDBSLT20_LDPQ_1] height] ; #latch height 0.7200
# set y_pitch $h
# set w_latch [get_attribute [get_lib_cells gf22nsdvlogl20hdl116a_TT_0P80V_0P00V_0P00V_0P00V_25C/HDBSLT20_LDPQ_1] width] ; #latch width 
# set wL1 [get_attribute [get_lib_cells gf22nsdvlogl20hdl116a_TT_0P80V_0P00V_0P00V_0P00V_25C/HDBSLT20_ND2_1] width] ; #NAND width
# set x_pitch [expr {$wL1 * 2}]
# set row_pitch [expr {($y_pitch/$site_height) + 1}]    
# set row_pitch [expr {ceil($row_pitch)}]
# set column_pitch [expr {($x_pitch/$site_width) + 1}]
# set column_pitch [expr {ceil($column_pitch)}]
