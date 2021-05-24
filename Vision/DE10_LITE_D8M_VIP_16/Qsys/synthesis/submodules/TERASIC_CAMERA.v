// Packet: follow video packet of "Avalon-ST Video Protocol" defined VIP spec.



module TERASIC_CAMERA(
	clk,
	reset_n,
	
	// streaming source interface
	st_data,
	st_valid,
	st_sop,
	st_eop,
	st_ready,



	// export
	CAMERA_D,
	CAMERA_FVAL,
	CAMERA_LVAL,
	CAMERA_PIXCLK
	
);



input		clk;
input 	reset_n;


output	  [23:0]	st_data;
output				st_valid;
output				st_sop;
output		 		st_eop;
input				st_ready;



input		      [11:0]		CAMERA_D;
input		            		CAMERA_FVAL;
input		            		CAMERA_LVAL;
input		            		CAMERA_PIXCLK;

////////////////////////////////////////////////
/*  ##lou mod
parameter VIDEO_W	= 800;
parameter VIDEO_H	= 600;
*/

parameter VIDEO_W	= 1280;
parameter VIDEO_H	= 720;
`define VIDEO_PIX_NUM	(VIDEO_W * VIDEO_H)

////////////////////////////////////////////////




wire [11:0] RGB_R,RGB_G, RGB_B;
wire [11:0] RGB_X,RGB_Y;
wire		RGB_VALID;

CAMERA_RGB CAMERA_RGB_inst( 
	.reset_n(reset_n),
	
	// Bayer Input
	.CAMERA_D(CAMERA_D),
	.CAMERA_FVAL(CAMERA_FVAL),
	.CAMERA_LVAL(CAMERA_LVAL),
	.CAMERA_PIXCLK(CAMERA_PIXCLK),
	
	// RGB Output
	.RGB_R(RGB_R),
	.RGB_G(RGB_G),
	.RGB_B(RGB_B),
	.RGB_X(RGB_X),
	.RGB_Y(RGB_Y),
	.RGB_VALID(RGB_VALID)
	
);		

defparam CAMERA_RGB_inst.VIDEO_W = VIDEO_W;		
defparam CAMERA_RGB_inst.VIDEO_H = VIDEO_H;
							


/////////////////////////////
// write rgb to fifo

reg [25:0]	 fifo_w_data;  // 1-bit sop + 1-bit eop + 24-bits data
wire fifo_w_full;
wire sop;
wire eop;
wire in_active_area;

assign sop = (RGB_X == 0 && RGB_Y == 0)?1'b1:1'b0;
assign eop = (((RGB_X+1) == VIDEO_W) && ((RGB_Y+1) == VIDEO_H))?1'b1:1'b0;

assign in_active_area = ((RGB_X < VIDEO_W) && (RGB_Y < VIDEO_H))?1'b1:1'b0;

reg fifo_w_write;
always @ (posedge CAMERA_PIXCLK or negedge reset_n)
begin
	if (~reset_n)
	begin
		fifo_w_write <= 1'b0;
		//push_fail <= 1'b0;
	end
	else if (RGB_VALID & in_active_area)
	begin
		if (!fifo_w_full)
		begin
	      fifo_w_data <= {sop,eop, RGB_B[11:4], RGB_G[11:4], RGB_R[11:4]};
			fifo_w_write <= 1'b1;
		end
		else
		begin
			fifo_w_write <= 1'b0;
		//	push_fail <= 1'b1; // fifo full !!!!!
		end
	end
	else
		fifo_w_write <= 1'b0;
end



/////////////////////////////
// read from fifo
wire 		fifo_r_empty;
wire [25:0] fifo_r_q;		
wire 		fifo_r_rdreq_ack;





/////////////////////////////
// FIFO
rgb_fifo rgb_fifo_inst(
	// write
	.data(fifo_w_data),
	.wrclk(~CAMERA_PIXCLK),
	.wrreq(fifo_w_write),
	.wrfull(fifo_w_full),
	
	// read
	.rdclk(clk),
	.rdreq(fifo_r_rdreq_ack),
	.q(fifo_r_q),
	.rdempty(fifo_r_empty),
	//
	.aclr(~reset_n)
	
	);	
	
	

///////////////////////////////
wire frame_start;
assign frame_start = fifo_r_q[25] & ~fifo_r_empty;
 
reg first_pix; 
always @ (posedge clk or negedge reset_n)
begin
	if (~reset_n)
		first_pix <= 1'b0;
	else if (send_packet_id)
		first_pix <= 1'b1;
	else
		first_pix <= 1'b0;
end	

wire send_packet_id;
assign send_packet_id = frame_start & ~first_pix;

/////////////////////////////
// flag for ready_latency=1
reg pre_ready;
always @ (posedge clk or negedge reset_n)
begin
	if (~reset_n)
		pre_ready <= 0;
	else
		pre_ready <= st_ready;
end


////////////////////////////////////
assign {st_sop, st_eop, st_data} = (send_packet_id)?{1'b1,1'b0, 24'h000000}:{1'b0, fifo_r_q[24:0]};
assign st_valid = ~fifo_r_empty & pre_ready; 
assign fifo_r_rdreq_ack = st_valid & (~send_packet_id);




endmodule
