`timescale 1ns / 1ps

module ram_tb();
reg clk, en, rst_n;
reg [3:0] we;
reg [7:0] addr;
reg [31:0] din;
wire [31:0] dout;

blk_mem_gen_0 dram(
    .clka (clk),
    .ena (en),
    .wea (we),
    .addra (addr),
    .dina (din),
    .douta (dout)
);

initial begin 
    clk = 1'b0;
    forever begin 
        #5 clk = ~clk;
    end
end

initial begin
    rst_n = 1'b0;
    #2;
    rst_n = 1'b1;
    en = 1;
end

reg [31:0] i;
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        we <= 4'b0;
        addr <= 8'b0;
        din <= 32'b0;
        i <= 32'b0;
    end
    else begin

        i <= i + 1;
        if(i < 12) begin
            //read
            we <= 4'b0;
            addr <= addr + 1;
        end
        else if(i == 12) begin
            we <= 4'b1100;
            addr <= 8'd4;
            din <= 32'h91912222;
        end
        else if(i == 13) begin
            we <= 4'b0011;
            addr <= 8'd8;
            din <= 32'h12349178;
        end
        else if(i == 14) begin
            we <= 4'b0;
            addr <= 8'b0; 
        end
        else if (i > 14) begin
            we <= 4'b0;
            addr <= addr + 1;
        end
    end
end

endmodule
