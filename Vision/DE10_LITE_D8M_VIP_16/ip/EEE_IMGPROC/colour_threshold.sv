module colour_threshold(

	input     [8:0] 	hue,//  0 - 360
	input     [7:0]   	sat,// 0- 255
	input     [7:0] 	val, // 0- 255
	output     			red_detect,
	output	  			green_detect,
	output	  			blue_detect,
	output     			grey_detect,
	output     			yellow_detect
);
	// Detect red areas
	assign red_detect = 		(9'd0   < hue) & (hue < 9'd30  ) 
							  & (8'd90  < sat) & (sat < 8'd255 ) 
							  & (8'd90  < val) & (val < 8'd255 );

	assign green_detect =  		(9'd110 < hue) & (hue < 9'd135 ) 
							  & (8'd100 < sat) & (sat < 8'd180 )
							  & (8'd100 < val) & (val < 8'd180 );
								 
	assign blue_detect = 		(9'd150 < hue) & (hue < 9'd220 ) 
							  & (8'd50  < sat) & (sat < 8'd255 )
							  & (8'd75  < val) & (val < 8'd255 );

	assign yellow_detect = 		(9'd36  < hue) & (hue < 9'd50  )  
							  & (8'd150 < sat) & (sat < 8'd255 )
							  & (8'd80  < val) & (val < 8'd255 );

	assign grey_detect = 		(9'd65  < hue) & (hue < 9'd140 ) 
							  & (8'd50  < sat) & (sat < 8'd130 )
							  & (8'd50  < val) & (val < 8'd100 );

endmodule