module mux_ahb(
    input  wire [31:0] hrdata_timer,
    input  wire        hready_timer,
    input  wire        hresp_timer,
    output wire [31:0] hrdata,
    output wire        hready,
    output wire        hresp
);

assign hrdata = hrdata_timer;
assign hready = hready_timer;
assign hresp  = hresp_timer;

endmodule