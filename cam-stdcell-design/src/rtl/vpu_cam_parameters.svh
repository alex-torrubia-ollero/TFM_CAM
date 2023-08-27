     //..select implementation: [0,bhvl] / [1,asic]
    parameter ASIC          = 1,
    //..depth
    parameter DEPTH         = 32,
    //..data width
    parameter DATA          = 50,
    //..payload width
    parameter PAYLOAD       = 0,
    //..update ports
    parameter WRITE         = 1,
    //..read ports
    parameter READ          = 3,
    //..index
    parameter INDEX         = $clog2(DEPTH),
    //..type: depth
    parameter type depth_t  = logic [DEPTH-1:0],
    //..type: index
    parameter type index_t  = logic [INDEX-1:0],
    //..type: data (update)
    parameter type udata_t  = logic [DATA+PAYLOAD-1:0],
    //..type: data (search)
    parameter type sdata_t  = logic [DATA-1:0],
    //..type: data (match)
    parameter type mdata_t  = logic [INDEX+PAYLOAD-1:0],
    //..enable priority logic: [1,on] / [0,off] (1 bit per read port)
    parameter PRIORITY_EN   = 'b111,
    //..priviledge mode: [1,first] (oldest) / [0,last] (youngest) (1 bit per read port)
    parameter PRIORITY_MODE = 'b110,
    //..single or multiple memories [0,single] / [1,multiple]
    //..(note: current support for "single" is "1 memory per read port")
    parameter MULTIPLE_MEM  = 0,
    
    /****************************************************************************/
    /* Matching tree gates parameters                                           */ 
    /* This parameters can vary if selected another matching logic distribution */
    /*                                                                          */
    /****************************************************************************/
    /* Number of NOR 4 on the first stage */
    parameter NUM_OF_NAND4_STAGE_1 = 12,
    /* Number of NOR 3 on the first stage */
    parameter NUM_OF_NAND3_STAGE_1 = 0,
    /* Number of NOR 2 on the first stage */
    parameter NUM_OF_NAND2_STAGE_1 = 1,
    /* Number of INV on the first stage*/
    parameter NUM_OF_INV_STAGE_1 = 0,
   
    /* Size of the outcoming bus from the first stage */
    parameter SIZE_OF_STAGE_1 = NUM_OF_NAND4_STAGE_1 + NUM_OF_NAND3_STAGE_1 + NUM_OF_NAND2_STAGE_1 + NUM_OF_INV_STAGE_1,
    
    /* Number of NAND 4 on the second stage */
    parameter NUM_OF_NOR4_STAGE_2 = 3,
    /* Number of NAND 3 on the second stage */
    parameter NUM_OF_NOR3_STAGE_2 = 0,
    /* Number of NAND 2 on the second stage */
    parameter NUM_OF_NOR2_STAGE_2 = 0,
    /* Number of INVERTERS on the second stage */
    parameter NUM_OF_INV_STAGE_2 = 1,
    
    /* Size of the outcoming bus from the second stage */
    parameter SIZE_OF_STAGE_2 = NUM_OF_NOR4_STAGE_2 + NUM_OF_NOR3_STAGE_2 + NUM_OF_NOR2_STAGE_2 + NUM_OF_INV_STAGE_2,
    
    /* Number of NOR 4 on the third stage */
    parameter NUM_OF_NAND4_STAGE_3 = 1,
    /* Number of NOR 3 on the third stage */
    parameter NUM_OF_NAND3_STAGE_3 = 0,
    /* Number of NOR 2 on the third stage */
    parameter NUM_OF_NAND2_STAGE_3 = 0,
    /* Number of INV on the third stage*/
    parameter NUM_OF_INV_STAGE_3 = 0,
   
    /* Size of the outcoming bus from the third stage */
    parameter SIZE_OF_STAGE_3 = NUM_OF_NAND4_STAGE_3 + NUM_OF_NAND3_STAGE_3 + NUM_OF_NAND2_STAGE_3 + NUM_OF_INV_STAGE_3

/*@EOF*/