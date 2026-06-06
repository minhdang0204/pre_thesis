module decoder(
    input  wire hsel_in,   // chọn slave
    output reg  hsel_timer
);

always @(*) begin
    hsel_timer = hsel_in;
end

endmodule