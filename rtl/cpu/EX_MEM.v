module EX_MEM (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        en,          // Chân Enable mới để kiểm soát Bus Stall

    input  wire [31:0] PCPlus4E,
    input  wire [31:0] ALUResultE,
    input  wire [31:0] WriteDataE,
    input  wire [4:0]  RdE,

    input  wire        MemReadE,
    input  wire        MemToRegE,
    input  wire        MemWriteE,
    input  wire        RegWriteE,
    input  wire        jumpE,       

    output reg  [31:0] PCPlus4M,
    output reg  [31:0] ALUResultM,
    output reg  [31:0] WriteDataM,
    output reg  [4:0]  RdM,

    output reg         MemReadM,
    output reg         MemToRegM,
    output reg         MemWriteM,
    output reg         RegWriteM,
    output reg         jumpM        
);

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        PCPlus4M   <= 32'b0;
        ALUResultM <= 32'b0;
        WriteDataM <= 32'b0;
        RdM        <= 5'b0;

        MemReadM   <= 1'b0;
        MemToRegM  <= 1'b0;
        MemWriteM  <= 1'b0;
        RegWriteM  <= 1'b0;
        jumpM      <= 1'b0;       
    end
    else if (en) begin // Chỉ cập nhật dữ liệu mới khi Bus sẵn sàng (en = 1)
        PCPlus4M   <= PCPlus4E;
        ALUResultM <= ALUResultE;
        WriteDataM <= WriteDataE;
        RdM        <= RdE;

        MemReadM   <= MemReadE;
        MemToRegM  <= MemToRegE;
        MemWriteM  <= MemWriteE;
        RegWriteM  <= RegWriteE;
        jumpM      <= jumpE;      
    end
    // Nếu en = 0, toàn bộ các thanh ghi trên sẽ tự động giữ nguyên giá trị cũ
end

endmodule