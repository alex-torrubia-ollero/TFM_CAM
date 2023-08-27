`timescale 100ps / 1ps
/****************************************************************************/
/* VPU CAM test                                                             */
/*                                                                          */
/* Test description:                                                        */
/* This test is used to check the basic functionality of the CAM cell.      */
/* In this test controlled data will be written in a CAM, and it will       */
/* be read in one clock cycle per data.                                     */
/*                                                                          */
/* Inputs:                                                                  */
/* WRITE CYCLE                                                              */
/* write_i/update_i = 1 whenever data is written                            */
/* update_addr_i = data is sent in order from 0 to DEPTH-1 each clock       */
/* update_data_i = data is sent in two times from 0 to DEPTH-1/2            */
/*                                                                          */
/* READ CYCLE                                                               */
/* read_i = 1 whenever data is read                                         */
/* read_data_i = data is sent in order from DEPTH to 1                      */
/*                                                                          */
/* EXPECTED OUTPUTS                                                         */
/* During READ cycle, the match_o and match_addr_o provide the results      */
/* expected, with the described priority order (MSB/LSB)                    */
/****************************************************************************/


module tb_vpu_cam_priority_test;
    
  parameter halfPeriod = 5; // 5*timescale = 500ns

  //..parameters
  localparam WIDTH   = 50;
  localparam DEPTH   = 32;
  localparam WRITE   = 1;
  localparam READ    = 3;
  localparam ADDRESS = $clog2(DEPTH);
  localparam MODE    = 3'b100;
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
  logic [WRITE-1:0]                 update_i;
  logic [WRITE-1:0] [ADDRESS-1:0]   update_addr_i;
  logic [WRITE-1:0] [WIDTH-1:0]     update_data_i;

  //..read access
  logic [READ-1:0]                  read_i;
  logic [READ-1:0][WIDTH-1:0]       read_data_i;
  logic [READ-1:0]                  read_d;
  logic [READ-1:0][WIDTH-1:0]       read_data_d;
  logic [READ-1:0]                  match_o;
  logic [READ-1:0][ADDRESS-1:0]     match_addr_o;

  //..clear pointer
  logic               clear_i, clear_d;
  logic [ADDRESS-1:0] clear_addr_i;

  /* Init*/
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

  /* Clock instance of 1 GHz*/
  always
    #5 clk = ~clk;

  /* Async reset */
  always
    #100 arst_n = 1'b1;


  always @ (posedge clk, negedge arst_n) begin
    if(~arst_n) begin
      for(int i = 0; i < WRITE; i++) begin
        update_i[i] <= 1'b0;
        update_addr_i[i] <= 0;
        update_data_i[i] <= 0;
      end
    end
    else begin
        for(int i = 0; i < WRITE; i++) begin
            /* write all the FF */
            #20;
            for(int j=0; j<=DEPTH/2-1; j=j+1) begin
                update_i[i] = 1'b1;
                update_addr_i[i] = j;
                update_data_i[i] = j+1;
                #10;
                update_i = 1'b0;
                #10;
            end
            
            for(int j=DEPTH/2; j<=DEPTH-1; j=j+1) begin
                update_i[i] = 1'b1;
                update_addr_i[i] = j;
                update_data_i[i] = (j-DEPTH/2)+1;
                #10;
                update_i = 1'b0;
                #10;
            end
        end
        /* Read all the FF*/
        #10;
        read_i = 3'b111;
        for(int j=0; j<=DEPTH/2-1; j=j+1) begin
            read_data_i[0] = j+1;
            read_data_i[1] = j+1;
            read_data_i[2] = j+1;
            #10;
        end
    end

  end

  /* Unit under test*/
  vlsu_cam_top
    dut (
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



endmodule: tb_vpu_cam_priority_test
