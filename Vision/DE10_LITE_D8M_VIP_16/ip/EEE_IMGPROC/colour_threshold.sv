module colour_threshold(

	input     [7:0] 	hue,//  0 - 360
	input     [7:0]   	sat,// 0- 255
	input     [7:0] 	val, // 0- 255
	output     			red_detect,
	output	  			green_detect,
	output	  			blue_detect,
	output     			grey_detect,
	output     			yellow_detect
);
	// Detect red areas
//	assign red_detect = 		(((8'd178  < hue) & (hue < 8'd246  )))
//							  & (8'd30  < sat) & (sat < 8'd132 ) 
//							  & (8'd125  < val) & (val < 8'd255 );
//
//	assign green_detect =  		(8'd90 < hue) & (hue < 8'd130 ) 
//							  & (8'd90 < sat) & (sat < 8'd191 )
//							  & (8'd96 < val) & (val < 8'd255 );
//								 
//	assign blue_detect = 		(8'd12 < hue) & (hue < 8'd212 ) 
//							  & (8'd128  < sat) & (sat < 8'd193 )
//							  & (8'd105 < val) & (val < 8'd230 );
//
//	assign yellow_detect = 		(8'd14  < hue) & (hue < 8'd70  )  
//							  & (8'd60 < sat) & (sat < 8'd212 )
//							  & (8'd140  < val) & (val < 8'd255 );
//
//	assign grey_detect = 		(((8'd137  < hue) & (hue < 8'd182 ) ))
//							  & (8'd99  < sat) & (sat < 8'd173 )
//							  & (8'd30  < val) & (val < 8'd130 );


//DARK MODE
	assign red_detect = 		((8'd228   < hue) & (hue <= 8'd255  ) || (8'd0   <= hue) & (hue < 8'd9  ))
							  & (8'd20  < sat) & (sat < 8'd70 ) 
							  & (8'd126  < val) & (val < 8'd180 );

   assign green_detect =  		(8'd59 < hue) & (hue < 8'd128 ) 
							  & (8'd122 < sat) & (sat < 8'd183 )
							  & (8'd43 < val) & (val < 8'd182 );
								 
	assign blue_detect = 		(8'd137 < hue) & (hue < 8'd155 ) 
							  & (8'd117  < sat) & (sat < 8'd183 )
							  & (8'd121  < val) & (val < 8'd230 );

	assign yellow_detect = 		(8'd10  < hue) & (hue < 8'd42  )  
							  & (8'd60 < sat) & (sat < 8'd120 )
							  & (8'd118  < val) & (val < 8'd214 );

	assign grey_detect = 		(8'd104  < hue) & (hue < 8'd174 ) 
							  & (8'd106  < sat) & (sat < 8'd187 )
							  & (8'd18  < val) & (val < 8'd80 );


	

endmodule