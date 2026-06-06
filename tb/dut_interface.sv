interface dut_interface();
    logic clk;
    logic rst_n;

    // CPU MEM stage (Internal signals)
    logic [31:0] ALUResultM;
    logic [31:0] WriteDataM;
    logic [31:0] ReadDataM; // Bác nhớ thêm cả chân này để Monitor bắt được Data đọc

    // AHB Bus signals (Standard)
    logic [31:0] haddr;
    logic [31:0] hwdata;    // Dữ liệu ghi AHB
    logic [31:0] hrdata;    // Dữ liệu đọc AHB
    logic        hwrite;
    logic [1:0]  htrans;
    logic        hready;

    // Timer IRQ
    logic timer_irq;
endinterface