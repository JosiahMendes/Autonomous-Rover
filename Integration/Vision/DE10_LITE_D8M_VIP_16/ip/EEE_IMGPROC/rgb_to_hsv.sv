module  rgb_to_hsv(
	input   logic           clk,	
	input   logic           rst_n,
	input   logic   [7:0]   rgb_r, rgb_g, rgb_b,
	output  logic   [7:0]   hsv_h,                  // 0 - 255
	output  logic   [7:0]   hsv_s,                  // 0 - 255
	output  logic   [7:0]   hsv_v,                   // 0 - 255
	output  logic   [15:0]  div1_out,
	output logic    [15:0]  div1_num,
	output logic    [15:0]  div2_num,
	output logic    [7:0]   div1_denom,
	output logic     [7:0]  div2_denom,
	output  logic   [15:0]  div2_out,
	output  logic   [15:0]  div7_out,
	output  logic   [15:0]  div8_out,
	output 	logic  [7:0]    hue_diff,
	output logic    [15:0] hue43_diff,
	output logic     [2:0]  stateOut,
	output logic     [1:0]  MaxRGB,
	output logic     [7:0]  rgbMaxHold,
	output logic     [7:0]  rgbDiffHold
);

//Find Maximum and Minimums of RGB values

logic r_isMAX, g_isMAX, b_isMAX;
logic [7:0] rgb_MAX, rgb_MIN, rgb_DIF;
logic [7:0] rgb_MAXHold0, rgb_MAXHold1, rgb_MAXHold2, rgb_MAXHold3, rgb_MAXHold4, rgb_MAXHold5;
logic [7:0] rgb_DIFHold0, rgb_DIFHold1, rgb_DIFHold2, rgb_DIFHold3, rgb_DIFHold4, rgb_DIFHold5;
logic [7:0] hue_DIF;

assign r_isMAX = (rgb_MAX == rgb_r);
assign g_isMAX = (rgb_MAX == rgb_g);
assign b_isMAX = (rgb_MAX == rgb_b);
assign hue_diff = hue_DIF;
assign rgbMaxHold = rgb_MAXHold0;
assign rgbDiffHold = rgb_DIFHold0;

assign rgb_MAX =    (rgb_r > rgb_g) ?
                    (rgb_r > rgb_b ? rgb_r : rgb_b) :
                    (rgb_g > rgb_b ? rgb_g : rgb_b);

assign rgb_MIN =    (rgb_r < rgb_g) ?
                    (rgb_r < rgb_b ? rgb_r : rgb_b) :
                    (rgb_g < rgb_b ? rgb_g : rgb_b);

assign rgb_DIF =    rgb_MAX-rgb_MIN;

assign hue_DIF =    (r_isMAX) ?   (rgb_g - rgb_b) :
                    (g_isMAX) ?   (rgb_b - rgb_r) :
                                  (rgb_r - rgb_g);

logic[15:0] rgb_DIF255, hue_DIF43;

