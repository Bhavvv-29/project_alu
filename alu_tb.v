//tb_new _alu

//==============================================
// Simple ALU Testbench
//==============================================

//new alu tb 

`timescale 1ns/1ps

module alu_tb;
    parameter DATA_WIDTH = 8;
    parameter CMD_WIDTH  = 4;

    // DUT signals
    reg [DATA_WIDTH-1:0] OPA, OPB;
    reg CLK, RST, CE, MODE, CIN;
    reg [CMD_WIDTH-1:0] CMD;
    reg [1:0] INP_VALID;

    wire [(2*DATA_WIDTH)-1:0] RES_dut;
    wire COUT_dut, OFLOW_dut, G_dut, E_dut, L_dut, ERR_dut;

    // Reference model signals
    wire [(2*DATA_WIDTH)-1:0] RES_ref;
    wire COUT_ref, OFLOW_ref, G_ref, E_ref, L_ref, ERR_ref;

    // Test counters
    integer pass_count = 0;
    integer fail_count = 0;
    integer test_count = 0;

    // DUT instantiation
    alu #(.width(DATA_WIDTH),.cwidth(CMD_WIDTH))dut (
        .opa(OPA), .opb(OPB), .cin(CIN),
        .clk(CLK), .rst(RST), .cmd(CMD),
        .ce(CE), .mode(MODE),
        .cout(COUT_dut), .oflow(OFLOW_dut),
        .res(RES_dut),
        .g(G_dut), .e(E_dut), .l(L_dut),
        .err(ERR_dut),.inp_valid(INP_VALID)
    );

    // Reference model instantiation
    alu_ref #(.data_width(DATA_WIDTH),.cmd_width(CMD_WIDTH)) ref  (.rst(RST),.clk(CLK),
        .opa(OPA), .opb(OPB), .cin(CIN),
        .mode(MODE), .cmd(CMD),.inp_valid(INP_VALID),.ce(CE),
        .res(RES_ref),.cout(COUT_ref), .oflow(OFLOW_ref),
        .g(G_ref), .e(E_ref), .l(L_ref),
        .err(ERR_ref)
    );

    // Clock generation
    initial begin
        CLK = 0;
        forever #5 CLK = ~CLK;
    end

    // Test stimulus
    initial begin
        // Initialize
        RST = 1; CE = 1; CIN = 0;
        OPA = 0; OPB = 0; MODE = 0; CMD = 0;INP_VALID=0;
        
        @(posedge CLK);
        RST = 0;  // Release reset
        @(posedge CLK);
// =======================
// CE DISABLE TEST
// =======================

$display("\n=== Testing CE Disable ===");

// First do a normal operation
CE = 1;
OPA = 8'h05;
OPB = 8'h03;
CMD = 4'b0000;
MODE = 1;
INP_VALID = 2'b11;

@(posedge CLK);

// Disable CE
CE = 0;

// Change inputs while CE=0
OPA = 8'hAA;
OPB = 8'h55;
CMD = 4'b0001;
MODE = 1;
INP_VALID = 2'b11;

// Wait some clocks
@(posedge CLK);
@(posedge CLK);

// Enable CE again
CE = 1;

@(posedge CLK);

// =======================================
// DIRECT FSM TEST FOR line 106 / 122-124
// =======================================

$display("\n=== FSM COVERAGE TEST ===");

MODE = 1;
INP_VALID = 2'b11;
CE = 1;
CIN = 0;

// STEP 1 : count -> 1
@(posedge CLK);
CMD = 4'b1010;
OPA = 8'h02;
OPB = 8'h03;

// STEP 2 : count -> 2
@(posedge CLK);
CMD = 4'b1010;
OPA = 8'h04;
OPB = 8'h02;

// STEP 3 : change command
@(posedge CLK);
CMD = 4'b0000;
OPA = 8'h01;
OPB = 8'h01;

// STEP 4 : should hit line 106 and 122-124
@(posedge CLK);
CMD = 4'b1010;
OPA = 8'h08;
OPB = 8'h02;

// extra clocks for FSM settle
@(posedge CLK);
@(posedge CLK);


        // Test Arithmetic Operations
        $display("\n=== Testing Arithmetic Operations (MODE=1) ===");
        MODE = 1;
        test_arithmetic();
	

        // Test Logical Operations
        $display("\n=== Testing Logical Operations (MODE=0) ===");
        MODE = 0;
        test_logical();

        // Summary
        $display("\n=== TEST SUMMARY ===");
        $display("Total Tests: %0d", test_count);
        $display("PASS: %0d", pass_count);
        $display("FAIL: %0d", fail_count);
        
        if (fail_count == 0)
            $display("\n*** ALL TESTS PASSED ***\n");
        else
            $display("\n*** SOME TESTS FAILED ***\n");

        #100;
        $finish;
    end

    // Test arithmetic operations
    task test_arithmetic();
        begin
            // ADD
            apply_test(8'h0F, 8'h11, 4'b0000,2'b11 ,"ADD");
            apply_test(8'hFF, 8'h01, 4'b0000, 2'b11 ,"ADD (overflow)");
	    apply_test(8'h00, 8'h00, 4'b0000,2'b11 ,"add_both_min");
	    apply_test(8'h00, 8'hFF, 4'b0000,2'b11 ,"add_min_max");
	    apply_test(8'hFF, 8'hFF, 4'b0000,2'b11 ,"add_max_max");

            
            // SUB
            apply_test(8'h20, 8'h10, 4'b0001,2'b11 , "SUB");
            apply_test(8'h00, 8'h00, 4'b0001,2'b11 , "SUB_min_min");
            apply_test(8'h00, 8'h01, 4'b0001,2'b11 , "SUB (underflow)");
            apply_test(8'hFF, 8'hFF, 4'b0001,2'b11 , "SUB_max_max");
            
            // ADD_CIN
            CIN = 1;
            apply_test(8'hFE, 8'h01, 4'b0010,2'b11 , "ADD_CIN");
            apply_test(8'h00, 8'h00, 4'b0010,2'b11 , "ADD_CIN");
            apply_test(8'hFF, 8'h01, 4'b0010,2'b11 , "ADD_CIN");
            CIN = 0;
	    //CIN = 1;
	    apply_test(8'hFE, 8'h01, 4'b0010,2'b11 , "ADD_CIN");
 	    apply_test(8'h00, 8'h00, 4'b0010,2'b11 , "ADD_CIN");
	    apply_test(8'hFF, 8'h01, 4'b0010,2'b11 , "ADD_CIN");
	    CIN = 0;
	    @(posedge CLK);
	    // SUB CIN 
	    CIN=1;
            apply_test(8'h01, 8'h01, 4'b0011,2'b11 , "SUB_CIN");

            
            // INC_A, DEC_A
            apply_test(8'h0A, 8'h00, 4'b0100, 2'b11 ,"INC_A");
            apply_test(8'hFF, 8'h00, 4'b0100,2'b11 , "INC_A");
            apply_test(8'h00, 8'h00, 4'b0100, 2'b11 ,"INC_A");

            apply_test(8'h0A, 8'h00, 4'b0101,2'b11 , "DEC_A");
            apply_test(8'h00, 8'h00, 4'b0101,2'b11 , "DEC_A");
            // INC_B, DEC_B
            apply_test(8'h00, 8'h0A, 4'b0110,2'b11 , "INC_B");
            apply_test(8'h00, 8'hFF, 4'b0110, 2'b11 ,"INC_B");
            apply_test(8'h00, 8'h00, 4'b0110, 2'b11 ,"INC_B");

            apply_test(8'h00, 8'h0A, 4'b0111,2'b11 , "DEC_B");
            apply_test(8'h00, 8'h00, 4'b0111, 2'b11 ,"DEC_B");
       
            
            // CMP
            apply_test(8'h10, 8'h10, 4'b1000, 2'b11 ,"CMP (equal)");
            apply_test(8'h20, 8'h10, 4'b1000,2'b11 , "CMP (greater)");
            apply_test(8'h10, 8'h20, 4'b1000,2'b11 , "CMP (less)");
	    //MUL1 - ADD1 AND MULTIPLY 
            apply_test(8'h00, 8'h00, 4'b1001,2'b11 , "MUL1(BOTH_zEROS)");
            apply_test(8'hFF, 8'hFF, 4'b1001,2'b11 , "MUL1(BOTH MAX )");
            apply_test(8'h00, 8'hFF, 4'b1001,2'b11 , "MUL1");
            apply_test(8'hFF, 8'h00, 4'b1001,2'b11 , "MUL1");
            apply_test(8'h01, 8'h01, 4'b1001, 2'b11 ,"MUL1");
            apply_test(8'h0F, 8'h0F, 4'b1001,2'b11 , "MUL1");
            apply_test(8'hAA, 8'h55, 4'b1001, 2'b11 ,"MUL1");
	    //MUL2 
            apply_test(8'h00, 8'h00, 4'b1010,2'b11 , "MUL2");
            apply_test(8'h80, 8'h02, 4'b1010, 2'b11 ,"MUL2");
            apply_test(8'hFF, 8'h00, 4'b1010, 2'b11 ,"MUL2");
            apply_test(8'hFF, 8'h01, 4'b1010,2'b11 , "MUL2");
            apply_test(8'hFF, 8'hFF, 4'b1010, 2'b11 ,"MUL2");
		//SIGNED ADD 
            apply_test(8'h00, 8'h00, 4'b1011,2'b11 , "SIGN_ADD");
            apply_test(8'h40, 8'h40, 4'b1011, 2'b11 ,"SIGN_aDD");
            apply_test(8'h7F, 8'h01, 4'b1011, 2'b11 ,"SIGN_ADD");
            apply_test(8'h7F, 8'h7F, 4'b1011,2'b11 , "SIGN_ADD");
           apply_test(8'h01, 8'h01, 4'b1011, 2'b11 ,"SIGN_aDD");
            apply_test(8'h7F, 8'h00, 4'b1011,2'b11 , "SIGN_ADD");
            apply_test(8'h80, 8'h80, 4'b1011, 2'b11 ,"SIGN_aDD");
            apply_test(8'hFF, 8'hFF, 4'b1011, 2'b11 ,"SIGN_ADD");
            apply_test(8'h80, 8'hFF, 4'b1011,2'b11 , "SIGN_ADD");
            apply_test(8'hFE, 8'hFF, 4'b1011, 2'b11 ,"SIGN_aDD");
	    apply_test(8'h7F, 8'h80, 4'b1011, 2'b11 ,"SIGN_ADD");
            apply_test(8'h7F, 8'hFF, 4'b1011,2'b11 , "SIGN_ADD");
            apply_test(8'h01, 8'hFF, 4'b1011, 2'b11 ,"SIGN_aDD");

//SIGNED SUB 

            apply_test(8'h7F, 8'h01, 4'b1100, 2'b11 ,"SIGN_SUB");
	    apply_test(8'h80, 8'h01, 4'b1100, 2'b11 ,"SIGN_SUB");
            apply_test(8'h7F, 8'hFF, 4'b1100,2'b11 , "SIGN_SUB");
            apply_test(8'h80, 8'h01, 4'b1100, 2'b11 ,"SIGN_SUB");
            apply_test(8'h00, 8'h01, 4'b1100, 2'b11 ,"SIGN_SUB");
	    apply_test(8'h00, 8'hFF, 4'b1100, 2'b11 ,"SIGN_SUB");
            apply_test(8'h01, 8'h01, 4'b1100,2'b11 , "SIGN_SUB");
            apply_test(8'h80, 8'h80, 4'b1100, 2'b11 ,"SIGN_SUB");

	apply_test(8'h80, 8'h80, 4'b1101, 2'b11 ,"CMD ABOVE RANGE ");
	apply_test(8'h0F, 8'h11, 4'b0000,2'b10 ,"ADD_ERR");
	apply_test(8'h20, 8'h10, 4'b0001,2'b10 , "SUBERR");
	apply_test(8'hFE, 8'h01, 4'b0010,2'b10 , "ADD_CIN ERR");
	apply_test(8'h01, 8'h01, 4'b0011,2'b10 , "SUB_CIN_ERR");
	apply_test(8'h0A, 8'h00, 4'b0100, 2'b01 ,"INC_A_ERR");
 	apply_test(8'h0A, 8'h00, 4'b0101,2'b01 , "DEC_A_ERR");
 	apply_test(8'h0A, 8'h00, 4'b0111,2'b10 , "DEC_B_ERR");
	apply_test(8'h00, 8'h00, 4'b0110, 2'b10 ,"INC_B_ERR");
 	apply_test(8'h10, 8'h20, 4'b1000,2'b10 , "CMP_ERR");
  	apply_test(8'h00, 8'hFF, 4'b1001,2'b10 , "MUL1_ERR");
 	apply_test(8'hFF, 8'hFF, 4'b1010, 2'b10 ,"MUL2_ERR");
	apply_test(8'h80, 8'h80, 4'b1011, 2'b10 ,"SIGN_aDD_ERR");
	apply_test(8'h7F, 8'h01, 4'b1100, 2'b10 ,"SIGN_SUB_ERR");
	apply_test(8'h01, 8'h01, 4'b1001, 2'b11, "MUL1_NORMAL");
	apply_test(8'h00, 8'h00, 4'b1001, 2'b11, "MUL1_ZERO");
	apply_test(8'hAA, 8'h55, 4'b1001, 2'b11, "MUL1_PATTERN");
	apply_test(8'h01, 8'h01, 4'b1001, 2'b01, "MUL1_ERR");
	apply_test(8'h01, 8'h01, 4'b1001, 2'b11, "FIRST_CMD");
	apply_test(8'h02, 8'h02, 4'b1010, 2'b11, "SECOND_CMD_DIFFERENT");
	apply_test(8'h02, 8'h03, 4'b1010, 2'b11, "MUL2_FIRST");
	apply_test(8'h01, 8'h01, 4'b1001, 2'b11, "CHANGE_CMD");
	apply_test(8'h04, 8'h02, 4'b1010, 2'b11, "MUL2_HIT_122");
  	

	apply_test(8'h02, 8'h03, 4'b1010, 2'b11, "MUL2_COUNT1");
	apply_test(8'h04, 8'h02, 4'b1010, 2'b11, "MUL2_COUNT2");		
	apply_test(8'h01, 8'h01, 4'b1001, 2'b11, "CHANGE_CMDO");
	apply_test(8'h05, 8'h02, 4'b1010, 2'b11, "HIT_COUNT0_ELSE");
	    
        end
    endtask

    // Test logical operations
    task test_logical();
        begin
            apply_test(8'hF0, 8'h0F, 4'b0000,2'b11 , "AND");
            apply_test(8'hF0, 8'h0F, 4'b0001,2'b11 , "NAND");
            apply_test(8'hF0, 8'h0F, 4'b0010,2'b11 , "OR");
            apply_test(8'hF0, 8'h0F, 4'b0011,2'b11 , "NOR");
            apply_test(8'hAA, 8'h55, 4'b0100,2'b11 , "XOR");
            apply_test(8'hAA, 8'h55, 4'b0101,2'b11 , "XNOR");
            apply_test(8'hF0, 8'h00, 4'b0110,2'b11 , "NOT_A");
            apply_test(8'h00, 8'hF0, 4'b0111,2'b11 , "NOT_B");
            apply_test(8'hAA, 8'h00, 4'b1000,2'b11 , "SHR1_A");
            apply_test(8'h55, 8'h00, 4'b1001, 2'b11 ,"SHL1_A");
            
            apply_test(8'h00, 8'hAA, 4'b1010,2'b11 , "SHR1_B");
            apply_test(8'h00, 8'h55, 4'b1011, 2'b11 ,"SHL1_B");
	    apply_test(8'hAA, 8'h03, 4'b1100,2'b11 , "ROL_A_B");
            apply_test(8'hAA, 8'h02, 4'b1101,2'b11 , "ROR_A_B");
	    apply_test(8'hAA, 8'h02, 4'b1110,2'b11 , "CMD ABOVE RANGE ");
	    apply_test(8'hAA, 8'h08, 4'b1100, 2'b11, "ROL_ERR_SHIFT_RANGE");
	    apply_test(8'hAA, 8'h09, 4'b1101, 2'b11, "ROR_ERR_SHIFT_RANGE");
        end
    endtask

    // Apply test and check
    task apply_test(
        input [DATA_WIDTH-1:0] a, b,
        input [CMD_WIDTH-1:0] cmd,
	input [1:0] inp_valid,
        input [80*8:1] test_name
    );
        begin
            @(posedge CLK);
            OPA <= a;
            OPB <= b;
            CMD <= cmd;
	    INP_VALID<=inp_valid;
            
            repeat(3) @(posedge CLK);
            //@(posedge CLK);
            
            test_count = test_count + 1;
            
            if (compare_outputs(1'b0)) begin
                $display("[PASS] %s: OPA=0x%h OPB=0x%h CMD=0x%h",
                         test_name, a, b, cmd);
                pass_count = pass_count + 1;
            end else begin
                $display("[FAIL] %s: OPA=0x%h OPB=0x%h CMD=0x%h", 
                         test_name, a, b, cmd);
                display_mismatch();
                fail_count = fail_count + 1;
            end
        end
    endtask

    // Compare DUT vs Reference
    function compare_outputs;
	input dummy; 
        begin
            compare_outputs = 1;
            
            // Compare RES (handle Z values)
            if (RES_dut !== RES_ref) begin
                if (!((RES_dut === {(2*DATA_WIDTH){1'b0}}) && (RES_ref === {(2*DATA_WIDTH){1'b0}})))
                    compare_outputs = 0;
            end
            
            // Compare flags (handle Z values)
            if (!compare_bit(COUT_dut, COUT_ref)) compare_outputs = 0;
            if (!compare_bit(OFLOW_dut, OFLOW_ref)) compare_outputs = 0;
            if (!compare_bit(G_dut, G_ref)) compare_outputs = 0;
            if (!compare_bit(E_dut, E_ref)) compare_outputs = 0;
            if (!compare_bit(L_dut, L_ref)) compare_outputs = 0;
            if (!compare_bit(ERR_dut, ERR_ref)) compare_outputs = 0;
        end
    endfunction

    // Compare single bit (handle Z)
    function compare_bit(input dut, ref);
        begin
            if (dut === ref)
                compare_bit = 1;
            else if ((dut === 1'bz) && (ref === 1'bz))
                compare_bit = 1;
            else
                compare_bit = 0;
        end
    endfunction

    // Display mismatch details
    task display_mismatch();
        begin
            $display("  DUT: RES=0x%h COUT=%b OFLOW=%b G=%b E=%b L=%b ERR=%b",
                     RES_dut, COUT_dut, OFLOW_dut, G_dut, E_dut, L_dut, ERR_dut);
            $display("  REF: RES=0x%h COUT=%b OFLOW=%b G=%b E=%b L=%b ERR=%b",
                     RES_ref, COUT_ref, OFLOW_ref, G_ref, E_ref, L_ref, ERR_ref);
        end
    endtask

    // Waveform dump
    initial begin
        $dumpfile("alu_test.vcd");
        $dumpvars(0, alu_tb);
    end

endmodule
