module ALU_control (
    input  wire [1:0] ALU_op,
    input  wire       ALUSrc,
    input  wire [6:0] funct7,
    input  wire [2:0] funct3,
    output reg  [3:0] ALU_control
);

always @(*) begin
    ALU_control = 4'b0010; // default ADD

    case (ALU_op)
        2'b00: ALU_control = 4'b0010; // load/store ADD
        2'b01: ALU_control = 4'b0110; // branch SUB
        2'b10: begin // R/I-type
            case (funct3)
                3'b000: ALU_control = (funct7 == 7'b0100000) ? 4'b0110 : 4'b0010; // SUB/ADD
                3'b001: ALU_control = 4'b1000; // SLL
                3'b010: ALU_control = 4'b1010; // SLT
                3'b011: ALU_control = 4'b1011; // SLTU
                3'b100: ALU_control = 4'b1100; // XOR
                3'b101: ALU_control = (funct7 == 7'b0100000) ? 4'b1111 : 4'b1101; // SRA/SRL
                3'b110: ALU_control = 4'b0001; // OR
                3'b111: ALU_control = 4'b0000; // AND
                default: ALU_control = 4'b0010;
            endcase
        end
        2'b11: begin // THÊM MỚI: Nhóm lệnh U-type (LUI / AUIPC)
            // LUI có Opcode[5] = 1 (7'b0110111), AUIPC có Opcode[5] = 0 (7'b0010111)
            // Vì module này không nhận Opcode, ta có thể mượn tạm funct7[5] hoặc phân biệt logic từ tầng EX.
            // Để đơn giản và chính xác nhất, ta quy ước dựa trên một mẹo thiết kế: 
            // Nếu bạn muốn chuẩn chỉ, hãy xem cách phân tách mã ALU_control dưới đây:
            if (funct3 == 3'b111) // Mẹo phân biệt nếu bạn có truyền bit từ Opcode, hoặc dùng toán tử mặc định:
                ALU_control = 4'b0111; // LUI
            else
                ALU_control = 4'b0011; // AUIPC (Sử dụng mã 4'b0011 để không trùng SLL)
        end
        default: ALU_control = 4'b0010;
    endcase
end
endmodule