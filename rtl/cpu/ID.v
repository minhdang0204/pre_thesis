module ID (
    input   wire            clk,
    input   wire            rst_n,

    input   wire    [31:0]  PCD,
    input   wire    [31:0]  PCPlus4D,
    input   wire    [31:0]  InstructionD,
    
    // write back from WB stage
    input   wire            RegWriteW,
    input   wire    [4:0]   rdW,
    input   wire    [31:0]  ResultW,
    
    output  wire    [4:0]   Rs1D,
    output  wire    [4:0]   Rs2D,
    output  wire    [4:0]   RdD,
    output  wire    [2:0]   funct3D,
    output  wire    [6:0]   funct7D,
    
    output  wire    [31:0]  RD1D,
    output  wire    [31:0]  RD2D,
    
    output  wire    [31:0]  Imm,
    output  wire    [31:0]  PCD_out,
    output  wire    [31:0]  PCPlus4D_out,
    
    output  wire            BranchD,
    output  wire            MemReadD,
    output  wire            MemToRegD,
    output  wire            MemWriteD,
    output  wire            ALUSrcD,
    output  wire            RegWriteD,
    output  wire    [1:0]   ALUOpD,
    output  wire    [2:0]   ImmSrcD,    // SỬA THÀNH 2:0 (3 bits) tương thích Bước 1
    output  wire            jumpD,      // THÊM MỚI ngõ ra đưa sang ID_EX
    output  wire            jalr_flagD  // THÊM MỚI ngõ ra đưa sang ID_EX
);
    
    wire [6:0] OpcodeD;

    assign OpcodeD = InstructionD[6:0];
    assign funct3D = InstructionD[14:12];
    assign funct7D = InstructionD[31:25];
    assign Rs1D    = InstructionD[19:15];
    assign Rs2D    = InstructionD[24:20];
    assign RdD     = InstructionD[11:7];

    assign  PCD_out = PCD;
    assign  PCPlus4D_out = PCPlus4D;

    Control_unit CU (
        .Opcode    (OpcodeD),
        .branch    (BranchD),
        .MemRead   (MemReadD),
        .MemToReg  (MemToRegD),
        .MemWrite  (MemWriteD),
        .ALUsrc    (ALUSrcD),
        .RegWrite  (RegWriteD),
        .ALU_op    (ALUOpD),
        .ImmSrc    (ImmSrcD),     // Đã tự động nhận wire 3-bit mới
        .jump      (jumpD),       // NỐI THÊM NGÕ RA MỚI
        .jalr_flag (jalr_flagD)   // NỐI THÊM NGÕ RA MỚI
    );
    
    register_file Register(
        .clk              (clk),
        .rst_n            (rst_n),
        .RegWrite         (RegWriteW),        
        .read_register_1  (Rs1D),
        .read_register_2  (Rs2D),
        .write_register   (rdW),
        .write_data       (ResultW),
        .read_data_1      (RD1D),
        .read_data_2      (RD2D)
    );

    Imm_Gen ImmGen(
        .instr      (InstructionD),
        .ImmSrc     (ImmSrcD),    // Đã tự động nhận wire 3-bit mới
        .imm_out    (Imm)
    );
endmodule