/*
取指令模块
正常情况下pc+4，遇到分支或者跳转语句需要重新定pc
input:
rst_n           //复位
curr_pc         //当前pc
jump_taken      //都是EX输出
jump_target
branch_taken
branch_target

output:
next_pc     //下一位pc
irom_addr   //取指地址
*/

module IF (
    input rst_n,
    input [31:0] curr_pc,
    input jump_taken,
    input [31:0] jump_target,
    input branch_taken,
    input [31:0] branch_target,
    input is_LAR,
    output [31:0] next_pc,
    output [31:0] irom_addr
);

assign irom_addr = (rst_n) ? curr_pc : 32'b0;
assign next_pc = jump_taken ? jump_target : 
                branch_taken ? branch_target :
                // is_LAR ? curr_pc - 8: 
                curr_pc + 4;
endmodule