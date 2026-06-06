module Forwarding_Unit (
    input  wire [4:0] Rs1E,
    input  wire [4:0] Rs2E,
    input  wire [4:0] RdM,
    input  wire [4:0] RdW,
    input  wire       RegWriteM,
    input  wire       RegWriteW,

    output reg  [1:0] ForwardAE,
    output reg  [1:0] ForwardBE
);

    always @(*) begin
        // Mặc định: Chọn dữ liệu trực tiếp từ Register File (chặng EX)
        ForwardAE = 2'b00;
        ForwardBE = 2'b00;

        // -----------------------------------------------------------
        // FORWARD SOURCE A
        // -----------------------------------------------------------
        // Ưu tiên 1: Hazard từ tầng MEM (Dữ liệu mới nhất từ ALU chặng trước)
        if (RegWriteM && (RdM != 5'b0) && (RdM == Rs1E)) begin
            ForwardAE = 2'b10;
        end
        // Ưu tiên 2: Hazard từ tầng WB (Dữ liệu từ RAM hoặc ALU chặng trước nữa)
        // Cần check thêm điều kiện: Tầng MEM không dùng chính thanh ghi này để tránh đè dữ liệu cũ hơn
        else if (RegWriteW && (RdW != 5'b0) && (RdW == Rs1E) && 
                 !(RegWriteM && (RdM != 5'b0) && (RdM == Rs1E))) begin
            ForwardAE = 2'b01;
        end

        // -----------------------------------------------------------
        // FORWARD SOURCE B
        // -----------------------------------------------------------
        // Ưu tiên 1: Hazard từ tầng MEM
        if (RegWriteM && (RdM != 5'b0) && (RdM == Rs2E)) begin
            ForwardBE = 2'b10;
        end
        // Ưu tiên 2: Hazard từ tầng WB
        else if (RegWriteW && (RdW != 5'b0) && (RdW == Rs2E) && 
                 !(RegWriteM && (RdM != 5'b0) && (RdM == Rs2E))) begin
            ForwardBE = 2'b01;
        end
    end

endmodule