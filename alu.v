module alu #(
    parameter width = 8,
    cwidth = 4
) (
    clk, rst, inp_valid, mode, cmd, ce, opa, opb, cin, err, res, oflow, cout, g, l, e
);
    input wire clk, rst, mode, ce, cin;
    input wire [1:0] inp_valid;
    input wire [width-1:0] opa, opb;
    input wire [cwidth-1:0] cmd;
    output reg g, l, e;
    reg g1, l1, e1;
    output wire cout, oflow;
    output reg err;
    output reg [2*width-1:0] res;

    reg [cwidth-1:0] cmdo;
    reg [2*width-1:0] res1;

    //cout for unsgined + and overflow for everyother
    //0 is driver default not z

    reg mg, i0;
    reg [2*width-1:0] s0;
    reg [1:0] count;
    reg err1;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            res1 <= 0;
            g   <= 0;
            l   <= 0;
            e   <= 0;
            g1  <= 0;
            l1  <= 0;
            e1  <= 0;
            mg  <= 0;
            s0  <= 0;
            i0  <= 0;
            cmdo<= 0;
            res <= 0;
        end else begin
            if (ce) begin
                g   <= g1;
                l   <= l1;
                e   <= e1;
                g1  <= 0;
                l1  <= 0;
                e1  <= 0;
                res1<= 0;
                s0  <= 0;
                i0  <= 0;
                res <= res1;

                count<= 0;
                mg   <= 0;
                cmdo <= cmd;
                if (mode) begin
                    case (cmd)
                        0: begin
                            res1 <= opa + opb;
                        end
                        1: begin
                            res1 <= opa - opb;
                        end
                        2: begin
                            res1 <= cin + opa + opb;
                        end
                        3: begin
                            res1 <= opa - opb - cin;
                        end
                        4: res1 <= opa + 1'b1;
                        5: res1 <= opa - 1'b1;
                        6: res1 <= opb + 1'b1;
                        7: res1 <= opb - 1'b1;
                        8: begin
                            g1 <= (opa > opb);
                            l1 <= (opa < opb);
                            e1 <= (opa == opb);
                        end
                        9: begin
                            res1 <= s0;
                            mg   <= i0;

                            case (count)
                                2'd0: begin
                                    s0   <= (opa + 1'b1) * (opb + 1'b1);
                                    i0   <= (inp_valid != 2'b11);
                                    count<= 1;
                                end
                                2'd1: begin
                                    if (cmdo != cmd) begin
                                        count<= 1;
                                        s0   <= (opa + 1'b1) * (opb + 1'b1);
                                        i0   <= (inp_valid != 2'b11);
                                    end 
                                    else
                                        count<= 2;
                                end
                                default: begin
                                    s0   <= (opa + 1'b1) * (opb + 1'b1);
                                    i0   <= (inp_valid != 2'b11);
                                    if (cmd == cmdo)
                                        count<= 1;
                                    else
                                        count<= 0;
                                end
                            endcase
                        end
                        10: begin
                            res1 <= s0;
                            mg   <= i0;

                            case (count)
                                2'd0: begin
                                    s0   <= (opa << 1'b1) * (opb);
                                    i0   <= (inp_valid != 2'b11);
                                    count<= 1;
                                end
                                2'd1: begin
                                    if (cmdo != cmd) begin
                                        count<= 1;
                                        s0   <= (opa << 1'b1) * (opb);
                                        i0   <= (inp_valid != 2'b11);
                                    end 
                                    else
                                        count<= 2;
                                end
                                default: begin
                                    s0   <= (opa << 1'b1) * (opb);
                                    i0   <= (inp_valid != 2'b11);
                                    if (cmd == cmdo)
                                        count<= 1;
                                    else
                                        count<= 0;
                                end
                            endcase
                        end
                        11: begin
                            g1 <= ($signed(opa) > $signed(opb));
                            l1 <= ($signed(opa) < $signed(opb));
                            e1 <= ($signed(opa) == $signed(opb));
                            res1 <= $signed(opa) + $signed(opb);
                        end
                        12: begin
                            g1 <= ($signed(opa) > $signed(opb));
                            l1 <= ($signed(opa) < $signed(opb));
                            e1 <= ($signed(opa) == $signed(opb));
                            res1 <= $signed(opa) - $signed(opb);
                        end
                        default: res1 <= 0;
                    endcase
                end else begin
                    case (cmd)
                        0:       res1 <= opa & opb;
                        1:       res1 <= ~(opa & opb);
                        2:       res1 <= opa | opb;
                        3:       res1 <= ~(opa | opb);
                        4:       res1 <= opa ^ opb;
                        5:       res1 <= (opa ~^ opb);
                        6:       res1 <= ~opa;
                        7:       res1 <= ~opb;
                        8:       res1 <= opa >> 1;
                        9:       res1 <= opa << 1;
                        10:      res1 <= opb >> 1;
                        11:      res1 <= opb << 1;
                        12:      res1 <= (((1 << width) - 1) & ((opa >> (width - opb[$clog2(width):0])) | (opa << (opb[$clog2(width):0]))));
                        13:      res1 <= (((1 << width) - 1) & ((opa << (width - opb[$clog2(width):0])) | (opa >> (opb[$clog2(width):0]))));
                        default: res1 <= 0;
                    endcase
                end
            end
        end
    end

    assign oflow = rst ? 0 : (
        ((mode & (cmd == 11)) & (opa[width-1] == opb[width-1]) & (res1[width-1] != (opa[width-1]))) ||
        ((mode & (cmd == 12)) & (opa[width-1] != opb[width-1]) & (res1[width-1] != (opa[width-1]))) ||
        ((mode & (cmd == 1)) & (opb > opa)) ||
        ((mode & (cmd == 3)) & ((opb + cin) > opa))
    );

    assign cout = rst ? 0 : (
        (mode & (cmd == 0) & (res1[width])) ||
        (mode & (cmd == 2) & (res1[width]))
    );

    always @(posedge clk, posedge rst) begin
        if (rst)
        begin
            err1 <= 0;
            err<=0;
        end
        else
        begin
            err1 <= (mg) || ((inp_valid != 2'b11) & (cmd != 4'd10 || cmd != 4'd9)) || ((cmd == 12 || cmd == 13) & (~mode) & (opb > ((1 << $clog2(width)) - 1)));
            err<=err1;
        end
    end

endmodule
