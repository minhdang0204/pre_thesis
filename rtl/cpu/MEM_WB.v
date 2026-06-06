module MEM_WB (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        en,         // THÊM MỚI: Khống chế Stall từ bus

    input  wire [31:0] ReadDataM,
    input  wire [31:0] ALUResultM,
    input  wire [4:0]  RdM,
    input  wire [31:0] PCPlus4M,   
    input  wire        jumpM,      

    input  wire        MemToRegM,
    input  wire        RegWriteM,

    output reg  [31:0] ReadDataW,
    output reg  [31:0] ALUResultW,
    output reg  [4:0]  RdW,
    output reg  [31:0] PCPlus4W,   
    output reg         jumpW,      

    output reg         MemToRegW,
    output reg         RegWriteW
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            ReadDataW  <= 32'b0;
            ALUResultW <= 32'b0;
            RdW        <= 5'b0;
            PCPlus4W   <= 32'b0;   
            jumpW      <= 1'b0;    
            MemToRegW  <= 1'b0;
            RegWriteW  <= 1'b0;
        end
        else if (en) begin // Chỉ cho phép đẩy dữ liệu sang chặng WB khi bus xong việc (en = 1)
            ReadDataW  <= ReadDataM;
            ALUResultW <= ALUResultM;
            RdW        <= RdM;
            PCPlus4W   <= PCPlus4M; 
            jumpW      <= jumpM;    
            MemToRegW  <= MemToRegM;
            RegWriteW  <= RegWriteM;
        end
        // Ngược lại nếu en = 0: đóng băng chặng WB, giữ nguyên dữ liệu cũ để tránh ghi đè Register File bậy
    end

endmodule