// focus function coding by Joe
// focus ip packaged by Dee

module TERASIC_AUTO_FOCUS(
	// global clock & reset
	clk,
	reset_n,
	
	// mm slave
	s_chipselect,
	s_read,
	s_write,
	s_readdata,
	s_writedata,
	s_address,

	// stream sink
	sink_data,
	sink_valid,
	sink_ready,
	sink_sop,
	sink_eop,
	
	// streaming source
	source_data,
	source_valid,
	source_ready,
	source_sop,
	source_eop,
	
	// conduit // i2c master
	clk50,
	vcm_i2c_scl,
	vcm_i2c_sda
	
);


// global clock & reset
input	clk;
input	reset_n;

// mm slave
input							s_chipselect;
input							s_read;
input							s_write;
output	reg	[31:0]	s_readdata;
input	[31:0]				s_writedata;
input	[2:0]					s_address;


// streaming sink
input	[23:0]            	sink_data;
input								sink_valid;
output							sink_ready;
input								sink_sop;
input								sink_eop;

// streaming source
output	[23:0]			  	   source_data;
output								source_valid;
input									source_ready;
output								source_sop;
output								source_eop;

// conduit export
input                         clk50;
inout                         vcm_i2c_scl;
inout                         vcm_i2c_sda;

////////////////////////////////////////////////////////////////////////
//
parameter    VIDEO_W   = 800,
             VIDEO_H   = 480;  
				 
localparam   FOCUS_FULL_VIDEO_MODE     = 1'b0,
             FOCUS_WINDOW_VIDEO_MODE   = 1'b1;
				 
reg process_start /*synthesis noprune*/;
reg focus_mode /*synthesis noprune*/;
				 
reg  [11:0]	 focus_active_w /*synthesis noprune*/;
reg  [11:0]	 focus_active_h /*synthesis noprune*/;
reg  [11:0]	 focus_active_x_start /*synthesis noprune*/;
reg  [11:0]	 focus_active_y_start /*synthesis noprune*/;

reg  [11:0]  x_cnt /*synthesis noprune*/;
reg  [11:0]  y_cnt /*synthesis noprune*/;
reg  [7:0]   scal;
reg  [7:0]   scal_f;
reg  [7:0]   th;
////////////////////////////////////////////////////////////////////////

// coding

