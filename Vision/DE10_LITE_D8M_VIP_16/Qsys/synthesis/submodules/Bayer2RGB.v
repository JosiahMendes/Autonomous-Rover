/* Bayer Pattern

->	G1, R, G1, R, ....
	B, G2, B, G2, ....
	G1, R, G1, R, ....
	B, G2, B, G2, ....
	G1, R, G1, R, ....
	B, G2, B, G2, ....
	...............
	...............
	G1, R, G1, R, ....
	B, G2, B, G2, ....
	G1, R, G1, R, ....
	B, G2, B, G2, ....


	// matrix
	[0]  [1]  [2]
	[3]  [4]  [5]  
	[6]  [7]  [8]
		

*/

`define GREEN_AVG_4

module Bayer2RGB(
		reset_n,
		
		BAYER_CLK,
		BAYER_X,
		BAYER_Y,
		BAYER_DATA,
		BAYER_VALID,
		BAYER_WIDTH,
		BAYER_HEIGHT,
		
		RGB_R,
		RGB_G,
		RGB_B,
		RGB_X,
		RGB_Y,
		RGB_VALID,
		RGB_FRAME_COUNT
		
);


parameter VIDEO_W = 800;
parameter VIDEO_H = 600;

input						reset_n;

input						BAYER_CLK;
input			[11:0]		BAYER_X;
input			[11:0]		BAYER_Y;
input			[11:0]		BAYER_DATA;
input						BAYER_VALID;
input			[11:0]		BAYER_WIDTH;
input			[11:0]		BAYER_HEIGHT;

output	reg		[11:0]		RGB_R;
output	reg		[11:0]		RGB_G;
output	reg		[11:0]		RGB_B;
output	reg		[11:0]		RGB_X;
output	reg		[11:0]		RGB_Y;
output	reg					RGB_VALID;
output	reg		[19:0]		RGB_FRAME_COUNT;


////////////////////////////////////
// push into Bayer_LineBuffer
wire [11:0]	LD0, LD1, LD2;

	
	
Bayer_LineBuffer#(
          .VIDEO_W(VIDEO_W)
              ) Bayer_LineBuffer_Inst(
	.aclr(~reset_n),
	.clken(BAYER_VALID),
	.clock(BAYER_CLK),
	.shiftin(BAYER_DATA),
	.shiftout(),
	.taps({LD0, LD1, LD2})  // msb is first data
	);



////////////////////////////////////
// RGB_X, RGB_Y

always @ (posedge BAYER_CLK)
begin
	RGB_X <= BAYER_X;
	RGB_Y <= BAYER_Y;
	RGB_VALID <= BAYER_VALID;
end

reg	[13:0] D[8:0];

always @ (posedge BAYER_CLK)
begin
	D[2] <= LD0;
	D[1] <= D[2];
	D[0] <= D[1];
	//
	D[5] <= LD1;
	D[4] <= D[5];
	D[3] <= D[4];
	//
	D[8] <= LD2;
	D[7] <= D[8];
	D[6] <= D[7];
	//			
end


/////////////////////////////////////

wire [1:0] bayer_case;
////assign bayer_case = USER_CTRL?{~BAYER_Y[0], ~BAYER_X[0]}:{BAYER_Y[0], BAYER_X[0]}; // col & row inverse
//assign bayer_case = {BAYER_Y[0], BAYER_X[0]}; 
assign bayer_case = {~BAYER_Y[0], BAYER_X[0]}; // col & row inverse

//assign bayer_case = {BAYER_Y[0], ~BAYER_X[0]};  // richard try


wire [13:0] avg1_sum, avg2_sum;
wire [12:0] avg3_sum, avg4_sum;
wire [11:0] avg0, avg1, avg2, avg3, avg4;


add4 add4_avg1(
	.data0x(D[1]),
	.data1x(D[3]),
	.data2x(D[5]),
	.data3x(D[7]),
	.result(avg1_sum));

assign avg1 = avg1_sum[13:2];// >> 2; //(D[1]+D[3]+D[5]+D[7]) >> 2;
	
	
add4 add4_avg2(
	.data0x(D[0]),
	.data1x(D[2]),
	.data2x(D[6]),
	.data3x(D[8]),
	.result(avg2_sum));	
	
assign avg2 = avg2_sum[13:2];// >> 2; //(D[0]+D[2]+D[6]+D[8]) >> 2;

add2 add2_avg3(
	.data0x(D[1]),
	.data1x(D[7]),
	.result(avg3_sum));	
	
assign avg3 = avg3_sum[12:1];// >> 1; //(D[1]+D[7]) >> 1;

add2 add2_avg4(
	.data0x(D[3]),
	.data1x(D[5]),
	.result(avg4_sum));	
	
assign avg4 = avg4_sum[12:1];// >> 1; //(D[3]+D[5]) >> 1;

assign avg0 = D[4];


reg in_rgb_active_area;

always @ (posedge BAYER_CLK or negedge reset_n)
begin
	if (~reset_n)
		in_rgb_active_area <= 1'b0;
	else if ((BAYER_X >=3) && (BAYER_Y >=5) && ((BAYER_X+3) < VIDEO_W) && ((BAYER_Y+3) < VIDEO_H))
		in_rgb_active_area <= 1'b1;
	else 
		in_rgb_active_area <= 1'b0;
end

reg xfer_rgb_data;
always @ (posedge BAYER_CLK or negedge reset_n)
begin
	if (~reset_n)
		xfer_rgb_data <= 1'b0;
	else 
		xfer_rgb_data <= BAYER_VALID;
end

//Interpolating the green component
//http://www.siliconimaging.com/RGB%20Bayer.htm
/*
->	G1, R, G1, R, G1, R, ....
	B, G2, B, G2, B, G2, ....
	G1, R, G1, R, G1, R, ....
	B, G2, B, G2, B, G2, ....
	G1, R, G1, R, G1, R, ....
	B, G2, B, G2, B, G2, ....
*/	
always @ (posedge BAYER_CLK or negedge reset_n)
begin
	if (~reset_n)
		RGB_G <= 0;
	else if (xfer_rgb_data & in_rgb_active_area)
	begin
		if (bayer_case == 2'b01 || bayer_case == 2'b10)
		begin 
			RGB_G <= avg1;
		end
		else
			RGB_G <= avg0;//D[12];
	end
	else
		RGB_G <= 0;
	
end

//Interpolating red and blue components 
//http://www.siliconimaging.com/RGB%20Bayer.htm
/*
->	G1, R, G1, R, ....
	B, G2, B, G2, ....
	G1, R, G1, R, ....
	B, G2, B, G2, ....
	G1, R, G1, R, ....
	B, G2, B, G2, ....
*/	
always @ (posedge BAYER_CLK or negedge reset_n)
begin
	if (~reset_n)
	begin
		RGB_B <= 0;
		RGB_R <= 0;
	end
	else if (xfer_rgb_data & in_rgb_active_area)
	begin
		if (bayer_case == 2'b00)
		begin // case (a)
			RGB_R <= avg3;//(D[7]+D[17]) >> 1;
			RGB_B <= avg4;//(D[11]+D[13]) >> 1;
		end
		else if (bayer_case == 2'b01)
		begin // case (c)
			RGB_B <= avg0;//D[12];
			RGB_R <= avg2;//(D[6]+D[8]+D[16]+D[18]) >> 2;
		end
		else if (bayer_case == 2'b10)
		begin // case (d)
			RGB_R <= avg0;// D[12];
			RGB_B <= avg2;//(D[6]+D[8]+D[16]+D[18]) >> 2;
		end
		else if (bayer_case == 2'b11)
		begin // case (b)
			RGB_B <= avg3;//(D[7]+D[17]) >> 1;
			RGB_R <= avg4;//(D[11]+D[13]) >> 1;
		end
	end
	else
	begin
		RGB_B <= 0;
		RGB_R <= 0;
	end
end




wire FirstPixel, LastPixel;
assign FirstPixel = (RGB_X == 0  && RGB_Y == 0)?1'b1:1'b0;
assign LastPixel = (RGB_X+1 == VIDEO_W  && RGB_Y+1 == VIDEO_H)?1'b1:1'b0;

reg FindFirstPixel;
always @ (posedge BAYER_CLK or negedge reset_n)
begin
	if (~reset_n)
	begin
		RGB_FRAME_COUNT <= 0;
		FindFirstPixel <= 1'b0;
	end
	else if (RGB_VALID)
	begin
		if (FirstPixel)
			FindFirstPixel <= 1'b1;
		else if (FindFirstPixel && LastPixel)
		begin
			FindFirstPixel <= 1'b0;
			RGB_FRAME_COUNT <= RGB_FRAME_COUNT + 1;
		end
	end
end


endmodule
