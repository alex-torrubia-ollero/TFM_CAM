# TFM_CAM
This github repository contains my Master thesis code. This repository is structured:
- 0_designEnvironment: Where the environments for Synthesis and physical design are located for HLD, LLD, LGD, with the following organization:
    - 0_HLD
    - 1_LLD
    - 2_LGD
        - 1_RTL: This locates the code, currently unused as the src/rtl folder is used.
        - 2_Constraints: Folder where the constraints are located.
        - 3_Scripts: Scripts for the synthesis and physical design tools.
            - 01_Synth.tcl: Synthesis script
            - 02_PnR.tcl Physical design script
            - (Only for LGD) 03_PnR_Controlled.tcl: Physical design script for controlled placement
            - (Only for LGD) 99_Controlled_Placement.tcl: Standard cell placement
            - 10_Parameters: Parameters of the design 
            - 11_Paths: Path variables
            - 12_Libraries used: Path of the used libraries and their correspoinding variables.
        - 4_Output: Folder where the Synthesis and physical design reports are located  
        - 5_Resuts: Folder where the Synthesis and Physical design output SDF and netlists are located
- src/rtl: Where the RTL is located, 
- tb/rtl: Where the testbench code is located 