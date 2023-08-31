    /* Select the description to use: [0,HLD] / [1,LLD or LGD] */
    parameter ASIC          = 1,
    /* Number of words */
    parameter DEPTH         = 32,
    /* Number of bits */
    parameter DATA          = 50,
    /* Payload data RAM [UNUSED]*/
    parameter PAYLOAD       = 0,
    /* Number of write ports */
    parameter WRITE         = 1,
    /* Number of read ports*/
    parameter READ          = 3,
    /* Size of address parameters */
    parameter INDEX         = $clog2(DEPTH),
    
    /* Type definition of the number of words*/
    parameter type depth_t  = logic [DEPTH-1:0],
    /* Type definition of the address size */
    parameter type index_t  = logic [INDEX-1:0],
    /* Type definition of the write data*/
    parameter type udata_t  = logic [DATA+PAYLOAD-1:0],
    /* Type definition of the read data*/
    parameter type sdata_t  = logic [DATA-1:0],
    /* Type definition of the match data*/
    parameter type mdata_t  = logic [INDEX+PAYLOAD-1:0],
    /* Priority encoder enable: [1,on] / [0,off] (1 bit per read port)*/
    parameter PRIORITY_EN   = 'b111,
    /* Priority encoder mode: [1,first] (oldest) / [0,last] (youngest) (1 bit per read port) */
    parameter PRIORITY_MODE = 'b110,
    /* Single memory or multiple memory [UNUSED]: [0,single] / [1,multiple] */
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