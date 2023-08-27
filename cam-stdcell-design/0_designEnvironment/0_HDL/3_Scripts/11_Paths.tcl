# Create the directories and set them on a variable for easy access
if {![file exists ../1_RTL]} {file mkdir ../1_RTL}
if {![file exists ../2_Constraints]} {file mkdir ../2_Constraints}
if {![file exists ../3_Scripts]} {file mkdir ../3_Scripts}
if {![file exists ../4_Output]} {file mkdir ../4_Output}
if {![file exists ../5_Results]} {file mkdir ../5_Results}

if {![file exists ../4_Output/1_Synth_reports]} {file mkdir ../4_Output/1_Synth_reports}
if {![file exists ../4_Output/1_Synth_reports/simple_gates]} {file mkdir ../4_Output/1_Synth_reports/simple_gates}
if {![file exists ../4_Output/1_Synth_reports/all_gates]} {file mkdir ../4_Output/1_Synth_reports/all_gates}

if {![file exists ../4_Output/2_PnR_reports]} {file mkdir ../4_Output/2_PnR_reports}
if {![file exists ../4_Output/2_PnR_reports/all_gates]} {file mkdir ../4_Output/2_PnR_reports/all_gates}
if {![file exists ../4_Output/2_PnR_reports/simple_gates]} {file mkdir ../4_Output/2_PnR_reports/simple_gates}


if {![file exists ../5_Results/1_Synth_results]} {file mkdir ../5_Results/1_Synth_results}
if {![file exists ../5_Results/1_Synth_results/all_gates]} {file mkdir ../5_Results/1_Synth_results/all_gates}
if {![file exists ../5_Results/1_Synth_results/simple_gates]} {file mkdir ../5_Results/1_Synth_results/simple_gates}

if {![file exists ../5_Results/2_PnR_results]} {file mkdir ../5_Results/2_PnR_results}
if {![file exists ../5_Results/2_PnR_results/all_gates]} {file mkdir ../5_Results/2_PnR_results/all_gates}
if {![file exists ../5_Results/2_PnR_results/simple_gates]} {file mkdir ../5_Results/2_PnR_results/simple_gates}


# Create directory variables for code compression
set dir_script              [file dirname [info script]]
set dir_rtl                 ${dir_script}/../../src/rtl
set file_sdc                ${dir_script}/../2_Constraints/test.tcl
set dir_scripts             ${dir_script}/../3_Scripts
set dir_output              ${dir_script}/../4_Output
set dir_results             ${dir_script}/../5_Results

# Synthesis folder vars
set dir_synth_reports_all_gates             ${dir_output}/1_Synth_reports/all_gates
set dir_synth_reports_simple_gates          ${dir_output}/1_Synth_reports/simple_gates
set dir_synth_results_all_gates             ${dir_results}/1_Synth_results/all_gates
set dir_synth_results_simple_gates          ${dir_results}/1_Synth_results/simple_gates

# PnR folder vars
set dir_PnR_reports_all_gates             ${dir_output}/2_PnR_reports/all_gates
set dir_PnR_reports_simple_gates          ${dir_output}/2_PnR_reports/simple_gates
set dir_PnR_results_all_gates             ${dir_results}/2_PnR_results/all_gates
set dir_PnR_results_simple_gates          ${dir_results}/2_PnR_results/simple_gates

# @EOF
