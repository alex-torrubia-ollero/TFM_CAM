
set DESIGN vlsu_cam_top
set DESIGN_LIBRARY $DESIGN

set INIT_DESIGN_BLOCK_NAME "init_design"

set REPORT_PREFIX $INIT_DESIGN_BLOCK_NAME

set RTL_SOURCE_FILES {vlsu_cam_top.v};


# setting variables
set clearence 5


set_host_options -max_cores 16
set TIMING_DRIVEN yes



