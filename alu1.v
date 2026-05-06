`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.05.2026 14:29:41
// Design Name: 
// Module Name: alu
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


module alu1#(parameter data_width =8, parameter cmd_width=4)(clk, rst,opa, opb, cin,ce, mode, inp_valid, cmd , res, oflow, cout,g,l,e,err ) ;

input clk, rst,ce;
input [data_width-1:0] opa, opb;
input mode,cin;
input [1:0] inp_valid;
input [cmd_width-1:0] cmd;
output reg [2*data_width-1:0] res;
output reg oflow,cout;
output reg g,l,e;
output reg err;

reg [data_width-1:0] arith_res;
reg [data_width-1:0] opa_1, opb_1;
parameter shift_b = $clog2(data_width);// used for shift operation 
reg [shift_b-1:0] shift;

reg [1:0] mul_cnt;  // counter fro multiplication 
reg [2*data_width-1:0] mul_temp;
reg mul_busy;
reg [data_width-1:0]mul_opa,mul_opb;


always @(posedge clk or posedge rst) begin 

if (rst) begin 
	res <= {(2*data_width){1'b0}};
	oflow <= 1'b0;
	cout <= 1'b0;
	g <= 1'b0;
	l <= 1'b0;
	e <= 1'b0;
	err <= 1'b0;
	mul_busy <= 0;
	mul_cnt  <= 0;
	mul_opa  <= 0;
	mul_opb  <= 0;
end 

else if (ce) begin 
	res <= {(2*data_width){1'b0}};
	oflow <= 1'b0;
	cout <= 1'b0;
	g <= 1'b0;
	l <= 1'b0;
	e <= 1'b0;
	err <= 1'b0;
	
	if (mode) begin 
		case (cmd) 
		4'd0:begin //add unsigned 
			if (inp_valid ==2'b11)begin 
			arith_res=opa+opb;
                        res[data_width-1:0] <= arith_res[data_width-1:0];
                        cout  <= arith_res[data_width];
                        if (opa>opb) oflow <= 1'b1;
			else oflow<=1'b0; end 
			else err <= 1'b0;
                end

                4'd1: begin // sub unsigned 
			if (inp_valid==2'b11) begin
                	arith_res=opa-opb;
                        res[data_width-1:0] <= arith_res[data_width-1:0];
			cout <= 1'b0;
                        oflow <=1'b0;
		end else if (inp_valid !=2'b11) err <= 1'b1;
		end
		
		4'd2: begin // add with carry 
			if (inp_valid==2'b11) begin
			            arith_res=opa+opb+cin;
                        res[data_width-1:0] <= arith_res[data_width-1:0];
                        cout  <= arith_res[data_width];
                        oflow <= 1'b0;
                        end 
                       end

		// sub unsigned 
		4'd3: begin
            if (inp_valid==2'b11) begin
            arith_res=opa-opb-cin;
            res[data_width-1:0] <= arith_res[data_width-1:0];
            cout <= 1'b0;
		if (opa<opb) oflow <=1'b1;
		else oflow <=1'b0;
		  end
			else err <= 1'b0;
		  end 

		4'd4:begin if (inp_valid[0]==1)res<=opa+1; end //inc a 
		4'd5:begin if (inp_valid[0]==1)res<=opa-1; end //dec a 
		4'd6:begin if (inp_valid[1]==1)res<=opb+1; end //inc b 
		4'd7:begin if (inp_valid[1]==1)res<=opb-1; end //dec b 
		4'd8:begin if (inp_valid==2'b11)  begin //compare 
            		//res=(data_width*2)'bz;
            		if(opa==opb)
             			begin e<=1'b1;g<=1'b0;l<=1'b0;end
            		else if(opa>opb)
             			begin e<=1'b0;g<=1'b1;l<=1'b0;end
            		else 
             			begin e<=1'b0;g<=1'b0;l<=1'b1;end
           		end
		end 
		

4'd9: begin/*
	if (inp_valid ==2'b11) begin 
		mul_opa=opa+1;
		mul_opb=opb+1;
		res<=mul_opa*mul_opb;
		
end 
end */
	                if (mul_busy==1'b0) begin                    
                    if (inp_valid==2'b11) begin
                        mul_opa  <= opa + 1;
                        mul_opb  <= opb + 1;
                                      
                        mul_busy <= 1'b1;
                        mul_cnt  <= 2'd0;
                    end
                end else begin                          
                    mul_cnt <= mul_cnt + 1;
                    if (mul_cnt == 2'd2) begin          
                        res      <= mul_opa * mul_opb;
                        mul_busy <= 1'b0;
                        mul_cnt  <= 2'd0;
                    end
                end
            end
            
          /*          
        4'd10: begin
            if (inp_valid == 2'b11 && !mul_busy) begin
                mul_busy <= 1'b1;
                mul_cnt  <= 2'd0;
                opa_reg <= opa << 1;
                opb_reg <= opb;
                end
            else if (mul_busy)begin
                mul_cnt <= mul_cnt + 1;
                if (mul_cnt == 2'd2) begin
                res <= opa_reg * opb_reg;
                mul_busy <= 1'b0;
                end
                end
        end*/

            4'd10: begin
                if (mul_busy==1'b0) begin                    
                    if (inp_valid==2'b11) begin
                        mul_opa  <= opa << 1;          
                        mul_opb  <= opb;                
                        
                        mul_busy <= 1'b1;
                        mul_cnt  <= 2'd0;
                    end
                end else begin                          
                    mul_cnt <= mul_cnt + 1;
                    if (mul_cnt == 2'd2) begin
                        res      <= mul_opa * mul_opb;  
                        mul_busy <= 1'b0;
                        mul_cnt  <= 2'd0;
                    end
                end
            end
        
		4'd11://signed addition
		begin if (inp_valid ==2'b11)
		begin 
			arith_res=opa+opb;
			cout  <= 1'b0;
		   	res <= {{data_width{1'b0}}, arith_res};
		  	if ((opa[data_width-1]==opb[data_width-1]) && (arith_res[data_width -1] != opa[data_width-1]))oflow<=1'b1;
		  	else oflow <= 1'b0;
		 end 
		 end 
		 
		4'd12://signed subtraction
		begin if (inp_valid== 2'b11)
		begin 
			arith_res = opa -opb;
			res <= {{data_width{1'b0}}, arith_res};
		  	if ((opa[data_width-1]!=opb[data_width-1]) && (arith_res[data_width -1] != opa[data_width-1]))oflow<=1'b1;
		  	else oflow <= 1'b0;
		 end
		end 
		 
		default:begin 
			res <= {(2*data_width){1'b0}};
			oflow <= 1'b0;
			cout <= 1'b0;
			g <= 1'b0;
			l <= 1'b0;
			e <= 1'b0;
			err <= 1'b1;
			end 
		endcase
	end 

	else begin 
		case (cmd) 
                4'b0000:begin if (inp_valid ==2'b11) res<={1'b0,opa&opb}; end    // CMD = 0000: AND
             	4'b0001:begin if (inp_valid ==2'b11) res<={1'b0,~(opa&opb)}; end // CMD = 0001: NAND
             	4'b0010:begin if (inp_valid ==2'b11) res<={1'b0,opa|opb};  end   // CMD = 0010: OR
             	4'b0011:begin if (inp_valid ==2'b11) res<={1'b0,~(opa|opb)}; end // CMD = 0011: NOR
             	4'b0100:begin if (inp_valid ==2'b11) res<={1'b0,opa^opb};   end  // CMD = 0100: XOR
             	4'b0101:begin if (inp_valid ==2'b11) res<={1'b0,~(opa^opb)}; end // CMD = 0101: XNOR
             	4'b0110:begin if (inp_valid[0] ==1'b1) res<={1'b0,~opa}; end       // CMD = 0110: NOT_A
             	4'b0111:begin if (inp_valid[1] ==1'b1) res<={1'b0,~opb};  end    // CMD = 0111: NOT_B
             	4'b1000:begin if (inp_valid[0] ==1'b1) res<={1'b0,opa>>1};  end   // CMD = 1000: SHR1_A
             	4'b1001:begin if (inp_valid[0] ==1'b1) res<={1'b0,opa<<1};  end // CMD = 1001: SHL1_A
             	4'b1010:begin if (inp_valid[1] ==1'b1) res<={1'b0,opb>>1};  end // CMD = 1010: SHR1_B
             	4'b1011:begin if (inp_valid[1] ==1'b1) res<={1'b0,opb<<1};  end // CMD = 1011: SHL1_B

		4'b1100: begin //rotate left 
		              if (inp_valid == 2'b11) begin
		                  shift = opb[shift_b-1:0];
		                  err <= |opb[data_width-1:shift_b];
		                  if (shift == 0)
		                      res <= {{data_width{1'b0}}, opa};
		                  else
		                      res <= {{data_width{1'b0}},(opa << shift) | (opa >> (data_width - shift))};
                        end
                     end 

                4'b1101: begin //rotate right 
                    if (inp_valid == 2'b11) begin
                        shift = opb[shift_b-1:0];
                        err <= |opb[data_width-1:shift_b];
                        if (shift == 0)
                            res <= {{data_width{1'b0}},opa};
                        else
                        res <= {{data_width{1'b0}},(opa >> shift) | (opa << (data_width - shift))};
                     end
                   end
             
		default:begin 
			res <= {(2*data_width){1'b0}};
			oflow <= 1'b0;
			cout <= 1'b0;
			g <= 1'b0;
			l <= 1'b0;
			e <= 1'b0;
			err <= 1'b1;
			end 
		endcase
	end 
end 
end 
endmodule   
