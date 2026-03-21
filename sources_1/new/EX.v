module EX(
    input [3:0]  alu_op,
    input        alu_src,  // 选择b的来源：0=rs2，1=imm
    input [31:0] a,        // 固定为rs1
    input [31:0] b,        // rs2
    input [31:0] imm,      // 立即数
    input jump_en,
    input branch_en,
    input is_jalr,
    input [31:0] pc,
    output jump_taken,
    output branch_taken,
    output [31:0] jump_target,
    output [31:0] branch_target,
    output [31:0] alu_result, // ALU运算结果
    output [31:0] j_rd
    );

wire [31:0] alu_b = alu_src ? imm : b;

reg [31:0] result;
always @(*) begin
    case(alu_op)
        4'b0001 : result = a + alu_b;   //加
        4'b0010 : result = a - alu_b;   //减
        4'b0011 : result = a & alu_b;   //按位与
        4'b0100 : result = a | alu_b;   //按位或
        4'b0101 : result = a ^ alu_b;   //按位异或
        4'b0110 : result = a << alu_b[4:0];     //逻辑左移
        4'b0111 : result = a >> alu_b[4:0];     //逻辑右移
        4'b1000 : result = $signed(a) >>> alu_b[4:0];   //有符号数算术右移
        4'b1001 : result = ($signed(a) < $signed(alu_b)) ? 32'b1 : 32'b0;   //有符号数比较小于
        4'b1010 : result = (a < alu_b) ? 32'd1 : 32'd0;   //无符号数比较小于
        4'b1011 : result = (a == alu_b) ?  32'd1 : 32'd0;
        4'b1100 : result = (a != alu_b) ?  32'd1 : 32'd0;
        4'b1101 : result = ($signed(a) >= $signed(alu_b)) ? 32'd1 : 32'd0; //有符号数比较大于等于
        4'b1110 : result = (a >= alu_b) ? 32'd1 : 32'd0;    //无符号数比较大于等于
        default : result = 32'd0;
    endcase
end

assign alu_result = result;
assign branch_target = $signed(pc) + $signed(imm);
assign branch_taken = branch_en & alu_result[0];
wire [32:0] tmp_target;
assign tmp_target = $signed(a) + $signed(imm);    
assign jump_target = is_jalr ? (tmp_target & 32'hFFFFFFFE) : branch_target;    
assign jump_taken = jump_en;
assign j_rd = pc + 4;
endmodule