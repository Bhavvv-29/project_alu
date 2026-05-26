
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.05.2026 18:07:16
// Design Name: 
// Module Name: alu1_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module alu1_tb;

    parameter data_width = 8;
    parameter cmd_width  = 4;

    reg [data_width-1:0] opa, opb;
    reg clk, rst;
    reg cin, mode, ce;
    reg [cmd_width-1:0] cmd;
    reg [1:0] inp_valid;

    wire [(2*data_width)-1:0] res;
    wire cout, oflow, g, e, l, err;

    // DUT Instantiation
    alu1 #(data_width, cmd_width) dut (
        .opa(opa),
        .opb(opb),
        .clk(clk),
        .rst(rst),
        .cin(cin),
        .mode(mode),
        .ce(ce),
        .cmd(cmd),
        .inp_valid(inp_valid),
        .res(res),
        .cout(cout),
        .oflow(oflow),
        .g(g),
        .e(e),
        .l(l),
        .err(err)
    );

    // Clock Generation
    always #5 clk = ~clk;

    initial begin

        // ===== Waveform Dump =====
        $dumpfile("alu_wave.vcd");
        $dumpvars(0, alu1_tb);

        // ===== Initial Values =====
        clk = 0;
        rst = 1;
        ce  = 1;

        opa = 0;
        opb = 0;
        cin = 0;
        mode = 0;
        cmd = 0;
        inp_valid = 2'b00;

        // ===== Reset =====
        #20;
        rst = 0;

        // =================================================
        //                ARITHMETIC MODE
        // =================================================

        // ADD
        @(posedge clk);
        mode = 1;
        cmd  = 4'b0000;
        opa  = 8'd10;
        opb  = 8'd20;
        inp_valid = 2'b11;

        // SUB
        @(posedge clk);
        cmd = 4'b0001;
        opa = 8'd40;
        opb = 8'd15;

        // ADD WITH CIN
        @(posedge clk);
        cmd = 4'b0010;
        opa = 8'd25;
        opb = 8'd5;
        cin = 1'b1;

        // SUB WITH CIN
        @(posedge clk);
        cmd = 4'b0011;
        opa = 8'd30;
        opb = 8'd10;
        cin = 1'b1;

        // INC A
        @(posedge clk);
        cmd = 4'b0100;
        opa = 8'd55;
        inp_valid = 2'b01;

        // DEC A
        @(posedge clk);
        cmd = 4'b0101;
        opa = 8'd55;

        // INC B
        @(posedge clk);
        cmd = 4'b0110;
        opb = 8'd99;
        inp_valid = 2'b10;

        // DEC B
        @(posedge clk);
        cmd = 4'b0111;
        opb = 8'd99;

        // CMP
        @(posedge clk);
        cmd = 4'b1000;
        opa = 8'd20;
        opb = 8'd20;
        inp_valid = 2'b11;

        // MUL INC
        @(posedge clk);
        cmd = 4'b1001;
        opa = 8'd3;
        opb = 8'd4;

        // Wait for pipeline output
        repeat(2) @(posedge clk);

        // SHIFT + MUL
        @(posedge clk);
        cmd = 4'b1010;
        opa = 8'd2;
        opb = 8'd5;

        // Wait for pipeline output
        repeat(2) @(posedge clk);

        // SIGNED ADD
        @(posedge clk);
        cmd = 4'b1011;
        opa = -8'd5;
        opb = 8'd3;

        // SIGNED SUB
        @(posedge clk);
        cmd = 4'b1100;
        opa = -8'd10;
        opb = 8'd4;

        // =================================================
        //                  LOGICAL MODE
        // =================================================

        // AND
        @(posedge clk);
        mode = 0;
        cmd  = 4'b0000;
        opa  = 8'b10101010;
        opb  = 8'b11001100;
        inp_valid = 2'b11;

        // NAND
        @(posedge clk);
        cmd = 4'b0001;

        // OR
        @(posedge clk);
        cmd = 4'b0010;

        // NOR
        @(posedge clk);
        cmd = 4'b0011;

        // XOR
        @(posedge clk);
        cmd = 4'b0100;

        // XNOR
        @(posedge clk);
        cmd = 4'b0101;

        // NOT A
        @(posedge clk);
        cmd = 4'b0110;
        inp_valid = 2'b01;

        // NOT B
        @(posedge clk);
        cmd = 4'b0111;
        inp_valid = 2'b10;

        // SHIFT RIGHT A
        @(posedge clk);
        cmd = 4'b1000;
        opa = 8'b11110000;
        inp_valid = 2'b01;

        // SHIFT LEFT A
        @(posedge clk);
        cmd = 4'b1001;
        opa = 8'b00001111;

        // SHIFT RIGHT B
        @(posedge clk);
        cmd = 4'b1010;
        opb = 8'b11110000;
        inp_valid = 2'b10;

        // SHIFT LEFT B
        @(posedge clk);
        cmd = 4'b1011;
        opb = 8'b00001111;

        // ROTATE LEFT
        @(posedge clk);
        cmd = 4'b1100;
        opa = 8'b10010011;
        opb = 8'd2;
        inp_valid = 2'b11;

        // ROTATE RIGHT
        @(posedge clk);
        cmd = 4'b1101;
        opa = 8'b10010011;
        opb = 8'd2;

        // INVALID INPUT
        @(posedge clk);
        cmd = 4'b0000;
        inp_valid = 2'b00;
        
        // ADD OVERFLOW
        @(posedge clk);
        mode = 1;
        cmd  = 4'b0000;
        opa  = 8'd255;
        opb  = 8'd1;
        inp_valid = 2'b11;
        
        // SUB UNDERFLOW
