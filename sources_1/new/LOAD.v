module LOAD(
    input [2:0] load_op,
    input [31:0] load_data_in,
    output [31:0] load_data_out
);
reg [31:0] load_data_out_reg;
assign load_data_out = load_data_out_reg;
always @(*) begin
    case(load_op)
        3'b000: load_data_out_reg = {{24{load_data_in[7]}}, load_data_in[7:0]};
        3'b001: load_data_out_reg = {{16{load_data_in[15]}}, load_data_in[15:0]};
        3'b010: load_data_out_reg = load_data_in;
        3'b100: load_data_out_reg = {24'b0, load_data_in[7:0]};
        3'b101: load_data_out_reg = {16'b0, load_data_in[15:0]};
        default: load_data_out_reg = 32'b0;
    endcase
end

endmodule