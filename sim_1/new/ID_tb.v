`timescale 1ns / 1ps

module ID_tb;

reg [31:0] ins;
wire alu_src;
wire [3:0] alu_op;
wire [31:0] imm;
wire jump_en, branch_en, is_lui, is_auipc, is_jalr;
wire [2:0] load_op, store_op;
wire [4:0] rs1, rs2, rd;

ID u_ID(
    .ins        (ins),
    .alu_src    (alu_src),
    .alu_op     (alu_op),
    .imm        (imm),
    .jump_en    (jump_en),
    .branch_en  (branch_en),
    .is_lui     (is_lui),
    .is_auipc   (is_auipc),
    .is_jalr    (is_jalr),
    .load_op    (load_op),
    .store_op   (store_op),
    .rs1        (rs1),
    .rs2        (rs2),
    .rd         (rd)
);

initial begin
    ins = 32'b0;
    #10;
    ins = {7'b0000000,5'd1,5'd2,3'b000,5'd3,7'b0110011};    //ADD
    #10;
    $display ("ADD:");
    $display ("alu_src = %b, alu_op = %b, imm = %h", alu_src, alu_op, imm);
    $display ("rs1 = %b, rs2 = %b, rd = %b", rs1, rs2, rd);
    $display ("jump_en,branch_en,is_lui,is_auipc,is_jalr: %b", {jump_en, branch_en, is_lui, is_auipc, is_jalr});
    $display ("load_op = %b, store_op = %b", load_op, store_op);
    $display ("===============================================");

    ins = {7'b0100000,5'd1,5'd2,3'b000,5'd3,7'b0110011};
    #10;
    $display ("SUB:");
    $display ("alu_src = %b, alu_op = %b, imm = %h", alu_src, alu_op, imm);
    $display ("rs1 = %b, rs2 = %b, rd = %b", rs1, rs2, rd);
    $display ("jump_en,branch_en,is_lui,is_auipc,is_jalr: %b", {jump_en, branch_en, is_lui, is_auipc, is_jalr});
    $display ("load_op = %b, store_op = %b", load_op, store_op);
    $display ("===============================================");

    ins = {7'b0000000,5'd1,5'd2,3'b001,5'd3,7'b0110011};
    #10;
    $display ("SLL:");
    $display ("alu_src = %b, alu_op = %b, imm = %h", alu_src, alu_op, imm);
    $display ("rs1 = %b, rs2 = %b, rd = %b", rs1, rs2, rd);
    $display ("jump_en,branch_en,is_lui,is_auipc,is_jalr: %b", {jump_en, branch_en, is_lui, is_auipc, is_jalr});
    $display ("load_op = %b, store_op = %b", load_op, store_op);
    $display ("===============================================");

    ins = {7'b0000000,5'd1,5'd2,3'b010,5'd3,7'b0110011};
    #10;
    $display ("SLT:");
    $display ("alu_src = %b, alu_op = %b, imm = %h", alu_src, alu_op, imm);
    $display ("rs1 = %b, rs2 = %b, rd = %b", rs1, rs2, rd);
    $display ("jump_en,branch_en,is_lui,is_auipc,is_jalr: %b", {jump_en, branch_en, is_lui, is_auipc, is_jalr});
    $display ("load_op = %b, store_op = %b", load_op, store_op);
    $display ("===============================================");

    ins = {-12'd12, 5'd2, 3'b000, 5'd3, 7'b0010011};
    #10
    $display ("ADDI:");
    $display ("alu_src = %b, alu_op = %b, imm = %h", alu_src, alu_op, imm);
    $display ("rs1 = %b, rs2 = %b, rd = %b", rs1, rs2, rd);
    $display ("jump_en,branch_en,is_lui,is_auipc,is_jalr: %b", {jump_en, branch_en, is_lui, is_auipc, is_jalr});
    $display ("load_op = %b, store_op = %b", load_op, store_op);
    $display ("===============================================");

    ins = {7'b0, 5'b10111, 5'd2, 3'b001, 5'd3, 7'b0010011};
    #10;
    $display ("SLLI:");
    $display ("alu_src = %b, alu_op = %b, imm = %h", alu_src, alu_op, imm);
    $display ("rs1 = %b, rs2 = %b, rd = %b", rs1, rs2, rd);
    $display ("jump_en,branch_en,is_lui,is_auipc,is_jalr: %b", {jump_en, branch_en, is_lui, is_auipc, is_jalr});
    $display ("load_op = %b, store_op = %b", load_op, store_op);
    $display ("===============================================");

    ins = {1'b0, 10'b1000110001, 1'b1, 8'b10001001, 5'd3, 7'b1101111};   //89c62 = 01000 1001 1100 0110 0010
    #10;
    $display ("JAL:");
    $display ("alu_src = %b, alu_op = %b, imm = %h", alu_src, alu_op, imm);
    $display ("rs1 = %b, rs2 = %b, rd = %b", rs1, rs2, rd);
    $display ("jump_en,branch_en,is_lui,is_auipc,is_jalr: %b", {jump_en, branch_en, is_lui, is_auipc, is_jalr});
    $display ("load_op = %b, store_op = %b", load_op, store_op);
    $display ("===============================================");

    ins = {1'b0, 6'b100001, 5'd1, 5'd2, 3'b000, 4'b1001, 1'b1, 7'b1100011};   //c32 = 01100 0011 0010
    #10;
    $display ("BEQ:");
    $display ("alu_src = %b, alu_op = %b, imm = %h", alu_src, alu_op, imm);
    $display ("rs1 = %b, rs2 = %b, rd = %b", rs1, rs2, rd);
    $display ("jump_en,branch_en,is_lui,is_auipc,is_jalr: %b", {jump_en, branch_en, is_lui, is_auipc, is_jalr});
    $display ("load_op = %b, store_op = %b", load_op, store_op);
    $display ("===============================================");

    ins = {7'b0, 5'd12, 5'd2, 3'b101, 5'd3, 7'b0010011};
    #10;
    $display ("SRLI:");
    $display ("alu_src = %b, alu_op = %b, imm = %h", alu_src, alu_op, imm);
    $display ("rs1 = %b, rs2 = %b, rd = %b", rs1, rs2, rd);
    $display ("jump_en,branch_en,is_lui,is_auipc,is_jalr: %b", {jump_en, branch_en, is_lui, is_auipc, is_jalr});
    $display ("load_op = %b, store_op = %b", load_op, store_op);
    $display ("===============================================");

    ins = {7'b0100000, 5'd12, 5'd2, 3'b101, 5'd3, 7'b0010011};
    #10;
    $display ("SRAI:");
    $display ("alu_src = %b, alu_op = %b, imm = %h", alu_src, alu_op, imm);
    $display ("rs1 = %b, rs2 = %b, rd = %b", rs1, rs2, rd);
    $display ("jump_en,branch_en,is_lui,is_auipc,is_jalr: %b", {jump_en, branch_en, is_lui, is_auipc, is_jalr});
    $display ("load_op = %b, store_op = %b", load_op, store_op);
    $display ("===============================================");

    ins = {12'd12, 5'd2, 3'b000, 5'd3, 7'b1100111};
    #10;
    $display ("JALR:");
    $display ("alu_src = %b, alu_op = %b, imm = %h", alu_src, alu_op, imm);
    $display ("rs1 = %b, rs2 = %b, rd = %b", rs1, rs2, rd);
    $display ("jump_en,branch_en,is_lui,is_auipc,is_jalr: %b", {jump_en, branch_en, is_lui, is_auipc, is_jalr});
    $display ("load_op = %b, store_op = %b", load_op, store_op);
    $display ("===============================================");

    ins = {20'd12, 5'd3, 7'b0110111};
    #10;
    $display ("LUI:");
    $display ("alu_src = %b, alu_op = %b, imm = %h", alu_src, alu_op, imm);
    $display ("rs1 = %b, rs2 = %b, rd = %b", rs1, rs2, rd);
    $display ("jump_en,branch_en,is_lui,is_auipc,is_jalr: %b", {jump_en, branch_en, is_lui, is_auipc, is_jalr});
    $display ("load_op = %b, store_op = %b", load_op, store_op);
    $display ("===============================================");

    ins = {12'd12, 5'd2, 3'b000, 5'd3, 7'b0000011};
    #10;
    $display ("LB:");
    $display ("alu_src = %b, alu_op = %b, imm = %h", alu_src, alu_op, imm);
    $display ("rs1 = %b, rs2 = %b, rd = %b", rs1, rs2, rd);
    $display ("jump_en,branch_en,is_lui,is_auipc,is_jalr: %b", {jump_en, branch_en, is_lui, is_auipc, is_jalr});
    $display ("load_op = %b, store_op = %b", load_op, store_op);
    $display ("===============================================");

    ins = {7'b0001000, 5'd1, 5'd2, 3'b000, 5'b01000, 7'b0100111};
    #10;
    $display ("SB:");
    $display ("alu_src = %b, alu_op = %b, imm = %h", alu_src, alu_op, imm);
    $display ("rs1 = %b, rs2 = %b, rd = %b", rs1, rs2, rd);
    $display ("jump_en,branch_en,is_lui,is_auipc,is_jalr: %b", {jump_en, branch_en, is_lui, is_auipc, is_jalr});
    $display ("load_op = %b, store_op = %b", load_op, store_op);
    $display ("===============================================");

    $finish;
end

endmodule
