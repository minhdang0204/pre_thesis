module IF_ID (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        en,
    input  wire        flush,
    input  wire [31:0] PCF,
    input  wire [31:0] PCPlus4F,
    input  wire [31:0] InstructionF,
    output reg  [31:0] PCD,
    output reg  [31:0] PCPlus4D,
    output reg  [31:0] InstructionD
);
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            PCD          <= 32'b0;
            PCPlus4D     <= 32'b0;
            InstructionD <= 32'b0;
        end
        else if (flush) begin
            PCD          <= 32'b0;
            PCPlus4D     <= 32'b0;
            InstructionD <= 32'b0;
        end
        else if (en) begin
            PCD          <= PCF;
            PCPlus4D     <= PCPlus4F;
            InstructionD <= InstructionF;
        end
    end
endmodule