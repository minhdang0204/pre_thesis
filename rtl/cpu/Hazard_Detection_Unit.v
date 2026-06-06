module Hazard_Detection_Unit (
    input  wire [4:0] Rs1D,
    input  wire [4:0] Rs2D,
    input  wire [4:0] RdE,
    input  wire       MemReadE,

    output wire       StallF,
    output wire       StallD,
    output wire       FlushE
);

    wire lwStall;

    // Phát hiện xung đột Load-Use: Lệnh trước là Load (MemReadE = 1) và đích RdE trùng với nguồn của lệnh sau
    assign lwStall = MemReadE && (RdE != 5'b0) &&
                     ((RdE == Rs1D) || (RdE == Rs2D));

    assign StallF = lwStall;
    assign StallD = lwStall;
    assign FlushE = lwStall; // Tạo bong bóng (bubble) xóa lệnh ở chặng EX

endmodule