always_comb begin
    rgb_DIF255 = 8'd255*rgb_DIF;
    hue_DIF43 = $signed(7'd43)*$signed(hue_DIF);
end

always_comb begin
	if(state ==3'd0) begin
		divider1InA = rgb_MAX;
		divider1InB = rgb_DIF255;
		divider7InA = rgb_DIF;
		divider7InB = hue_DIF43;
		divider2InA = 0;
		divider2InB = 0;
		divider3InA = 0;
		divider3InB = 0;
		divider4InA = 0;
		divider4InB = 0;
		divider5InA = 0;
		divider5InB = 0;
		divider6InA = 0;
		divider6InB = 0;
		divider8InA = 0;
		divider8InB = 0;
		divider9InA = 0;
		divider9InB = 0;
		divider10InA = 0;
		divider10InB = 0;
		divider11InA = 0;
		divider11InB = 0;
		divider12InA = 0;
		divider12InB = 0;
	end else if (state == 3'd1) begin
		divider2InA = rgb_MAX;
		divider2InB = rgb_DIF255;
		divider8InA = rgb_DIF;
		divider8InB = hue_DIF43;
		divider1InA = 0;
		divider1InB = 0;
		divider3InA = 0;
		divider3InB = 0;
		divider4InA = 0;
		divider4InB = 0;
		divider5InA = 0;
		divider5InB = 0;
		divider6InA = 0;
		divider6InB = 0;
		divider7InA = 0;
		divider7InB = 0;
		divider9InA = 0;
		divider9InB = 0;
		divider10InA = 0;
		divider10InB = 0;
		divider11InA = 0;
		divider11InB = 0;
		divider12InA = 0;
		divider12InB = 0;
	end else if (state == 3'd2) begin
		divider3InA = rgb_MAX;
		divider3InB = rgb_DIF255;
		divider9InA = rgb_DIF;
		divider9InB = hue_DIF43;
		divider1InA = 0;
		divider1InB = 0;
		divider2InA = 0;
		divider2InB = 0;
		divider4InA = 0;
		divider4InB = 0;
		divider5InA = 0;
		divider5InB = 0;
		divider6InA = 0;
		divider6InB = 0;
		divider7InA = 0;
		divider7InB = 0;
		divider8InA = 0;
		divider8InB = 0;
		divider10InA = 0;
		divider10InB = 0;
		divider11InA = 0;
		divider11InB = 0;
		divider12InA = 0;
		divider12InB = 0;
	end else if (state == 3'd3) begin
		divider4InA = rgb_MAX;
		divider4InB = rgb_DIF255;
		divider10InA = rgb_DIF;
		divider10InB = hue_DIF43;
		divider1InA = 0;
		divider1InB = 0;
		divider2InA = 0;
		divider2InB = 0;
		divider3InA = 0;
		divider3InB = 0;
		divider5InA = 0;
		divider5InB = 0;
		divider6InA = 0;
		divider6InB = 0;
		divider7InA = 0;
		divider7InB = 0;
		divider8InA = 0;
		divider8InB = 0;
		divider9InA = 0;
		divider9InB = 0;
		divider11InA = 0;
		divider11InB = 0;
		divider12InA = 0;
		divider12InB = 0;
	end else if (state == 3'd4) begin
		divider5InA = rgb_MAX;
		divider5InB = rgb_DIF255;
		divider11InA = rgb_DIF;
		divider11InB = hue_DIF43;
		divider1InA = 0;
		divider1InB = 0;
		divider2InA = 0;
		divider2InB = 0;
		divider3InA = 0;
		divider3InB = 0;
		divider4InA = 0;
		divider4InB = 0;
		divider6InA = 0;
		divider6InB = 0;
		divider7InA = 0;
		divider7InB = 0;
		divider8InA = 0;
		divider8InB = 0;
		divider9InA = 0;
		divider9InB = 0;
		divider10InA = 0;
		divider10InB = 0;
		divider12InA = 0;
		divider12InB = 0;
	end else if (state == 3'd5) begin
		divider6InA = rgb_MAX;
		divider6InB = rgb_DIF255;
		divider12InA = rgb_DIF;
		divider12InB = hue_DIF43;
		divider1InA = 0;
		divider1InB = 0;
		divider2InA = 0;
		divider2InB = 0;
		divider3InA = 0;
		divider3InB = 0;
		divider4InA = 0;
		divider4InB = 0;
		divider5InA = 0;
		divider5InB = 0;
		divider7InA = 0;
		divider7InB = 0;
		divider8InA = 0;
		divider8InB = 0;
		divider9InA = 0;
		divider9InB = 0;
		divider10InA = 0;
		divider10InB = 0;
		divider11InA = 0;
		divider11InB = 0;
	end else begin
		divider1InA = 0;
		divider1InB = 0;
		divider2InA = 0;
		divider2InB = 0;
		divider3InA = 0;
		divider3InB = 0;
		divider4InA = 0;
		divider4InB = 0;
		divider5InA = 0;
		divider5InB = 0;
		divider6InA = 0;
		divider6InB = 0;
		divider7InA = 0;
		divider7InB = 0;
		divider8InA = 0;
		divider8InB = 0;
		divider9InA = 0;
		divider9InB = 0;
		divider10InA = 0;
		divider10InB = 0;
		divider11InA = 0;
		divider11InB = 0;
		divider12InA = 0;
		divider12InB = 0;
	
	end
end

assign hue43_diff = hue_DIF43;

//assign divider1InA = rgb_MAX;
//assign divider1InB = rgb_DIF255;
//assign divider6InA = rgb_DIF;
//assign divider6InB = hue_DIF43;

logic[1:0] MaxRGBComponent0, MaxRGBComponent1, MaxRGBComponent2, MaxRGBComponent3, MaxRGBComponent4, MaxRGBComponent5;
assign MaxRGB = MaxRGBComponent0;

logic[2:0] state;
assign stateOut = state;

always_ff @(posedge clk ) begin
    if (~rst_n) begin
		  state <= 3'd0;
        hsv_h <= 8'd0;
        hsv_s <= 8'd0;
        hsv_v <= 8'd0; 
		  MaxRGBComponent0 <= 2'd3;
    end else if (state == 3'd0) begin
		  rgb_DIFHold0 <= rgb_DIF;
		  rgb_MAXHold0 <= rgb_MAX;
		  MaxRGBComponent0 <= r_isMAX ? 2'd0 : g_isMAX ? 2'd1 :b_isMAX ? 2'd2 :2'd3;
		  
		  
	     if (rgb_MAXHold1 == 8'd0) begin
            hsv_h <= 8'd0;
            hsv_s <= 8'd0;
            hsv_v <= rgb_MAXHold1;
        end else if (rgb_DIFHold1 == 8'd0) begin
            hsv_h <= 8'd0;
            hsv_s <= 8'd0;
            hsv_v <= rgb_MAXHold1;
        end else begin
            hsv_h <=  (MaxRGBComponent1 == 2'd0) ? divider8Out[7:0] : (MaxRGBComponent1 == 2'd1) ? (divider8Out[7:0] + 8'd85) : (MaxRGBComponent1 == 2'd2) ? (divider8Out[7:0] + 8'd171) : 8'd0;
            hsv_s <= divider2Out[7:0];
            hsv_v <= rgb_MAXHold1;
       end

		 
       state <=3'd1;
	 end else if (state == 3'd1) begin
		  rgb_DIFHold1 <= rgb_DIF;
		  rgb_MAXHold1 <= rgb_MAX;
		  MaxRGBComponent1 <= r_isMAX ? 2'd0 : g_isMAX ? 2'd1 :b_isMAX ? 2'd2 :2'd3;
		  
		  
	     if (rgb_MAXHold2 == 8'd0) begin
            hsv_h <= 8'd0;
            hsv_s <= 8'd0;
            hsv_v <= rgb_MAXHold2;
        end else if (rgb_DIFHold2 == 8'd0) begin
            hsv_h <= 8'd0;
            hsv_s <= 8'd0;
            hsv_v <= rgb_MAXHold2;
        end else begin
            hsv_h <=  (MaxRGBComponent2 == 2'd0) ? divider9Out[7:0] : (MaxRGBComponent2 == 2'd1) ? (divider9Out[7:0] + 8'd85) : (MaxRGBComponent2 == 2'd2) ? (divider9Out[7:0] + 8'd171) : 8'd0;
            hsv_s <= divider3Out[7:0];
            hsv_v <= rgb_MAXHold2;
       end

		 
	     state <= 3'd2;
	 end else if (state == 3'd2) begin
	 
		  rgb_DIFHold2 <= rgb_DIF;
		  rgb_MAXHold2 <= rgb_MAX;
		  MaxRGBComponent2 <= r_isMAX ? 2'd0 : g_isMAX ? 2'd1 :b_isMAX ? 2'd2 :2'd3;
		  
		  
	     if (rgb_MAXHold3 == 8'd0) begin
            hsv_h <= 8'd0;
            hsv_s <= 8'd0;
            hsv_v <= rgb_MAXHold3;
        end else if (rgb_DIFHold3 == 8'd0) begin
            hsv_h <= 8'd0;
            hsv_s <= 8'd0;
            hsv_v <= rgb_MAXHold3;
        end else begin
            hsv_h <=  (MaxRGBComponent3 == 2'd0) ? divider10Out[7:0] : (MaxRGBComponent3 == 2'd1) ? (divider10Out[7:0] + 8'd85) : (MaxRGBComponent3 == 2'd2) ? (divider10Out[7:0] + 8'd171) : 8'd0;
            hsv_s <= divider4Out[7:0];
            hsv_v <= rgb_MAXHold3;
       end
		 
		 
			state <= 3'd3;
	end else if (state == 3'd3) begin
	
		  rgb_DIFHold3 <= rgb_DIF;
		  rgb_MAXHold3 <= rgb_MAX;
		  MaxRGBComponent3 <= r_isMAX ? 2'd0 : g_isMAX ? 2'd1 :b_isMAX ? 2'd2 :2'd3;
		  
		  
	     if (rgb_MAXHold4 == 8'd0) begin
            hsv_h <= 8'd0;
            hsv_s <= 8'd0;
            hsv_v <= rgb_MAXHold4;
        end else if (rgb_DIFHold4 == 8'd0) begin
            hsv_h <= 8'd0;
            hsv_s <= 8'd0;
            hsv_v <= rgb_MAXHold4;
        end else begin
            hsv_h <=  (MaxRGBComponent4 == 2'd0) ? divider11Out[7:0] : (MaxRGBComponent4 == 2'd1) ? (divider11Out[7:0] + 8'd85) : (MaxRGBComponent4 == 2'd2) ? (divider11Out[7:0] + 8'd171) : 8'd0;
            hsv_s <= divider5Out[7:0];
            hsv_v <= rgb_MAXHold4;
       end
		 
		 
			state <= 3'd4;
	end else if (state == 3'd4) begin
		 rgb_DIFHold4 <= rgb_DIF;
		  rgb_MAXHold4 <= rgb_MAX;
		  MaxRGBComponent4 <= r_isMAX ? 2'd0 : g_isMAX ? 2'd1 :b_isMAX ? 2'd2 :2'd3;
		  
		  
	     if (rgb_MAXHold4 == 8'd0) begin
            hsv_h <= 8'd0;
            hsv_s <= 8'd0;
            hsv_v <= rgb_MAXHold4;
        end else if (rgb_DIFHold4 == 8'd0) begin
            hsv_h <= 8'd0;
            hsv_s <= 8'd0;
            hsv_v <= rgb_MAXHold4;
        end else begin
            hsv_h <=  (MaxRGBComponent4 == 2'd0) ? divider12Out[7:0] : (MaxRGBComponent4 == 2'd1) ? (divider12Out[7:0] + 8'd85) : (MaxRGBComponent4 == 2'd2) ? (divider12Out[7:0] + 8'd171) : 8'd0;
            hsv_s <= divider6Out[7:0];
            hsv_v <= rgb_MAXHold4;
       end
	
			state <= 3'd5;
	end else if (state == 3'd5) begin
			rgb_DIFHold5 <= rgb_DIF;
			rgb_MAXHold5 <= rgb_MAX;
			MaxRGBComponent5 <= r_isMAX ? 2'd0 : g_isMAX ? 2'd1 :b_isMAX ? 2'd2 :2'd3;
	
			if (rgb_MAXHold0 == 8'd0) begin
            hsv_h <= 8'd0;
            hsv_s <= 8'd0;
            hsv_v <= rgb_MAXHold0;
        end else if (rgb_DIFHold0 == 8'd0) begin
            hsv_h <= 8'd0;
            hsv_s <= 8'd0;
            hsv_v <= rgb_MAXHold0;
        end else begin
            hsv_h <=  (MaxRGBComponent0 == 2'd0) ? divider7Out[7:0] : (MaxRGBComponent0 == 2'd1) ? (divider7Out[7:0] + 8'd85) : (MaxRGBComponent0 == 2'd2) ? (divider7Out[7:0] + 8'd171) : 8'd0;
            hsv_s <= divider1Out[7:0];
            hsv_v <= rgb_MAXHold0;
       end
	     state <= 3'd0;
    end
end


logic [15:0] divider1InB, divider1Out, divider2InB, divider2Out,  divider3InB, divider3Out, divider4InB, divider4Out, divider5InB, divider5Out, divider6InB, divider6Out;
logic[15:0]  divider7InB, divider7Out,  divider8InB, divider8Out, divider9InB, divider9Out, divider10InB, divider10Out,  divider11InB, divider11Out,  divider12InB, divider12Out;
logic [7:0] divider1InA, divider2InA, divider3InA, divider4InA, divider5InA, divider6InA, divider7InA, divider8InA, divider9InA, divider10InA, divider11InA, divider12InA;
assign div1_num = divider2InB;
assign div1_denom = divider2InA;
assign div1_out = divider1Out;
assign div2_out = divider2Out;

rgbTohsvDivider	rgbTohsvDivider_inst1 (
	.clock ( clk ),
	.denom ( divider1InA ),
	.numer ( divider1InB ),
	.quotient ( divider1Out )
);

rgbTohsvDivider	rgbTohsvDivider_inst2 (
	.clock ( clk ),
	.denom ( divider2InA ),
	.numer ( divider2InB ),
	.quotient ( divider2Out )
);

rgbTohsvDivider	rgbTohsvDivider_inst3 (
	.clock ( clk ),
	.denom ( divider3InA ),
	.numer ( divider3InB ),
	.quotient ( divider3Out )
);

rgbTohsvDivider	rgbTohsvDivider_inst4 (
	.clock ( clk ),
	.denom ( divider4InA ),
	.numer ( divider4InB ),
	.quotient ( divider4Out )
);

rgbTohsvDivider	rgbTohsvDivider_inst5 (
	.clock ( clk ),
	.denom ( divider5InA ),
	.numer ( divider5InB ),
	.quotient ( divider5Out )
);

rgbTohsvDivider	rgbTohsvDivider_inst6 (
	.clock ( clk ),
	.denom ( divider6InA ),
	.numer ( divider6InB ),
	.quotient ( divider6Out )
);



assign div2_num = divider7InB;
assign div2_denom = divider7InA;
assign div7_out = divider7Out;
assign div8_out = divider8Out;

rgbTohsvDivider2	rgbTohsvDivider_inst7(
	.clock ( clk ),
	.denom ( divider7InA ),
	.numer ( divider7InB ),
	.quotient ( divider7Out)
);
rgbTohsvDivider2	rgbTohsvDivider_inst8(
	.clock ( clk ),
	.denom ( divider8InA ),
	.numer ( divider8InB ),
	.quotient ( divider8Out)
);
rgbTohsvDivider2	rgbTohsvDivider_inst9(
	.clock ( clk ),
	.denom ( divider9InA ),
	.numer ( divider9InB ),
	.quotient ( divider9Out)
);
rgbTohsvDivider2	rgbTohsvDivider_inst10(
	.clock ( clk ),
	.denom ( divider10InA ),
	.numer ( divider10InB ),
	.quotient ( divider10Out)
);

rgbTohsvDivider2	rgbTohsvDivider_inst11(
	.clock ( clk ),
	.denom ( divider11InA ),
	.numer ( divider11InB ),
	.quotient ( divider11Out)
);

rgbTohsvDivider2	rgbTohsvDivider_inst12(
	.clock ( clk ),
	.denom ( divider12InA ),
	.numer ( divider12InB ),
	.quotient ( divider12Out)
);

            
endmodule