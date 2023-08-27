module vlsu_cam_top
# (
    `include "vpu_cam_parameters.svh"
  )
(
  //..clock signal and reset
  input   logic               clk,
  input   logic               arst_n,
  input   logic               rst,

  //..enable comparisons
  input   index_t             head_i,
  input   depth_t [READ-1:0]  enable_i,

  //..write access (update)
  input   logic   [WRITE-1:0] write_i,
  input   index_t [WRITE-1:0] write_addr_i,
  input   udata_t [WRITE-1:0] write_data_i,

  //..read access (search)
  input   logic   [READ-1:0]  read_i,
  input   sdata_t [READ-1:0]  read_data_i,

  //..read access (result)
  output  logic   [READ-1:0]  match_o,
  output  mdata_t [READ-1:0]  match_data_o
);

  //..some typedefs
  typedef logic [WRITE-1:0] write_t;
  typedef logic [READ-1:0]  read_t;

  //..variables
  sdata_t [WRITE-1:0] write_data;
  depth_t [READ-1:0]  match_cmp;
  depth_t [READ-1:0]  match_post_en;
  index_t [READ-1:0]  match_addr;
  read_t              match, match_d;
  mdata_t [READ-1:0]  mdata, mdata_d;

  
  depth_t [WRITE-1:0]  address_select;
  depth_t [READ-1:0]  read_enable;
      
  /* Separate the data to be written from the payload data *UNUSED* */
  generate
    for(genvar write_port = 0; write_port < WRITE; write_port++) begin: cam_wdata_gen
      assign write_data[write_port] = write_data_i[write_port][DATA+PAYLOAD-1:PAYLOAD];
    end
  endgenerate
  
  //..cam (memory model)
  generate
    if(ASIC == 0) begin: bhvl_model_gen

    /*****************/
    /* Here goes HDL */
    /*****************/

    end
    else begin: asic_model_gen
      /* Declare variables */

        /* Write data delayed 1 Tclk */
        sdata_t [WRITE-1:0] write_data_delayed;

        /* Match line for each port and word */
        depth_t [READ-1:0]  match_line;

      /* Module instances that build the CAM without priority encoder */

        /* Declare data delayer for 1 Tclk delay on the write lines */
        write_data_delay write_data_ffs(
        .clk(clk),
        .data_i(write_data),
        .data_delayed(write_data_delayed)
        ); 

        /* Decoder instance */
        cam_decoder decoder(
                .clk_i(clk), 
                .input_address(write_addr_i), 
                .write_enable(write_i), 
                .address_enable(address_select)
            );
        
        /* Memory core instance */
        memory_core_instance memory_core(
                .clk(clk),
                .address_enable(address_select),
                .write_data_i(write_data_delayed),
                .read_i(read_i),
                .read_data_i(read_data_i),
                .match_line(match_cmp)
        ); 
        
    end
  endgenerate

  /********************/
  /* PRIORITY ENCODER */
  /********************/

endmodule: vlsu_cam_top

/*@EOF*/