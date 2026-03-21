/*
ID : Instruction decode
in: instruction
out: 
    alu_op : ex模块的执行控制信号
    alu_src : 1为立即数，0为寄存器2
    imm : 扩展为32位的立即数
    jump_en : 跳转指令标志位
    branch_en : 分支指令标志位
    is_lui : LUI指令标志位
    is_auipc : AUIPC指令标志位
    is_jalr : jalr标志，用于区分jalr和jal指令
    not_wb : 无目标寄存器的指令
    load_op : 111为非load指令，其他和funct3相同
    store_op : 111为非store指令，其他和funct3相同
    rs1 : 寄存器1的地址
    rs2 : 寄存器2的地址
    rd : 目标寄存器的地址

*/
module ID (
    input [31:0] ins,
    output alu_src,
    output [3:0] alu_op,
    output [31:0] imm,

    output jump_en,
    output branch_en,
    output is_lui,
    output is_auipc,
    output is_jalr,
    output not_wb,
    output [2:0] load_op,
    output [2:0] store_op,
    output [4:0] rs1,
    output [4:0] rs2,
    output [4:0] rd
);

wire [6:0] opcode = ins[6:0];
wire [2:0] funct3 = ins[14:12];
wire [6:0] funct7 = ins[31:25];
wire [11:0] immi = ins[31:20];     // I型指令立即数
wire [11:0] imms = {ins[31:25],ins[11:7]};      //S型指令立即数
wire [12:0] immb = {ins[31],ins[7],ins[30:25],ins[11:8],1'b0};  //B型指令立即数
wire [19:0] immu = ins[31:12];      //U型指令立即数
wire [20:0] immj = {ins[31],ins[19:12],ins[20],ins[30:21],1'b0};    //J型指令立即数
assign rd = ins[11:7];     //目标寄存器地址
assign rs1 = ins[19:15];   //地址
assign rs2 = ins[24:20];   //地址

reg alu_src_reg,jump_en_reg,branch_en_reg,is_jalr_reg,is_lui_reg,is_auipc_reg,not_wb_reg;
reg [3:0] alu_op_reg;
reg [31:0] imm_reg;
reg [2:0] load_op_reg;
reg [2:0] store_op_reg;


always @(*) begin
    case (opcode)
        7'b0110011: begin       //R-type
            alu_src_reg = 1'b0;
            imm_reg = 32'd0;
            jump_en_reg = 1'b0; 
            branch_en_reg = 1'b0;
            is_jalr_reg = 1'b0;
            is_auipc_reg = 1'b0;
            is_lui_reg = 1'b0;
            not_wb_reg = 1'b0;
            load_op_reg = 3'b111;
            store_op_reg = 3'b111;
            case ({funct7,funct3})
                10'b0000000000: alu_op_reg = 4'b0001;  //ADD
                10'b0100000000: alu_op_reg = 4'b0010;  //SUB
                10'b0000000111: alu_op_reg = 4'b0011;  //and
                10'b0000000110: alu_op_reg = 4'b0100;  //or
                10'b0000000100: alu_op_reg = 4'b0101;  //xor
                10'b0000000001: alu_op_reg = 4'b0110;  //SLL
                10'b0000000101: alu_op_reg = 4'b0111;  //SRL
                10'b0100000101: alu_op_reg = 4'b1000;  //SRA
                10'b0000000010: alu_op_reg = 4'b1001;  //SLT
                10'b0000000011: alu_op_reg = 4'b1010;  //SLTU
                default : alu_op_reg = 4'b0000;         //无效
            endcase
        end

        7'b0010011: begin  //I-type
            imm_reg = (funct3 == 3'b001 || funct3 == 3'b101) ? 
                        {27'd0, immi[4:0]}:
                        {{20{immi[11]}}, immi};
            alu_src_reg = 1'b1;
            jump_en_reg = 1'b0;
            branch_en_reg = 1'b0;
            is_jalr_reg = 1'b0;
            is_auipc_reg = 1'b0;
            is_lui_reg = 1'b0;
            not_wb_reg = 1'b0;
            load_op_reg = 3'b111;
            store_op_reg = 3'b111;
            case (funct3)
                3'b000: alu_op_reg = 4'b0001;  //ADDI
                3'b010: alu_op_reg = 4'b1001;  //SLTI
                3'b011: alu_op_reg = 4'b1010;  //SLTIU 
                3'b100: alu_op_reg = 4'b0101;  //XORI
                3'b110: alu_op_reg = 4'b0100;  //ORI
                3'b111: alu_op_reg = 4'b0011;  //ANDI
                
                3'b001: alu_op_reg = (funct7==7'b0000000) ? 4'b0110 : 4'b0000;  //SLLI
                3'b101: alu_op_reg = (funct7==7'b0000000) ? 4'b0111 : (funct7==7'b0100000) ? 4'b1000 : 4'b0000; //SRLI or SRAI
                default: alu_op_reg = 4'b0000;
            endcase
        end

        7'b1100011: begin  //B-type
            imm_reg = {{19{immb[12]}},immb};
            alu_src_reg = 1'b0; //比较指令用两个寄存器值进行比较
            branch_en_reg = 1'b1;   //使能branch_en
            jump_en_reg = 1'b0;
            is_jalr_reg = 1'b0;
            is_auipc_reg = 1'b0;
            is_lui_reg = 1'b0;
            not_wb_reg = 1'b1;
            load_op_reg = 3'b111;
            store_op_reg = 3'b111;
            case (funct3)
                3'b000: alu_op_reg = 4'b1011;  //BEQ
                3'b001: alu_op_reg = 4'b1100;  //BNE
                3'b100: alu_op_reg = 4'b1001;  //BLT
                3'b101: alu_op_reg = 4'b1101;  //BGE
                3'b110: alu_op_reg = 4'b1010;  //BLTU
                3'b111: alu_op_reg = 4'b1110;  //BGEU
                default: alu_op_reg = 4'b0000;
            endcase
        end

        7'b1101111: begin  //JAL(J-type)
            imm_reg = {{11{immj[20]}},immj};
            alu_src_reg = 1'b1;     //使用立即数
            jump_en_reg = 1'b1;     //使能跳转
            branch_en_reg = 1'b0;
            is_jalr_reg = 1'b0;
            alu_op_reg = 4'b0000;
            is_auipc_reg = 1'b0;
            is_lui_reg = 1'b0;
            not_wb_reg = 1'b0;
            load_op_reg = 3'b111;
            store_op_reg = 3'b111;
        end

        7'b1100111: begin  //JALR(I-type)
            imm_reg = {{20{immi[11]}},immi};
            alu_src_reg = 1'b1;
            jump_en_reg = 1'b1;
            branch_en_reg = 1'b0;
            is_jalr_reg = 1'b1;
            alu_op_reg = 4'b0000;
            is_auipc_reg = 1'b0;
            is_lui_reg = 1'b0;
            not_wb_reg = 1'b0;
            load_op_reg = 3'b111;
            store_op_reg = 3'b111;
        end

        7'b0110111: begin  //LUI(U-type)
            imm_reg = {immu,12'd0};
            alu_src_reg = 1'b1;
            jump_en_reg = 1'b0;
            branch_en_reg = 1'b0;
            is_jalr_reg = 1'b0;
            alu_op_reg = 4'b0000;
            is_auipc_reg = 1'b0;
            is_lui_reg = 1'b1;
            not_wb_reg = 1'b0;
            load_op_reg = 3'b111;
            store_op_reg = 3'b111;
        end

        7'b0010111: begin  //AUIPC(U-type)
            imm_reg = {immu,12'd0};
            alu_src_reg = 1'b1;
            jump_en_reg = 1'b0;
            branch_en_reg = 1'b0;
            is_jalr_reg = 1'b0;
            alu_op_reg = 4'b0000;   //加法（pc + imm)   可以套用branch_target
            is_auipc_reg = 1'b1;
            is_lui_reg = 1'b0;
            not_wb_reg = 1'b0;
            load_op_reg = 3'b111;
            store_op_reg = 3'b111;
        end
        
        7'b0000011: begin  //load(I-type)
            imm_reg = {{20{immi[11]}},immi};
            alu_src_reg = 1'b1;
            jump_en_reg = 1'b0;
            branch_en_reg = 1'b0;
            is_jalr_reg = 1'b0;
            alu_op_reg = 4'b0001;
            is_auipc_reg = 1'b0;
            is_lui_reg = 1'b0;
            not_wb_reg = 1'b0;
            store_op_reg = 3'b111;
            load_op_reg = funct3;
        end 

        7'b0100111: begin   //store(S-type)
            imm_reg = {{20{imms[11]}},imms};
            alu_src_reg = 1'b1;
            jump_en_reg = 1'b0;
            branch_en_reg = 1'b0;
            is_jalr_reg = 1'b0;
            alu_op_reg = 4'b0001;
            is_auipc_reg = 1'b0;
            is_lui_reg = 1'b0;
            not_wb_reg = 1'b1;
            load_op_reg = 3'b111;
            store_op_reg = funct3; 
        end

        default: begin
            imm_reg = 32'd0;
            alu_src_reg = 1'b0;
            jump_en_reg = 1'b0;
            branch_en_reg =1'b0;
            alu_op_reg = 4'b0000;
            is_auipc_reg = 1'b0;
            is_lui_reg = 1'b0;
            not_wb_reg = 1'b1;
            load_op_reg = 3'b111;
            store_op_reg = 3'b111;
        end
    endcase
end

assign imm = imm_reg;
assign alu_src = alu_src_reg;
assign jump_en = jump_en_reg;
assign branch_en = branch_en_reg;
assign is_jalr = is_jalr_reg;
assign alu_op = alu_op_reg;
assign is_auipc = is_auipc_reg;
assign is_lui = is_lui_reg;
assign load_op = load_op_reg;
assign store_op = store_op_reg;
assign not_wb = not_wb_reg;

endmodule