module WB (
    input  wire [31:0] ReadDataW,
    input  wire [31:0] ALUResultW,
    input  wire [4:0]  RdW,
    input  wire        MemToRegW,
    input  wire        RegWriteW,
    input  wire [31:0] PCPlus4W,      // THÊM MỚI: Nhận địa chỉ PC+4 từ thanh ghi MEM_WB
    input  wire        jumpW,         // THÊM MỚI: Tín hiệu điều khiển từ thanh ghi MEM_WB

    output wire [31:0] ResultW,
    output wire [4:0]  RdW_out,
    output wire        RegWriteOutW
);

    wire [31:0] alu_or_mem;

    // MUX cũ: Chọn giữa dữ liệu đọc từ RAM (Data Memory) và kết quả tính từ ALU
    assign alu_or_mem   = (MemToRegW) ? ReadDataW : ALUResultW;

    // MUX mới nâng cấp: Nếu là lệnh nhảy vô điều kiện (jumpW = 1 như JAL, JALR), 
    // ép mạch chọn địa chỉ PC+4 để ghi lại vào thanh ghi đích (rd) làm liên kết (link register).
    assign ResultW      = (jumpW) ? PCPlus4W : alu_or_mem;

    assign RdW_out      = RdW;
    assign RegWriteOutW = RegWriteW;

endmodule