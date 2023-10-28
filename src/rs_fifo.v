`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer:
//
// Create Date: 2023/06/25 15:32:02
// Design Name:
// Module Name: rs_fifo
// Project Name:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created 2023/06/15 11:32:02
// Revision 0.02 - File Created 2023/10/18 20:32:21
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////

`ifndef D
`define D #0.2
`endif

module rs_fifo (
    input wire        clk,
    input wire        rstn,
    input wire        push_data_ena,
    input wire [63:0] rs_data0,
    input wire [63:0] rs_data1,
    input wire        data_last0,
    input wire        data_last1,

    input wire        rs_errdata_vld,
    input wire [63:0] rs_errdata,
    input wire        rs_syncbit_vld,
    input wire [11:0] rs_syncbit,
    input wire        pop_data_ena,

    output reg        rs_pop_data_vld,
    output reg [63:0] rs_pop_data,
    output reg        rs_pop_isos
);
    //======================== common used logics ========================//
    wire        data_last;
    wire [11:0] rs_data_syncbit;
    wire        pop_data_end;

    assign data_last       = data_last0 | data_last1;
    assign rs_data_syncbit = data_last1 ? rs_data1[59:48] : rs_data0[59:48];
    assign pop_data_end    = ~pop_data_ena & rs_pop_data_vld;

    always @(posedge clk or negedge rstn) begin
        if(!rstn) begin
            rs_pop_data_vld <= `D 'd0;
        end else begin
            rs_pop_data_vld <= `D pop_data_ena;
        end
    end
    //======================== data fifo logics ========================//
    reg     [63:0] data_ram      [0:31];
    reg     [ 5:0] data_wr_ptr;
    reg     [ 5:0] data_aw_ptr;
    reg     [ 5:0] data_rd_ptr;
    wire    [ 4:0] data_wr_addr;
    wire    [ 4:0] data_aw_addr;
    wire    [ 4:0] data_rd_addr;
    wire           data_wr_full;
    wire           data_aw_empty;
    wire           data_rd_empty;
    integer        i; //used for initializing data_ram

    assign data_wr_addr  = data_wr_ptr[4:0];
    assign data_aw_addr  = data_aw_ptr[4:0];
    assign data_rd_addr  = data_rd_ptr[4:0];
    assign data_wr_full  = data_wr_ptr == {~data_rd_ptr[5], data_rd_ptr[4:0]};
    assign data_aw_empty = data_aw_ptr == data_wr_ptr;
    assign data_rd_empty = data_rd_ptr == data_wr_ptr;

    always @(posedge clk) begin
        if (!rstn) begin
            data_wr_ptr <= `D 'b0;
            data_aw_ptr <= `D 'b0;
            for (i = 0; i < 32; i = i + 1) begin : reset_data_ram
                data_ram[i] <= `D {64{1'b0}};
            end
        end else begin
            if (push_data_ena & !data_last0 & !data_wr_full) begin
                data_wr_ptr            <= `D data_wr_ptr + 'b1;
                data_ram[data_wr_addr] <= `D rs_data0;
            end
            if (rs_errdata_vld & !data_aw_empty) begin
                data_aw_ptr            <= `D data_aw_ptr + 'b1;
                data_ram[data_aw_addr] <= `D data_ram[data_aw_addr] ^ rs_errdata;
            end else if (pop_data_end) begin
                data_aw_ptr            <= `D data_rd_ptr;
            end
        end
    end

    always @(posedge clk) begin
        if (!rstn) begin
            data_rd_ptr <= `D 'b0;
            rs_pop_data <= `D {64{1'b0}};
        end else if (pop_data_ena & !data_rd_empty) begin
            data_rd_ptr <= `D data_rd_ptr + 'b1;
            rs_pop_data <= `D data_ram[data_rd_addr];
        end else begin
            data_rd_ptr <= `D data_rd_ptr;
            rs_pop_data <= `D rs_pop_data;
        end
    end
    //======================== isos fifo logics ========================//
    reg  [11:0] isos_ram         [0:1];
    reg  [ 1:0] isos_wr_ptr;
    reg  [ 1:0] isos_aw_ptr;
    reg  [ 1:0] isos_rd_ptr;
    wire        isos_wr_full;
    wire        isos_aw_empty;
    wire        isos_rd_empty;
    reg  [ 4:0] counter_pop_isos;
    wire [ 3:0] sync_bit_loc;

    assign isos_wr_full  = isos_wr_ptr == {~isos_rd_ptr[1], isos_rd_ptr[0]};
    assign isos_aw_empty = isos_aw_ptr == isos_wr_ptr;
    assign isos_rd_empty = isos_rd_ptr == isos_wr_ptr;

    always @(posedge clk) begin
        if (!rstn) begin
            isos_wr_ptr <= `D 'b0;
            isos_aw_ptr <= `D 'b0;
            isos_ram[0] <= `D 'b0;
            isos_ram[1] <= `D 'b0;
        end else begin
            if (push_data_ena & data_last & !isos_wr_full) begin
                isos_wr_ptr              <= `D isos_wr_ptr + 'b1;
                isos_ram[isos_wr_ptr[0]] <= `D rs_data_syncbit;
            end
            if (rs_syncbit_vld & !isos_aw_empty) begin
                isos_aw_ptr              <= `D isos_aw_ptr + 'b1;
                isos_ram[isos_aw_ptr[0]] <= `D isos_ram[isos_aw_ptr[0]] ^ rs_syncbit;
            end else if (pop_data_end) begin
                isos_aw_ptr            <= `D isos_rd_ptr;
            end
        end
    end

    always @(posedge clk) begin
        if (!rstn) begin
            isos_rd_ptr      <= `D 'b0;
            counter_pop_isos <= `D 'd0;
        end else if (counter_pop_isos == 'd23) begin
            isos_rd_ptr      <= `D isos_rd_ptr + 'b1;
            counter_pop_isos <= `D 'd0;
        end else if (pop_data_ena & !isos_rd_empty) begin
            isos_rd_ptr      <= `D isos_rd_ptr;
            counter_pop_isos <= `D counter_pop_isos + 'd1;
        end else begin
            isos_rd_ptr      <= `D isos_rd_ptr;
            counter_pop_isos <= `D counter_pop_isos;
        end
    end

    assign sync_bit_loc = counter_pop_isos[4:1];

    always @(posedge clk) begin
        if (!rstn) begin
            rs_pop_isos <= `D 'b0;
        end else if (pop_data_ena & !isos_rd_empty) begin
            rs_pop_isos <= `D isos_ram[isos_rd_ptr[0]]['d11-sync_bit_loc];
        end else begin
            rs_pop_isos <= `D 'b0;
        end
    end

    //======================== read ram items ========================//
    wire [11:0] dbg_isos_ram_0  = isos_ram[0];
    wire [11:0] dbg_isos_ram_1  = isos_ram[1];
    wire [63:0] dbg_data_ram_0  = data_ram[0];
    wire [63:0] dbg_data_ram_1  = data_ram[1];
    wire [63:0] dbg_data_ram_2  = data_ram[2];
    wire [63:0] dbg_data_ram_3  = data_ram[3];
    wire [63:0] dbg_data_ram_4  = data_ram[4];
    wire [63:0] dbg_data_ram_5  = data_ram[5];
    wire [63:0] dbg_data_ram_6  = data_ram[6];
    wire [63:0] dbg_data_ram_7  = data_ram[7];
    wire [63:0] dbg_data_ram_8  = data_ram[8];
    wire [63:0] dbg_data_ram_9  = data_ram[9];
    wire [63:0] dbg_data_ram_10 = data_ram[10];
    wire [63:0] dbg_data_ram_11 = data_ram[11];
    wire [63:0] dbg_data_ram_12 = data_ram[12];
    wire [63:0] dbg_data_ram_13 = data_ram[13];
    wire [63:0] dbg_data_ram_14 = data_ram[14];
    wire [63:0] dbg_data_ram_15 = data_ram[15];
    wire [63:0] dbg_data_ram_16 = data_ram[16];
    wire [63:0] dbg_data_ram_17 = data_ram[17];
    wire [63:0] dbg_data_ram_18 = data_ram[18];
    wire [63:0] dbg_data_ram_19 = data_ram[19];
    wire [63:0] dbg_data_ram_20 = data_ram[20];
    wire [63:0] dbg_data_ram_21 = data_ram[21];
    wire [63:0] dbg_data_ram_22 = data_ram[22];
    wire [63:0] dbg_data_ram_23 = data_ram[23];
    wire [63:0] dbg_data_ram_24 = data_ram[24];
    wire [63:0] dbg_data_ram_25 = data_ram[25];
    wire [63:0] dbg_data_ram_26 = data_ram[26];
    wire [63:0] dbg_data_ram_27 = data_ram[27];
    wire [63:0] dbg_data_ram_28 = data_ram[28];
    wire [63:0] dbg_data_ram_29 = data_ram[29];
    wire [63:0] dbg_data_ram_30 = data_ram[30];
    wire [63:0] dbg_data_ram_31 = data_ram[31];

endmodule


