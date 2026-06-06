module Imm_Gen (
    input  wire [31:0] instr,
    input  wire [2:0]  ImmSrc, // Đổi từ 2 bits lên 3 bits tương ứng
    output reg  [31:0] imm_out
);
    always @(*) begin
        case (ImmSrc)
            3'b000: imm_out = {{20{instr[31]}}, instr[31:20]}; // Định dạng I
            3'b001: imm_out = {{20{instr[31]}}, instr[31:25], instr[11:7]}; // Định dạng S
            3'b010: imm_out = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0}; // Định dạng B
            3'b011: imm_out = {{11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0}; // Định dạng J
            3'b100: imm_out = {instr[31:12], 12'b0}; // Định dạng U (Dịch trái sẵn 12 bit cho LUI/AUIPC)
            default: imm_out = 32'b0;
        endcase
    end
endmodule

