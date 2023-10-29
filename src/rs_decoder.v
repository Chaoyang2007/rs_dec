`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: 
// 
// reate Date: 2023/06/25 22:59:31
// Design Name: 
// Module Name: rs_decoder
// Project Name: 
// Desription: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File reated 2023/06/25 22:59:31
// Revision 0.02 - File reated 2023/10/18 20:43:29
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`ifndef D
`define D #0.2
`endif


module rs_decoder (
    input wire        clk,
    input wire        rstn,
    input wire        rsfec_ena,
    input wire        rx_data_vld,
    input wire [63:0] rx_data,

    output reg        dec_data_vld,
    output     [63:0] dec_data,
    output            dec_isos,
    output            rde_error
);

    //======================== rx_data process  ========================//
    reg  [63:0] rx_data_1t;
    wire [63:0] syn_data0;
    wire [63:0] syn_data1;

    reg [1:0] counter_rx_len0;
    reg [4:0] counter_rx_len1;

    wire syn_data_init;
    wire syn_data_last;
    wire syn_data_last0;
    wire syn_data_last1;

    assign syn_data_init  = (counter_rx_len1 == 'd0);
    assign syn_data_last  = syn_data_last0 | syn_data_last1;
    assign syn_data_last0 = (~&counter_rx_len0 && counter_rx_len1=='d24);
    assign syn_data_last1 = ( &counter_rx_len0 && counter_rx_len1=='d23);

    always @(posedge clk or negedge rstn) begin
        if(!rstn) begin
            counter_rx_len0 <= `D 'd0;
        end else if(rx_data_vld) begin
            counter_rx_len0 <= `D syn_data_last ? counter_rx_len0 + 'd1 : counter_rx_len0;
        end
    end

    always @(posedge clk or negedge rstn) begin
        if(!rstn) begin
            counter_rx_len1 <= `D 'd0;
        end else if(rx_data_vld) begin
            counter_rx_len1 <= `D syn_data_last ? 'd0 : counter_rx_len1 + 'd1;
        end
    end

    always @(posedge clk or negedge rstn) begin
        if(!rstn) begin
            rx_data_1t <= `D 'h0;
        end else begin
            rx_data_1t <= `D rx_data_vld ? rx_data : rx_data_1t;
        end
    end

    assign syn_data0 = (counter_rx_len0=='d0) ? (syn_data_last0 ? {rx_data   [63:16], 16'b0                } : rx_data                            ) :
                       (counter_rx_len0=='d1) ? (syn_data_last0 ? {rx_data_1t[15: 0], rx_data[63:32], 16'b0} : {rx_data_1t[15: 0], rx_data[63:16]}) :
                       (counter_rx_len0=='d2) ? (syn_data_last0 ? {rx_data_1t[31: 0], rx_data[63:48], 16'b0} : {rx_data_1t[31: 0], rx_data[63:32]}) :
                       (counter_rx_len0=='d3) ? (                                                              {rx_data_1t[47: 0], rx_data[63:48]}) : 64'b0;
    assign syn_data1 = {rx_data[47: 0], 16'b0};
    //======================== dec_data rd_ctrl ========================//
    reg [4:0] counter_rd_len;

    wire syn_nerror;
    wire kes_done;

    wire dec_data_rd_init;
    wire dec_data_rd_done;
    reg  dec_data_rd_ena;

    assign dec_data_rd_init = syn_nerror || kes_done;
    assign dec_data_rd_done = counter_rd_len == 'd23;

    always @(posedge clk or negedge rstn) begin
        if(!rstn) begin
            dec_data_rd_ena <= `D 'b0;
        end else if(dec_data_rd_done) begin
            dec_data_rd_ena <= `D 'b0;
        end else if(dec_data_rd_init) begin
            dec_data_rd_ena <= `D 'b1;
        end else begin
            dec_data_rd_ena <= `D dec_data_rd_ena;
        end
    end

    always @(posedge clk or negedge rstn) begin
        if(!rstn) begin
            counter_rd_len <= `D 'd0;
        end else if(dec_data_rd_done) begin
            counter_rd_len <= `D 'd0;
        end else if(dec_data_rd_ena) begin
            counter_rd_len <= `D counter_rd_len + 'd1;
        end else begin
            counter_rd_len <= `D counter_rd_len;
        end
    end
    //======================== sub modules inst ========================//
    wire [7:0] rs_syn0;
    wire [7:0] rs_syn1;
    wire [7:0] rs_syn2;
    wire [7:0] rs_syn3;
    wire syn_error;
    wire syn_done;

    s1_syncal u_s1_syncal(
        .clk(clk),
        .rstn(rstn),
        .rs_ena(rsfec_ena),
        .data_vld(rx_data_vld),
        .syn_data0(syn_data0),
        .syn_data1(syn_data1),
        .data_init(syn_data_init),
        .data_last0(syn_data_last0),
        .data_last1(syn_data_last1),

        .rs_syn0(rs_syn0),
        .rs_syn1(rs_syn1),
        .rs_syn2(rs_syn2),
        .rs_syn3(rs_syn3),
        .syn_error(syn_error),
        .syn_nerror(syn_nerror),
        .syn_done(syn_done)
    );

    wire [7:0] rs_lambda0;
    wire [7:0] rs_lambda1;
    wire [7:0] rs_lambda2;
    wire [7:0] rs_omega0;
    wire [7:0] rs_omega1;

    s2_kes u_s2_kes(
        .clk(clk),
        .rstn(rstn),
        .kes_ena(syn_error),
        .rs_syn0(rs_syn0),
        .rs_syn1(rs_syn1),
        .rs_syn2(rs_syn2),
        .rs_syn3(rs_syn3),

        .rs_lambda0(rs_lambda0),
        .rs_lambda1(rs_lambda1),
        .rs_lambda2(rs_lambda2),
        .rs_omega0(rs_omega0),
        .rs_omega1(rs_omega1),
        .kes_done(kes_done)
    );

    wire [63:0] rs_errdata;
    wire [11:0] rs_syncbit;
    wire csee_ongo;
    wire rsdec_fail;
    
    s3_csee u_s3_csee(
        .clk(clk),
        .rstn(rstn),
        .rs_ena(rsfec_ena),
        .csee_ena(kes_done),
        .rs_lambda0(rs_lambda0),
        .rs_lambda1(rs_lambda1),
        .rs_lambda2(rs_lambda2),
        .rs_omega0(rs_omega0),
        .rs_omega1(rs_omega1),

        .csee_ongo(csee_ongo),
        .rs_errdata(rs_errdata),
        .rs_syncbit(rs_syncbit),
        .rsdec_fail(rsdec_fail)
    );

    wire        rs_pop_data_vld;
    wire [63:0] rs_pop_data;
    wire        rs_pop_isos;
    rs_fifo u_rs_fifo(
        .clk(clk),
        .rstn(rstn),
        .push_data_ena(rx_data_vld),
        .rs_data0(syn_data0),
        .rs_data1(syn_data1),
        .data_last0(syn_data_last0),
        .data_last1(syn_data_last1),
        .rs_errdata_vld(csee_ongo),
        .rs_errdata(rs_errdata),
        .rs_syncbit_vld(kes_done),
        .rs_syncbit(rs_syncbit),
        .pop_data_ena(dec_data_rd_ena),
        
        .rs_pop_data_vld(rs_pop_data_vld),
        .rs_pop_data(rs_pop_data),
        .rs_pop_isos(rs_pop_isos)
    );

    //========================   output logic   ========================//
    assign dec_data_vld = rs_pop_data_vld;
    assign dec_data     = rs_pop_data;
    assign dec_isos     = rs_pop_isos;
    assign rde_error    = rsdec_fail;

endmodule
