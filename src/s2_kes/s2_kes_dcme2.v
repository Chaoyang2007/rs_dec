`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: 
// 
// Create Date: 2023/06/25 22:51:57
// Design Name: 
// Module Name: s2_kes_dcme2
// Project Name: 
// Desription: 5 cycles
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

module s2_kes_dcme2(
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
    localparam S0='b00001;
    localparam S1='b00010;
    localparam S2='b00100;
    localparam S3='b01000;
    localparam S4='b10000;

    reg  kes_ena_1t;
    wire kes_init;

    reg [4:0] dcme2_state;
    reg [4:0] dcme2_state_next;

    wire load;
    wire done;
    wire stop;
    wire shift;
    wire swap;

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

    wire [7:0] msb_R;
    wire [7:0] msb_Q;

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
        case (dcme2_state)
            S0: dcme2_state_next = kes_init ? S1 : S0;
            S1: dcme2_state_next = S2;
            S2: dcme2_state_next = S3;
            S3: dcme2_state_next = S4;
            S4: dcme2_state_next = S0;
            default: dcme2_state_next = S0;
        endcase
    end

    always @(posedge clk or negedge rstn) begin
        if(!rstn) begin
            dcme2_state <= `D S0;
        end else begin
            dcme2_state <= `D dcme2_state_next;
        end
    end

    assign load  = kes_init; // dcme2_state[0] & dcme2_state_next[1]; // load syndrome
    assign done  = dcme2_state[4]; // kes done
    assign stop  = deg_R < 'd2; // early termination
    assign shift = msb_Q==8'h00; // right shift Q
    assign swap  = msb_R!=8'h00 && deg_R<deg_Q; // swap R Q and calculate
    // assign calculate = msb_R==8'h00 || deg_R>=deg_Q;

    assign msb_R = reg_R6;
    assign msb_Q = reg_Q6;

    gf2m8_multi u_gf2m8_multi_rq0 ( .x(msb_R), .y(reg_Q0), .z(msb_R_multi_Q0) );
    gf2m8_multi u_gf2m8_multi_rq1 ( .x(msb_R), .y(reg_Q1), .z(msb_R_multi_Q1) );
    gf2m8_multi u_gf2m8_multi_rq2 ( .x(msb_R), .y(reg_Q2), .z(msb_R_multi_Q2) );
    gf2m8_multi u_gf2m8_multi_rq3 ( .x(msb_R), .y(reg_Q3), .z(msb_R_multi_Q3) );
    gf2m8_multi u_gf2m8_multi_rq4 ( .x(msb_R), .y(reg_Q4), .z(msb_R_multi_Q4) );
    gf2m8_multi u_gf2m8_multi_rq5 ( .x(msb_R), .y(reg_Q5), .z(msb_R_multi_Q5) );
    //gf2m8_multi u_gf2m8_multi_rq6 ( .x(msb_R), .y(reg_Q6), .z(msb_R_multi_Q6) );
    gf2m8_multi u_gf2m8_multi_qr0 ( .x(msb_Q), .y(reg_R0), .z(msb_Q_multi_R0) );
    gf2m8_multi u_gf2m8_multi_qr1 ( .x(msb_Q), .y(reg_R1), .z(msb_Q_multi_R1) );
    gf2m8_multi u_gf2m8_multi_qr2 ( .x(msb_Q), .y(reg_R2), .z(msb_Q_multi_R2) );
    gf2m8_multi u_gf2m8_multi_qr3 ( .x(msb_Q), .y(reg_R3), .z(msb_Q_multi_R3) );
    gf2m8_multi u_gf2m8_multi_qr4 ( .x(msb_Q), .y(reg_R4), .z(msb_Q_multi_R4) );
    gf2m8_multi u_gf2m8_multi_qr5 ( .x(msb_Q), .y(reg_R5), .z(msb_Q_multi_R5) );
    //gf2m8_multi u_gf2m8_multi_qr6 ( .x(msb_Q), .y(reg_R6), .z(msb_Q_multi_R6) );
    wire [7:0] aqbr_0, aqbr_1, aqbr_2, aqbr_3, aqbr_4, aqbr_5;
    assign {aqbr_0, aqbr_1, aqbr_2, aqbr_3, aqbr_4, aqbr_5} = { msb_R_multi_Q0^msb_Q_multi_R0, msb_R_multi_Q1^msb_Q_multi_R1, msb_R_multi_Q2^msb_Q_multi_R2,
                                                                msb_R_multi_Q3^msb_Q_multi_R3, msb_R_multi_Q4^msb_Q_multi_R4, msb_R_multi_Q5^msb_Q_multi_R5 };
    
    always @(*) begin
        if(!rstn) begin
            deg_R_next <= deg_R;
            deg_Q_next <= deg_Q;
            {reg_R0_next, reg_R1_next, reg_R2_next, reg_R3_next, reg_R4_next, reg_R5_next, reg_R6_next} <= {reg_R0, reg_R1, reg_R2, reg_R3, reg_R4, reg_R5, reg_R6};
            {reg_Q0_next, reg_Q1_next, reg_Q2_next, reg_Q3_next, reg_Q4_next, reg_Q5_next, reg_Q6_next} <= {reg_Q0, reg_Q1, reg_Q2, reg_Q3, reg_Q4, reg_Q5, reg_Q6};
        end else if(load) begin
            deg_R_next <= 'd4;
            deg_Q_next <= 'd3;
            {reg_R0_next, reg_R1_next, reg_R2_next, reg_R3_next, reg_R4_next, reg_R5_next, reg_R6_next} <= {8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h01};
            {reg_Q0_next, reg_Q1_next, reg_Q2_next, reg_Q3_next, reg_Q4_next, reg_Q5_next, reg_Q6_next} <= {8'h01, 8'h00, 8'h00, rs_syn0, rs_syn1, rs_syn2, rs_syn3};
        end else if(!stop) begin
            if(shift) begin
                deg_R_next <= deg_R;
                deg_Q_next <= deg_Q - 'd1;
                {reg_R0_next, reg_R1_next, reg_R2_next, reg_R3_next, reg_R4_next, reg_R5_next, reg_R6_next} <= {reg_R0, reg_R1, reg_R2, reg_R3, reg_R4, reg_R5, reg_R6};
                {reg_Q0_next, reg_Q1_next, reg_Q2_next, reg_Q3_next, reg_Q4_next, reg_Q5_next, reg_Q6_next} <= {8'h00,  reg_Q0, reg_Q1, reg_Q2, reg_Q3, reg_Q4, reg_Q5};
            end else begin
                {reg_R0_next, reg_R1_next, reg_R2_next, reg_R3_next, reg_R4_next, reg_R5_next, reg_R6_next} <= {8'h00, aqbr_0, aqbr_1, aqbr_2, aqbr_3, aqbr_4, aqbr_5};
                if(swap) begin
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

    // assign in_process = kes_init | ~dcme2_state[0];
    icg u_icg_kes_rq(.clk(clk), .ena(kes_init | ~dcme2_state[0]), .rstn(rstn), .gclk(kes_doing_clk));
    always @(posedge kes_doing_clk or negedge rstn) begin
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

    // icg u_icg_kes_lo(.clk(clk), .ena(done), .rstn(rstn), .gclk(kes_lo_clk));
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            rs_lambda0 <= `D 8'h00;
            rs_lambda1 <= `D 8'h00;
            rs_lambda2 <= `D 8'h00;
            rs_omega0  <= `D 8'h00;
            rs_omega1  <= `D 8'h00;
        end else if(done) begin
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
        end else if (done) begin
            kes_done <= `D 1;
        end else begin
            kes_done <= `D 0;
        end
    end

endmodule
