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
//this is new code 

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
// arithemetic operations 
	
	if (mode) begin 
		case (cmd) 
		4'd0:begin //add unsigned 
			if (inp_valid ==2'b11)begin 
			arith_res=opa+opb;
                        res[data_width-1:0] <= arith_res[data_width-1:0];
                        cout  <= arith_res[data_width];
			//oflow<=1'b0;  
			end 
			else err <= 1'b1;
                end

                4'd1: begin // sub unsigned 
			if (inp_valid==2'b11) begin
                	arith_res=opa-opb;
                        res[data_width-1:0] <= arith_res[data_width-1:0];
			//cout <= 1'b0;
                        if (opa<opb) oflow <=1'b1;
			else oflow <=1'b0;
		end else err <= 1'b1;
		end
		
		4'd2: begin // add with carry 
			if (inp_valid==2'b11) begin
			arith_res=opa+opb+cin;
                        res[data_width-1:0] <= arith_res[data_width-1:0];
                        cout  <= arith_res[data_width];
                        //oflow <= 1'b0;
                        end
			else err<=1'b1; 
                       end

		// sub unsigned with carry 
		4'd3: begin
            		if (inp_valid==2'b11) begin
            		arith_res=opa-opb-cin;
            		res[data_width-1:0] <= arith_res[data_width-1:0];
            		//cout <= 1'b0;
			if (opa<(opb+cin)) oflow <=1'b1;
			else oflow <=1'b0;
		  end
			else err <= 1'b1;
		  end 

		4'd4://inc a 
			begin
			if (inp_valid[0]==0) err=1'b1;
			else res<=opa+1; 
			end 
 
		4'd5://dec a 
			begin
			if (inp_valid[0]==0) err=1'b1;
			else res<=opa-1;
			end  
		4'd6://inc b 
			begin
			if (inp_valid[1]==0) err=1'b1;
			else res<=opb+1; 
			end 
		4'd7://dec b 
			begin 
			if (inp_valid[1]==0) err=1'b0;
			res<=opb-1;
			end  

		4'd8://compare 
			begin
			if (inp_valid==2'b11)  begin  
            			if(opa==opb)
             				begin e<=1'b1;g<=1'b0;l<=1'b0;end
            			else if(opa>opb)
             				begin e<=1'b0;g<=1'b1;l<=1'b0;end
            			else 
             				begin e<=1'b0;g<=1'b0;l<=1'b1;end
           			end
			else err <= 1'b1;	
			end 
		

		4'd9://inc and multiply 
		 begin
	                if (mul_busy==1'b0) begin                    
        	        	if (inp_valid==2'b11) begin
                        	mul_opa  <= opa + 1;
                        	mul_opb  <= opb + 1;                     
                        	mul_busy <= 1'b1;
                        	mul_cnt  <= 2'd0;
                    		end
                	end 
			else begin                          
                    		mul_cnt <= mul_cnt + 1;
                    		if (mul_cnt == 2'd2)
				begin          
                        	res <= mul_opa * mul_opb;
                        	mul_busy <= 1'b0;
                        	mul_cnt  <= 2'd0;
                    		end
                	end
            	end
            
            4'd10://shift a and multiply 
		begin
                if (mul_busy==1'b0) begin                    
                	if (inp_valid==2'b11) begin
                        	mul_opa  <= opa << 1;          
                        	mul_opb  <= opb;                
                        	mul_busy <= 1'b1;
                        	mul_cnt  <= 2'd0;
                    	end
                end 
		else begin                          
			mul_cnt <= mul_cnt + 1;
                	if (mul_cnt == 2'd2) begin
                        	res <= mul_opa * mul_opb;  
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
		  	if ((opa[data_width-1]==opb[data_width-1]) && (arith_res[data_width -1] != opa[data_width-1])) 
				oflow<=1'b1;
		  	else oflow <= 1'b0;
		 	end 
		 end 
		 
		4'd12://signed subtraction
		begin if (inp_valid== 2'b11)
			begin 
			arith_res = opa -opb;
			res <= {{data_width{1'b0}}, arith_res};
		  	if ((opa[data_width-1]!=opb[data_width-1]) && (arith_res[data_width -1] != opa[data_width-1]))
				oflow<=1'b1;
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
		//logical operations 
		case (cmd) 
                4'b0000://and 
			begin
				if (inp_valid ==2'b11) res<={1'b0,opa&opb};
				else err<=1'b1;
			end  
             	
		4'b0001://nand 
			begin
				if (inp_valid ==2'b11) res<={1'b0,~(opa&opb)};
				else err<=1'b1;
			end
             	4'b0010://or 
			begin 
				if (inp_valid ==2'b11) res<={1'b0,opa|opb};
				else err<=1'b1;
			end 

             	4'b0011://nor 
			begin
				if (inp_valid ==2'b11) res<={1'b0,~(opa|opb)}; 
				else err<=1'b1;
			end 

             	4'b0100://xor 
			begin
				if (inp_valid ==2'b11) res<={1'b0,opa^opb};
				else err<=1'b1;
			end  


             	4'b0101://xnor 
			begin
				if (inp_valid ==2'b11) res<={1'b0,~(opa^opb)};
				else err<=1'b1;
			end
 
             	4'b0110://not a 
			begin 
				if (inp_valid[0] !=1'b1)err=1'b1;
				else  res<={1'b0,~opa};
			 end 

             	4'b0111://not b 
			begin
				if (inp_valid[1] !=1'b1) err=1'b1;
				else res<={1'b0,~opb};
			end

             	4'b1000://shift right a 
			begin
				if (inp_valid[0] !=1'b1)err=1'b1;
				else res<={1'b0,opa>>1};
			end

             	4'b1001://shift left a 
			begin
				if (inp_valid[0] !=1'b1) err=1'b1;
				else res<={1'b0,opa<<1};
			end 

             	4'b1010://shift right b 
			begin
				if (inp_valid[1] !=1'b1) err=1'b1;
				else res<={1'b0,opb>>1};  
			end
             	4'b1011://shift left b 
			begin
				if (inp_valid[1] !=1'b1) err=1'b1;
				else res<={1'b0,opb<<1};
			end

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
