`timescale 1ns / 1ps
// // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // 
// Engineer:
// 
// Create Date: 2023/06/26 22:44:03
// Design Name:
// Module Name: s1_syncal
// Project Name:
// Description:
// 
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created 2023/05/26 14:16:03
// Revision 0.02 - File Created 2023/10/16 22:53:27
// Additional Comments:
// 
// // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // 

`ifndef D
`define D #0.2
`endif

module s1_syncal(
    input wire        clk,
    input wire        rstn,
    input wire        rs_ena,
    input wire        data_vld,
    input wire [63:0] syn_data0,
    input wire [63:0] syn_data1,
    input wire        data_init,
    input wire        data_last0,
    input wire        data_last1,

    output reg [ 7:0] rs_syn0,
    output reg [ 7:0] rs_syn1,
    output reg [ 7:0] rs_syn2,
    output reg [ 7:0] rs_syn3,
    output reg        syn_error,
    output reg        syn_nerror,
    output reg        syn_done
);

    localparam ALPHA01 = 8'd2,    ALPHA02 = 8'd4,   ALPHA03 = 8'd8,   ALPHA04 = 8'd16,  ALPHA05 = 8'd32,  ALPHA06 = 8'd64;
    localparam ALPHA07 = 8'd128,  ALPHA08 = 8'd29,  ALPHA09 = 8'd58,  ALPHA10 = 8'd116, ALPHA11 = 8'd232, ALPHA12 = 8'd205;
    localparam ALPHA13 = 8'd135,  ALPHA14 = 8'd19,  ALPHA15 = 8'd38,  ALPHA16 = 8'd76,  ALPHA17 = 8'd152, ALPHA18 = 8'd45;
    localparam ALPHA19 = 8'd90,   ALPHA20 = 8'd180, ALPHA21 = 8'd117, ALPHA22 = 8'd234, ALPHA23 = 8'd201, ALPHA24 = 8'd143;
    localparam ITERATION='d25;

    reg [ 4:0] counter_it;

    reg [63:0] syn_data0_1t;

    reg [ 7:0] syn0_temp;
    reg [ 7:0] syn1_temp;
    reg [ 7:0] syn2_temp;
    reg [ 7:0] syn3_temp;

    wire[ 7:0] syn0_next;
    wire[ 7:0] syn1_next;
    wire[ 7:0] syn2_next;
    wire[ 7:0] syn3_next;

    //========================   normal syn_data   ========================//
    wire[ 7:0] data0_0;
    wire[ 7:0] data0_1;
    wire[ 7:0] data0_2;
    wire[ 7:0] data0_3;
    wire[ 7:0] data0_4;
    wire[ 7:0] data0_5;
    wire[ 7:0] data0_6;
    wire[ 7:0] data0_7;

    //wire[ 7:0] data0_0_multi_alpha00;
    wire[ 7:0] data0_1_multi_alpha01;
    wire[ 7:0] data0_2_multi_alpha02;
    wire[ 7:0] data0_3_multi_alpha03;
    wire[ 7:0] data0_4_multi_alpha04;
    wire[ 7:0] data0_5_multi_alpha05;
    wire[ 7:0] data0_6_multi_alpha06;
    wire[ 7:0] data0_7_multi_alpha07;
    //wire[ 7:0] data0_0_multi_alpha00;
    wire[ 7:0] data0_1_multi_alpha02;
    wire[ 7:0] data0_2_multi_alpha04;
    wire[ 7:0] data0_3_multi_alpha06;
    wire[ 7:0] data0_4_multi_alpha08;
    wire[ 7:0] data0_5_multi_alpha10;
    wire[ 7:0] data0_6_multi_alpha12;
    wire[ 7:0] data0_7_multi_alpha14;
    //wire[ 7:0] data0_0_multi_alpha00;
    wire[ 7:0] data0_1_multi_alpha03;
    wire[ 7:0] data0_2_multi_alpha06;
    wire[ 7:0] data0_3_multi_alpha09;
    wire[ 7:0] data0_4_multi_alpha12;
    wire[ 7:0] data0_5_multi_alpha15;
    wire[ 7:0] data0_6_multi_alpha18;
    wire[ 7:0] data0_7_multi_alpha21;

    wire[ 7:0] sum_data0_multi_x0;
    wire[ 7:0] sum_data0_multi_x1;
    wire[ 7:0] sum_data0_multi_x2;
    wire[ 7:0] sum_data0_multi_x3;

    assign data0_0 = syn_data0[23:16];
    assign data0_1 = syn_data0[31:24];
    assign data0_2 = syn_data0[39:32];
    assign data0_3 = syn_data0[47:40];
    assign data0_4 = syn_data0[55:48];
    assign data0_5 = syn_data0[63:56];
    assign data0_6 = data_init ? 8'h00 : syn_data0_1t[ 7: 0];
    assign data0_7 = data_init ? 8'h00 : syn_data0_1t[15: 8];

    //gf2m8_multi u_gf2m8_multi_010(.x(data0_0), .y(ALPHA00),  .z(data0_0_multi_alpha00));
    gf2m8_multi u_gf2m8_multi_011(.x(data0_1), .y(ALPHA01),  .z(data0_1_multi_alpha01));
    gf2m8_multi u_gf2m8_multi_012(.x(data0_2), .y(ALPHA02),  .z(data0_2_multi_alpha02));
    gf2m8_multi u_gf2m8_multi_013(.x(data0_3), .y(ALPHA03),  .z(data0_3_multi_alpha03));
    gf2m8_multi u_gf2m8_multi_014(.x(data0_4), .y(ALPHA04),  .z(data0_4_multi_alpha04));
    gf2m8_multi u_gf2m8_multi_015(.x(data0_5), .y(ALPHA05),  .z(data0_5_multi_alpha05));
    gf2m8_multi u_gf2m8_multi_016(.x(data0_6), .y(ALPHA06),  .z(data0_6_multi_alpha06));
    gf2m8_multi u_gf2m8_multi_017(.x(data0_7), .y(ALPHA07),  .z(data0_7_multi_alpha07));
    //gf2m8_multi u_gf2m8_multi_020(.x(data0_0), .y(ALPHA00),  .z(data0_0_multi_alpha00));
    gf2m8_multi u_gf2m8_multi_021(.x(data0_1), .y(ALPHA02),  .z(data0_1_multi_alpha02));
    gf2m8_multi u_gf2m8_multi_022(.x(data0_2), .y(ALPHA04),  .z(data0_2_multi_alpha04));
    gf2m8_multi u_gf2m8_multi_023(.x(data0_3), .y(ALPHA06),  .z(data0_3_multi_alpha06));
    gf2m8_multi u_gf2m8_multi_024(.x(data0_4), .y(ALPHA08),  .z(data0_4_multi_alpha08));
    gf2m8_multi u_gf2m8_multi_025(.x(data0_5), .y(ALPHA10),  .z(data0_5_multi_alpha10));
    gf2m8_multi u_gf2m8_multi_026(.x(data0_6), .y(ALPHA12),  .z(data0_6_multi_alpha12));
    gf2m8_multi u_gf2m8_multi_027(.x(data0_7), .y(ALPHA14),  .z(data0_7_multi_alpha14));
    //gf2m8_multi u_gf2m8_multi_030(.x(data0_0), .y(ALPHA00),  .z(data0_0_multi_alpha00));
    gf2m8_multi u_gf2m8_multi_031(.x(data0_1), .y(ALPHA03),  .z(data0_1_multi_alpha03));
    gf2m8_multi u_gf2m8_multi_032(.x(data0_2), .y(ALPHA06),  .z(data0_2_multi_alpha06));
    gf2m8_multi u_gf2m8_multi_033(.x(data0_3), .y(ALPHA09),  .z(data0_3_multi_alpha09));
    gf2m8_multi u_gf2m8_multi_034(.x(data0_4), .y(ALPHA12),  .z(data0_4_multi_alpha12));
    gf2m8_multi u_gf2m8_multi_035(.x(data0_5), .y(ALPHA15),  .z(data0_5_multi_alpha15));
    gf2m8_multi u_gf2m8_multi_036(.x(data0_6), .y(ALPHA18),  .z(data0_6_multi_alpha18));
    gf2m8_multi u_gf2m8_multi_037(.x(data0_7), .y(ALPHA21),  .z(data0_7_multi_alpha21));

    assign sum_data0_multi_x0 = data0_0 ^ data0_1 ^ data0_2 ^ data0_3 ^ data0_4 ^ data0_5 ^ data0_6 ^ data0_7;
    assign sum_data0_multi_x1 = data0_0 ^ data0_1_multi_alpha01 ^ data0_2_multi_alpha02 ^ data0_3_multi_alpha03 ^ 
                                data0_4_multi_alpha04 ^ data0_5_multi_alpha05 ^ data0_6_multi_alpha06 ^ data0_7_multi_alpha07;
    assign sum_data0_multi_x2 = data0_0 ^ data0_1_multi_alpha02 ^ data0_2_multi_alpha04 ^ data0_3_multi_alpha06 ^ 
                                data0_4_multi_alpha08 ^ data0_5_multi_alpha10 ^ data0_6_multi_alpha12 ^ data0_7_multi_alpha14;
    assign sum_data0_multi_x3 = data0_0 ^ data0_1_multi_alpha03 ^ data0_2_multi_alpha06 ^ data0_3_multi_alpha09 ^ 
                                data0_4_multi_alpha12 ^ data0_5_multi_alpha15 ^ data0_6_multi_alpha18 ^ data0_7_multi_alpha21;

    //========================   burst syn_data   ========================//
    wire[ 7:0] data1_0;
    wire[ 7:0] data1_1;
    wire[ 7:0] data1_2;
    wire[ 7:0] data1_3;
    wire[ 7:0] data1_4;
    wire[ 7:0] data1_5;
    wire[ 7:0] data1_6;
    wire[ 7:0] data1_7;

    //wire[ 7:0] data1_0_multi_alpha00;
    wire[ 7:0] data1_1_multi_alpha01;
    wire[ 7:0] data1_2_multi_alpha02;
    wire[ 7:0] data1_3_multi_alpha03;
    wire[ 7:0] data1_4_multi_alpha04;
    wire[ 7:0] data1_5_multi_alpha05;
    wire[ 7:0] data1_6_multi_alpha06;
    wire[ 7:0] data1_7_multi_alpha07;
    //wire[ 7:0] data1_0_multi_alpha00;
    wire[ 7:0] data1_1_multi_alpha02;
    wire[ 7:0] data1_2_multi_alpha04;
    wire[ 7:0] data1_3_multi_alpha06;
    wire[ 7:0] data1_4_multi_alpha08;
    wire[ 7:0] data1_5_multi_alpha10;
    wire[ 7:0] data1_6_multi_alpha12;
    wire[ 7:0] data1_7_multi_alpha14;
    //wire[ 7:0] data1_0_multi_alpha00;
    wire[ 7:0] data1_1_multi_alpha03;
    wire[ 7:0] data1_2_multi_alpha06;
    wire[ 7:0] data1_3_multi_alpha09;
    wire[ 7:0] data1_4_multi_alpha12;
    wire[ 7:0] data1_5_multi_alpha15;
    wire[ 7:0] data1_6_multi_alpha18;
    wire[ 7:0] data1_7_multi_alpha21;

    wire[ 7:0] sum_data1_multi_x0;
    wire[ 7:0] sum_data1_multi_x1;
    wire[ 7:0] sum_data1_multi_x2;
    wire[ 7:0] sum_data1_multi_x3;
   
    assign data1_0 = syn_data1[23:16];
    assign data1_1 = syn_data1[31:24];
    assign data1_2 = syn_data1[39:32];
    assign data1_3 = syn_data1[47:40];
    assign data1_4 = syn_data1[55:48];
    assign data1_5 = syn_data1[63:56];
    assign data1_6 = syn_data0[ 7: 0];
    assign data1_7 = syn_data0[15: 8];

    //gf2m8_multi u_gf2m8_multi_110(.x(data1_0), .y(ALPHA00),  .z(data1_0_multi_alpha00));
    gf2m8_multi u_gf2m8_multi_111(.x(data1_1), .y(ALPHA01),  .z(data1_1_multi_alpha01));
    gf2m8_multi u_gf2m8_multi_112(.x(data1_2), .y(ALPHA02),  .z(data1_2_multi_alpha02));
    gf2m8_multi u_gf2m8_multi_113(.x(data1_3), .y(ALPHA03),  .z(data1_3_multi_alpha03));
    gf2m8_multi u_gf2m8_multi_114(.x(data1_4), .y(ALPHA04),  .z(data1_4_multi_alpha04));
    gf2m8_multi u_gf2m8_multi_115(.x(data1_5), .y(ALPHA05),  .z(data1_5_multi_alpha05));
    gf2m8_multi u_gf2m8_multi_116(.x(data1_6), .y(ALPHA06),  .z(data1_6_multi_alpha06));
    gf2m8_multi u_gf2m8_multi_117(.x(data1_7), .y(ALPHA07),  .z(data1_7_multi_alpha07));
    //gf2m8_multi u_gf2m8_multi_120(.x(data1_0), .y(ALPHA00),  .z(data1_0_multi_alpha00));
    gf2m8_multi u_gf2m8_multi_121(.x(data1_1), .y(ALPHA02),  .z(data1_1_multi_alpha02));
    gf2m8_multi u_gf2m8_multi_122(.x(data1_2), .y(ALPHA04),  .z(data1_2_multi_alpha04));
    gf2m8_multi u_gf2m8_multi_123(.x(data1_3), .y(ALPHA06),  .z(data1_3_multi_alpha06));
    gf2m8_multi u_gf2m8_multi_124(.x(data1_4), .y(ALPHA08),  .z(data1_4_multi_alpha08));
    gf2m8_multi u_gf2m8_multi_125(.x(data1_5), .y(ALPHA10),  .z(data1_5_multi_alpha10));
    gf2m8_multi u_gf2m8_multi_126(.x(data1_6), .y(ALPHA12),  .z(data1_6_multi_alpha12));
    gf2m8_multi u_gf2m8_multi_127(.x(data1_7), .y(ALPHA14),  .z(data1_7_multi_alpha14));
    //gf2m8_multi u_gf2m8_multi_130(.x(data1_0), .y(ALPHA00),  .z(data1_0_multi_alpha00));
    gf2m8_multi u_gf2m8_multi_131(.x(data1_1), .y(ALPHA03),  .z(data1_1_multi_alpha03));
    gf2m8_multi u_gf2m8_multi_132(.x(data1_2), .y(ALPHA06),  .z(data1_2_multi_alpha06));
    gf2m8_multi u_gf2m8_multi_133(.x(data1_3), .y(ALPHA09),  .z(data1_3_multi_alpha09));
    gf2m8_multi u_gf2m8_multi_134(.x(data1_4), .y(ALPHA12),  .z(data1_4_multi_alpha12));
    gf2m8_multi u_gf2m8_multi_135(.x(data1_5), .y(ALPHA15),  .z(data1_5_multi_alpha15));
    gf2m8_multi u_gf2m8_multi_136(.x(data1_6), .y(ALPHA18),  .z(data1_6_multi_alpha18));
    gf2m8_multi u_gf2m8_multi_137(.x(data1_7), .y(ALPHA21),  .z(data1_7_multi_alpha21));

    assign sum_data1_multi_x0 = data1_0 ^ data1_1 ^ data1_2 ^ data1_3 ^ data1_4 ^ data1_5 ^ data1_6 ^ data1_7;
    assign sum_data1_multi_x1 = data1_0 ^ data1_1_multi_alpha01 ^ data1_2_multi_alpha02 ^ data1_3_multi_alpha03 ^ 
                                data1_4_multi_alpha04 ^ data1_5_multi_alpha05 ^ data1_6_multi_alpha06 ^ data1_7_multi_alpha07;
    assign sum_data1_multi_x2 = data1_0 ^ data1_1_multi_alpha02 ^ data1_2_multi_alpha04 ^ data1_3_multi_alpha06 ^ 
                                data1_4_multi_alpha08 ^ data1_5_multi_alpha10 ^ data1_6_multi_alpha12 ^ data1_7_multi_alpha14;
    assign sum_data1_multi_x3 = data1_0 ^ data1_1_multi_alpha03 ^ data1_2_multi_alpha06 ^ data1_3_multi_alpha09 ^ 
                                data1_4_multi_alpha12 ^ data1_5_multi_alpha15 ^ data1_6_multi_alpha18 ^ data1_7_multi_alpha21;

    //========================   syn*_next   ========================//
    //wire[ 7:0] syn0_multi_alpha00;
    wire[ 7:0] syn1_multi_alpha08;
    wire[ 7:0] syn2_multi_alpha16;
    wire[ 7:0] syn3_multi_alpha24;

    wire[ 7:0] syn0_next_op1;
    wire[ 7:0] syn1_next_op1;
    wire[ 7:0] syn2_next_op1;
    wire[ 7:0] syn3_next_op1;

    //wire[ 7:0] syn0_next_op1_multi_alpha00;
    wire[ 7:0] syn1_next_op1_multi_alpha08;
    wire[ 7:0] syn2_next_op1_multi_alpha16;
    wire[ 7:0] syn3_next_op1_multi_alpha24;

    wire[ 7:0] syn0_next_op2;
    wire[ 7:0] syn1_next_op2;
    wire[ 7:0] syn2_next_op2;
    wire[ 7:0] syn3_next_op2;
    
    //gf2m8_multi u_gf2m8_multi_s0(.x(syn0_temp), .y(ALPHA00),  .z(syn0_multi_alpha00));
    gf2m8_multi u_gf2m8_multi_s1(.x(syn1_temp ), .y(ALPHA08),  .z(syn1_multi_alpha08));
    gf2m8_multi u_gf2m8_multi_s2(.x(syn2_temp ), .y(ALPHA16),  .z(syn2_multi_alpha16));
    gf2m8_multi u_gf2m8_multi_s3(.x(syn3_temp ), .y(ALPHA24),  .z(syn3_multi_alpha24));

    //gf2m8_multi u_gf2m8_multi_s4(.x(syn0_next_op1), .y(ALPHA00),  .z(syn0_next_op1_multi_alpha00));
    gf2m8_multi u_gf2m8_multi_s5(.x(syn1_next_op1), .y(ALPHA08),  .z(syn1_next_op1_multi_alpha08));
    gf2m8_multi u_gf2m8_multi_s6(.x(syn2_next_op1), .y(ALPHA16),  .z(syn2_next_op1_multi_alpha16));
    gf2m8_multi u_gf2m8_multi_s7(.x(syn3_next_op1), .y(ALPHA24),  .z(syn3_next_op1_multi_alpha24));

    assign syn0_next_op1 = sum_data0_multi_x0 ^ syn0_temp         ;
    assign syn1_next_op1 = sum_data0_multi_x1 ^ syn1_multi_alpha08;
    assign syn2_next_op1 = sum_data0_multi_x2 ^ syn2_multi_alpha16;
    assign syn3_next_op1 = sum_data0_multi_x3 ^ syn3_multi_alpha24;

    assign syn0_next_op2 = sum_data1_multi_x0 ^ syn0_next_op1              ;
    assign syn1_next_op2 = sum_data1_multi_x1 ^ syn1_next_op1_multi_alpha08;
    assign syn2_next_op2 = sum_data1_multi_x2 ^ syn2_next_op1_multi_alpha16;
    assign syn3_next_op2 = sum_data1_multi_x3 ^ syn3_next_op1_multi_alpha24;

    assign syn0_next = data_init ? sum_data0_multi_x0 : data_last1 ? syn0_next_op2 : syn0_next_op1;//mux 位置，驱动能力的差异
    assign syn1_next = data_init ? sum_data0_multi_x1 : data_last1 ? syn1_next_op2 : syn1_next_op1;
    assign syn2_next = data_init ? sum_data0_multi_x2 : data_last1 ? syn2_next_op2 : syn2_next_op1;
    assign syn3_next = data_init ? sum_data0_multi_x3 : data_last1 ? syn3_next_op2 : syn3_next_op1;

    always @(posedge clk or negedge rstn) begin
        if(!rstn) begin
            syn_data0_1t <= `D 'b0;
        end else if(rs_ena & data_vld) begin
            syn_data0_1t <= `D syn_data0;
        end
    end

    always @(posedge clk or negedge rstn) begin
        if(!rstn) begin
            counter_it <= `D 'd0;
        end else if(rs_ena & data_vld) begin
            if(counter_it=='d0 && data_init) begin
                counter_it <= `D 'd1;
            end else if((counter_it==ITERATION-1 && data_last0) || (counter_it==ITERATION-2 && data_last1)) begin
                counter_it <= `D 'd0;
            end else if(counter_it) begin
                counter_it <= `D counter_it + 'd1;
            end else begin
                counter_it <= `D counter_it;
            end
        end
    end

    icg u_icg_syn_temp(.clk(clk), .ena(rs_ena & data_vld), .rstn(rstn), .gclk(syn_temp_clk));
    always @(posedge syn_temp_clk or negedge rstn) begin
        if(!rstn) begin
            syn0_temp <= `D 'b0;
            syn1_temp <= `D 'b0;
            syn2_temp <= `D 'b0;
            syn3_temp <= `D 'b0;
        end else begin
            syn0_temp <= `D syn0_next;
            syn1_temp <= `D syn1_next;
            syn2_temp <= `D syn2_next;
            syn3_temp <= `D syn3_next;
        end
    end

    icg u_icg_rs_syn(.clk(clk), .ena(rs_ena && data_vld && (data_last0 || data_last1)), .rstn(rstn), .gclk(rs_syn_clk));
    always @(posedge rs_syn_clk or negedge rstn) begin
        if(!rstn) begin
            rs_syn0 <= `D 'b0;
            rs_syn1 <= `D 'b0;
            rs_syn2 <= `D 'b0;
            rs_syn3 <= `D 'b0;
        end else begin
            rs_syn0 <= `D syn0_next;
            rs_syn1 <= `D syn1_next;
            rs_syn2 <= `D syn2_next;
            rs_syn3 <= `D syn3_next;
        end
    end

    always @(posedge clk or negedge rstn) begin
        if(!rstn) begin
            syn_error  <= `D 'b0;
            syn_nerror <= `D 'b0;
            syn_done   <= `D 'b0;
        end else if(rs_ena && (data_last0 || data_last1) && data_vld) begin
            syn_error  <= `D {syn0_next,syn1_next,syn2_next,syn3_next} != 'b0;
            syn_nerror <= `D {syn0_next,syn1_next,syn2_next,syn3_next} == 'b0;
            syn_done   <= `D 'b1;
        end else begin
            syn_error  <= `D 'b0;
            syn_nerror <= `D 'b0;
            syn_done   <= `D 'b0;
        end
    end


endmodule
