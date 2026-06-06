module riscv_pipeline_top (
    input wire clk,
    input wire rst_n,
    input wire bus_ready,
    // MEM stage AHB interface
    output wire [31:0] ALUResultM,   // -> HADDR
    output wire [31:0] WriteDataM,   // -> HWDATA
    output wire MemReadM,
    output wire MemWriteM,
    input  wire [31:0] ReadDataM     // <- HRDATA từ AHB master
);

    // =========================
    // Dây kết nối (Giữ nguyên phần khai báo của bác)
    // =========================
    wire [31:0] PCF, PCPlus4F, InstructionF;
    wire [31:0] PCD, PCPlus4D, InstructionD;
    wire [4:0]  Rs1D, Rs2D, RdD;
    wire [2:0]  funct3D; wire [6:0] funct7D;
    wire [31:0] RD1D, RD2D, ImmD, PCD_out, PCPlus4D_out;
    wire        BranchD, MemReadD, MemToRegD, MemWriteD, ALUSrcD, RegWriteD, jumpD, jalr_flagD;
    wire [1:0]  ALUOpD;

    wire [31:0] PCE, PCPlus4E, RD1E, RD2E, ImmExtE;
    wire [4:0]  Rs1E, Rs2E, RdE;
    wire [2:0]  funct3E; wire [6:0] funct7E;
    wire        BranchE, MemReadE, MemToRegE, MemWriteE, ALUSrcE, RegWriteE, jumpE, jalr_flagE;
    wire [1:0]  ALUOpE;

    wire [31:0] PCTargetE, ALUResultE, WriteDataE;
    wire        ZeroE, PCSrcE;
    wire [4:0]  RdE_out;
    wire        MemReadE_out, MemToRegE_out, MemWriteE_out, RegWriteE_out, jumpE_out;      

    wire [31:0] PCPlus4M; wire [4:0] RdM; wire MemToRegM, RegWriteM, jumpM;          
    wire [31:0] ALUResultM_out; wire [4:0] RdM_out; wire MemToRegM_out, RegWriteM_out;

    wire [31:0] ReadDataW, ALUResultW; wire [4:0] RdW; wire MemToRegW, RegWriteW;
    wire [31:0] PCPlus4W; wire jumpW;          
    wire [31:0] ResultW; wire [4:0] RdW_out; wire RegWriteOutW;

    wire        StallF, StallD, FlushD, FlushE;
    wire [1:0]  ForwardAE, ForwardBE;

    assign FlushD = PCSrcE; 

    // =========================
    // IF Stage
    // =========================
    IF u_if (
        .clk         (clk),
        .rst_n       (rst_n),
        .en          (~StallF && bus_ready), 
        .PCTargetE   (PCTargetE),
        .PCSrcE      (PCSrcE),
        .PCF         (PCF),
        .PCPlus4F    (PCPlus4F),
        .InstructionF(InstructionF)
    );

    // =========================
    // IF/ID Pipeline Register
    // =========================
    IF_ID u_if_id (
        .clk         (clk),
        .rst_n       (rst_n),
        .en          (~StallD && bus_ready), 
        .flush       (FlushD), 
        .PCF         (PCF),
        .PCPlus4F    (PCPlus4F),
        .InstructionF(InstructionF),
        .PCD         (PCD),
        .PCPlus4D    (PCPlus4D),
        .InstructionD(InstructionD)
    );

    // =========================
    // ID Stage
    // =========================
    ID u_id (
        .clk         (clk),
        .rst_n       (rst_n),
        .PCD         (PCD),
        .PCPlus4D    (PCPlus4D),
        .InstructionD(InstructionD),
        .RegWriteW   (RegWriteOutW),
        .rdW         (RdW_out),
        .ResultW     (ResultW),
        .Rs1D        (Rs1D),
        .Rs2D        (Rs2D),
        .RdD         (RdD),
        .funct3D     (funct3D),
        .funct7D     (funct7D),
        .RD1D        (RD1D),
        .RD2D        (RD2D),
        .Imm         (ImmD),
        .PCD_out     (PCD_out),
        .PCPlus4D_out(PCPlus4D_out),
        .BranchD     (BranchD),
        .MemReadD    (MemReadD),
        .MemToRegD   (MemToRegD),
        .MemWriteD   (MemWriteD),
        .ALUSrcD     (ALUSrcD),
        .RegWriteD   (RegWriteD),
        .ALUOpD      (ALUOpD),
        .ImmSrcD     (ImmSrcD),
        .jumpD       (jumpD),       
        .jalr_flagD  (jalr_flagD)   
    );

    // =========================
    // Hazard Detection Unit
    // =========================
    Hazard_Detection_Unit u_hdu (
        .Rs1D        (Rs1D),
        .Rs2D        (Rs2D),
        .RdE         (RdE),
        .MemReadE    (MemReadE),
        .StallF      (StallF),
        .StallD      (StallD),
        .FlushE      (FlushE)  
    );

    // =========================
    // ID/EX Pipeline Register (ĐÃ ĐỒNG BỘ CHÂN EN)
    // =========================
    ID_EX u_id_ex (
        .clk         (clk),
        .rst_n       (rst_n),
        .en          (bus_ready),         // ĐÃ KẾT NỐI VÀO PORT MỚI SỬA
        .flush       (FlushE | PCSrcE), 
        .PCD         (PCD_out),
        .PCPlus4D    (PCPlus4D_out),
        .RD1D        (RD1D),
        .RD2D        (RD2D),
        .ImmExtD     (ImmD),
        .Rs1D        (Rs1D),
        .Rs2D        (Rs2D),
        .RdD         (RdD),
        .funct3D     (funct3D),
        .funct7D     (funct7D),
        .BranchD     (BranchD),
        .MemReadD    (MemReadD),
        .MemToRegD   (MemToRegD),
        .MemWriteD   (MemWriteD),
        .ALUSrcD     (ALUSrcD),
        .RegWriteD   (RegWriteD),
        .ALUOpD      (ALUOpD),
        .jumpD       (jumpD),       
        .jalr_flagD  (jalr_flagD),  
        .PCE         (PCE),
        .PCPlus4E    (PCPlus4E),
        .RD1E        (RD1E),
        .RD2E        (RD2E),
        .ImmExtE     (ImmExtE),
        .Rs1E        (Rs1E),
        .Rs2E        (Rs2E),
        .RdE         (RdE),
        .funct3E     (funct3E),
        .funct7E     (funct7E),
        .BranchE     (BranchE),
        .MemReadE    (MemReadE),
        .MemToRegE   (MemToRegE),
        .MemWriteE   (MemWriteE),
        .ALUSrcE     (ALUSrcE),
        .RegWriteE   (RegWriteE),
        .ALUOpE      (ALUOpE),
        .jumpE       (jumpE),       
        .jalr_flagE  (jalr_flagE)   
    );

    // =========================
    // Forwarding Unit
    // =========================
    Forwarding_Unit u_fwd (
        .Rs1E        (Rs1E),
        .Rs2E        (Rs2E),
        .RdM         (RdM),
        .RdW         (RdW),
        .RegWriteM   (RegWriteM),
        .RegWriteW   (RegWriteW),
        .ForwardAE   (ForwardAE),
        .ForwardBE   (ForwardBE)
    );

    // =========================
    // EX Stage
    // =========================
    EX u_ex (
        .PCE         (PCE),
        .RD1E        (RD1E),
        .RD2E        (RD2E),
        .ImmExtE     (ImmExtE),
        .RdE         (RdE),
        .funct3E     (funct3E),
        .funct7E     (funct7E),
        .BranchE     (BranchE),
        .MemReadE    (MemReadE),
        .MemToRegE   (MemToRegE),
        .MemWriteE   (MemWriteE),
        .ALUSrcE     (ALUSrcE),
        .RegWriteE   (RegWriteE),
        .ALUOpE      (ALUOpE),
        .jumpE       (jumpE),       
        .jalr_flagE  (jalr_flagE),  
        .ForwardAE   (ForwardAE),
        .ForwardBE   (ForwardBE),
        .ALUResultM  (ALUResultM),
        .ResultW     (ResultW),
        .PCTargetE   (PCTargetE),
        .ALUResultE  (ALUResultE),
        .WriteDataE  (WriteDataE),
        .ZeroE       (ZeroE),
        .PCSrcE      (PCSrcE),
        .RdE_out     (RdE_out),
        .MemReadE_out(MemReadE_out),
        .MemToRegE_out(MemToRegE_out),
        .MemWriteE_out(MemWriteE_out),
        .RegWriteE_out(RegWriteE_out),
        .jumpE_out   (jumpE_out)    
    );

    // =========================
    // EX/MEM Pipeline Register
    // =========================
    EX_MEM u_ex_mem (
        .clk         (clk),
        .rst_n       (rst_n),
        .en          (bus_ready), 
        .PCPlus4E    (PCPlus4E),
        .ALUResultE  (ALUResultE),
        .WriteDataE  (WriteDataE),
        .RdE         (RdE_out),
        .MemReadE    (MemReadE_out),
        .MemToRegE   (MemToRegE_out),
        .MemWriteE   (MemWriteE_out),
        .RegWriteE   (RegWriteE_out),
        .jumpE       (jumpE_out),   
        .PCPlus4M    (PCPlus4M),
        .ALUResultM  (ALUResultM),
        .WriteDataM  (WriteDataM),
        .RdM         (RdM),
        .MemReadM    (MemReadM),
        .MemToRegM   (MemToRegM),
        .MemWriteM   (MemWriteM),
        .RegWriteM   (RegWriteM),
        .jumpM       (jumpM)        
    );

    // =========================
    // MEM Stage 
    // =========================
    MEM u_mem (
        .clk         (clk),
        .rst_n       (rst_n),
        .ALUResultM  (ALUResultM),
        .WriteDataM  (WriteDataM),
        .RdM         (RdM),
        .MemReadM    (MemReadM),
        .MemToRegM   (MemToRegM),
        .MemWriteM   (MemWriteM),
        .RegWriteM   (RegWriteM),
        .ReadDataM   (ReadDataM),
        .ALUResultM_out(ALUResultM_out),
        .RdM_out     (RdM_out),
        .MemToRegM_out(MemToRegM_out),
        .RegWriteM_out(RegWriteM_out)
    );

    // =========================
    // MEM/WB Pipeline Register (ĐÃ ĐỒNG BỘ CHÂN EN)
    // =========================
    MEM_WB u_mem_wb (
        .clk         (clk),
        .rst_n       (rst_n),
        .en          (bus_ready),         // ĐÃ KẾT NỐI VÀO PORT MỚI SỬA
        .ReadDataM   (ReadDataM),
        .ALUResultM  (ALUResultM_out),
        .RdM         (RdM_out),
        .PCPlus4M    (PCPlus4M),    
        .jumpM       (jumpM),       
        .MemToRegM   (MemToRegM_out),
        .RegWriteM   (RegWriteM_out),
        .ReadDataW   (ReadDataW),
        .ALUResultW  (ALUResultW),
        .RdW         (RdW),
        .PCPlus4W    (PCPlus4W),    
        .jumpW       (jumpW),       
        .MemToRegW   (MemToRegW),
        .RegWriteW   (RegWriteW)
    );

    // =========================
    // WB Stage
    // =========================
    WB u_wb (
        .ReadDataW   (ReadDataW),
        .ALUResultW  (ALUResultW),
        .RdW         (RdW),
        .MemToRegW   (MemToRegW),
        .RegWriteW   (RegWriteW),
        .PCPlus4W    (PCPlus4W),    
        .jumpW       (jumpW),       
        .ResultW     (ResultW),
        .RdW_out     (RdW_out),
        .RegWriteOutW(RegWriteOutW)
    );

endmodule