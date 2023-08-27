`timescale 100ps / 1ps
/****************************************************************************/
/* Concatenate write/search                                                 */
/*                                                                          */
/* Test description:                                                        */
/* This test is used to check the read and write operations can be done     */
/* with one clock cycle apart. In this test the CAM will be written with    */
/* known values that will be read on the next clock cycle.                  */
/*                                                                          */
/* Inputs:                                                                  */
/* WRITE CYCLE                                                              */
/* write_i/update_i = 1 whenever data is written                            */
/* update_addr_i = data is sent in order from 0 to DEPTH-1 each 2 clocks    */
/* update_data_i = data is sent in order from 1 to DEPTH each 2 clocks      */
/*                                                                          */
/* READ CYCLE                                                               */
/* read_i = 1 whenever data is read, 0 otherwise                            */
/* read_data_i = data is sent in order from DEPTH to 1 each 2 clocks        */
/*                                                                          */
/* EXPECTED OUTPUTS                                                         */
/* During READ cycle, match_o is expected to rise for the port that is      */
/* being read when the data is the same that the one written.               */
/* Also, match_addr_o will output the address that has been previously      */
/* written.                                                                 */
/****************************************************************************/


module tb_cam_concatenate_write_read;
    
  parameter halfPeriod = 5; // 5*timescale = 500ns

  //..parameters
  localparam WIDTH   = 50;
  localparam DEPTH   = 32;
  localparam WRITE   = 1;
  localparam READ    = 3;
  localparam ADDRESS = $clog2(DEPTH);
  localparam MODE    = 3'b111;
  localparam ASIC    = 1;
  localparam MULTIPLE_MEM = 0;
  localparam PRIORITY_EN = 3'b111;

  //..some typedefs
  typedef logic [WIDTH-1:0]   width_t;
  typedef logic [ADDRESS-1:0] addr_t;
  typedef logic [DEPTH-1:0]   depth_t;
  typedef logic [WRITE-1:0]   write_t;
  typedef logic [READ-1:0]    read_t;

  //..clock signal and reset
  logic               clk;
  logic               arst_n;
  logic               rst, rst_d;
  
  //..enable comparisons
  logic [ADDRESS-1:0]               head_i;
  logic [READ-1:0] [DEPTH-1:0]       enable_i;
    
  //..write access
  logic [WRITE-1:0]                 update_i, update_i_ideal;
  logic [WRITE-1:0] [ADDRESS-1:0]   update_addr_i, update_addr_i_ideal;
  logic [WRITE-1:0] [WIDTH-1:0]     update_data_i, update_data_i_ideal;

  //..read access
  logic [READ-1:0]                  read_i, read_i_ideal;
  logic [READ-1:0][WIDTH-1:0]       read_data_i, read_data_i_ideal;
  logic [READ-1:0]                  read_d;
  logic [READ-1:0][WIDTH-1:0]       read_data_d;
  logic [READ-1:0]                  match_o;
  logic [READ-1:0][ADDRESS-1:0]     match_addr_o;

  //..clear pointer
  logic               clear_i, clear_d;
  logic [ADDRESS-1:0] clear_addr_i;


  //..initialization
  initial begin
    clk = 1'b0;
    arst_n = 1'b0;
    read_d = 3'b111;
    for (int i=0; i<READ; i++) begin
        for(int j=0; j<DEPTH;j++) begin
            enable_i[i][j]=1;
            read_i[i] = 1'b0;
            read_data_i[i] = 0;
        end
    end
    for (int i=0; i<WRITE; i++) begin
        for(int j=0; j<DEPTH;j++) begin
            enable_i[i][j]=1;
            update_i[i] = 1'b0;
            update_addr_i[i] = 0;
            update_data_i[i] = 0;
        end
    end
    
    head_i = 0;
  end

  /*  Clock generation of 1 GHz */
  always
    #5 clk = ~clk;

  /* Asynchronous reset */
  always
    #100 arst_n = 1'b1;

  always @ (posedge clk, negedge arst_n) begin
    if(~arst_n) begin
      for(int i = 0; i < WRITE; i++) begin
        update_i_ideal[i] <= 1'b0;
        update_addr_i_ideal[i] <= 0;
        update_data_i_ideal[i] <= 0;
      end
    end
    else begin
    
    /* Initalize CAM*/
    for(int j=0; j<=DEPTH-1; j=j+1) begin
        update_i_ideal = 1'b1;
        update_addr_i_ideal = j;
        update_data_i_ideal = 0;
        #10;
    end
        update_i= 1'b0;

        /* Write on CAM */
        for (int port = 0; port <= WRITE-1; port++) begin
            #50; /* Wait */
            for (int rows = 0; rows < DEPTH; rows++) begin
                read_i_ideal[0] = 'h00000000;
                read_i_ideal[1] = 'h00000000;
                read_i_ideal[2] = 'h00000000;
                update_i_ideal[port] = 1'b1;
                update_addr_i_ideal = rows;
                update_data_i_ideal = rows+1;
                #10; /* Wait one clock period*/
                update_i_ideal[port] = 1'b0;
                update_addr_i_ideal = 0;
                update_data_i_ideal = 0;
                read_i_ideal[0] = 'hFFFFFFFF;
                read_i_ideal[1] = 'hFFFFFFFF;
                read_i_ideal[2] = 'hFFFFFFFF;
                read_data_i_ideal[0] = rows+1;
                read_data_i_ideal[1] = rows+1;
                read_data_i_ideal[2] = rows+1;
                #10;
            end
                read_i_ideal[0] = 'h00000000;
                read_i_ideal[1] = 'h00000000;
                read_i_ideal[2] = 'h00000000;
        end
        
        for (int port = 0; port <= WRITE-1; port++) begin
            #50; /* Wait */
            for (int rows = 0; rows < DEPTH; rows++) begin
                read_i_ideal[0] = 'h00000000;
                read_i_ideal[1] = 'h00000000;
                read_i_ideal[2] = 'h00000000;
                update_i_ideal[port] = 1'b1;
                update_addr_i_ideal = rows;
                update_data_i_ideal = DEPTH+1-rows;
                #10; /* Wait one clock period*/
                update_i_ideal[port] = 1'b0;
                update_addr_i_ideal = 0;
                update_data_i_ideal = 0;
                read_i_ideal[0] = 'hFFFFFFFF;
                read_i_ideal[1] = 'hFFFFFFFF;
                read_i_ideal[2] = 'hFFFFFFFF;
                read_data_i_ideal[0] = DEPTH+1-rows;
                read_data_i_ideal[1] = DEPTH+1-rows;
                read_data_i_ideal[2] = DEPTH+1-rows;
                #10;
            end
                read_i_ideal[0] = 'h00000000;
                read_i_ideal[1] = 'h00000000;
                read_i_ideal[2] = 'h00000000;
        end
    end
  end
  
  
/* Flip flop simulation, acts as a delay to meet with the input delay constraints */  
always @ (posedge clk, negedge arst_n) begin
    #3;
    read_i=read_i_ideal;
    read_data_i=read_data_i_ideal;
    update_i = update_i_ideal;
    update_addr_i = update_addr_i_ideal;
    update_data_i = update_data_i_ideal;
end

  /* Unit under test*/
  vlsu_cam_top dut (
        .head_i(head_i), 
        .enable_i(enable_i), 
        .write_i(update_i), 
        .write_addr_i(update_addr_i), 
        .write_data_i(update_data_i), 
        .match_data_o(match_addr_o), 
        .match_o(match_o), 
        .read_data_i(read_data_i), 
        .read_i(read_i), 
        .rst(rst), 
        .arst_n(arst_n), 
        .clk(clk)
        );

endmodule: tb_cam_concatenate_write_read
