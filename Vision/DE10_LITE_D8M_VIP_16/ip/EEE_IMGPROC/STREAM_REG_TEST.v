module STREAM_REG_TEST (
	input clk,
	input reset_n,
	input en_src,
	input snk_ready,
	output reg [7:0] src_data,
	output [7:0] snk_data,
	output reg [7:0] data_out,
	output reg src_valid,
	output reg_valid,
	output reg_ready
	);

always@(posedge clk) begin
	if (~reset_n) begin
		src_data <= 8'h0;
		src_valid <= 1'b0;
	end
	else begin
		src_valid <= 1'b0;
		if (en_src & reg_ready) begin
			src_data = src_data + 8'h1;
			src_valid <= 1'b1;
		end
	end
end
	

	STREAM_REG #(.DATA_WIDTH(8)) SR0 (
		.clk(clk),
		.rst_n(reset_n),
		.ready_out(reg_ready),
		.valid_out(reg_valid),
		.data_out(snk_data),
		.ready_in(snk_ready),
		.valid_in(src_valid),
		.data_in(src_data)
	);
	
always@(posedge clk) begin
	if (~reset_n) begin
		data_out <= 8'h0;
	end
	else begin
		if (reg_valid) begin
			data_out <= snk_data;
		end
	end
end

endmodule
