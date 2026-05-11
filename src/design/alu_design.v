// this is proper design 
// use it for ref 

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.05.2026 12:14:57
// Design Name: 
// Module Name: alu1
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



module alu1 #(parameter data_width = 8, parameter cmd_width = 4)
(
    input                        clk,
    input                        rst,
    input  [data_width-1:0]      opa,
    input  [data_width-1:0]      opb,
    input                        cin,
    input                        ce,
    input                        mode,
    input  [1:0]                 inp_valid,
    input  [cmd_width-1:0]       cmd,
    output reg [2*data_width-1:0] res,
    output reg                   oflow,
    output reg                   cout,
    output reg                   g,
    output reg                   l,
    output reg                   e,
    output reg                   err
);
 
    localparam shift_b = $clog2(data_width);
 
    reg [1:0]            r_inp_valid;
    reg                  r_mode;
    reg [cmd_width-1:0]  r_cmd;
    reg [data_width-1:0] r_opa;
    reg [data_width-1:0] r_opb;
    reg                  r_cin;
 
    reg signed [2*data_width-1:0] signed_result;
    reg [2*data_width-1:0]        mulinc_s1, mulshl_s1;
    reg                           mulinc_v1, mulshl_v1;
 
    always @(posedge clk or posedge rst) begin
 
        if (rst) begin
            r_inp_valid <= 2'b00;
            r_mode      <= 1'b0;
            r_cmd       <= {cmd_width{1'b0}};
            r_opa       <= {data_width{1'b0}};
            r_opb       <= {data_width{1'b0}};
            r_cin       <= 1'b0;
 
            res         <= {(2*data_width){1'b0}};
            oflow       <= 1'b0;
            cout        <= 1'b0;
            g           <= 1'b0;
            l           <= 1'b0;
            e           <= 1'b0;
            err         <= 1'b0;
 
            mulinc_s1   <= {(2*data_width){1'b0}};
            mulinc_v1   <= 1'b0;
            mulshl_s1   <= {(2*data_width){1'b0}};
            mulshl_v1   <= 1'b0;
        end
 
        else if (ce) begin
 
            r_inp_valid <= inp_valid;
            r_mode      <= mode;
            r_cmd       <= cmd;
            r_opa       <= opa;
            r_opb       <= opb;
            r_cin       <= cin;
 
            err   <= 1'b0;
            oflow <= 1'b0;
            cout  <= 1'b0;
            g     <= 1'b0;
            l     <= 1'b0;
            e     <= 1'b0;
 
            if (mulinc_v1 && r_cmd == 4'h9) begin
                res       <= mulinc_s1;
                mulinc_v1 <= 1'b0;
            end
            else if (mulshl_v1 && r_cmd == 4'hA) begin
                res       <= mulshl_s1;
                mulshl_v1 <= 1'b0;
            end
 
            else begin
 
                if (r_mode) begin
                    case (r_cmd)
 
                        4'h0: begin
                            {cout, res[data_width-1:0]} <= (r_inp_valid == 2'b11) ? (r_opa + r_opb) : {cout, res[data_width-1:0]};
                            res                         <= (r_inp_valid == 2'b11) ? (r_opa + r_opb) : res;
                            err                         <= ~(r_inp_valid == 2'b11);
                        end
 
                        4'h1: begin
                            res   <= (r_inp_valid == 2'b11) ? (r_opa - r_opb) : res;
                            oflow <= (r_opb > r_opa);
                            err   <= ~(r_inp_valid == 2'b11);
                        end
 
                        4'h2: begin
                            {cout, res[data_width-1:0]} <= (r_inp_valid == 2'b11) ? (r_opa + r_opb + r_cin) : {cout, res[data_width-1:0]};
                            res                         <= (r_inp_valid == 2'b11) ? (r_opa + r_opb + r_cin) : res;
                            err                         <= ~(r_inp_valid == 2'b11);
                        end
 
                        4'h3: begin
                            res   <= (r_inp_valid == 2'b11) ? (r_opa - r_opb - r_cin) : res;
                            oflow <= ({1'b0, r_opa} < ({1'b0, r_opb} + r_cin));
                            err   <= ~(r_inp_valid == 2'b11);
                        end
 
                        4'h4: begin
                            res <= (r_inp_valid == 2'b11 || r_inp_valid == 2'b01) ? r_opa + 1 : res;
                            err <= ~(r_inp_valid == 2'b11 || r_inp_valid == 2'b01);
                        end
 
                        4'h5: begin
                            res <= (r_inp_valid == 2'b11 || r_inp_valid == 2'b01) ? r_opa - 1 : res;
                            err <= ~(r_inp_valid == 2'b11 || r_inp_valid == 2'b01);
                        end
 
                        4'h6: begin
                            res <= (r_inp_valid == 2'b11 || r_inp_valid == 2'b10) ? r_opb + 1 : res;
                            err <= ~(r_inp_valid == 2'b11 || r_inp_valid == 2'b10);
                        end
 
                        4'h7: begin
                            res <= (r_inp_valid == 2'b11 || r_inp_valid == 2'b10) ? r_opb - 1 : res;
                            err <= ~(r_inp_valid == 2'b11 || r_inp_valid == 2'b10);
                        end
 
                        4'h8: begin
                            res     <= {(2*data_width){1'b0}};
                            {g,l,e} <= {(r_opa > r_opb), (r_opa < r_opb), (r_opa == r_opb)};
                            err     <= ~(r_inp_valid == 2'b11);
                        end
 
                        4'h9: begin
                            if (r_inp_valid == 2'b11) begin
                                mulinc_s1 <= (r_opa + 1) * (r_opb + 1);
                                mulinc_v1 <= 1'b1;
                                                                res <= 16'hxxxx;

                            end else begin
                                err <= 1'b1;
                                                                res <= 16'hxxxx;

                            end
                        end
 
                        4'hA: begin
                            if (r_inp_valid == 2'b11) begin
                                mulshl_s1 <= (r_opa << 1) * r_opb;
                                mulshl_v1 <= 1'b1;
                                res <= 16'hxxxx;
                            end else begin
                                err <= 1'b1;
                                res <= 16'hxxxx;

                            end
                        end
 
                        4'hB: begin
                            if (r_inp_valid == 2'b11) begin
                                signed_result          = $signed({1'b0, r_opa}) + $signed({1'b0, r_opb});
                                cout                  <= signed_result[data_width];
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
 
                        4'hC: begin
                            if (r_inp_valid == 2'b11) begin
                                signed_result          = $signed({1'b0, r_opa}) - $signed({1'b0, r_opb});
                                cout                  <= signed_result[data_width];
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
 
                end else begin
 
                    case (r_cmd)
 
                        4'h0: begin
                            res[data_width-1:0]          <= (r_inp_valid == 2'b11) ? (r_opa & r_opb) : {data_width{1'b0}};
                            res[2*data_width-1:data_width] <= {data_width{1'b0}};
                            oflow <= 1'b0; cout <= 1'b0; {g,l,e} <= 3'b000;
                            err   <= ~(r_inp_valid == 2'b11);
                        end
 
                        4'h1: begin
                            res[data_width-1:0]          <= (r_inp_valid == 2'b11) ? ~(r_opa & r_opb) : {data_width{1'b0}};
                            res[2*data_width-1:data_width] <= {data_width{1'b0}};
                            oflow <= 1'b0; cout <= 1'b0; {g,l,e} <= 3'b000;
                            err   <= ~(r_inp_valid == 2'b11);
                        end
 
                        4'h2: begin
                            res[data_width-1:0]          <= (r_inp_valid == 2'b11) ? (r_opa | r_opb) : {data_width{1'b0}};
                            res[2*data_width-1:data_width] <= {data_width{1'b0}};
                            oflow <= 1'b0; cout <= 1'b0; {g,l,e} <= 3'b000;
                            err   <= ~(r_inp_valid == 2'b11);
                        end
 
                        4'h3: begin
                            res[data_width-1:0]          <= (r_inp_valid == 2'b11) ? ~(r_opa | r_opb) : {data_width{1'b0}};
                            res[2*data_width-1:data_width] <= {data_width{1'b0}};
                            oflow <= 1'b0; cout <= 1'b0; {g,l,e} <= 3'b000;
                            err   <= ~(r_inp_valid == 2'b11);
                        end
 
                        4'h4: begin
                            res[data_width-1:0]          <= (r_inp_valid == 2'b11) ? (r_opa ^ r_opb) : {data_width{1'b0}};
                            res[2*data_width-1:data_width] <= {data_width{1'b0}};
                            oflow <= 1'b0; cout <= 1'b0; {g,l,e} <= 3'b000;
                            err   <= ~(r_inp_valid == 2'b11);
                        end
 
                        4'h5: begin
                            res[data_width-1:0]          <= (r_inp_valid == 2'b11) ? ~(r_opa ^ r_opb) : {data_width{1'b0}};
                            res[2*data_width-1:data_width] <= {data_width{1'b0}};
                            oflow <= 1'b0; cout <= 1'b0; {g,l,e} <= 3'b000;
                            err   <= ~(r_inp_valid == 2'b11);
                        end
 
                        4'h6: begin
                            res[data_width-1:0]          <= (r_inp_valid == 2'b11 || r_inp_valid == 2'b01) ? ~r_opa : {data_width{1'b0}};
                            res[2*data_width-1:data_width] <= {data_width{1'b0}};
                            oflow <= 1'b0; cout <= 1'b0; {g,l,e} <= 3'b000;
                            err   <= ~(r_inp_valid == 2'b11 || r_inp_valid == 2'b01);
                        end
 
                        4'h7: begin
                            res[data_width-1:0]          <= (r_inp_valid == 2'b11 || r_inp_valid == 2'b10) ? ~r_opb : {data_width{1'b0}};
                            res[2*data_width-1:data_width] <= {data_width{1'b0}};
                            oflow <= 1'b0; cout <= 1'b0; {g,l,e} <= 3'b000;
                            err   <= ~(r_inp_valid == 2'b11 || r_inp_valid == 2'b10);
                        end
 
                        4'h8: begin
                            res[data_width-1:0]          <= (r_inp_valid == 2'b11 || r_inp_valid == 2'b01) ? r_opa >> 1 : {data_width{1'b0}};
                            res[2*data_width-1:data_width] <= {data_width{1'b0}};
                            oflow <= 1'b0; cout <= 1'b0; {g,l,e} <= 3'b000;
                            err   <= ~(r_inp_valid == 2'b11 || r_inp_valid == 2'b01);
                        end
 
                        4'h9: begin
                            res[data_width-1:0]          <= (r_inp_valid == 2'b11 || r_inp_valid == 2'b01) ? r_opa << 1 : {data_width{1'b0}};
                            res[2*data_width-1:data_width] <= {data_width{1'b0}};
                            oflow <= 1'b0; cout <= 1'b0; {g,l,e} <= 3'b000;
                            err   <= ~(r_inp_valid == 2'b11 || r_inp_valid == 2'b01);
                        end
 
                        4'hA: begin
                            res[data_width-1:0]          <= (r_inp_valid == 2'b11 || r_inp_valid == 2'b10) ? r_opb >> 1 : {data_width{1'b0}};
                            res[2*data_width-1:data_width] <= {data_width{1'b0}};
                            oflow <= 1'b0; cout <= 1'b0; {g,l,e} <= 3'b000;
                            err   <= ~(r_inp_valid == 2'b11 || r_inp_valid == 2'b10);
                        end
 
                        4'hB: begin
                            res[data_width-1:0]          <= (r_inp_valid == 2'b11 || r_inp_valid == 2'b10) ? r_opb << 1 : {data_width{1'b0}};
                            res[2*data_width-1:data_width] <= {data_width{1'b0}};
                            oflow <= 1'b0; cout <= 1'b0; {g,l,e} <= 3'b000;
                            err   <= ~(r_inp_valid == 2'b11 || r_inp_valid == 2'b10);
                        end
 
                        4'hC: begin
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
 
                        4'hD: begin
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

