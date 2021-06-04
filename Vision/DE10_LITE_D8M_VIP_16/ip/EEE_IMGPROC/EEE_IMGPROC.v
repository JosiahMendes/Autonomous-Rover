module EEE_IMGPROC(
	// global clock & reset
	input 	clk,
	input 	reset_n,
	
	// mm slave
	input 					s_chipselect,
	input 					s_read,
	input 					s_write,
	output 	reg 	[31:0]	s_readdata,
	input			[31:0]	s_writedata,
	input			[2:0]	s_address,

	// stream sink
	input			[23:0]	sink_data,
	input					sink_valid,
	output					sink_ready,
	input					sink_sop,
	input					sink_eop,
	
	// streaming source
	output			[23:0]	source_data,
	output					source_valid,
	input					source_ready,
	output					source_sop,
	output					source_eop,
	
	// conduit
	input					mode
	
);


////////////////////////////////////////////////////////////////////////
// Parameters
parameter IMAGE_W = 11'd640;
parameter IMAGE_H = 11'd480;
parameter MESSAGE_BUF_MAX = 256;
parameter MSG_INTERVAL = 20;
parameter BB_COL_DEFAULT = 24'h00ff00;
////////////////////////////////////////////////////////////////////////


//Wires going out to OUTPUT Streaming Register
wire [7:0]   redStreamOUT,greenStreamOUT,blueStreamOUT;
//Wires coming in from INPUT Streaming Register
wire [7:0]   redStreamIN, greenStreamIN, blueStreamIN; 

wire         in_valid, out_ready, videoPacketSOP, videoPacketEOP;


//Grayscale Conversion
wire [7:0]   grey;
assign grey = greenStreamIN[7:1] + redStreamIN[7:2] + blueStreamIN[7:2]; //Grey = green/2 + red/4 + blue/4

//HSV Conversion
wire [8:0]   hue;
wire [7:0]   saturation, value;

//Colour Detection Thresholds
wire 	     red_detect, green_detect, blue_detect, grey_detect, yellow_detect;

