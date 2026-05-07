`timescale 1ns / 1ps

module tb_alu1;

parameter data_width = 8;
parameter cmd_width  = 4;

reg clk, rst, ce;
reg [data_width-1:0] opa, opb;
reg cin, mode;
reg [1:0] inp_valid;
reg [cmd_width-1:0] cmd;

wire [2*data_width-1:0] res;
wire oflow, cout;
wire g, l, e;
wire err;

alu1 #(data_width, cmd_width) dut (
    .clk(clk), .rst(rst), .opa(opa), .opb(opb),
    .cin(cin), .ce(ce), .mode(mode),
    .inp_valid(inp_valid), .cmd(cmd),
    .res(res), .oflow(oflow), .cout(cout),
    .g(g), .l(l), .e(e), .err(err)
);

//////////////////////////////////////////////////
// Clock
//////////////////////////////////////////////////
always #5 clk = ~clk;

//////////////////////////////////////////////////
// Task
//////////////////////////////////////////////////
task apply;
input [3:0] t_cmd;
input t_mode;
input [7:0] t_opa, t_opb;
input [1:0] t_valid;
input t_cin;
begin
    @(posedge clk);
    cmd       = t_cmd;
    mode      = t_mode;
    opa       = t_opa;
    opb       = t_opb;
    inp_valid = t_valid;
    cin       = t_cin;
end
endtask

//////////////////////////////////////////////////
// Test Sequence
//////////////////////////////////////////////////
integer i;

initial begin
    clk = 0; rst = 1; ce = 1;
    opa = 0; opb = 0; cmd = 0;
    mode = 0; inp_valid = 0; cin = 0;

    #10 rst = 0;

    ////////////////////////////////////////////
    // 🔢ARITHMETIC MODE (CMD 0–12)
    ////////////////////////////////////////////
    mode = 1;

    for (i = 0; i <= 12; i = i + 1) begin
        case(i)

        0: apply(i,1, 10,5, 2'b11,0);         // ADD
        1: apply(i,1, 20,8, 2'b11,0);         // SUB
        2: apply(i,1, 10,5, 2'b11,1);         // ADD + CIN
        3: apply(i,1, 20,8, 2'b11,1);         // SUB + CIN
        4: apply(i,1, 15,0, 2'b01,0);         // INC A
        5: apply(i,1, 15,0, 2'b01,0);         // DEC A
        6: apply(i,1, 0,15, 2'b10,0);         // INC B
        7: apply(i,1, 0,15, 2'b10,0);         // DEC B
        8: apply(i,1, 25,25,2'b11,0);         // COMPARE
        9: begin                              // MUL (3 cycles)
               apply(i,1, 3,4,2'b11,0);
               #40;
           end
        10: begin                             // MUL (3 cycles)
               apply(i,1, 3,5,2'b11,0);
               #40;
            end
        11: apply(i,1, 127,1,2'b11,0);        // SIGNED ADD overflow
        12: apply(i,1, 128,1,2'b11,0);        // SIGNED SUB

        endcase

        #10;
    end

    ////////////////////////////////////////////
    // 🔌LOGICAL MODE (CMD 0–13)
    ////////////////////////////////////////////
    mode = 0;

    for (i = 0; i <= 13; i = i + 1) begin
        case(i)

        0: apply(i,0, 8'hAA,8'hCC,2'b11,0); // AND
        1: apply(i,0, 8'hAA,8'hCC,2'b11,0); // NAND
        2: apply(i,0, 8'hAA,8'hCC,2'b11,0); // OR
        3: apply(i,0, 8'hAA,8'hCC,2'b11,0); // NOR
        4: apply(i,0, 8'hAA,8'hCC,2'b11,0); // XOR
        5: apply(i,0, 8'hAA,8'hCC,2'b11,0); // XNOR
        6: apply(i,0, 8'hAA,0,    2'b01,0); // NOT A
        7: apply(i,0, 0,8'hCC,    2'b10,0); // NOT B
        8: apply(i,0, 8'hF0,0,    2'b01,0); // SHR A
        9: apply(i,0, 8'hF0,0,    2'b01,0); // SHL A
        10:apply(i,0, 0,8'h0F,    2'b10,0); // SHR B
        11:apply(i,0, 0,8'h0F,    2'b10,0); // SHL B
        12:apply(i,0, 8'b10110001,8'd2,2'b11,0); // ROL
        13:apply(i,0, 8'b10110001,8'd2,2'b11,0); // ROR

        endcase

        #10;
    end

    ////////////////////////////////////////////
    // ❌INVALID CASE TESTS
    ////////////////////////////////////////////
    mode = 1;
    apply(4'd0,1, 10,5,2'b00,0); // invalid input
    #10;

    ////////////////////////////////////////////
    // END
    ////////////////////////////////////////////
    #50;
    $finish;
end

//////////////////////////////////////////////////
// Monitor
//////////////////////////////////////////////////
initial begin
    $monitor("T=%0t | mode=%b cmd=%d | opa=%d opb=%d | res=%d | of=%b c=%b err=%b",
              $time, mode, cmd, opa, opb, res, oflow, cout, err);
end

endmodule
