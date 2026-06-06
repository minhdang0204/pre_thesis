module IF (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        en,
    input  wire [31:0] PCTargetE,
    input  wire        PCSrcE,
    output wire [31:0] PCF,
    output wire [31:0] PCPlus4F,
    output wire [31:0] InstructionF
);
    wire [31:0] PCF_pre;

    Mux mux_PC_in (
        .a   (PCPlus4F),
        .b   (PCTargetE),
        .s   (PCSrcE),
        .out (PCF_pre)
    );

    program_counter PC (
        .clk   (clk),
        .rst_n (rst_n),
        .en    (en),
        .PC_in (PCF_pre),
        .PC_out(PCF)
    );

    Instruction_Mem IM (
        .clk            (clk),
        .rst_n          (rst_n),
        .read_address   (PCF),
        .instruction_out(InstructionF)
    );

    assign PCPlus4F = PCF + 32'd4;
endmodule