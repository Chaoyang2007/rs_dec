`timescale  1ns / 1ps


module top;


// rs_decoder Parameters
parameter PERIOD  = 2;

// rs_decoder Inputs
reg   clk                                  = 0 ;
reg   rstn                                 = 0 ;
reg   rsfec_ena                             = 0 ;
reg   rx_data_vld                          = 0 ;
reg   [63:0]  rx_data                      = 0 ;

// rs_decoder Outputs
wire  dec_data_vld                         ;
wire  [63:0]  dec_data                     ;
wire  dec_isos                             ;
wire  rde_error                            ;


initial
begin
    forever #(PERIOD/2)  clk=~clk;
end

initial
begin
    #(PERIOD*2) rstn  =  1;
    rsfec_ena = 1;
end

rs_decoder  u_rs_decoder (
    .clk                     ( clk                  ),
    .rstn                    ( rstn                 ),
    .rsfec_ena               ( rsfec_ena             ),
    .rx_data_vld             ( rx_data_vld          ),
    .rx_data                 ( rx_data       [63:0] ),

    .dec_data_vld            ( dec_data_vld         ),
    .dec_data                ( dec_data      [63:0] ),
    .dec_isos                ( dec_isos             ),
    .rde_error               ( rde_error            )
);

integer k;
initial
begin

    #(PERIOD*2);
    // ================= 1st =================
    k = 0;
    @(posedge clk) #0.2;
    rx_data_vld = 1;
    rx_data = {8'd1, 8'd2, 8'd3, 8'd4, 8'd5, 8'd6, 8'd7, 8'd8};
    for(integer i=0; i<23; i++) begin:_1_rx_symbol_1of1 //rcv=msg, 0-error
        @(posedge clk) #0.2;
        rx_data_vld = 1;
        rx_data[63:56] = 8*k+9;
        rx_data[55:48] = 8*k+10;
        rx_data[47:40] = 8*k+11;
        rx_data[39:32] = 8*k+12;
        rx_data[31:24] = 8*k+13;
        rx_data[23:16] = 8*k+14;
        rx_data[15:8 ] = 8*k+15;
        rx_data[7:0  ] = 8*k+16;
        k++;
    end
    @(posedge clk) #0.2;
    rx_data_vld = 1;
    rx_data = {8'd3, 8'd51, 8'd196, 8'd215, 8'd142, 8'd109, 8'd1, 8'd2};

    @(posedge clk) #0.2;
    rx_data_vld = 0;

    // ================= 2nd =================
    @(posedge clk) #0.2;
    k = 0;
    rx_data_vld = 1;
    rx_data = {8'd3, 8'd4, 8'd5, 8'd6, 8'd7, 8'd8, 8'd9, 8'd10};
    for(integer i=0; i<44; i++) begin:_2_rx_symbol_1of2 //rcv(192)=0, 1-error
        @(posedge clk) #0.2;
        if(i%2 == 0)
            rx_data_vld = 0;
        else begin
            rx_data_vld = 1;
            rx_data[63:56] = 8*k+11;
            rx_data[55:48] = 8*k+12;
            rx_data[47:40] = 8*k+13;
            rx_data[39:32] = 8*k+14;
            rx_data[31:24] = 8*k+15;
            rx_data[23:16] = 8*k+16;
            rx_data[15:8 ] = 8*k+17;
            rx_data[7:0  ] = 8*k+18;
            k++;
        end
    end
    @(posedge clk) #0.2;
    rx_data_vld = 0;
    @(posedge clk) #0.2;
    rx_data_vld = 1;
    rx_data = {8'd187, 8'd188, 8'd189, 8'd190, 8'd191, 8'd0, 8'd3, 8'd51};
    @(posedge clk) #0.2;
    rx_data_vld = 0;
    @(posedge clk) #0.2;
    rx_data_vld = 1;
    rx_data = {8'd196, 8'd215, 8'd142, 8'd109, 8'd1, 8'd2, 8'd3, 8'd4};

    @(posedge clk) #0.2;
    rx_data_vld = 0;

    // ================= 3rd =================
    k = 0;
    @(posedge clk) #0.2;
    rx_data_vld = 1;
    rx_data = {8'd5, 8'd6, 8'd7, 8'd8, 8'd9, 8'd10, 8'd11, 8'd12};
    for(integer i=0; i<33; i++) begin:_3_rx_symbol_2of3 //rcv(192)=0, rcv(193)=0, 2-error
        @(posedge clk) #0.2;
        if(i%3 == 0)
            rx_data_vld = 0;
        else begin
            rx_data_vld = 1;
            rx_data[63:56] = 8*k+13;
            rx_data[55:48] = 8*k+14;
            rx_data[47:40] = 8*k+15;
            rx_data[39:32] = 8*k+16;
            rx_data[31:24] = 8*k+17;
            rx_data[23:16] = 8*k+18;
            rx_data[15:8 ] = 8*k+19;
            rx_data[7:0  ] = 8*k+20;
            k++;
        end
    end
    @(posedge clk) #0.2;
    rx_data_vld = 0;
    @(posedge clk) #0.2;
    rx_data_vld = 1;
    rx_data = {8'd189, 8'd190, 8'd191, 8'd0, 8'd0, 8'd51, 8'd196, 8'd215};
    @(posedge clk) #0.2;
    rx_data_vld = 1;
    rx_data = {8'd142, 8'd109, 8'd1, 8'd2, 8'd3, 8'd4, 8'd5, 8'd6};

    @(posedge clk) #0.2;
    rx_data_vld = 0;

    // ================= 4th =================
    k = 0;
    @(posedge clk) #0.2;
    rx_data_vld = 1;
    rx_data = {8'd7, 8'd0, 8'd9, 8'd10, 8'd11, 8'd12, 8'd13, 8'd14};
    for(integer i=0; i<27; i++) begin:_4_rx_symbol_5of6 //rcv(8)=0, rcv(194)=0, 2-error
        @(posedge clk) #0.2;
        if(i%6 == 0)
            rx_data_vld = 0;
        else begin
            rx_data_vld = 1;
            rx_data[63:56] = 8*k+15;
            rx_data[55:48] = 8*k+16;
            rx_data[47:40] = 8*k+17;
            rx_data[39:32] = 8*k+18;
            rx_data[31:24] = 8*k+19;
            rx_data[23:16] = 8*k+20;
            rx_data[15:8 ] = 8*k+21;
            rx_data[7:0  ] = 8*k+22;
            k++;
        end
    end
    @(posedge clk) #0.2;
    rx_data_vld = 1;
    rx_data = {8'd191, 8'd192, 8'd3, 8'd0, 8'd196, 8'd215, 8'd142, 8'd109};

    @(posedge clk) #0.2;
    rx_data_vld = 0;

    repeat(10) @(posedge clk);
    // ================= 5th =================
    k = 0;
    @(posedge clk) #0.2;
    rx_data_vld = 1;
    rx_data = {8'd1, 8'd2, 8'd3, 8'd4, 8'd5, 8'd6, 8'd7, 8'd8};
    for(integer i=0; i<23; i++) begin:_4_rx_symbol_1of1 //rcv=msg, 0-error
        @(posedge clk) #0.2;
        rx_data_vld = 1;
        rx_data[63:56] = 8*k+9;
        rx_data[55:48] = 8*k+10;
        rx_data[47:40] = 8*k+11;
        rx_data[39:32] = 8*k+12;
        rx_data[31:24] = 8*k+13;
        rx_data[23:16] = 8*k+14;
        rx_data[15:8 ] = 8*k+15;
        rx_data[7:0  ] = 8*k+16;
        k++;
    end
    @(posedge clk) #0.2;
    rx_data_vld = 1;
    rx_data = {8'd3, 8'd51, 8'd196, 8'd215, 8'd142, 8'd109, 8'd1, 8'd2};

    @(posedge clk) #0.2;
    rx_data_vld = 0;



    // ================= end =================
    repeat(30) @(posedge clk);
    @(posedge clk) #0.2 rsfec_ena = 0; 
    @(negedge clk) #0.2 rstn = 0;
    #(PERIOD*2);

    $display($time, " end normal.");
    $finish;
end

initial begin
    #3000
    $display($time, " end overtime!");
    $finish;
end

/*
initial
begin            
    $fsdbDumpfile("top_wave.fsdb"); //         fsdb            
    $fsdbDumpvars(0, top); //tb            
end
*/

endmodule
