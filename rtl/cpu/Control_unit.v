module Control_unit (
    input  wire [6:0] Opcode,
    output reg        branch,
    output reg        MemRead,
    output reg        MemToReg,
    output reg        MemWrite,
    output reg        ALUsrc,
    output reg        RegWrite,
    output reg [1:0]  ALU_op,
    output reg [2:0]  ImmSrc,     // Mở rộng từ 2 bits lên 3 bits
    output reg        jump,       // Tín hiệu mới: Bật lên 1 khi là JAL hoặc JALR
    output reg        jalr_flag   // Tín hiệu mới: Bật lên 1 riêng cho JALR
);

    always @(*) begin
        // Giá trị mặc định cho tất cả các tín hiệu để tránh tạo ra Latch (mạch chốt) ngoài ý muốn
        branch    = 1'b0; MemRead  = 1'b0; MemToReg  = 1'b0; MemWrite = 1'b0;
        ALUsrc    = 1'b0; RegWrite = 1'b0; ALU_op    = 2'b00; ImmSrc  = 3'b000;
        jump      = 1'b0; jalr_flag = 1'b0;

        case (Opcode)
            7'b0110011: begin // R-type (add, sub, or, and,...)
                RegWrite = 1'b1; ALU_op = 2'b10;
            end
            7'b0010011: begin // I-type ALU (addi, xori, slli,...)
                RegWrite = 1'b1; ALUsrc = 1'b1; ALU_op = 2'b10; ImmSrc = 3'b000;
            end
            7'b0000011: begin // Load (lw)
                RegWrite = 1'b1; MemRead = 1'b1; MemToReg = 1'b1; ALUsrc = 1'b1; ImmSrc = 3'b000;
            end
            7'b0100011: begin // Store (sw)
                MemWrite = 1'b1; ALUsrc = 1'b1; ImmSrc = 3'b001; // Kiểu S
            end
            7'b1100011: begin // Branch (beq, bne, blt,...)
                branch = 1'b1; ALU_op = 2'b01; ImmSrc = 3'b010; // Kiểu B
            end
            7'b1101111: begin // JAL (Jump and Link)
                RegWrite = 1'b1; jump = 1'b1; ImmSrc = 3'b011; // Kiểu J
            end
            7'b1100111: begin // JALR (Jump and Link Register)
                RegWrite = 1'b1; ALUsrc = 1'b1; jump = 1'b1; jalr_flag = 1'b1; ImmSrc = 3'b000; // Kiểu I
            end
            7'b0110111: begin // LUI (Load Upper Immediate)
                RegWrite = 1'b1; ALUsrc = 1'b1; ALU_op = 2'b11; ImmSrc = 3'b100; // Kiểu U
            end
            7'b0010111: begin // AUIPC (Add Upper Immediate to PC)
                RegWrite = 1'b1; ALUsrc = 1'b1; ALU_op = 2'b11; ImmSrc = 3'b100; // Kiểu U
            end
            default: ;
        endcase
    end
endmodule