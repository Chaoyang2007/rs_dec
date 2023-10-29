`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: 
// 
// reate Date: 2023/06/25 22:51:57
// Design Name: 
// Module Name: s2_kes
// Project Name: 
// Desription: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File reated 2023/06/02 13:57:31
// Revision 0.02 - File reated 2023/10/18 11:30:27
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`ifndef D
`define D #0.2
`endif

module s2_kes(
    input wire       clk,
    input wire       rstn,
    input wire       kes_ena,
    input wire [7:0] rs_syn0,
    input wire [7:0] rs_syn1,
    input wire [7:0] rs_syn2,
    input wire [7:0] rs_syn3,

    output reg [7:0] rs_lambda0,
    output reg [7:0] rs_lambda1,
    output reg [7:0] rs_lambda2,
    output reg [7:0] rs_omega0,
    output reg [7:0] rs_omega1,
    output reg       kes_done
);
    localparam S0='b0001, S1='b0010, S2='b0100, S3='b1000;

    reg  kes_ena_1t;
    wire kes_init;

    reg [3:0] dcme_state;
    reg [3:0] dcme_state_next;

    wire dcme_idle;
    wire dcme_done;
    wire dcme_abort;

    reg [2:0] deg_R;
    reg [2:0] deg_Q;
    reg [7:0] reg_R0;
    reg [7:0] reg_R1;
    reg [7:0] reg_R2;
    reg [7:0] reg_R3;
    reg [7:0] reg_R4;
    reg [7:0] reg_R5;
    reg [7:0] reg_R6;
    reg [7:0] reg_Q0;
    reg [7:0] reg_Q1;
    reg [7:0] reg_Q2;
    reg [7:0] reg_Q3;
    reg [7:0] reg_Q4;
    reg [7:0] reg_Q5;
    reg [7:0] reg_Q6;

    reg [2:0] deg_R_next;
    reg [2:0] deg_Q_next;
    reg [7:0] reg_R0_next;
    reg [7:0] reg_R1_next;
    reg [7:0] reg_R2_next;
    reg [7:0] reg_R3_next;
    reg [7:0] reg_R4_next;
    reg [7:0] reg_R5_next;
    reg [7:0] reg_R6_next;
    reg [7:0] reg_Q0_next;
    reg [7:0] reg_Q1_next;
    reg [7:0] reg_Q2_next;
    reg [7:0] reg_Q3_next;
    reg [7:0] reg_Q4_next;
    reg [7:0] reg_Q5_next;
    reg [7:0] reg_Q6_next;

    reg [7:0] msb_R;
    reg [7:0] msb_Q;

    reg [7:0] mux_R0;
    reg [7:0] mux_R1;
    reg [7:0] mux_R2;
    reg [7:0] mux_R3;
    reg [7:0] mux_R4;
    reg [7:0] mux_R5;
    //reg [7:0] mux_R6;
    reg [7:0] mux_Q0;
    reg [7:0] mux_Q1;
    reg [7:0] mux_Q2;
    reg [7:0] mux_Q3;
    reg [7:0] mux_Q4;
    reg [7:0] mux_Q5;
    //reg [7:0] mux_Q6;

    wire [7:0] msb_R_multi_Q0;
    wire [7:0] msb_R_multi_Q1;
    wire [7:0] msb_R_multi_Q2;
    wire [7:0] msb_R_multi_Q3;
    wire [7:0] msb_R_multi_Q4;
    wire [7:0] msb_R_multi_Q5;
    //wire [7:0] msb_R_multi_Q6;
    wire [7:0] msb_Q_multi_R0;
    wire [7:0] msb_Q_multi_R1;
    wire [7:0] msb_Q_multi_R2;
    wire [7:0] msb_Q_multi_R3;
    wire [7:0] msb_Q_multi_R4;
    wire [7:0] msb_Q_multi_R5;
    //wire [7:0] msb_Q_multi_R6;

    always @(posedge clk or negedge rstn) begin
        if(!rstn) begin
            kes_ena_1t <= `D 1'b0;
        end else begin
            kes_ena_1t <= `D kes_ena;
        end
    end
    assign kes_init = kes_ena & ~kes_ena_1t;

    always @(*) begin
        case (dcme_state)
            S0: dcme_state_next = kes_init ? S1 : dcme_state;
            S1: dcme_state_next = S2;
            S2: dcme_state_next = S3;
            S3: dcme_state_next = S0;
            default: dcme_state_next = S0;
        endcase
    end

    always @(posedge clk or negedge rstn) begin
        if(!rstn) begin
            dcme_state <= `D S0;
        end else begin
            dcme_state <= `D dcme_state_next;
        end
    end

    assign dcme_idle  = dcme_state[0];
    assign dcme_done  = dcme_state[3];
    assign dcme_abort = deg_R < 'd2;

    always @(*) begin
        if(dcme_idle) begin
            {mux_R0, mux_R1, mux_R2, mux_R3, mux_R4, mux_R5, /* mux_R6,*/ msb_R} <= {8'h00, 8'h00, 8'h00,   8'h00,   8'h00,   8'h00,   8'h01};
            {mux_Q0, mux_Q1, mux_Q2, mux_Q3, mux_Q4, mux_Q5, /* mux_Q6,*/ msb_Q} <= {8'h01, 8'h00, 8'h00, rs_syn0, rs_syn1, rs_syn2, rs_syn3};
        end else begin
            {mux_R0, mux_R1, mux_R2, mux_R3, mux_R4, mux_R5, /* mux_R6,*/ msb_R} <= {reg_R0, reg_R1, reg_R2, reg_R3, reg_R4, reg_R5, reg_R6};
            {mux_Q0, mux_Q1, mux_Q2, mux_Q3, mux_Q4, mux_Q5, /* mux_Q6,*/ msb_Q} <= {reg_Q0, reg_Q1, reg_Q2, reg_Q3, reg_Q4, reg_Q5, reg_Q6};
        end
    end

    gf2m8_multi u_gf2m8_multi_rq0 ( .x(msb_R), .y(mux_Q0), .z(msb_R_multi_Q0) );
    gf2m8_multi u_gf2m8_multi_rq1 ( .x(msb_R), .y(mux_Q1), .z(msb_R_multi_Q1) );
    gf2m8_multi u_gf2m8_multi_rq2 ( .x(msb_R), .y(mux_Q2), .z(msb_R_multi_Q2) );
    gf2m8_multi u_gf2m8_multi_rq3 ( .x(msb_R), .y(mux_Q3), .z(msb_R_multi_Q3) );
    gf2m8_multi u_gf2m8_multi_rq4 ( .x(msb_R), .y(mux_Q4), .z(msb_R_multi_Q4) );
    gf2m8_multi u_gf2m8_multi_rq5 ( .x(msb_R), .y(mux_Q5), .z(msb_R_multi_Q5) );
    //gf2m8_multi u_gf2m8_multi_rq6 ( .x(msb_R), .y(mux_Q6), .z(msb_R_multi_Q6) );
    gf2m8_multi u_gf2m8_multi_qr0 ( .x(msb_Q), .y(mux_R0), .z(msb_Q_multi_R0) );
    gf2m8_multi u_gf2m8_multi_qr1 ( .x(msb_Q), .y(mux_R1), .z(msb_Q_multi_R1) );
    gf2m8_multi u_gf2m8_multi_qr2 ( .x(msb_Q), .y(mux_R2), .z(msb_Q_multi_R2) );
    gf2m8_multi u_gf2m8_multi_qr3 ( .x(msb_Q), .y(mux_R3), .z(msb_Q_multi_R3) );
    gf2m8_multi u_gf2m8_multi_qr4 ( .x(msb_Q), .y(mux_R4), .z(msb_Q_multi_R4) );
    gf2m8_multi u_gf2m8_multi_qr5 ( .x(msb_Q), .y(mux_R5), .z(msb_Q_multi_R5) );
    //gf2m8_multi u_gf2m8_multi_qr6 ( .x(msb_Q), .y(mux_R6), .z(msb_Q_multi_R6) );
    wire [7:0] aqbr_0, aqbr_1, aqbr_2, aqbr_3, aqbr_4, aqbr_5;
    assign {aqbr_0, aqbr_1, aqbr_2, aqbr_3, aqbr_4, aqbr_5} = { msb_R_multi_Q0^msb_Q_multi_R0, msb_R_multi_Q1^msb_Q_multi_R1, msb_R_multi_Q2^msb_Q_multi_R2,
                                                                msb_R_multi_Q3^msb_Q_multi_R3, msb_R_multi_Q4^msb_Q_multi_R4, msb_R_multi_Q5^msb_Q_multi_R5 };
    
    always @(*) begin
        if(!rstn) begin
            deg_R_next <= 'd0;//4
            deg_Q_next <= 'd0;//3
            {reg_R0_next, reg_R1_next, reg_R2_next, reg_R3_next, reg_R4_next, reg_R5_next, reg_R6_next} <= {8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00};
            {reg_Q0_next, reg_Q1_next, reg_Q2_next, reg_Q3_next, reg_Q4_next, reg_Q5_next, reg_Q6_next} <= {8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00};
        end else if(dcme_idle) begin
            if(msb_Q==8'h00) begin
                deg_R_next <= 'd4;
                deg_Q_next <= 'd2;
                {reg_R0_next, reg_R1_next, reg_R2_next, reg_R3_next, reg_R4_next, reg_R5_next, reg_R6_next} <= {8'h00, 8'h00, 8'h00, 8'h00,   8'h00,   8'h00,   8'h01};
                {reg_Q0_next, reg_Q1_next, reg_Q2_next, reg_Q3_next, reg_Q4_next, reg_Q5_next, reg_Q6_next} <= {8'h00, 8'h01, 8'h00, 8'h00, rs_syn0, rs_syn1, rs_syn2};
            end else begin
                deg_R_next <= 'd3;
                deg_Q_next <= 'd3;
                {reg_R0_next, reg_R1_next, reg_R2_next, reg_R3_next, reg_R4_next, reg_R5_next, reg_R6_next} <= {8'h00, aqbr_0, aqbr_1, aqbr_2, aqbr_3, aqbr_4, aqbr_5};
                {reg_Q0_next, reg_Q1_next, reg_Q2_next, reg_Q3_next, reg_Q4_next, reg_Q5_next, reg_Q6_next} <= {8'h01, 8'h00, 8'h00, rs_syn0, rs_syn1, rs_syn2, rs_syn3};
            end
        end else if(!dcme_abort) begin
            if(msb_Q==8'h00) begin
                deg_R_next <= deg_R;
                deg_Q_next <= deg_Q - 'd1;
                {reg_R0_next, reg_R1_next, reg_R2_next, reg_R3_next, reg_R4_next, reg_R5_next, reg_R6_next} <= {reg_R0, reg_R1, reg_R2, reg_R3, reg_R4, reg_R5, reg_R6};
                {reg_Q0_next, reg_Q1_next, reg_Q2_next, reg_Q3_next, reg_Q4_next, reg_Q5_next, reg_Q6_next} <= {8'h00,  reg_Q0, reg_Q1, reg_Q2, reg_Q3, reg_Q4, reg_Q5};
            end else begin
                {reg_R0_next, reg_R1_next, reg_R2_next, reg_R3_next, reg_R4_next, reg_R5_next, reg_R6_next} <= {8'h00, aqbr_0, aqbr_1, aqbr_2, aqbr_3, aqbr_4, aqbr_5};
                if(msb_Q!=8'h00 && deg_R<deg_Q) begin
                    deg_R_next <= deg_Q - 'd1;
                    deg_Q_next <= deg_R;
                    {reg_Q0_next, reg_Q1_next, reg_Q2_next, reg_Q3_next, reg_Q4_next, reg_Q5_next, reg_Q6_next} <= {reg_R0, reg_R1, reg_R2, reg_R3, reg_R4, reg_R5, reg_R6};                    
                end else begin
                    deg_R_next <= deg_R - 'd1;
                    deg_Q_next <= deg_Q;
                    {reg_Q0_next, reg_Q1_next, reg_Q2_next, reg_Q3_next, reg_Q4_next, reg_Q5_next, reg_Q6_next} <= {reg_Q0, reg_Q1, reg_Q2, reg_Q3, reg_Q4, reg_Q5, reg_Q6};  
                end
            end
        end else begin
            deg_R_next <= deg_R;
            deg_Q_next <= deg_Q;
            {reg_R0_next, reg_R1_next, reg_R2_next, reg_R3_next, reg_R4_next, reg_R5_next, reg_R6_next} <= {reg_R0, reg_R1, reg_R2, reg_R3, reg_R4, reg_R5, reg_R6};
            {reg_Q0_next, reg_Q1_next, reg_Q2_next, reg_Q3_next, reg_Q4_next, reg_Q5_next, reg_Q6_next} <= {reg_Q0, reg_Q1, reg_Q2, reg_Q3, reg_Q4, reg_Q5, reg_Q6};
        end
    end

    icg u_icg_kes_rq(.clk(clk), .ena(kes_init | ~dcme_state[0]), .rstn(rstn), .gclk(kes_rq_clk));
    always @(posedge kes_rq_clk or negedge rstn) begin
        if(!rstn) begin
            deg_R <= `D 8'h00;//4
            deg_Q <= `D 8'h00;//3
            {reg_R0, reg_R1, reg_R2, reg_R3, reg_R4, reg_R5, reg_R6} <= `D {8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00};
            {reg_Q0, reg_Q1, reg_Q2, reg_Q3, reg_Q4, reg_Q5, reg_Q6} <= `D {8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00};
        end else begin
            deg_R <= `D deg_R_next;
            deg_Q <= `D deg_Q_next;
            {reg_R0, reg_R1, reg_R2, reg_R3, reg_R4, reg_R5, reg_R6} <= `D {reg_R0_next, reg_R1_next, reg_R2_next, reg_R3_next, reg_R4_next, reg_R5_next, reg_R6_next};
            {reg_Q0, reg_Q1, reg_Q2, reg_Q3, reg_Q4, reg_Q5, reg_Q6} <= `D {reg_Q0_next, reg_Q1_next, reg_Q2_next, reg_Q3_next, reg_Q4_next, reg_Q5_next, reg_Q6_next};
        end
    end

    icg u_icg_kes_lo(.clk(clk), .ena(dcme_done), .rstn(rstn), .gclk(kes_lo_clk));
    always @(posedge kes_lo_clk or negedge rstn) begin
        if (!rstn) begin
            rs_lambda0 <= `D 8'h00;
            rs_lambda1 <= `D 8'h00;
            rs_lambda2 <= `D 8'h00;
            rs_omega0  <= `D 8'h00;
            rs_omega1  <= `D 8'h00;
        end
        else begin
            rs_lambda0 <= `D reg_R2_next;
            rs_lambda1 <= `D reg_R3_next;
            rs_lambda2 <= `D reg_R4_next;
            rs_omega0  <= `D reg_R5_next;
            rs_omega1  <= `D reg_R6_next;
        end
    end

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            kes_done <= `D 0;
        end
        else if (dcme_done) begin
            kes_done <= `D 1;
        end
        else begin
            kes_done <= `D 0;
        end
    end

endmodule
