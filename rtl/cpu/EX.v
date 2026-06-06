module EX (
    input  wire [31:0] PCE,
    input  wire [31:0] RD1E,
    input  wire [31:0] RD2E,
    input  wire [31:0] ImmExtE,
    input  wire [4:0]  RdE,
    input  wire [2:0]  funct3E,
    input  wire [6:0]  funct7E,
    input  wire        BranchE,
    input  wire        MemReadE,
    input  wire        MemToRegE,
    input  wire        MemWriteE,
    input  wire        ALUSrcE,
    input  wire        RegWriteE,
    input  wire [1:0]  ALUOpE,
    input  wire        jumpE,         // THÊM MỚI ngõ vào từ ID_EX
    input  wire        jalr_flagE,    // THÊM MỚI ngõ vào từ ID_EX

    input  wire [1:0]  ForwardAE,
    input  wire [1:0]  ForwardBE,
    input  wire [31:0] ALUResultM,
    input  wire [31:0] ResultW,

    output wire [31:0] PCTargetE,
    output wire [31:0] ALUResultE,
    output wire [31:0] WriteDataE,
    output wire        ZeroE,
    output wire        PCSrcE,

    output wire [4:0]  RdE_out,
    output wire        MemReadE_out,
    output wire        MemToRegE_out,
    output wire        MemWriteE_out,
    output wire        RegWriteE_out,
    output wire        jumpE_out      // THÊM MỚI ngõ ra đưa sang EX_MEM
);

    wire [3:0]  ALUControlE;
    wire [31:0] SrcAE;
    wire [31:0] SrcBE;
    wire [31:0] RD1E_fwd;
    wire [31:0] RD2E_fwd;

    // Logic Forwarding giữ nguyên
    assign RD1E_fwd = (ForwardAE == 2'b00) ? RD1E :
                      (ForwardAE == 2'b10) ? ALUResultM :
                      (ForwardAE == 2'b01) ? ResultW :
                      RD1E;

    assign RD2E_fwd = (ForwardBE == 2'b00) ? RD2E :
                      (ForwardBE == 2'b10) ? ALUResultM :
                      (ForwardBE == 2'b01) ? ResultW :
                      RD2E;

    assign SrcAE      = RD1E_fwd;
    assign SrcBE      = (ALUSrcE) ? ImmExtE : RD2E_fwd;
    assign WriteDataE = RD2E_fwd;

    // --- ĐOẠN SỬA ĐỔI QUAN TRỌNG CHO CÁC LỆNH NHẢY ---
    
    // MUX chọn mốc tính địa chỉ đích: JALR chọn giá trị thanh ghi (đã forward), JAL/Branch chọn PCE
    wire [31:0] base_pc_or_reg;
    assign base_pc_or_reg = (jalr_flagE) ? SrcAE : PCE;

    // Bộ cộng tính toán địa chỉ nhảy thực tế
    assign PCTargetE = base_pc_or_reg + ImmExtE;

    // Bộ phát tín hiệu chuyển hướng PC: khi thỏa điều kiện Branch HOẶC gặp lệnh Jump vô điều kiện
    assign PCSrcE    = (BranchE & ZeroE) | jumpE;

    // Truyền tín hiệu điều khiển thẳng xuống tầng sau
    assign RdE_out       = RdE;
    assign MemReadE_out  = MemReadE;
    assign MemToRegE_out = MemToRegE;
    assign MemWriteE_out = MemWriteE;
    assign RegWriteE_out = RegWriteE;
    assign jumpE_out     = jumpE;      // Đẩy tín hiệu jump tiếp tục đi xuống ống pipeline

    // Khởi tạo ALU_control (cần cập nhật thêm bên trong module này cho lệnh LUI/AUIPC ở bước 4)
    ALU_control u_alu_ctrl (
        .ALU_op      (ALUOpE),
        .ALUSrc      (ALUSrcE),
        .funct7      (funct7E),
        .funct3      (funct3E),
        .ALU_control (ALUControlE)
    );

    // Khởi tạo ALU (Cần thêm ngõ vào PCE cho lệnh AUIPC ở bước 4)
    ALU u_alu (
        .A           (SrcAE),
        .B           (SrcBE),
        .PCE         (PCE),            // THÊM ĐƯỜNG TRUYỀN PC cho lệnh AUIPC
        .alu_control (ALUControlE),
        .alu_result  (ALUResultE),
        .zero        (ZeroE)
    );

endmodule