// connnect sink & source direct
assign source_data  =  (vcm_en & focus_mode & focus_window_border )?{8'h7f, 8'h7f, 8'h0}:sink_data;
assign source_valid =  sink_valid;
assign sink_ready   =  source_ready; 
assign source_sop   =  sink_sop;
assign source_eop   =  sink_eop;



/////////////////////////////////
/// command from mm master  /////
/////////////////////////////////

// write
`define REG_GO    			0
`define REG_CTRL   			1
`define REG_FOCUS_W        2
`define REG_FOCUS_H        3
`define REG_FOCUS_X_START  4
`define REG_FOCUS_Y_START  5
`define REG_SCAL           6  // scan 0 -> 1023 , step: SCAL , to find STEP_UP
                              // scan STEP_UP + - SCAL/2 , step: SCAL_F
`define REG_TH             7 

// read
`define REG_STATUS         0
//`define REG_SUM            1


// mm mater write
always @ (posedge clk)
begin
	if (~reset_n)
	begin
		process_start <= 1'b0;
		focus_mode    <=  FOCUS_FULL_VIDEO_MODE;
		
		focus_active_w       <= 12'd200;
		focus_active_h       <= 12'd120;
		focus_active_x_start <= 12'd300;
		focus_active_y_start <= 12'd180;
		
		scal                 <= 8'd10;
		scal_f               <= 8'd1;
		
		th                   <= 8'd5;
	end
	else begin
	  if(s_chipselect & s_write) begin
		   if      (s_address == `REG_GO)	process_start <= s_writedata[0];
	      else if (s_address == `REG_CTRL)	focus_mode    <= s_writedata[0];// FOCUS_WINDOW_VIDEO_MODE  settings if not full-screen mode	
	      else if (s_address == `REG_FOCUS_W)       focus_active_w       <= s_writedata[11:0];	
	      else if (s_address == `REG_FOCUS_H)       focus_active_h       <= s_writedata[11:0];
      	else if (s_address == `REG_FOCUS_X_START) focus_active_x_start <= s_writedata[11:0];	
	      else if (s_address == `REG_FOCUS_Y_START) focus_active_y_start <= s_writedata[11:0];
	      else if (s_address == `REG_SCAL)    begin scal                 <= s_writedata[15:8];
		               	                           scal_f               <= s_writedata[7:0];
															end
		   else if (s_address == `REG_TH)            th                   <= s_writedata[7:0];
		end
	end
end



// mm mater read
always @ (posedge clk)
begin
   if (~reset_n) 
	   s_readdata <= {16'b0,1'b1,15'b0};
	else if (s_chipselect & s_read)
	begin
		if   (s_address == `REG_STATUS) s_readdata <= {16'b0,status};
//		else if (s_address == `REG_SUM) s_readdata <= sum;
	end
end

/////////////////////////////////
// remember previus 'process_start' status
reg pre_process_start;
always @ (posedge clk or negedge reset_n)
  if (~reset_n) pre_process_start <= 1'b1;
  else pre_process_start <= process_start;


wire process_start_tiggle;
assign process_start_tiggle = (~pre_process_start & process_start)?1'b1:1'b0;


////////////////////////////////////
////////////////////////////////////
// process kernel
////////////////////////////////////
////////////////////////////////////

wire focus_window_area /*synthesis keep*/;
wire focus_window_border /*synthesis keep*/;


always @ (posedge clk or negedge reset_n)
begin
	if (~reset_n) begin
		x_cnt <= 12'd0;
		y_cnt <= 12'd0;
   end
	else if(sink_sop) begin
			x_cnt <= 12'd0;
		   y_cnt <= 12'd0;
	end 
	else if(sink_valid) begin
	   if(x_cnt == VIDEO_W - 1'b1) begin
			     x_cnt <= 12'd0;
				  y_cnt <= y_cnt + 1'b1;
	   end else x_cnt <= x_cnt + 1'b1;
	end

end

assign focus_window_area = (    x_cnt >= focus_active_x_start 
                             && x_cnt <= (focus_active_x_start + focus_active_w) 
									  && y_cnt >= focus_active_y_start 
                             && y_cnt <= (focus_active_y_start + focus_active_h) 
									  )?1'b1:1'b0;
									  
assign focus_window_border = (( x_cnt == focus_active_x_start 
                             || x_cnt == (focus_active_x_start + focus_active_w) 
									  || y_cnt == focus_active_y_start 
                             || y_cnt == (focus_active_y_start + focus_active_h) 
									  ) && focus_window_area) ?1'b1:1'b0;		
		
/////////////////////////////////////////////////
// VCM enable
reg       vcm_en;
reg [1:0] vcm_en_delay_cnt; 
always @ (posedge clk or negedge reset_n)
begin
	if (~reset_n) begin
   	vcm_en           <= 1'b0;
		vcm_en_delay_cnt <= 2'd0;
	end
	else if(process_start_tiggle) begin
   	vcm_en           <= 1'b1;
		vcm_en_delay_cnt <= 2'd0;
	end
	else if(VCM_END & sink_eop )  begin
      if(vcm_en_delay_cnt == 2'd3) vcm_en <= 1'b0;// or delay x frame?
		else               vcm_en_delay_cnt <= vcm_en_delay_cnt + 1'b1;
	end
end
		

//----VCM_STEP CONTROL & PIXEL HIGH_Statistics

VCM_CTRL_P vcm_ctrl(
.iR (sink_data[23:16]),  // RGB sequence must the same as the LCD side(final RGB sequence)
.iG (sink_data[15: 8]),
.iB (sink_data[ 7: 0]),
.VS (sink_sop & sink_valid),// VS_

.SCAL(scal),
.SCAL_F(scal_f),
.TH(th),
.ACTIV_C (focus_window_area & sink_valid) ,    // focus-window area
.ACTIV_V (sink_valid) , // full-screen
 
.VIDEO_CLK  ( clk   ), 
.AUTO_FOC   ( ~process_start_tiggle    ),  // focus trigger
.SW_FUC_ALL_CEN( focus_mode) ,//
.VCM_END ( VCM_END) ,
.Y   ( Y ),
.S   (S ),
.END_STEP  (END_STEP ),
.VCM_DATA (VCM_DATA ),
.SUM(sum)

);// 
wire  [15:0] VCM_DATA ;
wire [9:0] END_STEP ; 
wire    VCM_END  ;
wire  [7:0] S  ; 
wire   [17:0] Y  ; 
//-----
wire [15:0] status;
wire [31:0]  sum;
assign status  = { ~vcm_en,5'b0,END_STEP} ;
		

						
I2C_VCM_Config vcm_i2c(	
				.iCLK(clk50),//clk_50
				.ENABLE(vcm_en),    // enable  
				.iRST_N(~sink_eop), // trigger
				.VCM_DATA(VCM_DATA),
				.END(),//vcm_i2c_end
				
				.I2C_SCLK(vcm_i2c_scl),
				.I2C_SDAT(vcm_i2c_sda)
				);
						


endmodule

