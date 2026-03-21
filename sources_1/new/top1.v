module top1(
    input rst_n,
    input clk,
    output [31:0] inst,
    output [31:0] rs1,
    output [31:0] rs2,
    output [31:0] rs3
    );

//==================== irom_test instance start ================
wire [7:0] pc_irom;
wire [31:0] dout_irom;

irom_test u_irom(
    .addra (pc_irom),
    .clka (clk),
    .douta (dout_irom)
);

//==================== IF module instance start ================
reg [31:0] curr_pc_if;
reg jump_taken_if;
reg [31:0] jump_target_if;
reg branch_taken_if;
reg [31:0] branch_target_if;
wire [31:0] next_pc_if;
wire [31:0] irom_addr_if;

IF u_IF(
    .rst_n (rst_n),
    .curr_pc (curr_pc_if),
    .jump_taken (jump_taken_if),
    .jump_target (jump_target_if),
    .branch_taken (branch_taken_if),
    .branch_target (branch_target_if),
    .next_pc (next_pc_if),
    .irom_addr (irom_addr_if)
);
//===================== IF module instance end ==================

//===================== ID module instance start ================
reg [31:0] ins;
wire alu_src_id;
wire [3:0] alu_op_id;
wire [31:0] imm_id;
wire jump_en_id, branch_en_id, is_lui_id, is_auipc_id, is_jalr_id;
wire [2:0] load_op_id, store_op_id;
wire [4:0] rs1_id, rs2_id, rd_id;

ID u_ID(
    .ins        (ins),
    .alu_src    (alu_src_id),
    .alu_op     (alu_op_id),
    .imm        (imm_id),
    .jump_en    (jump_en_id),
    .branch_en  (branch_en_id),
    .is_lui     (is_lui_id),
    .is_auipc   (is_auipc_id),
    .is_jalr    (is_jalr_id),
    .load_op    (load_op_id),
    .store_op   (store_op_id),
    .rs1        (rs1_id),
    .rs2        (rs2_id),
    .rd         (rd_id)
);
//=================== ID module instance end =====================

//=================== EX module instance start ===================
reg [3:0] alu_op_ex;
reg alu_src_ex;
reg [31:0] a_ex, b_ex, imm_ex;
reg jump_en_ex, branch_en_ex, is_jalr_ex;
reg [31:0] pc_ex;
wire jump_taken_ex, branch_taken_ex;
wire [31:0] jump_target_ex, branch_target_ex, alu_result_ex;
wire [31:0] j_rd_ex;

EX u_EX(
    .alu_op (alu_op_ex),
    .alu_src (alu_src_ex),
    .a (a_ex),
    .b (b_ex),
    .imm (imm_ex),
    .jump_en (jump_en_ex),
    .branch_en (branch_en_ex),
    .is_jalr (is_jalr_ex),
    .pc (pc_ex),
    .jump_taken (jump_taken_ex),
    .branch_taken (branch_taken_ex),
    .jump_target (jump_target_ex),
    .branch_target (branch_target_ex),
    .alu_result (alu_result_ex),
    .j_rd (j_rd_ex)
);
//================= EX module instance end =====================

//================= WB module instance start ===================
reg [4:0] rd_wb;
reg not_wb;
wire wb_en;

WB u_WB(
    .rd (rd_wb),
    .not_wb (not_wb),
    .wb_en (wb_en)
);
//=============== WB module instance end =======================

//寄存器组定义
reg [31:0] rs [31:0];

//传给后续端口的信号
reg not_wb_ex;
reg [2:0] load_op_ex, store_op_ex;
reg [31:0] rd_ex;
reg [31:0] curr_pc_id;
reg is_lui_ex, is_auipc_ex;
//==================================================
//取指
assign pc_irom = irom_addr_if [9:2];
always @(posedge clk or negedge rst_n)
begin
    if (!rst_n) begin
        curr_pc_if <= 32'b0;
        jump_taken_if <= 1'b0;
        branch_taken_if <= 1'b0;
    end
    else begin
        curr_pc_if <= next_pc_if;
    end
end
//==============================

//译码
always @(posedge clk or negedge rst_n)
begin
    if (!rst_n) begin
        ins <= 32'b0;
        curr_pc_id <= 32'b0;
    end
    else begin
        ins <= dout_irom;
        curr_pc_id <= curr_pc_if;
    end
end
//================================

//执行
always @(posedge clk or negedge rst_n)
begin
    if (!rst_n) begin
        alu_op_ex <= 4'b0;
        alu_src_ex <= 1'b0;
        a_ex <= 32'b0;
        b_ex <= 32'b0;
        imm_ex <= 32'b0;
        jump_en_ex <= 1'b0;
        branch_en_ex <= 1'b0;
        is_jalr_ex <= 1'b0;
        pc_ex <= 32'b0;
        not_wb_ex <= 1'b1;
        load_op_ex <= 3'b111;
        store_op_ex <= 3'b111;
        rd_ex <= 5'b0;
        is_lui_ex <= 1'b0;
        is_auipc_ex <= 1'b0;
    end
    else begin
        alu_op_ex <= alu_op_id;
        alu_src_ex <= alu_src_id;
        a_ex <= rs [rs1_id];
        b_ex <= rs [rs2_id];
        imm_ex <= imm_id;
        jump_en_ex <= jump_en_id;
        branch_en_ex <= branch_en_id;
        is_jalr_ex <= is_jalr_id;
        pc_ex <= curr_pc_id;
        not_wb_ex <= not_wb;
        load_op_ex <= load_op_id;
        store_op_ex <= store_op_id;
        rd_ex <= rd_id;
        is_lui_ex <= is_lui_id;
        is_auipc_ex <= is_auipc_id;
    end
end
//写回
wire [2:0] wb_op;
assign wb_op = {is_lui_ex, is_auipc_ex, jump_taken_ex};
always @(posedge clk or negedge rst_n)
begin
    if (!rst_n) begin : init_rs
        integer i;
        for (i = 0; i < 32; i = i + 1) begin
            rs[i] <= 32'd0; 
        end
    end
    else begin
        if ((not_wb_ex != 1'b1) & (rd_ex != 5'b0)) begin
            case(wb_op)
                3'b100: rs [rd_ex] <= imm_ex;
                3'b010: rs [rd_ex] <= branch_target_ex; //实际为 pc+imm
                3'b001: rs [rd_ex] <= j_rd_ex;
                default : rs [rd_ex] <= alu_result_ex;
            endcase
        end
    end
end
//====================================


//输出
assign rs1 = rs[1];
assign rs2 = rs[2];
assign rs3 = rs[3];
assign inst = ins;
endmodule
