
module STORE(
    input [2:0] store_op,
    output [3:0] we
    );

reg [3:0] we_reg;
assign we = we_reg;
always @(*) begin
    case(store_op)
        3'b000: we_reg = 4'b0001;
        3'b001: we_reg = 4'b0011;
        3'b010: we_reg = 4'b1111;
        default: we_reg = 4'b0000;
    endcase 
end
endmodule
