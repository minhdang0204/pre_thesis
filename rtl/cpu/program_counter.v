module program_counter (
	input	wire		clk,
	input	wire		rst_n,
	input	wire		en,
	input	wire	[31:0]	PC_in,
	output	reg	[31:0]	PC_out
);
	always @(posedge clk or negedge rst_n) begin
		if(!rst_n)
			PC_out <= 32'b0;
		else if (en)
			PC_out <= PC_in;
		else 
			PC_out <= PC_out;
	end
endmodule