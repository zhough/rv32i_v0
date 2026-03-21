
module WB(
    input [2:0] wb_op,
    input [31:0] imm,
    input [31:0] branch_target,
    input [31:0] j_rd,
    input [31:0] alu_result,
    output [31:0] rs_result
    );

reg [31:0] result;
always @(*) begin
    case(wb_op)
        3'b100: result <= imm;
        3'b010: result <= branch_target; //实际为 pc+imm
        3'b001: result <= j_rd;
        default : result <= alu_result;
    endcase
end

assign rs_result = result;

endmodule
