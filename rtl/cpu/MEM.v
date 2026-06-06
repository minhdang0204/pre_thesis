module MEM (
    input  wire        clk,
    input  wire        rst_n,

    input  wire [31:0] ALUResultM,
    input  wire [31:0] WriteDataM,
    input  wire [4:0]  RdM,

    input  wire        MemReadM,
    input  wire        MemToRegM,
    input  wire        MemWriteM,
    input  wire        RegWriteM,

    output wire [31:0] ReadDataM,
    output wire [31:0] ALUResultM_out,
    output wire [4:0]  RdM_out,

    output wire        MemToRegM_out,
    output wire        RegWriteM_out
);

    assign ALUResultM_out = ALUResultM;
    assign RdM_out        = RdM;
    assign MemToRegM_out  = MemToRegM;
    assign RegWriteM_out  = RegWriteM;

    Data_Mem u_dmem (
        .clk        (clk),
        .rst_n      (rst_n),
        .MemRead    (MemReadM),
        .MemWrite   (MemWriteM),
        .Address    (ALUResultM),
        .Write_data (WriteDataM),
        .Read_data  (ReadDataM)
    );

endmodule