module Mux (
	input	wire 	[31:0]	a,
	input	wire	[31:0]	b,
	input	wire		s,
	output	wire	[31:0]	out
);
	assign out = (~s) ? a : b;
endmodule