@(posedge clk);
cmd = 4'b0001;
opa = 8'd5;
opb = 8'd10;
inp_valid = 2'b11;

// ADD WITH CIN OVERFLOW
@(posedge clk);
cmd = 4'b0010;
opa = 8'd255;
opb = 8'd0;
cin = 1'b1;
inp_valid = 2'b11;

// SUB WITH CIN UNDERFLOW
@(posedge clk);
cmd = 4'b0011;
opa = 8'd0;
opb = 8'd0;
cin = 1'b1;
inp_valid = 2'b11;

// INC_A MAX
@(posedge clk);
cmd = 4'b0100;
opa = 8'hFF;
inp_valid = 2'b01;

// DEC_A MIN
@(posedge clk);
cmd = 4'b0101;
opa = 8'h00;
inp_valid = 2'b01;

// CMP EQUAL
@(posedge clk);
cmd = 4'b1000;
opa = 8'd25;
opb = 8'd25;
inp_valid = 2'b11;

// CMP LESS
@(posedge clk);
cmd = 4'b1000;
opa = 8'd10;
opb = 8'd20;
inp_valid = 2'b11;

// MUL INC MAX
@(posedge clk);
cmd = 4'b1001;
opa = 8'hFF;
opb = 8'hFF;
inp_valid = 2'b11;

repeat(2) @(posedge clk);

// SHIFT MUL MAX
@(posedge clk);
cmd = 4'b1010;
opa = 8'hFF;
opb = 8'hFF;
inp_valid = 2'b11;

repeat(2) @(posedge clk);

// SIGNED ADD OVERFLOW
@(posedge clk);
cmd = 4'b1011;
opa = 8'sd127;
opb = 8'sd1;
inp_valid = 2'b11;

// SIGNED ADD NEG OVERFLOW
@(posedge clk);
cmd = 4'b1011;
opa = -8'sd128;
opb = -8'sd1;
inp_valid = 2'b11;

// SIGNED SUB OVERFLOW
@(posedge clk);
cmd = 4'b1100;
opa = 8'sd127;
opb = -8'sd1;
inp_valid = 2'b11;

// AND ALL ONES
@(posedge clk);
mode = 0;
cmd  = 4'b0000;
opa  = 8'hFF;
opb  = 8'hFF;
inp_valid = 2'b11;

// XOR SAME
@(posedge clk);
cmd = 4'b0100;
opa = 8'hAA;
opb = 8'hAA;
inp_valid = 2'b11;

// NOT ZERO
@(posedge clk);
cmd = 4'b0110;
opa = 8'h00;
inp_valid = 2'b01;

// SHL MSB LOSS
@(posedge clk);
cmd = 4'b1001;
opa = 8'b10000000;
inp_valid = 2'b01;

// ROTATE LEFT 0
@(posedge clk);
cmd = 4'b1100;
opa = 8'b10101010;
opb = 8'd0;
inp_valid = 2'b11;

// ROTATE LEFT FULL WIDTH
@(posedge clk);
cmd = 4'b1100;
opa = 8'b10101010;
opb = 8'd8;
inp_valid = 2'b11;

// INVALID ROTATE
@(posedge clk);
cmd = 4'b1100;
opa = 8'hAA;
opb = 8'd20;
inp_valid = 2'b11;

// INVALID INPUT ADD
@(posedge clk);
mode = 1;
cmd  = 4'b0000;
opa  = 8'd10;
opb  = 8'd20;
inp_valid = 2'b01;

// INVALID INPUT NOT_B
@(posedge clk);
mode = 0;
cmd  = 4'b0111;
opb  = 8'h55;
inp_valid = 2'b01;

// ROTATE LEFT INVALID SHIFT
@(posedge clk);
cmd = 4'b1100;
opa = 8'hAA;
opb = 8'd8;
inp_valid = 2'b11;

// CE DISABLED
@(posedge clk);
ce = 0;
mode = 1;
cmd  = 4'b0000;
opa  = 8'd11;
opb  = 8'd22;
inp_valid = 2'b11;

@(posedge clk);
ce = 1;

// RESET MID OPERATION
@(posedge clk);
mode = 1;
cmd  = 4'b0000;
opa  = 8'd50;
opb  = 8'd10;
inp_valid = 2'b11;

#2 rst = 1;
#10 rst = 0;



        // Finish
        #50;
        $finish;
    end

    // ===== Monitor =====
    initial begin
        $monitor("TIME=%0t | mode=%b | cmd=%b | opa=%d | opb=%d | res=%d | cout=%b | oflow=%b | g=%b | e=%b | l=%b | err=%b",
                  $time, mode, cmd, opa, opb, res, cout, oflow, g, e, l, err);
    end

endmodule
