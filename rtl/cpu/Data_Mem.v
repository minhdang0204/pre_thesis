module Data_Mem (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        MemRead,
    input  wire        MemWrite,
    input  wire [31:0] Address,
    input  wire [31:0] Write_data,
    output wire [31:0] Read_data
);
    reg [31:0] Dmem [63:0];
    integer k;

  wire [5:0] idx;
  assign idx = Address[7:2]; // 64 words -> 6-bit index

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (k = 0; k < 64; k = k + 1)
                Dmem[k] <= 32'b0;
        end else if (MemWrite) begin
            Dmem[idx] <= Write_data;
        end
    end

    assign Read_data = (MemRead) ? Dmem[idx] : 32'b0;

endmodule