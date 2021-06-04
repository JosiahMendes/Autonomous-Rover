module  rgb_to_hsv(
	input   logic           clk,	
	input   logic           rst_n,
	input   logic   [7:0]   rgb_r, rgb_g, rgb_b,
	output  logic   [8:0]   hsv_h,                  // 0 - 360
	output  logic   [7:0]   hsv_s,                  // 0 - 255
	output  logic   [7:0]   hsv_v                   // 0 - 255
);

//Find Maximum and Minimums of RGB values

logic [7:0] rgb_MAX, rgb_MIN, rgb_DIF;


assign rgb_MAX =    (rgb_r > rgb_g) ?
                    (rgb_r > rgb_b ? rgb_r : rgb_b) :
                    (rgb_g > rgb_b ? rgb_g : rgb_b);

assign rgb_MIN =    (rgb_r < rgb_g) ?
                    (rgb_r < rgb_b ? rgb_r : rgb_b) :
                    (rgb_g < rgb_b ? rgb_g : rgb_b);

assign rgb_DIF =    rgb_MAX-rgb_MIN;

logic[8:0] hsv_h_temp;
logic[7:0] hsv_s_temp;

always@(*) begin
    hsv_s_temp = 255 * rgb_DIF /rgb_MAX;
    if(rgb_MAX == rgb_r) begin
        hsv_h_temp = 0   + 43 * (rgb_g - rgb_b)/rgb_DIF;
    end else if (rgb_MAX == rgb_g) begin
        hsv_h_temp = 85  + 43 * (rgb_b - rgb_r)/rgb_DIF;
    end else if (rgb_MAX == rgb_b) begin
        hsv_h_temp = 171 + 43 * (rgb_r - rgb_g)/rgb_DIF;
    end
end

always_ff @(posedge clk ) begin
    if (~rst_n) begin
        hsv_h <= 9'd0;
        hsv_s <= 8'd0;
        hsv_v <= 8'd0; 
    end else if (rgb_MAX == 8'd0) begin
        hsv_h <= 9'd0;
        hsv_s <= 8'd0;
        hsv_v <= rgb_MAX;
    end else if (rgb_DIF == 8'd0) begin
        hsv_h <= 9'd0;
        hsv_s <= 8'd0;
        hsv_v <= rgb_MAX;
    end else begin
        hsv_h <= hsv_h_temp;
        hsv_s <= hsv_s_temp;
        hsv_v <= rgb_MAX;
    end
    
end

            
endmodule