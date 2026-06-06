module ALU (
    input  wire [31:0] A,
    input  wire [31:0] B,
    input  wire [31:0] PCE,         // THÊM MỚI ngõ vào PC từ tầng EX
    input  wire [3:0]  alu_control,
    output reg  [31:0] alu_result,  // Chuyển sang reg để viết trong block always
    output wire        zero
);

    always @(*) begin
        case (alu_control)
            4'b0000: alu_result = A & B;          // AND
            4'b0001: alu_result = A | B;          // OR
            4'b0010: alu_result = A + B;          // ADD (Normal)
            4'b0110: alu_result = A - B;          // SUB
            4'b0111: alu_result = B;              // THÊM MỚI (LUI): Lấy trực tiếp hằng số hự lớn ImmExt
            4'b0011: alu_result = PCE + B;        // THÊM MỚI (AUIPC): Lấy PC cộng với ImmExt
            // Bạn có thể bổ sung các phép toán dịch bit cũ của bạn ở đây nếu cần:
            4'b1000: alu_result = A << B[4:0];    // SLL
            4'b1010: alu_result = ($signed(A) < $signed(B)) ? 32'b1 : 32'b0; // SLT
            4'b1011: alu_result = (A < B) ? 32'b1 : 32'b0;                   // SLTU
            4'b1100: alu_result = A ^ B;          // XOR
            4'b1101: alu_result = A >> B[4:0];    // SRL
            4'b1111: alu_result = $signed(A) >>> B[4:0]; // SRA
            default: alu_result = 32'b0;
        endcase
    end

    assign zero = (alu_result == 32'b0);
endmodule