// Highlighting detected areas for new image
wire [23:0] detectedAreaRGB;
assign detectedAreaRGB  = red_detect ? {8'hff, 8'h0, 8'h0} : 
                        blue_detect ? {8'hCC, 8'hff, 8'hff} :
                        green_detect ? {8'h0, 8'hff, 8'h0} :
						yellow_detect ? {8'hff, 8'hff, 8'h0} :
                        grey_detect ? {8'h0, 8'h33, 8'h66} :
                        {grey, grey, grey};

// Drawing bounding box for new image
wire [23:0] new_image;
wire redBB_active, greenBB_active, blueBB_active, greyBB_active, yellowBB_active;
assign redBB_active 	= (((x == r_left) | (x == r_right)) & (r_bot >= y & y >= r_top)) | (((y == r_top) | (y == r_bot)) & (r_left <= x & x <= r_right));
assign greenBB_active 	= (((x == g_left) | (x == g_right)) & (g_bot >= y & y >= g_top)) | (((y == g_top) | (y == g_bot)) & (g_left <= x & x <= g_right));
assign blueBB_active 	= (((x == b_left) | (x == b_right)) & (b_bot >= y & y >= b_top)) | (((y == b_top) | (y == b_bot)) & (b_left <= x & x <= b_right));
assign yellowBB_active 	= (((x == y_left) | (x == y_right)) & (y_bot >= y & y >= y_top)) | (((y == y_top) | (y == y_bot)) & (y_left <= x & x <= y_right));
assign greyBB_active 	= (((x == gr_left) | (x == gr_right)) & (gr_bot >= y & y >= gr_top)) | (((y == gr_top) | (y == gr_bot)) & (gr_left <= x & x <= gr_right));
assign new_image 		= 	redBB_active	? {8'hff, 8'h00, 8'h00} : 
							blueBB_active 	? {8'hCC, 8'hff, 8'hff} :
							greenBB_active 	? {8'h00, 8'hff, 8'h00} :
							yellowBB_active ? {8'hff, 8'hff, 8'h00} :
							greyBB_active 	? {8'hff, 8'hff, 8'hff} :
							detectedAreaRGB;

// Switch output pixels depending on mode switch
// Don't modify the start-of-packet word - it's a packet discriptor
// Don't modify data in non-video packets
assign {redStreamOUT, greenStreamOUT, blueStreamOUT} = (mode & ~videoPacketSOP & packet_video) ? new_image : {redStreamIN,greenStreamIN,blueStreamIN};


//Count valid pixels to tget the image coordinates. Reset and detect packet type on Start of Packet.
reg [10:0] x, y;
reg packet_video;
always@(posedge clk) begin
	if (videoPacketSOP) begin
		x <= 11'h0;
		y <= 11'h0;
		packet_video <= (blueStreamIN[3:0] == 3'h0); // LSB = 0 means video packet being sent - @229 Piazza
	end
	else if (in_valid) begin
		if (x == IMAGE_W-1) begin
			x <= 11'h0;
			y <= y + 11'h1;
		end
		else begin
			x <= x + 11'h1;
		end
	end
end

//Find first and last red pixels
reg [10:0] r_x_min, r_y_min, r_x_max, r_y_max;
reg [10:0] g_x_min, g_y_min, g_x_max, g_y_max;
reg [10:0] b_x_min, b_y_min, b_x_max, b_y_max;
reg [10:0] gr_x_min, gr_y_min, gr_x_max, gr_y_max;
reg [10:0] y_x_min, y_y_min, y_x_max, y_y_max;
always@(posedge clk) begin
	if (in_valid) begin

        if (red_detect & in_valid) begin	//Update bounds when the pixel is red
            if (x < r_x_min) r_x_min <= x;
            if (x > r_x_max) r_x_max <= x;
            if (y < r_y_min) r_y_min <= y;
            r_y_max <= y;
        end
        else if (blue_detect & in_valid) begin	//Update bounds when the pixel is red
            if (x < b_x_min) b_x_min <= x;
            if (x > b_x_max) b_x_max <= x;
            if (y < b_y_min) b_y_min <= y;
            b_y_max <= y;
        end 
        else if (green_detect ) begin	//Update bounds when the pixel is red
            if (x < g_x_min) g_x_min <= x;
            if (x > g_x_max) g_x_max <= x;
            if (y < g_y_min) g_y_min <= y;
            g_y_max <= y;
        end
        else if (yellow_detect) begin	//Update bounds when the pixel is red
            if (x < y_x_min) y_x_min <= x;
            if (x > y_x_max) y_x_max <= x;
            if (y < y_y_min) y_y_min <= y;
            y_y_max <= y;
        end
        else if (grey_detect) begin	//Update bounds when the pixel is red
            if (x < gr_x_min) gr_x_min <= x;
            if (x > gr_x_max) gr_x_max <= x;
            if (y < gr_y_min) gr_y_min <= y;
            gr_y_max <= y;
        end

        if (videoPacketSOP) begin	//Reset bounds on start of packet
            r_x_min  <= IMAGE_W-11'h1; 	r_x_max  <= 0;	r_y_min  <= IMAGE_H-11'h1;	r_y_max <= 0;
			b_x_min  <= IMAGE_W-11'h1;  b_x_max  <= 0;	b_y_min  <= IMAGE_H-11'h1;	b_y_max <= 0;
			g_x_min  <= IMAGE_W-11'h1;	g_x_max  <= 0;	g_y_min  <= IMAGE_H-11'h1;	g_y_max <= 0;
			y_x_min  <= IMAGE_W-11'h1;	y_x_max  <= 0;	y_y_min  <= IMAGE_H-11'h1;	y_y_max <= 0;
			gr_x_min <= IMAGE_W-11'h1;	gr_x_max <= 0; 	gr_y_min <= IMAGE_H-11'h1;	gr_y_max <= 0;
        end
	end
end

//Process bounding box at the end of the frame.
reg [3:0] msg_state;
reg [10:0] r_left, r_right, r_top, r_bot;
reg [10:0] g_left, g_right, g_top, g_bot;
reg [10:0] b_left, b_right, b_top, b_bot;
reg [10:0] y_left, y_right, y_top, y_bot;
reg [10:0] gr_left, gr_right, gr_top, gr_bot;
reg [7:0] frame_count;

always@(posedge clk) begin
    if (videoPacketEOP & in_valid & packet_video) begin  //Ignore non-video packets
        //Latch edges for display overlay on next frame
        r_left 	<= r_x_min;
        r_right <= r_x_max;
        r_top 	<= r_y_min;
        r_bot 	<= r_y_max;
  
        g_left 	<= g_x_min;
        g_right <= g_x_max;
        g_top 	<= g_y_min;
        g_bot 	<= g_y_max;	

        b_left 	<= b_x_min;
        b_right <= b_x_max;
        b_top 	<= b_y_min;
        b_bot 	<= b_y_max;	

		y_left 	<= y_x_min;
        y_right <= y_x_max;
        y_top 	<= y_y_min;
        y_bot 	<= y_y_max;	

        gr_left  <= gr_x_min;
        gr_right <= gr_x_max;
        gr_top   <= gr_y_min;
        gr_bot   <= gr_y_max;	
		
		//Start message writer FSM once every MSG_INTERVAL frames, if there is room in the FIFO
		frame_count <= frame_count - 1;
		
		if (frame_count == 0 && msg_buf_size < MESSAGE_BUF_MAX - 3) begin
			msg_state <= 4'b0001;
			frame_count <= MSG_INTERVAL-1;
		end
	end
	
	//Cycle through message writer states once started
	if (msg_state != 4'b0000)
		begin
			if (msg_state == 4'b1101)  msg_state <= 4'b0000;
			else msg_state <= msg_state + 4'b0001;
		end
end
	
//Generate output messages for CPU
reg [31:0] msg_buf_in; 
wire [31:0] msg_buf_out;
reg msg_buf_wr;
wire msg_buf_rd, msg_buf_flush;
wire [7:0] msg_buf_size;
wire msg_buf_empty;

`define START_MSG_ID "RBB"
`define PIXEL_VALUE_ID  "PIX"

always@(*) begin	//Write words to FIFO as state machine advances
	case(msg_state)
		4'b0000: begin
			msg_buf_in = 32'b0;
			msg_buf_wr = 1'b0;
		end
		4'b0001: begin
			msg_buf_in = `START_MSG_ID;	//Message ID
			msg_buf_wr = 1'b1;
		end
		4'b0010: begin
			msg_buf_in = {5'b0, r_x_min, 5'b0, r_y_min};	//Top left coordinate - RED
			msg_buf_wr = 1'b1;
		end
		4'b0011: begin
			msg_buf_in = {5'b0, r_x_max, 5'b0, r_y_max}; //Bottom right coordinate - RED
			msg_buf_wr = 1'b1;
		end
		4'b0100: begin
			msg_buf_in = {5'b0, g_x_min, 5'b0, g_y_min};	//Top left coordinate - GREEN
			msg_buf_wr = 1'b1;
		end
		4'b0101: begin
			msg_buf_in = {5'b0, g_x_max, 5'b0, g_y_max}; //Bottom right coordinate - GREEN
			msg_buf_wr = 1'b1;
        end
		4'b0110: begin
			msg_buf_in = {5'b0, b_x_min, 5'b0, b_y_min};	//Top left coordinate - BLUE
			msg_buf_wr = 1'b1;
		end
		4'b0111: begin
			msg_buf_in = {5'b0, b_x_max, 5'b0, b_y_max}; //Bottom right coordinate - BLUE
			msg_buf_wr = 1'b1;
        end
		4'b1000: begin
			msg_buf_in = {5'b0, y_x_min, 5'b0, y_y_min};	//Top left coordinate - YELLOW
			msg_buf_wr = 1'b1;
		end
		4'b1001: begin
			msg_buf_in = {5'b0, y_x_max, 5'b0, y_y_max}; //Bottom right coordinate - YELLOW
			msg_buf_wr = 1'b1;
		end
		4'b1010: begin
			msg_buf_in = {5'b0, gr_x_min, 5'b0, gr_y_min};	//Top left coordinate - GREY
			msg_buf_wr = 1'b1;
		end
		4'b1011: begin
			msg_buf_in = {5'b0, gr_x_max, 5'b0, gr_y_max}; //Bottom right coordinate - GREY
			msg_buf_wr = 1'b1;
		end
		4'b1100:begin
			msg_buf_in = `PIXEL_VALUE_ID;
			msg_buf_wr = 1'b1;
		end
		4'b1101:begin
			msg_buf_in = {8'b0,redStreamIN,greenStreamIN,blueStreamIN};
			msg_buf_wr = 1'b1;
		end
		default: begin
			msg_buf_in = 32'b0;
			msg_buf_wr = 1'b0;
		end
	endcase
end


////////////////////////////////////////////////////////////////////////
//Output message FIFO
MSG_FIFO	MSG_FIFO_inst (
	.clock (clk),
	.data (msg_buf_in),
	.rdreq (msg_buf_rd),
	.sclr (~reset_n | msg_buf_flush),
	.wrreq (msg_buf_wr),
	.q (msg_buf_out),
	.usedw (msg_buf_size),
	.empty (msg_buf_empty)
	);



////////////////////////////////////////////////////////////////////////
//Streaming registers to buffer video signal
STREAM_REG #(.DATA_WIDTH(26)) in_reg (
	.clk(clk),
	.rst_n(reset_n),
	.ready_out(sink_ready),
	.valid_out(in_valid),
	.data_out({redStreamIN,greenStreamIN,blueStreamIN,videoPacketSOP,videoPacketEOP}),
	.ready_in(out_ready),
	.valid_in(sink_valid),
	.data_in({sink_data,sink_sop,sink_eop})
);



STREAM_REG #(.DATA_WIDTH(26)) out_reg (
	.clk(clk),
	.rst_n(reset_n),
	.ready_out(out_ready),
	.valid_out(source_valid),
	.data_out({source_data,source_sop,source_eop}),
	.ready_in(source_ready),
	.valid_in(in_valid),
	.data_in({redStreamOUT, greenStreamOUT, blueStreamOUT, videoPacketSOP, videoPacketEOP})
);



///////////////////////////////////////////////////////////////////////
//RGB to HSV
rgb_to_hsv rgb_hsv(
	.clk(clk),
	.rst_n(reset_n),
	.rgb_r(redStreamIN),
	.rgb_g(greenStreamIN),
	.rgb_b(blueStreamIN),	
	.hsv_h(hue),//  0 - 360
	.hsv_s(saturation),// 0- 255
	.hsv_v(value) // 0- 255
);



///////////////////////////////////////////////////////////////////////
// Color Threshold
colour_threshold ColourDetect (
	.hue(hue),//  0 - 360
	.sat(saturation),// 0- 255
	.val(value), // 0- 255
	.red_detect(red_detect),
	.green_detect(green_detect),
	.blue_detect(blue_detect),
	.grey_detect(grey_detect),
	.yellow_detect(yellow_detect)
);


/////////////////////////////////
/// Memory-mapped port		 /////
/////////////////////////////////

// Addresses
`define REG_STATUS    			0
`define READ_MSG    				1
`define READ_ID    				2
`define REG_BBCOL					3

//Status register bits
// 31:16 - unimplemented
// 15:8 - number of words in message buffer (read only)
// 7:5 - unused
// 4 - flush message buffer (write only - read as 0)
// 3:0 - unused


// Process write

reg  [7:0]   reg_status;
reg	[23:0]	bb_col;

always @ (posedge clk)
begin
	if (~reset_n)
	begin
		reg_status <= 8'b0;
		bb_col <= BB_COL_DEFAULT;
	end
	else begin
		if(s_chipselect & s_write) begin
		   if      (s_address == `REG_STATUS)	reg_status <= s_writedata[7:0];
		   if      (s_address == `REG_BBCOL)	bb_col <= s_writedata[23:0];
		end
	end
end


//Flush the message buffer if 1 is written to status register bit 4
assign msg_buf_flush = (s_chipselect & s_write & (s_address == `REG_STATUS) & s_writedata[4]);


// Process reads
reg read_d; //Store the read signal for correct updating of the message buffer

// Copy the requested word to the output port when there is a read.
always @ (posedge clk)
begin
   if (~reset_n) begin
	   s_readdata <= {32'b0};
		read_d <= 1'b0;
	end
	
	else if (s_chipselect & s_read) begin
		if   (s_address == `REG_STATUS) s_readdata <= {16'b0,msg_buf_size,reg_status};
		if   (s_address == `READ_MSG) s_readdata <= {msg_buf_out};
		if   (s_address == `READ_ID) s_readdata <= 32'h1234EEE2;
		if   (s_address == `REG_BBCOL) s_readdata <= {8'h0, bb_col};
	end
	
	read_d <= s_read;
end

//Fetch next word from message buffer after read from READ_MSG
assign msg_buf_rd = s_chipselect & s_read & ~read_d & ~msg_buf_empty & (s_address == `READ_MSG);
						


endmodule
