module ahb_slave(
    input  wire        clk,
    input  wire        hresetn,
    input  wire [31:0] hwdata,
    input  wire [31:0] haddr,
    input  wire        hsel,
    input  wire        hwrite,
    input  wire [1:0]  htrans,
    output reg  [31:0] hrdata,
    output reg         hready
);

    reg [31:0] mem[0:63];
    
    // Thanh ghi chốt thông tin từ Address Phase
    reg [31:0] haddr_reg;
    reg        hwrite_reg;
    reg        valid_data_phase;

    always @(posedge clk or negedge hresetn) begin
        if(!hresetn) begin
            haddr_reg        <= 0;
            hwrite_reg       <= 0;
            valid_data_phase <= 0;
            hready           <= 1'b1;
        end else begin
            // Address Phase: Lưu thông tin nếu Master yêu cầu transfer hợp lệ
            if (hready) begin
                haddr_reg        <= haddr;
                hwrite_reg       <= hwrite;
                valid_data_phase <= hsel && htrans[1];
            end

            // Data Phase: Thực hiện đọc/ghi dựa trên thông tin đã chốt
            if (valid_data_phase) begin
                if (hwrite_reg) begin
                    mem[haddr_reg[7:2]] <= hwdata;
                end else begin
                    hrdata <= mem[haddr_reg[7:2]];
                end
                valid_data_phase <= 1'b0; // Hoàn thành trong 1 chu kỳ (Zero-wait-state)
                hready           <= 1'b1;
            end
        end
    end
endmodule