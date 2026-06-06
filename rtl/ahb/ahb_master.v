module ahb_master (
    input  wire        clk,
    input  wire        hresetn,
    input  wire        enable,        
    input  wire        hready_in,     
    input  wire        hresp_in,      
    input  wire [31:0] hrdata_in,     

    input  wire [31:0] in_hwdata,    // Dữ liệu từ CPU (Data phase)
    input  wire [31:0] in_haddr,     // Địa chỉ từ CPU (Addr phase)
    input  wire        in_hwrite,    

    output reg  [31:0] hwdata,
    output reg  [31:0] haddr,
    output reg         hwrite,
    output reg  [1:0]  htrans,
    output reg  [31:0] out_hrdata
);

    // Cần bộ đệm chốt dữ liệu ghi cho Data Phase
    reg [31:0] hwdata_buf;
    reg        write_data_phase;

    typedef enum reg [1:0] {IDLE=2'b00, NONSEQ_STATE=2'b01} state_t;
    state_t state;

    always @(posedge clk or negedge hresetn) begin
        if(!hresetn) begin
            state            <= IDLE;
            haddr            <= 32'h0;
            hwrite           <= 1'b0;
            htrans           <= 2'b00; // IDLE
            hwdata           <= 32'h0;
            write_data_phase <= 1'b0;
        end else begin
            if (hready_in) begin
                // Xử lý Data Phase từ chu kỳ trước
                if (write_data_phase) begin
                    hwdata           <= hwdata_buf;
                    write_data_phase <= 1'b0;
                end
                
                // Đọc dữ liệu về cho CPU khi Slave sẵn sàng
                if (htrans == 2'b10 && !hwrite) begin
                    out_hrdata <= hrdata_in;
                end

                // Xử lý Address Phase mới
                if(enable) begin
                    haddr            <= in_haddr;
                    hwrite           <= in_hwrite;
                    htrans           <= 2'b10; // NONSEQ
                    hwdata_buf       <= in_hwdata;
                    write_data_phase <= in_hwrite;
                    state            <= NONSEQ_STATE;
                end else begin
                    htrans           <= 2'b00; // IDLE
                    state            <= IDLE;
                end
            end
        end
    end
endmodule