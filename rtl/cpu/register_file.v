module register_file (
	input	wire		clk,
	input	wire		rst_n,
	input	wire		RegWrite,
	input	wire	[4:0]	read_register_1,
	input	wire	[4:0] 	read_register_2,
	input 	wire	[4:0]	write_register,
	input	wire	[31:0]	write_data,
	output	wire	[31:0]	read_data_1,
	output	wire	[31:0] 	read_data_2
);
	reg [31:0] Registers [31:0]; //32 32-bit registers
	
	assign read_data_1 = !rst_n ? 32'b0:
                         (read_register_1 == 5'b0) ? 32'b0 : 
                         (RegWrite && (write_register == read_register_1)) ? write_data : Registers[read_register_1];    
    
    assign read_data_2 = !rst_n ? 32'b0:
                         (read_register_2 == 5'b0) ? 32'b0 : 
                         (RegWrite && (write_register == read_register_2)) ? write_data : Registers[read_register_2];
	
	integer i;
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			for (i = 0; i < 32; i = i + 1) begin
				Registers[i] <= 32'b0;
			end
		end
		else if (RegWrite && (write_register != 5'b0)) 
			Registers[write_register] <= write_data;
		else begin
		end
	end
endmodule
