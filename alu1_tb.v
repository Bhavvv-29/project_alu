`default_nettype none
module alu1_tb;
wire g,e,l;
wire oflow;
wire [15:0]res;
wire err;
wire cout;
reg cin,clk,rst,ce;
reg [7:0]opa,opb;
reg [1:0]inp_valid;
reg mode;
reg [3:0]cmd;

alu1 #(.data_width(8),.cmd_width(4)) m1(.cmd(cmd),.mode(mode),.inp_valid(inp_valid),.opa(opa),.opb(opb),.cin(cin),.clk(clk),.rst(rst),.ce(ce),.cout(cout),.err(err),.oflow(oflow),.res(res),.g(g),.e(e),.l(l));

initial clk=0;
always #5 clk=~clk;
initial begin

    //initial
   rst=1; opa=0; opb=0; cin=0; inp_valid=0; cmd=0; mode=0;ce=0;
   //0 arthematic addition
   #10 rst=1; rst=0;
   ce=1; mode=1; cmd=0; inp_valid=3; opa=8'hff; opb=8'hff; cin=1;
   #10; opa=8'hff; opb=0; cin=0; inp_valid=0;
   #10; inp_valid=3;
   #10; inp_valid =2;
 
   // 1 arithematic subtarction 50
   #10 rst=1; //rst=0;
   ce=1; mode=1; cmd=1; inp_valid=3; opa=8'hff; opb=8'hff; cin=1;

   // 2 arithematic add 
   #10 rst=1; rst=0;
   ce=1; mode=1; cmd=2; inp_valid=3; opa=8'hff; opb=8'hff; cin=0;
   #10; cin=1;

   // 3  subtract cin 80
   #10 rst=1; rst=0;
   ce=1; mode=1; cmd=3; inp_valid=3; opa=8'hff; opb=8'hff; cin=0;
   #10; cin=1;

   // 4 increment a 100

    #10 rst=1; rst=0;
   ce=1; mode=1; cmd=4; inp_valid=3; opa=8'hff; opb=8'hff; cin=0;
   #10; cin=1;

   // 5 decrement a
    #10 rst=1; rst=0;
   ce=1; mode=1; cmd=5; inp_valid=3; opa=8'hff; opb=8'hff; cin=0;
   #10; cin=1;
 
   // 6 increment b
    #10 rst=1; rst=0;
   ce=1; mode=1; cmd=6; inp_valid=3; opa=8'hff; opb=8'hff; cin=0;
   #10; cin=1;

   // 7 dec b
    #10 rst=1; rst=0;
   ce=1; mode=1; cmd=7; inp_valid=3; opa=8'hff; opb=8'hff; cin=0;
   #10; cin=1;

   // 8 cmp
    #10 rst=1; rst=0;
   ce=1; mode=1; cmd=8; inp_valid=3; opa=8'hff; opb=8'hff; cin=0;
   #10; cin=1;

   // 9 increment by 1 and multiply
   #10 rst=1; rst=0;
   ce=1; mode=1; cmd=9; inp_valid=3; opa=8'hff; opb=8'hff; cin=0;
   #30; cin=1;
   #30; opa=8'hfe; opb=8'hfe;
   #30;

   // 10 a left shift by 1 and multiply
   #10 rst=1; rst=0;
   ce=1; mode=1; cmd=10; inp_valid=3; opa=8'hff; opb=8'hff; cin=0;
   #30; cin=1;
   #30; opa=8'hfe; opb=8'hfe;
   #30;

   // 11 signed addition
   #10 rst=1; rst=0;
   ce=1; mode=1; cmd=11; inp_valid=3; opa=8'h11; opb=8'h03; cin=0;
   #10; cin=1;
   #10; opa=8'hf4; opb=8'hf2;
 
   // 12 signed subtraction
   #10 rst=1; rst=0;
   ce=1; mode=1; cmd=12; inp_valid=3; opa=8'h11; opb=8'h03; cin=0;
   #10; cin=1;
   #10; opa=8'hf4; opb=8'hf2;

   // 13 invalid cmd
    #10 rst=1; rst=0;
   ce=1; mode=1; cmd=13; inp_valid=3; opa=8'h11; opb=8'h03; cin=0;
   #10; cin=1;
   #10; opa=8'hf4; opb=8'hf2;

   // now mode 0 logical operations

   //0 and operation

   #10 rst=1; rst=0;
   ce=1; mode=0; cmd=0; inp_valid=3; opa=8'hff; opb=8'hff; cin=1;
   #10; opa=8'hff; opb=0; cin=0; inp_valid=0;
   #10; inp_valid=3;
   #10; inp_valid =2;

   // 1 nand operation
   #10 rst=1; rst=0;
   ce=1; mode=0; cmd=1; inp_valid=3; opa=8'hff; opb=8'hff; cin=1;

   // 2 or operation 
   #10 rst=1; rst=0;
  ce=1; mode=0; cmd=2; inp_valid=3; opa=8'hff; opb=8'hff; cin=0;
   #10; cin=1;

   // 3  nor operation
   #10 rst=1; rst=0;
   ce=1; mode=0; cmd=3; inp_valid=3; opa=8'hff; opb=8'hff; cin=0;
   #10; cin=1;
 
   // 4 xor operation
    #10 rst=1; rst=0;
   ce=1; mode=0; cmd=4; inp_valid=3; opa=8'hff; opb=8'hff; cin=0;
   #10; cin=1;

   // 5 xnor operation
    #10 rst=1; rst=0;
   ce=1; mode=0; cmd=5; inp_valid=3; opa=8'hff; opb=8'hff; cin=0;
   #10; cin=1;
 
   // 6 not a
    #10 rst=1; rst=0;
   ce=1; mode=0; cmd=6; inp_valid=3; opa=8'hff; opb=8'hff; cin=0;
   #10; cin=1;

   // 7 not b
    #10 rst=1; rst=0;
   ce=1; mode=0; cmd=7; inp_valid=3; opa=8'hff; opb=8'hff; cin=0;
   #10; cin=1;

   // 8 shift right by 1 opa
    #10 rst=1; rst=0;
   ce=1; mode=0; cmd=8; inp_valid=3; opa=8'hff; opb=8'hff; cin=0;
   #10; cin=1;

   // 9 shift left by 1 opa
   #10 rst=1; rst=0;
   ce=1; mode=0; cmd=9; inp_valid=3; opa=8'hff; opb=8'hff; cin=0;
   #30; cin=1;
   #30; opa=8'hfe; opb=8'hfe;
   #30;

   // 10 shift right by 1 opb
   #10 rst=1; rst=0;
   ce=1; mode=0; cmd=10; inp_valid=3; opa=8'hff; opb=8'hff; cin=0;
   #30; cin=1;
   #30; opa=8'hfe; opb=8'hfe;
   #30;

   // 11 shift left by 1 opb
   #10 rst=1; rst=0;
   ce=1; mode=0; cmd=11; inp_valid=3; opa=8'h11; opb=8'h03; cin=0;
   #10; cin=1;
   #10; opa=8'hf4; opb=8'hf2;

   // 12 rotate left operand a 
   #10 rst=1; rst=0;
   ce=1; mode=0; cmd=12; inp_valid=3; opa=8'h11; opb=8'h03; cin=0;
   #10; opa=8'hf4; opb=8'h52;
   #10; opb=8'h08;

   // 13 rotate right operand a
    #10 rst=1; rst=0;
   ce=1; mode=0; cmd=13; inp_valid=3; opa=8'h11; opb=8'h03; cin=0;
   #10; opa=8'hf4; opb=8'h52;
   #10; opb=8'h08;
   #20;
    $finish;

end

initial begin
    $monitor("T=%0t | mode=%b cmd=%d | opa=%d opb=%d | res=%d | of=%b c=%b err=%b",$time, mode, cmd, opa, opb, res, oflow, cout,err);
end

endmodule
 
