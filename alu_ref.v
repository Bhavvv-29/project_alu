
`timescale 1ns / 1ps
// alu_new reference model 

module alu_ref #(parameter data_width = 8, parameter cmd_width = 4)
(
    input [data_width-1:0] opa,opb,
    input clk,rst,
    input cin,mode,ce,
    input [cmd_width-1:0] cmd,
    input [1:0]inp_valid,
    output reg [(2*data_width)-1:0] res,
    output reg cout, oflow, g, e, l, err
);

    reg [data_width-1:0] r_opa, r_opb;
    reg [1:0] r_inp_valid;
    reg r_cin, r_mode;
    reg [cmd_width-1:0] r_cmd;
    reg [(2*data_width)-1:0] temp_res;
    reg [(2*data_width)-1:0] arith_res;
    reg [2*data_width-1:0] mulinc_s1, mulshl_s1;
    reg mulinc_v1, mulshl_v1;
    reg signed [2*data_width-1:0] signed_result;

    localparam shift_b = $clog2(data_width);

always @(posedge clk or posedge rst) begin
        // Default values
	if (rst ) begin 
		r_opa<={data_width{1'b0}};
		r_opb<={data_width{1'b0}};
		r_inp_valid<=2'b00;
		r_cin<= 1'b0;
		r_mode<=1'b0;
	        res = {data_width{1'b0}};
        	cout = 1'b0;
        	oflow = 1'b0;
        	g = 1'b0;
        	e = 1'b0;
        	l = 1'b0;
        	err = 1'b0;
		mulinc_s1<= {(2*data_width){1'b0}};
		mulinc_v1<= 1'b0;
		mulshl_s1<= {(2*data_width){1'b0}};
		mulshl_v1<= 1'b0;
	end 

	else if (ce) begin 
		r_inp_valid <= inp_valid;
		r_mode <= mode;
		r_cmd <= cmd;
		r_opa <= opa;
		r_opb <= opb;
		r_cin <= cin;
 
            err   <= 1'b0;
            oflow <= 1'b0;
            cout  <= 1'b0;
            g     <= 1'b0;
            l     <= 1'b0;
            e     <= 1'b0;

	if (mulinc_v1 && r_cmd == 4'b1001) begin
                res       <= mulinc_s1;
                mulinc_v1 <= 1'b0;
            end

	else if (mulshl_v1 && r_cmd == 4'b1010) begin
                res       <= mulshl_s1;
                mulshl_v1 <= 1'b0;
            end

	else begin 
		if (mode) begin 
            	case(r_cmd)
                	4'b0000:/* begin  // ADD
		    		if (r_inp_valid == 2'b11) begin 
                    		res <= r_opa + r_opb;
                    		cout <= res[8];
				            end 
 		   		    else err=1; 
                	end*/


			begin
                        {cout, res[data_width-1:0]} <= (r_inp_valid == 2'b11) ? (r_opa + r_opb) : {cout, res[data_width-1:0]};
                        res <= (r_inp_valid == 2'b11) ? (r_opa + r_opb) : res;
                        err <= ~(r_inp_valid == 2'b11);
                        end


                	4'b0001: begin  // SUB
		    		        if (r_inp_valid ==2'b11) begin 
                    		  oflow <= (r_opa < r_opb);
                    		  res <= r_opa-r_opb;
				            end 
				            else err=1;
                	end

                	4'b0010: 
				/*begin  // ADD_CIN
				        if (r_inp_valid ==2'b11) begin 
                    		res <= r_opa + r_opb + r_cin;
                    		cout <= res[8];
				        end 
				        else err=1;
                	 end*/
			begin
                            {cout, res[data_width-1:0]} <= (r_inp_valid == 2'b11) ? (r_opa + r_opb + r_cin) : {cout, res[data_width-1:0]};
                            res <= (r_inp_valid == 2'b11) ? (r_opa + r_opb + r_cin) : res;
                            err<= ~(r_inp_valid == 2'b11);
                        end


                	4'b0011: begin  // SUB_CIN
		    		    if (r_inp_valid ==2'b11) begin 
                    		oflow <= (r_opa<(r_opb+r_cin));
    				        res <= opa-opb-cin;
				        end 
				        else err=1;
                	end

                4'b0100: begin if (r_inp_valid[0] !=1) err=1; else res <= r_opa + 1;  end // INC_A
                4'b0101: begin if (r_inp_valid[0] !=1) err=1; else res <= r_opa - 1; end   // DEC_A
                4'b0110: begin if (r_inp_valid[1] !=1) err=1; else res <= r_opb + 1; end // INC_B
                4'b0111: begin if (r_inp_valid[1] !=1) err=1; else res <= r_opb - 1; end // DEC_B

                4'b1000: begin  // CMP
                    res = {data_width{1'b0}};
			        if (r_inp_valid ==2'b11) begin 
				        if (r_opa == r_opb) begin
                        		e <= 1'b1; g <= 1'b0; l <= 1'b0;
                    	end
				        else if (r_opa > r_opb) begin
                        		e <= 1'b0; g <= 1'b1; l <= 1'b0;
                    	end 
				        else begin
                        		e <= 1'b0; g <= 1'b0; l <= 1'b1;
                    	end
                    end
                 end 

		 4'b1001: begin
                if (r_inp_valid == 2'b11) begin
                    mulinc_s1 <= (r_opa + 1) * (r_opb + 1);
                    mulinc_v1 <= 1'b1;
                    //res <= 16'hxxxx;
                    end
                else begin 
                    err <= 1'b1;
                    //res <= 16'hxxxx;
                 end
         end

		4'b1010: begin //shift opa and multiply 
    			if (r_inp_valid==2'b11) begin
        			mulshl_s1 <= (r_opa<<1)*r_opb;
        			mulshl_v1 <= 1;
        		//	res <= 16'hxxxx;
        		end 
     			else begin 
     			    err <= 1;
     			  //  res <= 16'hxxxx;
     			end 
    	end


                4'b1011://signed addition
                /*begin if (inp_valid ==2'b11)
                        begin
                            arith_res=opa+opb;
                            cout  <= 1'b0;
			    //{g,l,e}<=3'b0;
				
                                g                     <= ($signed(r_opa) >  $signed(r_opb));
                                l                     <= ($signed(r_opa) <  $signed(r_opb));
                                e                     <= ($signed(r_opa) == $signed(r_opb));



                            res <= {{data_width{1'b0}}, arith_res};
                            if ((r_opa[data_width-1]==r_opb[data_width-1]) && (arith_res[data_width -1] != r_opa[data_width-1]))
                                oflow<=1'b1;
                            else oflow <= 1'b0;
                        end
                 end*/


		begin
                            if (r_inp_valid == 2'b11) begin
                                signed_result          = $signed({1'b0, r_opa}) + $signed({1'b0, r_opb});
                                cout                  <= 1'b0;
// signed_result[data_width];
                                res                   <= {{data_width{signed_result[data_width-1]}}, signed_result[data_width-1:0]};
                                oflow                 <= (r_opa[data_width-1] == r_opb[data_width-1]) &&
                                                         (signed_result[data_width-1] != r_opa[data_width-1]);
                                g                     <= ($signed(r_opa) >  $signed(r_opb));
                                l                     <= ($signed(r_opa) <  $signed(r_opb));
                                e                     <= ($signed(r_opa) == $signed(r_opb));
                            end else begin
                                res   <= {(2*data_width){1'b0}};
                                cout  <= 1'b0;
                                oflow <= 1'b0;
                                g     <= 1'b0;
                                l     <= 1'b0;
                                e     <= 1'b0;
                            end
                            err <= ~(r_inp_valid == 2'b11);
                        end


                4'b1100://signed subtraction
/*                    begin if (inp_valid== 2'b11)
                        begin
                            arith_res = r_opa -r_opb;
                            res <= {{data_width{1'b0}}, arith_res};


				 g                     <= ($signed(r_opa) >  $signed(r_opb));
                            l                     <= ($signed(r_opa) <  $signed(r_opb));
                             e                     <= ($signed(r_opa) == $signed(r_opb));

                            if ((r_opa[data_width-1]!=r_opb[data_width-1]) && (arith_res[data_width -1] != r_opa[data_width-1]))
                                oflow<=1'b1;
                            else oflow <= 1'b0;
                        end
                    end*/
begin
                            if (r_inp_valid == 2'b11) begin
                                signed_result          = $signed({1'b0, r_opa}) - $signed({1'b0, r_opb});
                                cout                  <= 1'b0;
//signed_result[data_width];
                                res                   <= {{data_width{signed_result[data_width-1]}}, signed_result[data_width-1:0]};
                                oflow                 <= (r_opa[data_width-1] != r_opb[data_width-1]) &&
                                                         (signed_result[data_width-1] != r_opa[data_width-1]);
                                g                     <= ($signed(r_opa) >  $signed(r_opb));
                                l                     <= ($signed(r_opa) <  $signed(r_opb));
                                e                     <= ($signed(r_opa) == $signed(r_opb));
                            end else begin
                                res   <= {(2*data_width){1'b0}};
                                cout  <= 1'b0;
                                oflow <= 1'b0;
                                g     <= 1'b0;
                                l     <= 1'b0;
                                e     <= 1'b0;
                            end
                            err <= ~(r_inp_valid == 2'b11);
                        end


                 default: begin
                            res   <= {(2*data_width){1'b0}};
                            cout  <= 1'b0;
                            oflow <= 1'b0;
                            g     <= 1'b0;
                            l     <= 1'b0;
                            e     <= 1'b0;
                        end

            endcase
        end 
        else begin  // Logical Mode
            case(r_cmd)
                4'b0000: begin if (r_inp_valid==2'b11) res <= {{data_width{1'b0}}, r_opa & r_opb}; else err<=1; end      // AND
                4'b0001: begin if (r_inp_valid==2'b11) res <= { {data_width{1'b0}},~(r_opa & r_opb)}; else err<=1;end   // NAND
                4'b0010: begin if (r_inp_valid==2'b11) res <= {{data_width{1'b0}}, r_opa | r_opb}; else err<=1; end       // OR
                4'b0011: begin if (r_inp_valid==2'b11)res <= {{data_width{1'b0}}, ~(r_opa | r_opb)}; else err<=1; end    // NOR
                4'b0100: begin if (r_inp_valid==2'b11)res <= { {data_width{1'b0}},r_opa ^ r_opb};   else err<=1; end     // XOR
                4'b0101: begin if (r_inp_valid==2'b11)res <= {{data_width{1'b0}}, ~(r_opa^r_opb)};   else err<=1; end  // XNOR
                4'b0110: begin if (r_inp_valid[0]==1'b1)res <= {{data_width{1'b0}}, ~r_opa};   else err<=1; end         // NOT_A
                4'b0111: begin if (r_inp_valid[1]==1'b1)res <= {{ data_width{1'b0}},~r_opb};     else err<=1;  end     // NOT_B
                4'b1000: begin if (r_inp_valid[0]==1'b1)res <= {{ data_width{1'b0}},r_opa >> 1};   else err<=1;end // SHR1_A
                4'b1001: begin if (r_inp_valid[0]==1'b1)res <= {{ data_width{1'b0}},r_opa << 1};     else err<=1;end  // SHL1_A
                4'b1010: begin if (r_inp_valid[1]==1'b1)res <= {{ data_width{1'b0}},r_opb >> 1};  else err<=1;end   // SHR1_B
                4'b1011: begin if (r_inp_valid[1]==1'b1)res <= {{ data_width{1'b0}},r_opb << 1};   else err<=1;end  // SHL1_B
                

                4'b1100: begin
                            if (r_inp_valid == 2'b11) begin
                                if (|r_opb[data_width-1:shift_b]) begin
                                    err <= 1'b1;
                                end else begin
                                    res[data_width-1:0]          <= (r_opa << r_opb[shift_b-1:0]) | (r_opa >> (data_width - r_opb[shift_b-1:0]));
                                    res[2*data_width-1:data_width] <= {data_width{1'b0}};
                                    err <= 1'b0;
                                end
                            end else begin
                                res <= {(2*data_width){1'b0}};
                                err <= 1'b1;
                            end
                            oflow <= 1'b0; cout <= 1'b0; {g,l,e} <= 3'b000;
                        end
 



                4'b1101: begin
                            if (r_inp_valid == 2'b11) begin
                                if (|r_opb[data_width-1:shift_b]) begin
                                    err <= 1'b1;
                                end else begin
                                    res[data_width-1:0]          <= (r_opa >> r_opb[shift_b-1:0]) | (r_opa << (data_width - r_opb[shift_b-1:0]));
                                    res[2*data_width-1:data_width] <= {data_width{1'b0}};
                                    err <= 1'b0;
                                end
                            end else begin
                                res <= {(2*data_width){1'b0}};
                                err <= 1'b1;
                            end
                            oflow <= 1'b0; cout <= 1'b0; {g,l,e} <= 3'b000;
                        end

                  default: begin
                            res   <= {(2*data_width){1'b0}};
                            cout  <= 1'b0;
                            oflow <= 1'b0;
                            g     <= 1'b0;
                            l     <= 1'b0;
                            e     <= 1'b0;
                        end
            endcase
        end
    end
    end 
    end 
endmodule
