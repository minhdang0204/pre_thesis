module top_soc (
    input  wire clk,
    input  wire rst_n,
    output wire timer_irq,

    // ==========================================================
    // OUTPUT SIGNALS FOR MONITOR / TESTBENCH (ĐÃ CẬP NHẬT CHUẨN AHB)
    // ==========================================================
    output wire [1:0]  htrans_out,     // Trạng thái bus (IDLE, NONSEQ)
    output wire        hwrite_out,     // THÊM MỚI: Biết chu kỳ là ĐỌC hay GHI
    output wire [31:0] haddr_out,      // THÊM MỚI: Địa chỉ thực tế trên bus AHB (Thay vì ALUResultM)
    output wire [31:0] hwdata_out,     // THÊM MỚI: Data ghi thực tế từ AHB Master
    output wire [31:0] hrdata_out,     // THÊM MỚI: Data đọc từ ngoại vi trả về CPU
    output wire        hready_out      // Sẵn sàng của bus (Kiểm soát Stall/Data Phase)
);

    // =================================================
    // CPU pipelined
    // =================================================
    wire [31:0] ALUResultM;
    wire [31:0] WriteDataM;
    wire MemReadM, MemWriteM;
    wire [31:0] ReadDataM;
    wire hready_bridge; 

    riscv_pipeline_top cpu (
        .clk(clk),
        .rst_n(rst_n),
        .bus_ready(hready_bridge), 
        .ALUResultM(ALUResultM),
        .WriteDataM(WriteDataM),
        .MemReadM(MemReadM),
        .MemWriteM(MemWriteM),
        .ReadDataM(ReadDataM)
    );

    // =================================================
    // AHB Master / Control Signals
    // =================================================
    wire [31:0] haddr, hwdata;
    wire [1:0]  htrans;
    wire        hwrite;
    wire [31:0] hrdata_timer; 
    wire        hready_timer; 

    ahb_master master (
        .clk(clk),
        .hresetn(rst_n),
        .enable(MemReadM | MemWriteM),
        .hready_in(hready_bridge),    
        .hresp_in(1'b0),
        .hrdata_in(hrdata_timer),
        .in_hwdata(WriteDataM),
        .in_haddr(ALUResultM),
        .in_hwrite(MemWriteM),
        .hwdata(hwdata),
        .haddr(haddr),
        .hwrite(hwrite),
        .htrans(htrans),
        .out_hrdata(ReadDataM)
    );

    // ==========================================================
    // AHB-TO-APB BRIDGE CHUẨN
    // ==========================================================
    wire [11:0] apb_paddr;
    wire        apb_pwrite;
    wire        apb_psel;
    wire        apb_penable;
    wire [31:0] apb_pwdata;

    reg [11:0] paddr_reg;
    reg        pwrite_reg;

    typedef enum reg [1:0] {
        ST_IDLE   = 2'b00,
        ST_SETUP  = 2'b01,
        ST_ACCESS = 2'b10
    } bridge_state_t;

    bridge_state_t state;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state      <= ST_IDLE;
            paddr_reg  <= 12'h0;
            pwrite_reg <= 1'b0;
        end else begin
            case (state)
                ST_IDLE: begin
                    if (htrans[1]) begin 
                        paddr_reg  <= haddr[11:0];
                        pwrite_reg <= hwrite;
                        state      <= ST_SETUP;
                    end
                end
                ST_SETUP: begin
                    state <= ST_ACCESS;
                end
                ST_ACCESS: begin
                    if (hready_timer) begin
                        if (htrans[1]) begin
                            paddr_reg  <= haddr[11:0];
                            pwrite_reg <= hwrite;
                            state      <= ST_SETUP; 
                        end else begin
                            state      <= ST_IDLE;  
                        end
                    end
                end
                default: state <= ST_IDLE;
            endcase
        end
    end

    assign apb_psel    = (state == ST_SETUP) || (state == ST_ACCESS);
    assign apb_penable = (state == ST_ACCESS);
    assign apb_paddr   = paddr_reg;
    assign apb_pwrite  = pwrite_reg;
    assign apb_pwdata  = hwdata; 

    assign hready_bridge = (state == ST_IDLE) || (state == ST_ACCESS && hready_timer);

    // =================================================
    // Timer APB Peripheral
    // =================================================
    wire [31:0] tim_prdata_local; 

    timer_top u_timer (
        .sys_clk(clk),
        .sys_rst_n(rst_n),
        .tim_psel(apb_psel),
        .tim_pwrite(apb_pwrite),
        .tim_penable(apb_penable),
        .tim_paddr(apb_paddr),
        .tim_pwdata(apb_pwdata),
        .tim_pstrb(4'b1111),
        .dbg_mode(1'b0),
        .tim_prdata(tim_prdata_local), 
        .tim_pready(hready_timer), 
        .tim_pslverr(), 
        .tim_int(timer_irq)
    );

    assign hrdata_timer = tim_prdata_local;

    // ==========================================================
    // CONNECT OUTPUTS FOR MONITOR (ĐÃ CHỈNH SỬA KẾT NỐI CHUẨN)
    // ==========================================================
    assign htrans_out     = htrans;
    assign hwrite_out     = hwrite;
    assign haddr_out      = haddr;        // Lấy từ AHB Master (đúng chuẩn bus HADDR)
    assign hwdata_out     = hwdata;       // Lấy từ AHB Master (đúng chuẩn bus HWDATA)
    assign hrdata_out     = ReadDataM;    // Dữ liệu đọc ngược về CPU (đúng chuẩn bus HRDATA)
    assign hready_out     = hready_bridge; 

endmodule