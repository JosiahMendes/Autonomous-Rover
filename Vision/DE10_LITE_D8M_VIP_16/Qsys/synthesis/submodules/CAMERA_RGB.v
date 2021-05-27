module CAMERA_RGB(
	reset_n,
	
	// Bayer Input
	CAMERA_D,
	CAMERA_FVAL,
	CAMERA_LVAL,
	CAMERA_PIXCLK,
	
	// RGB Output
	RGB_R,
	RGB_G,
	RGB_B,
	RGB_X,
	RGB_Y,
	RGB_VALID
	
	
);


input		          		reset_n;

input		    [11:0]		CAMERA_D;
input		          		CAMERA_FVAL;
input		          		CAMERA_LVAL;
input		          		CAMERA_PIXCLK;

output			[11:0]		RGB_R;
output			[11:0]		RGB_G;
output			[11:0]		RGB_B;
output			[11:0]		RGB_X;
output			[11:0]		RGB_Y;
output						RGB_VALID;

////////////////////////////////////////////////

/*  ##lou mod
parameter VIDEO_W	= 800;
parameter VIDEO_H	= 600;
*/

parameter VIDEO_W	= 1280;
parameter VIDEO_H	= 720;

////////////////////////////////////
wire		[11:0]		BAYER_X;
wire		[11:0]		BAYER_Y;
wire		[11:0]		BAYER_DATA;
wire					BAYER_VALID;

CAMERA_Bayer CAMERA_Bayer_inst(
	.reset_n(reset_n),
	
	.CAMERA_D(CAMERA_D),
	.CAMERA_FVAL(CAMERA_FVAL),
	.CAMERA_LVAL(CAMERA_LVAL),
	.CAMERA_PIXCLK(CAMERA_PIXCLK),
	
	.BAYER_X(BAYER_X),
	.BAYER_Y(BAYER_Y),
	.BAYER_DATA(BAYER_DATA),
	.BAYER_VALID(BAYER_VALID),
	.BAYER_WIDTH(),
	.BAYER_HEIGH()
);



Bayer2RGB Bayer2RGB_inst(
		.reset_n(reset_n),
		
		.BAYER_CLK(CAMERA_PIXCLK),
		.BAYER_X(BAYER_X),
		.BAYER_Y(BAYER_Y),
		.BAYER_DATA(BAYER_DATA),
		.BAYER_VALID(BAYER_VALID),
		.BAYER_WIDTH(),
		.BAYER_HEIGH(),
		
		.RGB_R(RGB_R),
		.RGB_G(RGB_G),
		.RGB_B(RGB_B),
		.RGB_X(RGB_X),
		.RGB_Y(RGB_Y),
		.RGB_VALID(RGB_VALID)
		
);

defparam Bayer2RGB_inst.VIDEO_W = VIDEO_W;		
defparam Bayer2RGB_inst.VIDEO_H = VIDEO_H;


endmodule

