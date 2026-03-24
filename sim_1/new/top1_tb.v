`timescale 1ns / 1ps

module top1_tb;

reg clk, rst_n;
initial begin
    clk = 1'b0;  // 初始值
    forever begin  // 永久循环
        #5 clk = ~clk;
    end
end
initial begin
    rst_n = 0;
    #2;
    rst_n = 1;
end

//==================== irom_test instance start ================
wire [7:0] pc_irom;
wire [31:0] dout_irom;

irom_test u_irom(
    .addra (pc_irom),
    .clka (clk),
    .douta (dout_irom)
);

//==================== IF module instance start ================

// reg jump_taken_if;
// reg [31:0] jump_target_if;
// reg branch_taken_if;
// reg [31:0] branch_target_if;
//改为wire
wire jump_taken_if;
wire [31:0] jump_target_if;
wire branch_taken_if;
wire [31:0] branch_target_if;
reg [31:0] curr_pc_if;
wire [31:0] next_pc_if;
wire [31:0] irom_addr_if;
wire is_LAR_if;

IF u_IF(
    .rst_n (rst_n),
    .curr_pc (curr_pc_if),
    .jump_taken (jump_taken_if),
    .jump_target (jump_target_if),
    .branch_taken (branch_taken_if),
    .branch_target (branch_target_if),
    .is_LAR (is_LAR_if),
    .next_pc (next_pc_if),
    .irom_addr (irom_addr_if)
);
//===================== IF module instance end ==================

//===================== ID module instance start ================
reg [31:0] ins;
wire alu_src_id;
wire [3:0] alu_op_id;
wire [31:0] imm_id;
wire jump_en_id, branch_en_id, is_lui_id, is_auipc_id, is_jalr_id, not_wb_id;
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
    .not_wb     (not_wb_id),
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


//寄存器组定义
reg [31:0] rs [31:0];

//传给后续端口的信号
reg not_wb_ex, not_wb_mem;
reg [2:0] load_op_ex, store_op_ex, load_op_mem;
reg [4:0] rd_ex, rs2_ex, rd_mem;
reg [31:0] curr_pc_id;
reg is_lui_ex, is_auipc_ex;
//==================================================

//检测写寄存器下一条指令读同一寄存器    (标志位会在译码的下一个周期，即执行周期开始生效)
wire is_WAR1, is_WAR2; //write after read标志位
wire is_WAR1_last, is_WAR2_last; //上上条指令的写和当前读为同一寄存器
wire is_LAR;   //load after read标志位
wire is_load_id, is_store_id;
wire is_load, is_store;
assign is_load_id = ~(&load_op_id);
assign is_store_id = ~(&store_op_id);
assign is_load = ~(&load_op_ex);
assign is_store = ~(&store_op_ex);
reg is_load_mem, is_store_mem;
assign is_WAR1 = ((rd_ex == rs1_id) & (rd_ex != 5'b0) & (~is_load)) ? 1'b1 : 1'b0;
assign is_WAR2 = ((rd_ex == rs2_id) & (rd_ex != 5'b0) & (~is_load)) ? 1'b1 : 1'b0;
assign is_WAR1_last = ((rd_mem == rs1_id) & (rd_mem != 5'b0)) ? 1'b1 : 1'b0;    //包含了load-x-read类型
assign is_WAR2_last = ((rd_mem == rs2_id) & (rd_mem != 5'b0)) ? 1'b1 : 1'b0;
assign is_LAR_if = is_LAR;
assign is_LAR = ((rd_ex == rs1_id) & (rd_ex != 5'b0) & is_load) ? 1'b1 : 1'b0;
//取指
assign pc_irom = irom_addr_if [9:2];
always @(posedge clk or negedge rst_n)
begin
    if (!rst_n) begin
        curr_pc_if <= 32'b0;
    end
    else begin
        //curr_pc_if <= next_pc_if;
        if (is_LAR_if) curr_pc_if = curr_pc_if - 4;
        else begin
            curr_pc_if = next_pc_if;
        end 
    end
end
//==============================

//译码
reg [31:0] curr_pc_id_reg;
always @(posedge clk or negedge rst_n)
begin
    if (!rst_n) begin
        ins <= 32'b0;
        curr_pc_id <= 32'b0;
        curr_pc_id_reg <= 32'b0;
    end
    else begin
        if(~is_LAR_if) begin
            ins <= dout_irom;
            curr_pc_id_reg <= curr_pc_if;
            curr_pc_id <= curr_pc_id_reg;
        end
        else begin
            ins <= ins;
            curr_pc_id_reg <= curr_pc_id_reg;
            curr_pc_id <= curr_pc_id;
        end
    end
end
//================================

//执行
wire [31:0] rs_result;
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
        rs2_ex <= 5'b0;
        is_lui_ex <= 1'b0;
        is_auipc_ex <= 1'b0;
    end
    else begin
        alu_op_ex <= alu_op_id;
        alu_src_ex <= alu_src_id;
        //数据旁路选择分支
        a_ex <= (is_WAR1) ? rs_result :
                (is_WAR1_last) ? wb_result : rs [rs1_id];   //这种情况包含load-x-read
        b_ex <= (is_WAR2) ? rs_result :
                (is_WAR2_last) ? wb_result : rs [rs2_id];
        rs2_ex <= rs2_id;
        imm_ex <= imm_id;
        jump_en_ex <= jump_en_id;
        branch_en_ex <= branch_en_id;
        is_jalr_ex <= is_jalr_id;
        pc_ex <= curr_pc_id;
        not_wb_ex <= not_wb_id;
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

WB u_wb(
    .wb_op (wb_op),
    .imm (imm_ex),
    .branch_target (branch_target_ex),
    .j_rd (j_rd_ex),
    .alu_result (alu_result_ex),
    .rs_result (rs_result)
);

wire [31:0] wb_result;
always @(posedge clk or negedge rst_n)
begin
    if (!rst_n) begin : init_rs
        integer i;
        for (i = 0; i < 32; i = i + 1) begin
            rs[i] <= 32'd0; 
        end
    end
    else begin
        if ((not_wb_mem != 1'b1) & (rd_mem != 5'b0)) begin
            rs [rd_mem] <= wb_result;
        end
    end
end

//分支跳转
assign branch_taken_if = branch_taken_ex;
assign branch_target_if = branch_target_ex;
assign jump_taken_if = jump_taken_ex;
assign jump_target_if = jump_target_ex;


//mem
wire [3:0] we;
wire [31:0] ram_dout;
wire [31:0] load_data_out;
wire [7:0] dram_addr;

assign we = is_store ? we_store : 4'b0;
assign dram_addr = alu_result_ex[9:2];

LOAD u_load(
    .load_op (load_op_mem),
    .load_data_in (ram_dout),
    .load_data_out (load_data_out)
);

STORE u_store(
    .store_op (store_op_ex),
    .we (we_store)
);

blk_mem_gen_0 dram(
    .clka (clk),
    .ena (1'b1),
    .wea (we),
    .addra (dram_addr),
    .dina (rs[rs2_ex]),
    .douta (ram_dout)
);

reg [31:0] rs_result_mem;
always @(posedge clk or negedge rst_n)
begin
    if (!rst_n) begin
        load_op_mem <= 3'b111;
        rs_result_mem <= 32'b0;
        not_wb_mem <= 1'b0;
        rd_mem <= 5'b0;
        is_load_mem <= 1'b0;
        is_store_mem <= 1'b0;
    end
    else begin
        load_op_mem <= load_op_ex;
        rs_result_mem <= rs_result;
        not_wb_mem <= not_wb_ex;
        rd_mem <= rd_ex;
        is_load_mem <= is_load;
        is_store_mem <= is_store;
    end
end
assign wb_result = is_load_mem ? load_data_out : rs_result_mem;

//output 
wire [31:0] rs1 = rs[1];
wire [31:0] rs2 = rs[2];
wire [31:0] rs3 = rs[3];
endmodule
