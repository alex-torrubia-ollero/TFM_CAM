set_app_options -name lib.setting.use_tech_scale_factor -value true


## search paths for SC, macros and RTL:
set search_path ""
    lappend search_path /technos/GF22FDX/standardCells/GF22FDX_SC9T_116CPP/globalfoundaries22nhsda/20hd/hdl/ulvt/6.01a/liberty/ccs_lvf/
    lappend search_path /users/atorrubia/WORK/cam-stdcell-design/0_designEnvironment/2_synth+PnR_logicGates/5_Results/1_Synth_results/simple_gates/

# .db files for SC and macros
set target_library ""
    lappend target_library gf22nsdvlogl20hdl116a_TT_0P90V_0P00V_0P00V_0P00V_85C.db
    lappend target_library gf22nsdvlogl20hdl116a_SSG_0P81V_0P00V_0P00V_0P00V_125C.db

#Synopsys lib
set synthetic_library [list dw_foundation.sldb]
set link_library [concat  [concat  * $target_library] $synthetic_library]


# Reference libraries is for the ndm of the SC and macros
set reference_libraries ""
    lappend reference_libraries /technos/GF22FDX/standardCells/GF22FDX_SC9T_116CPP/globalfoundaries22nhsda/20hd/hdl/ulvt/6.01a/ndm/gf22nsdvlogl20hdl116a_frame_only.ndm/

    
set TLUPLUS_TYP_FILE /technos/GF22FDX/PDK_V1.0_4.1/PlaceRoute/ICC2/TLUPlus/10M_2Mx_6Cx_2Ix_LBthick/22fdsoi_10M_2Mx_6Cx_2Ix_LBthick_nominal_detailed.tluplus
set TLUPLUS_MAX_FILE /technos/GF22FDX/PDK_V1.0_4.1/PlaceRoute/ICC2/TLUPlus/10M_2Mx_6Cx_2Ix_LBthick/22fdsoi_10M_2Mx_6Cx_2Ix_LBthick_FuncRCmaxDP_detailed.tluplus
set TLUPLUS_MIN_FILE /technos/GF22FDX/PDK_V1.0_4.1/PlaceRoute/ICC2/TLUPlus/10M_2Mx_6Cx_2Ix_LBthick/22fdsoi_10M_2Mx_6Cx_2Ix_LBthick_FuncRCminDP_detailed.tluplus

set TECH_FILE /technos/GF22FDX/PDK_V1.0_4.1/PlaceRoute/ICC2/Techfiles/10M_2Mx_6Cx_2Ix_LB/22FDSOI_10M_2Mx_6Cx_2Ix_LB_116cpp_9t_mw.tf
set ITFMAP_FILE /technos/GF22FDX/PDK_V1.0_4.1/PlaceRoute/ICC2/Techfiles/10M_2Mx_6Cx_2Ix_LB/22FDSOI_10M_2Mx_6Cx_2Ix_LB_StarRCXT_MW.map

# Create library
create_lib -technology /technos/GF22FDX/PDK_V1.0_4.1/PlaceRoute/ICC2/Techfiles/10M_2Mx_6Cx_2Ix_LB/22FDSOI_10M_2Mx_6Cx_2Ix_LB_116cpp_9t_mw.tf \
-ref_libs $reference_libraries $lib_name

create_block $lib_name:cam.design

