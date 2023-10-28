`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: 
// 
// Create Date: 2023/06/27 18:22:37
// Design Name: 
// Module Name: s3_csee
// Project Name: 
// Desription: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File reated 2023/06/13 14:33:52
// Revision 0.01 - File reated 2023/10/18 16:22:41
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
`ifndef UTILS
`define UTILS
`include "../src/rs_utils.v"
`endif

`ifndef D
`define D #0.2
`endif

module s3_csee(
    input  wire        clk,
    input  wire        rstn,
    input  wire        rs_ena,
    input  wire        csee_ena,
    input  wire [ 7:0] rs_lambda0,
    input  wire [ 7:0] rs_lambda1,
    input  wire [ 7:0] rs_lambda2,
    input  wire [ 7:0] rs_omega0,
    input  wire [ 7:0] rs_omega1,

    output wire        csee_ongo,
    output wire [63:0] rs_errdata,
    output wire [11:0] rs_syncbit,
    output reg         rsdec_fail
);

    localparam ALPHA1  = 8'd2,    ALPHA2  = 8'd4,    ALPHA3  = 8'd8,    ALPHA4  = 8'd16,   ALPHA5  = 8'd32,   ALPHA6  = 8'd64;
    localparam ALPHA7  = 8'd128,  ALPHA8  = 8'd29,   ALPHA10 = 8'd116,  ALPHA12 = 8'd205,  ALPHA14 = 8'd19,   ALPHA16 = 8'd76;
    localparam ALPHA58 = 8'd105,  ALPHA59 = 8'd210,  ALPHA60 = 8'd185,  ALPHA61 = 8'd111,  ALPHA62 = 8'd222,  ALPHA63 = 8'd161,  ALPHA64 =  8'd95,  ALPHA65 = 8'd190;
    localparam ALPHA116 = 8'd248, ALPHA118 = 8'd199, ALPHA120 =  8'd59, ALPHA122 = 8'd236, ALPHA124 = 8'd151, ALPHA126 = 8'd102, ALPHA128 = 8'd133, ALPHA130 =  8'd46;
    localparam ALPHA250 = 8'd108, ALPHA251 = 8'd216, ALPHA252 = 8'd173, ALPHA253 = 8'd71,  ALPHA254 = 8'd142, ALPHA255 = 8'd1;
    localparam ALPHA500 = 8'd233, ALPHA502 = 8'd131, ALPHA504 = 8'd54,  ALPHA506 = 8'd216, ALPHA508 = 8'd71,  ALPHA510 = 8'd1;
    localparam ITERATION='d24;
    localparam IDLE='b0, CYCLE='b1;

    reg [4:0] counter_it;
    reg csee_state;

    reg [7:0] counter_err;

    wire err_flag_0;
    wire err_flag_1;
    wire err_flag_2;
    wire err_flag_3;
    wire err_flag_4;
    wire err_flag_5;
    wire err_flag_6;
    wire err_flag_7;
    wire [7:0] err_data_0;
    wire [7:0] err_data_1;
    wire [7:0] err_data_2;
    wire [7:0] err_data_3;
    wire [7:0] err_data_4;
    wire [7:0] err_data_5;
    wire [7:0] err_data_6;
    wire [7:0] err_data_7;

    wire err_flag_192;
    wire err_flag_193;
    wire err_flag_194;
    wire err_flag_195;
    wire err_flag_196;
    wire err_flag_197;
    wire [7:0] err_data_192;
    wire [7:0] err_data_193;
    wire [7:0] err_data_194;
    wire [7:0] err_data_195;
    wire [7:0] err_data_196;
    wire [7:0] err_data_197;

    reg  [7:0] l1_multi_a1_x8;
    reg  [7:0] l2_multi_a2_x8;
    reg  [7:0] o1_multi_a1_x8;
    wire [7:0] l1_multi_a1_x8_next;
    wire [7:0] l2_multi_a2_x8_next;
    wire [7:0] o1_multi_a1_x8_next;

    wire [7:0] mux_lambda1;
    wire [7:0] mux_lambda2;
    wire [7:0] mux_omega1;

    wire [7:0] mux_alpha1_0;
    wire [7:0] mux_alpha1_1;
    wire [7:0] mux_alpha1_2;
    wire [7:0] mux_alpha1_3;
    wire [7:0] mux_alpha1_4;
    wire [7:0] mux_alpha1_5;
    wire [7:0] mux_alpha1_6;
    wire [7:0] mux_alpha1_7;
    wire [7:0] mux_alpha2_0;
    wire [7:0] mux_alpha2_1;
    wire [7:0] mux_alpha2_2;
    wire [7:0] mux_alpha2_3;
    wire [7:0] mux_alpha2_4;
    wire [7:0] mux_alpha2_5;
    wire [7:0] mux_alpha2_6;
    wire [7:0] mux_alpha2_7;

    wire csee_idle;
    wire csee_init;
    wire csee_cycle;
    wire csee_done;
    reg  csee_done_1t;
    reg  csee_done_2t;
    
    assign csee_idle  = (csee_state == IDLE  );
    assign csee_init  = (csee_idle & csee_ena);
    assign csee_cycle = (csee_state == CYCLE );
    assign csee_done  = (counter_it == ITERATION-'d1);

    assign csee_ongo = csee_init | csee_cycle;

    always @(posedge clk or negedge rstn) begin
        if(!rstn) begin
            counter_it <= `D 'd0;
        end else if(csee_done) begin
            counter_it <= `D 'd0;
        end else if(csee_ena | csee_cycle) begin
            counter_it <= `D counter_it + 'd1;
        end else begin
            counter_it <= `D counter_it;
        end
    end

    always @(posedge clk or negedge rstn) begin
        if(!rstn) begin
            csee_state <= `D IDLE;
        end else if(csee_init) begin //if(csee_ena) begin
            csee_state <= `D CYCLE;
        end else if(csee_done) begin //if(csee_cycle & csee_done) begin
            csee_state <= `D IDLE;
        end else begin
            csee_state <= `D csee_state;
        end
    end

    icg u_icg_csee_lo_next(.clk(clk), .ena(csee_ongo), .rstn(rstn), .gclk(csee_lo_next_clk));
    always @(posedge csee_lo_next_clk or negedge rstn) begin
        if(!rstn) begin
            l1_multi_a1_x8 <= `D 'h00;
            l2_multi_a2_x8 <= `D 'h00;
            o1_multi_a1_x8 <= `D 'h00;
        end else begin
            l1_multi_a1_x8 <= `D l1_multi_a1_x8_next;
            l2_multi_a2_x8 <= `D l2_multi_a2_x8_next;
            o1_multi_a1_x8 <= `D o1_multi_a1_x8_next;
        end
    end

    assign mux_lambda1  = csee_init ? rs_lambda1 : (csee_cycle ? l1_multi_a1_x8 : 'h00);
    assign mux_lambda2  = csee_init ? rs_lambda2 : (csee_cycle ? l2_multi_a2_x8 : 'h00);
    assign mux_omega1   = csee_init ? rs_omega1  : (csee_cycle ? o1_multi_a1_x8 : 'h00);

    assign mux_alpha1_0 = csee_init ? ALPHA58   : ALPHA1 ;
    assign mux_alpha1_1 = csee_init ? ALPHA59   : ALPHA2 ;
    assign mux_alpha1_2 = csee_init ? ALPHA60   : ALPHA3 ;
    assign mux_alpha1_3 = csee_init ? ALPHA61   : ALPHA4 ;
    assign mux_alpha1_4 = csee_init ? ALPHA62   : ALPHA5 ;
    assign mux_alpha1_5 = csee_init ? ALPHA63   : ALPHA6 ;
    assign mux_alpha1_6 = csee_init ? ALPHA64   : ALPHA7 ;
    assign mux_alpha1_7 = csee_init ? ALPHA65   : ALPHA8 ;
    assign mux_alpha2_0 = csee_init ? ALPHA116  : ALPHA2 ;
    assign mux_alpha2_1 = csee_init ? ALPHA118  : ALPHA4 ;
    assign mux_alpha2_2 = csee_init ? ALPHA120  : ALPHA6 ;
    assign mux_alpha2_3 = csee_init ? ALPHA122  : ALPHA8 ;
    assign mux_alpha2_4 = csee_init ? ALPHA124  : ALPHA10;
    assign mux_alpha2_5 = csee_init ? ALPHA126  : ALPHA12;
    assign mux_alpha2_6 = csee_init ? ALPHA128  : ALPHA14;
    assign mux_alpha2_7 = csee_init ? ALPHA130  : ALPHA16;

    s3_csee_comp u_s3_csee_comp_0 (.comp_ena(csee_ena | csee_cycle), .alpha1(mux_alpha1_0), .alpha2(mux_alpha2_0), .rs_lambda0(rs_lambda0), .rs_lambda1(mux_lambda1), .rs_lambda2(mux_lambda2), .rs_omega0(rs_omega0), .rs_omega1(mux_omega1), .err_flag(err_flag_0), .err_data(err_data_0));
    s3_csee_comp u_s3_csee_comp_1 (.comp_ena(csee_ena | csee_cycle), .alpha1(mux_alpha1_1), .alpha2(mux_alpha2_1), .rs_lambda0(rs_lambda0), .rs_lambda1(mux_lambda1), .rs_lambda2(mux_lambda2), .rs_omega0(rs_omega0), .rs_omega1(mux_omega1), .err_flag(err_flag_1), .err_data(err_data_1));
    s3_csee_comp u_s3_csee_comp_2 (.comp_ena(csee_ena | csee_cycle), .alpha1(mux_alpha1_2), .alpha2(mux_alpha2_2), .rs_lambda0(rs_lambda0), .rs_lambda1(mux_lambda1), .rs_lambda2(mux_lambda2), .rs_omega0(rs_omega0), .rs_omega1(mux_omega1), .err_flag(err_flag_2), .err_data(err_data_2));
    s3_csee_comp u_s3_csee_comp_3 (.comp_ena(csee_ena | csee_cycle), .alpha1(mux_alpha1_3), .alpha2(mux_alpha2_3), .rs_lambda0(rs_lambda0), .rs_lambda1(mux_lambda1), .rs_lambda2(mux_lambda2), .rs_omega0(rs_omega0), .rs_omega1(mux_omega1), .err_flag(err_flag_3), .err_data(err_data_3));
    s3_csee_comp u_s3_csee_comp_4 (.comp_ena(csee_ena | csee_cycle), .alpha1(mux_alpha1_4), .alpha2(mux_alpha2_4), .rs_lambda0(rs_lambda0), .rs_lambda1(mux_lambda1), .rs_lambda2(mux_lambda2), .rs_omega0(rs_omega0), .rs_omega1(mux_omega1), .err_flag(err_flag_4), .err_data(err_data_4));
    s3_csee_comp u_s3_csee_comp_5 (.comp_ena(csee_ena | csee_cycle), .alpha1(mux_alpha1_5), .alpha2(mux_alpha2_5), .rs_lambda0(rs_lambda0), .rs_lambda1(mux_lambda1), .rs_lambda2(mux_lambda2), .rs_omega0(rs_omega0), .rs_omega1(mux_omega1), .err_flag(err_flag_5), .err_data(err_data_5));
    s3_csee_comp u_s3_csee_comp_6 (.comp_ena(csee_ena | csee_cycle), .alpha1(mux_alpha1_6), .alpha2(mux_alpha2_6), .rs_lambda0(rs_lambda0), .rs_lambda1(mux_lambda1), .rs_lambda2(mux_lambda2), .rs_omega0(rs_omega0), .rs_omega1(mux_omega1), .err_flag(err_flag_6), .err_data(err_data_6));
    s3_csee_comp u_s3_csee_comp_7 (.comp_ena(csee_ena | csee_cycle), .alpha1(mux_alpha1_7), .alpha2(mux_alpha2_7), .rs_lambda0(rs_lambda0), .rs_lambda1(mux_lambda1), .rs_lambda2(mux_lambda2), .rs_omega0(rs_omega0), .rs_omega1(mux_omega1), .err_flag(err_flag_7), .err_data(err_data_7), 
                                   .l1_multi_a1(l1_multi_a1_x8_next), .l2_multi_a2(l2_multi_a2_x8_next), .o1_multi_a1(o1_multi_a1_x8_next));

    s3_csee_comp u_s3_csee_comp_192 (.comp_ena(csee_init), .alpha1(ALPHA250), .alpha2(ALPHA500), .rs_lambda0(rs_lambda0), .rs_lambda1(rs_lambda1), .rs_lambda2(rs_lambda2), .rs_omega0(rs_omega0), .rs_omega1(rs_omega1), .err_flag(err_flag_192), .err_data(err_data_192));
    s3_csee_comp u_s3_csee_comp_193 (.comp_ena(csee_init), .alpha1(ALPHA251), .alpha2(ALPHA502), .rs_lambda0(rs_lambda0), .rs_lambda1(rs_lambda1), .rs_lambda2(rs_lambda2), .rs_omega0(rs_omega0), .rs_omega1(rs_omega1), .err_flag(err_flag_193), .err_data(err_data_193));
    s3_csee_comp u_s3_csee_comp_194 (.comp_ena(csee_init), .alpha1(ALPHA252), .alpha2(ALPHA504), .rs_lambda0(rs_lambda0), .rs_lambda1(rs_lambda1), .rs_lambda2(rs_lambda2), .rs_omega0(rs_omega0), .rs_omega1(rs_omega1), .err_flag(err_flag_194), .err_data(err_data_194));
    s3_csee_comp u_s3_csee_comp_195 (.comp_ena(csee_init), .alpha1(ALPHA253), .alpha2(ALPHA506), .rs_lambda0(rs_lambda0), .rs_lambda1(rs_lambda1), .rs_lambda2(rs_lambda2), .rs_omega0(rs_omega0), .rs_omega1(rs_omega1), .err_flag(err_flag_195), .err_data(err_data_195));
    s3_csee_comp u_s3_csee_comp_196 (.comp_ena(csee_init), .alpha1(ALPHA254), .alpha2(ALPHA508), .rs_lambda0(rs_lambda0), .rs_lambda1(rs_lambda1), .rs_lambda2(rs_lambda2), .rs_omega0(rs_omega0), .rs_omega1(rs_omega1), .err_flag(err_flag_196), .err_data(err_data_196));
    s3_csee_comp u_s3_csee_comp_197 (.comp_ena(csee_init), .alpha1(ALPHA255), .alpha2(ALPHA510), .rs_lambda0(rs_lambda0), .rs_lambda1(rs_lambda1), .rs_lambda2(rs_lambda2), .rs_omega0(rs_omega0), .rs_omega1(rs_omega1), .err_flag(err_flag_197), .err_data(err_data_197));

    assign rs_errdata = {err_data_0, err_data_1, err_data_2, err_data_3, err_data_4, err_data_5, err_data_6, err_data_7};
    assign rs_syncbit = {err_data_192[3:0], err_data_193};

    always @(posedge clk or negedge rstn) begin
        if(!rstn) begin
            csee_done_1t <= `D 'd0;
            csee_done_2t <= `D 'd0;
        end else begin
            csee_done_1t <= `D csee_done;
            csee_done_2t <= `D csee_done_1t;
        end
    end

    always @(posedge clk or negedge rstn) begin
        if(!rstn) begin
            counter_err <= `D 'd0;
        end else if(csee_init) begin
            counter_err <= `D counter_err + (((err_flag_0+err_flag_1)+(err_flag_2+err_flag_3))
                                          + ((err_flag_4+err_flag_5)+(err_flag_6+err_flag_7)))
                                          + (((err_flag_192+err_flag_193)+(err_flag_194+err_flag_195))
                                          + (err_flag_196+err_flag_197));
        end else if(csee_cycle) begin
            counter_err <= `D counter_err + (((err_flag_0+err_flag_1)+(err_flag_2+err_flag_3))
                                          + ((err_flag_4+err_flag_5)+(err_flag_6+err_flag_7)));
        end else if(csee_done_2t & !rsdec_fail) begin
            counter_err <= `D 'd0;
        end else begin
            counter_err <= `D counter_err;
        end
    end

    always @(posedge clk or negedge rstn) begin
        if(!rstn) begin
            rsdec_fail <= `D 'd0;
        end else if(!rs_ena) begin
            rsdec_fail <= `D 'd0;
        end else if(csee_ena | csee_cycle | csee_done_1t) begin
            rsdec_fail <= `D (counter_err > 'd2);
        end else begin
            rsdec_fail <= `D rsdec_fail;
        end
    end

endmodule

module s3_csee_comp(
    input wire       comp_ena,
    input wire [7:0] alpha1,
    input wire [7:0] alpha2,
    input wire [7:0] rs_lambda0,
    input wire [7:0] rs_lambda1,
    input wire [7:0] rs_lambda2,
    input wire [7:0] rs_omega0,
    input wire [7:0] rs_omega1,

    output wire       err_flag,
    output wire [7:0] err_data,
    output wire [7:0] l1_multi_a1,
    output wire [7:0] l2_multi_a2,
    output wire [7:0] o1_multi_a1
);

    wire [7:0] l1_x_a1;
    wire [7:0] l2_x_a2;
    wire [7:0] o1_x_a1;
    wire [7:0] l1_x_a1_inv;
    wire [7:0] err_value;
    wire       sum_check;

    gf2m8_multi u_gf2m8_multi_l1al( .x(rs_lambda1), .y(alpha1), .z(l1_x_a1) );
    gf2m8_multi u_gf2m8_multi_l2a2( .x(rs_lambda2), .y(alpha2), .z(l2_x_a2) );
    gf2m8_multi u_gf2m8_multi_o1a1( .x(rs_omega1 ), .y(alpha1), .z(o1_x_a1) );

    gf2m8_inverse u_gf2m8_inverse_l1a1i( .b(l1_x_a1), .b_inv(l1_x_a1_inv) );

    gf2m8_multi u_gf2m8_multi_errv( .x(rs_omega0 ^ o1_x_a1), .y(l1_x_a1_inv), .z(err_value) );

    assign sum_check = ( (rs_lambda0 ^ l1_x_a1 ^ l2_x_a2) == 0 );

    assign err_flag = comp_ena & sum_check;
    assign err_data = {8{err_flag}} & err_value;
    assign l1_multi_a1 = {8{comp_ena}} & l1_x_a1;
    assign l2_multi_a2 = {8{comp_ena}} & l2_x_a2;
    assign o1_multi_a1 = {8{comp_ena}} & o1_x_a1;

endmodule