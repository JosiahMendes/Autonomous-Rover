module alt_vipitc131_IS2Vid(
    rst,
    
    // video
    vid_clk,
    vid_data,
    vid_datavalid,
    
    // optional video ports
    vid_v,
    vid_h,
    vid_f,
    vid_v_sync,
    vid_h_sync,
    vid_ln,
    vid_trs,
    vid_std,
    vid_mode_change,
    vid_sof,
    vid_sof_locked,
    vid_vcoclk_div,
    
    // IS
    is_clk,
    is_ready,
    is_valid,
    is_data,
    is_sop,
    is_eop,
    
    // Control
    av_address,
    av_read,
    av_readdata,
    av_write,
    av_writedata,
    av_waitrequest,
    
    // Sync
    sof,
    sof_locked,
    
    // Interrupt
    status_update_int,
    
    // Error
    underflow);

parameter BPS = 10;
parameter NUMBER_OF_COLOUR_PLANES = 2;
parameter COLOUR_PLANES_ARE_IN_PARALLEL = 1;
parameter FIFO_DEPTH = 1920;
parameter USE_EMBEDDED_SYNCS = 1;
parameter CLOCKS_ARE_SAME = 0;
parameter USE_CONTROL = 1;
parameter Y_C_SWAP = 1;
parameter NO_OF_MODES = 3;
parameter ACCEPT_COLOURS_IN_SEQ = 0;
parameter THRESHOLD = 0;
parameter STD_WIDTH = 3;
parameter GENERATE_SYNC = 1;

parameter INTERLACED = 0;
parameter AP_LINE = 42;

// horizontal parameters in pixels
parameter H_ACTIVE_PIXELS = 1920;
parameter H_SYNC_LENGTH = 112;
parameter H_FRONT_PORCH = 48;
parameter H_BACK_PORCH = 120;
parameter H_OFFSET = 0;
parameter H_BLANK = 280;

// vertical parameters in lines
parameter V_ACTIVE_LINES = 538;
parameter V_SYNC_LENGTH = 3;
parameter V_FRONT_PORCH = 4;
parameter V_BACK_PORCH = 38;
parameter V_OFFSET = 0;
parameter V_BLANK = 45;

parameter F_RISING_EDGE = 564;
parameter F_FALLING_EDGE = 18;
parameter FIELD0_V_RISING_EDGE = 561;
parameter FIELD0_V_SYNC_LENGTH = 3;
parameter FIELD0_V_FRONT_PORCH = 4;
parameter FIELD0_V_BACK_PORCH = 38;
parameter FIELD0_V_BLANK = 45;
parameter ANC_LINE = 10;
parameter FIELD0_ANC_LINE = 562;

localparam CONVERT_SEQ_TO_PAR = COLOUR_PLANES_ARE_IN_PARALLEL == 1 && ACCEPT_COLOURS_IN_SEQ != 0 && NUMBER_OF_COLOUR_PLANES > 1;
localparam COLOUR_PLANES_IN_SEQUENCE = (COLOUR_PLANES_ARE_IN_PARALLEL && !CONVERT_SEQ_TO_PAR) ? 1 : NUMBER_OF_COLOUR_PLANES;
localparam DATA_WIDTH = (COLOUR_PLANES_ARE_IN_PARALLEL) ? BPS * NUMBER_OF_COLOUR_PLANES : BPS;
localparam NUMBER_OF_COLOUR_PLANES_IN_PARALLEL = (COLOUR_PLANES_ARE_IN_PARALLEL) ? NUMBER_OF_COLOUR_PLANES : 1;
localparam READ_LATENCY = 2;
localparam TRS_PARALLEL = 4;
localparam TRS_SEQUENCE = 4 / NUMBER_OF_COLOUR_PLANES;
localparam TRS = (COLOUR_PLANES_ARE_IN_PARALLEL) ? TRS_PARALLEL : TRS_SEQUENCE;
localparam TRS_CP_OFFSET = 4 % NUMBER_OF_COLOUR_PLANES;

localparam H_BLANK_INT = (USE_EMBEDDED_SYNCS) ? H_BLANK : H_FRONT_PORCH + H_SYNC_LENGTH + H_BACK_PORCH;
localparam V_BLANK_INT = (USE_EMBEDDED_SYNCS) ? V_BLANK : V_FRONT_PORCH + V_SYNC_LENGTH + V_BACK_PORCH;
localparam FIELD0_V_BLANK_INT = (USE_EMBEDDED_SYNCS) ? FIELD0_V_BLANK : FIELD0_V_FRONT_PORCH + FIELD0_V_SYNC_LENGTH + FIELD0_V_BACK_PORCH;
localparam FIELD0_V_RISING_EDGE_INT = FIELD0_V_RISING_EDGE - AP_LINE;

localparam H_TOTAL = H_ACTIVE_PIXELS + H_BLANK_INT; // line length incl. blanking
localparam V_TOTAL = V_ACTIVE_LINES + ((INTERLACED) ? FIELD0_V_BLANK_INT : 0) + V_BLANK_INT; // number of lines incl. blanking
localparam LOG2_H_TOTAL = alt_clogb2(H_TOTAL);
localparam LOG2_V_TOTAL = alt_clogb2(V_TOTAL);
localparam LOG2_COLOUR_PLANES_IN_SEQUENCE = alt_clogb2(COLOUR_PLANES_IN_SEQUENCE);
localparam NO_OF_MODES_INT = (USE_CONTROL) ? NO_OF_MODES : 1;
localparam LOG2_NO_OF_MODES = alt_clogb2(NO_OF_MODES_INT);
localparam COLOUR_PLANES_IN_SEQUENCE_FIFO = (COLOUR_PLANES_ARE_IN_PARALLEL) ? 1 : NUMBER_OF_COLOUR_PLANES;
localparam FIFO_DEPTH_INT = (FIFO_DEPTH * COLOUR_PLANES_IN_SEQUENCE_FIFO) + 4;
localparam THRESHOLD_INT = (THRESHOLD * COLOUR_PLANES_IN_SEQUENCE_FIFO);
localparam USED_WORDS_WIDTH = alt_clogb2(FIFO_DEPTH_INT);

localparam F_RISING_EDGE_INT = F_RISING_EDGE - AP_LINE;
localparam F_FALLING_EDGE_INT = V_TOTAL - (AP_LINE - F_RISING_EDGE);

localparam F0_LINE_COUNT = (INTERLACED) ? FIELD0_V_RISING_EDGE_INT : V_ACTIVE_LINES;
localparam F1_LINE_COUNT = V_ACTIVE_LINES - F0_LINE_COUNT;

localparam BLANKING_SER1 = (BPS < 10) ? 128 : 512;
localparam BLANKING_SER2 = (BPS < 10) ? 16 : 64;
localparam BLANKING_PAR = 66048; // 20'h10200

function integer alt_clogb2;
  input [31:0] value;
  integer i;
  begin
    alt_clogb2 = 32;
    for (i=31; i>0; i=i-1) begin
      if (2**i>=value)
        alt_clogb2 = i;
    end
  end
endfunction

function [9:0] calc_xyz;
  input [2:0] FVH;
  case (FVH)
    3'b000 : calc_xyz = 10'h200;
    3'b001 : calc_xyz = 10'h274;
    3'b010 : calc_xyz = 10'h2ac;
    3'b011 : calc_xyz = 10'h2d8;
    3'b100 : calc_xyz = 10'h31c;
    3'b101 : calc_xyz = 10'h368;
    3'b110 : calc_xyz = 10'h3b0;
    3'b111 : calc_xyz = 10'h3c4;
  endcase
endfunction

input rst;

// video
input vid_clk;
output [DATA_WIDTH-1:0] vid_data;
output vid_datavalid;

// optional video ports
output vid_v;
output vid_h;
output vid_f;
output vid_v_sync;
output vid_h_sync;
output [10:0] vid_ln;
output vid_trs;
output [STD_WIDTH-1:0] vid_std;
output vid_mode_change;
output vid_sof;
output vid_sof_locked;
output vid_vcoclk_div;

// IS
input is_clk;
output is_ready;
input is_valid;
input [DATA_WIDTH-1:0] is_data;
input is_sop;
input is_eop;

// Control
input [7:0] av_address;
input av_read;
output [15:0] av_readdata;
input av_write;
input [15:0] av_writedata;
output av_waitrequest;

// Sync
input sof;
input sof_locked;

// Interrupt
output status_update_int;

// Error
output underflow;

reg [DATA_WIDTH-1:0] vid_data;

// optional video ports
wire vid_v;
wire vid_h;
wire vid_f;
wire vid_v_sync;
wire vid_h_sync;
wire vid_trs;
wire vid_datavalid;
wire vid_sof;
wire vid_sof_locked;

reg vid_v_reg;
reg vid_h_reg;
reg vid_f_reg;
reg vid_v_sync_reg;
reg vid_h_sync_reg;
reg vid_datavalid_reg;

wire status_update_int;

wire vid_f_nxt;
wire vid_h_nxt;
wire vid_v_nxt;
wire vid_h_sync_nxt;
wire vid_v_sync_nxt;

reg [READ_LATENCY-1:0] vid_datavalid_pipeline;
reg [READ_LATENCY-1:0] vid_f_pipeline;
reg [READ_LATENCY-1:0] vid_h_pipeline;
reg [READ_LATENCY-1:0] vid_v_pipeline;
reg [READ_LATENCY-1:0] vid_h_sync_pipeline;
reg [READ_LATENCY-1:0] vid_v_sync_pipeline;
reg [READ_LATENCY-1:0] anc_valid_word_pipeline;

wire rdreq;
wire rdreq_pre_swap;
wire wrreq;
wire [DATA_WIDTH-1:0] q_data;
wire [DATA_WIDTH-1:0] q_post_swap;
wire empty;
wire [USED_WORDS_WIDTH-1:0] usedw;
wire [USED_WORDS_WIDTH-1:0] rdusedw;
wire enable;
wire [11:0] h_count;
wire [11:0] v_count;
wire v_enable;
wire request_data_nxt;
reg request_data;
reg request_data_valid;
wire trs;
wire [DATA_WIDTH-1:0] trs_data;
wire ap;
wire [DATA_WIDTH-1:0] vid_data_pre_ln;
wire [DATA_WIDTH:0] q;
wire [DATA_WIDTH:0] writedata;
wire sop;
reg sop_reg;

wire enable_sync1;
reg enable_synced;
reg enable_threshold;
wire threshold_reached;
reg [15:0] frames_in_sync /* synthesis noprune preserve */;
reg reset_counters;
wire enable_synced_nxt;
wire ap_synched;

wire underflow_nxt;
wire anc_underflow_nxt;
reg underflow_reg;

localparam [3:0] IDLE            = 4'd0;
localparam [3:0] FIND_SOP        = 4'd1;
localparam [3:0] WIDTH_3         = 4'd2;
localparam [3:0] WIDTH_2         = 4'd3;
localparam [3:0] WIDTH_1         = 4'd4;
localparam [3:0] WIDTH_0         = 4'd5;
localparam [3:0] HEIGHT_3        = 4'd6;
localparam [3:0] HEIGHT_2        = 4'd7;
localparam [3:0] HEIGHT_1        = 4'd8;
localparam [3:0] HEIGHT_0        = 4'd9;
localparam [3:0] INTERLACING     = 4'd10;
localparam [3:0] FIND_MODE       = 4'd11;
localparam [3:0] SYNCHED         = 4'd12;
localparam [3:0] WAIT_FOR_SYNCH  = 4'd13;
localparam [3:0] WAIT_FOR_ANC    = 4'd14;
localparam [3:0] INSERT_ANC      = 4'd15;

wire [3:0] state_next, state;
reg [15:0] samples, lines;
reg [3:0] interlaced_field;
reg field_prediction;
wire field_prediction_nxt;
reg start_of_ap;
wire start_of_ap_nxt;
reg start_of_vsync;

wire clear_underflow_sticky;
wire clear_underflow_sticky_sync1;

wire vid_clk_int;
wire rst_vid_clk;

wire [DATA_WIDTH-1:0] blanking_value;
wire start_of_cp;
wire start_of_frame, vid_datavalid_nxt;
wire anc_datavalid_nxt;
wire anc_valid_word_nxt;

wire find_mode_nxt;
wire wait_for_anc_nxt;
wire mode_change;
wire dirty_modes;

wire [NO_OF_MODES_INT-1:0] mode_match_safe;
wire write_trigger;
wire write_trigger_ack;
wire [1:0] genlock_enable;
wire [1:0] genlock_enable_sync1;
wire genlocked;
wire genlocked_sync1;
wire mode_write;
wire sync_lines;
wire sync_samples;
wire remove_repeatn;
wire [15:0] sync_compare_h_reset;
wire [15:0] sync_compare_v_reset;

wire interlaced;
wire serial_output;
wire [15:0] h_total_minus_one;
wire [15:0] v_total_minus_one;
wire [15:0] ap_line;
wire [15:0] ap_line_end;
wire [15:0] h_blank;
wire [15:0] sav;
wire [15:0] h_sync_start;
wire [15:0] h_sync_end;
wire [15:0] f2_v_start;
wire [15:0] f1_v_start;
wire [15:0] f1_v_end;
wire [15:0] f2_v_sync_start;
wire [15:0] f2_v_sync_end;
wire [15:0] f1_v_sync_start;
wire [15:0] f1_v_sync_end;
wire [15:0] f_rising_edge;
wire [15:0] f_falling_edge;
wire [15:0] f1_v_end_nxt;
wire [12:0] total_line_count_f0;
wire [12:0] total_line_count_f1;
wire [13:0] sof_sample;
wire [12:0] sof_line;
wire [1:0] sof_subsample;
wire [13:0] vcoclk_divider_value;
wire [15:0] f2_anc_v_start;
wire [15:0] f1_anc_v_start;

generate
     if(CLOCKS_ARE_SAME) begin
         assign rst_vid_clk = rst;
         assign vid_clk_int = is_clk;
     end else begin
         reg rst_vid_clk_reg;
         reg rst_vid_clk_reg2;
         
         always @ (posedge rst or posedge vid_clk_int) begin
             if(rst) begin
                rst_vid_clk_reg <= 1'b1;
                rst_vid_clk_reg2 <= 1'b1;
             end else begin
                rst_vid_clk_reg <= 1'b0;
                rst_vid_clk_reg2 <= rst_vid_clk_reg;
             end
         end
         assign rst_vid_clk = rst_vid_clk_reg2;
         assign vid_clk_int = vid_clk;
     end
endgenerate

wire enable_resync1;
wire underflow_sticky_sync1;
wire mode_change_sync1;
wire av_write_ack;

alt_vipitc131_common_sync #(CLOCKS_ARE_SAME) enable_resync_sync(
    .rst(rst),
    .sync_clock(is_clk),
    .data_in(enable_synced),
    .data_out(enable_resync1));
        
alt_vipitc131_common_sync #(CLOCKS_ARE_SAME) underflow_sync(
    .rst(rst),
    .sync_clock(is_clk),
    .data_in(underflow),
    .data_out(underflow_sticky_sync1));
    
alt_vipitc131_common_trigger_sync #(CLOCKS_ARE_SAME) mode_change_trigger_sync(
    .input_rst(rst_vid_clk),
    .input_clock(vid_clk_int),
    .rst(rst),
    .sync_clock(is_clk),
    
    .trigger_in(mode_change),
    .ack_in(1'b0),
    .trigger_out(mode_change_sync1));
    
alt_vipitc131_common_sync #(CLOCKS_ARE_SAME) genlocked_sync(
    .rst(rst),
    .sync_clock(is_clk),
    .data_in(genlocked),
    .data_out(genlocked_sync1));

alt_vipitc131_IS2Vid_control control(
    .rst(rst),
    .clk(is_clk),
    
    // From mode registers
    .av_write_ack(av_write_ack),
    .mode_change(mode_change_sync1),
    .mode_match(mode_match_safe),
    
    // From FIFO
    .usedw(usedw),
    .underflow_sticky(underflow_sticky_sync1),
    .enable_resync(enable_resync1), // from the outgoing state machine
    .genlocked(genlocked_sync1),
    
    // IS2Vid control signals
    .enable(enable),
    .clear_underflow_sticky(clear_underflow_sticky),
    .write_trigger(write_trigger),
    .write_trigger_ack(write_trigger_ack),
    .genlock_enable(genlock_enable),
    
    // Aavalon-MM slave port
    .av_address(av_address),
    .av_read(av_read),
    .av_readdata(av_readdata),
    .av_write(av_write),
    .av_writedata(av_writedata),
    .av_waitrequest(av_waitrequest),
    
    .status_update_int(status_update_int));
    
defparam control.USE_CONTROL = USE_CONTROL,
         control.NO_OF_MODES_INT = NO_OF_MODES_INT,
         control.USED_WORDS_WIDTH = USED_WORDS_WIDTH;
    
alt_vipitc131_common_trigger_sync #(CLOCKS_ARE_SAME) av_write_trigger_sync(
    .input_rst(rst),
    .input_clock(is_clk),
    .rst(rst_vid_clk),
    .sync_clock(vid_clk_int),
    
    .trigger_in(write_trigger),
    .ack_in(write_trigger_ack),
    .trigger_out(mode_write));

alt_vipitc131_IS2Vid_mode_banks mode_banks(
    .rst(rst_vid_clk),
    .clk(vid_clk_int),
    
    // From control
    .mode_write(mode_write),
    .find_mode_nxt(find_mode_nxt),
    .av_address(av_address),
    .av_writedata(av_writedata),
    
    // To control
    .mode_match_safe(mode_match_safe),
    .dirty_modes(dirty_modes),
    .mode_change(mode_change),
    
    // To video output
    .vid_std(vid_std),
    .vid_mode_change(vid_mode_change),
    
    // From video output
    .interlaced_field(interlaced_field),
    .field_prediction(field_prediction_nxt),
    .samples(samples),
    .lines(lines),
    
    // To video output
    .interlaced(interlaced),
    .serial_output(serial_output),
    .h_total_minus_one(h_total_minus_one),
    .v_total_minus_one(v_total_minus_one),
    .ap_line(ap_line),
    .ap_line_end(ap_line_end),
    .h_blank(h_blank),
    .sav(sav),
    .h_sync_start(h_sync_start),
    .h_sync_end(h_sync_end),
    .f2_v_start(f2_v_start),
    .f1_v_start(f1_v_start),
    .f1_v_end(f1_v_end),
    .f2_v_sync_start(f2_v_sync_start),
    .f2_v_sync_end(f2_v_sync_end),
    .f1_v_sync_start(f1_v_sync_start),
    .f1_v_sync_end(f1_v_sync_end),
    .f_rising_edge(f_rising_edge),
    .f_falling_edge(f_falling_edge),
    .f1_v_end_nxt(f1_v_end_nxt),
    .sof_sample(sof_sample),
    .sof_line(sof_line),
    .sof_subsample(sof_subsample),
    .vcoclk_divider_value(vcoclk_divider_value),
    .f2_anc_v_start(f2_anc_v_start),
    .f1_anc_v_start(f1_anc_v_start)
);

defparam mode_banks.USE_CONTROL = USE_CONTROL,
         mode_banks.NO_OF_MODES_INT = NO_OF_MODES_INT,
         mode_banks.LOG2_NO_OF_MODES = LOG2_NO_OF_MODES,
         mode_banks.COLOUR_PLANES_ARE_IN_PARALLEL = COLOUR_PLANES_ARE_IN_PARALLEL,
         mode_banks.TRS = TRS,
         mode_banks.INTERLACED = INTERLACED,
         mode_banks.H_ACTIVE_PIXELS = H_ACTIVE_PIXELS,
         mode_banks.F0_LINE_COUNT = F0_LINE_COUNT,
         mode_banks.F1_LINE_COUNT = F1_LINE_COUNT,
         mode_banks.H_FRONT_PORCH = H_FRONT_PORCH,
         mode_banks.H_SYNC_LENGTH = H_SYNC_LENGTH,
         mode_banks.H_BLANK_INT = H_BLANK_INT,
         mode_banks.V_FRONT_PORCH = V_FRONT_PORCH,
         mode_banks.V_SYNC_LENGTH = V_SYNC_LENGTH,
         mode_banks.V_BLANK_INT = V_BLANK_INT,
         mode_banks.FIELD0_V_FRONT_PORCH = FIELD0_V_FRONT_PORCH,
         mode_banks.FIELD0_V_SYNC_LENGTH = FIELD0_V_SYNC_LENGTH,
         mode_banks.FIELD0_V_BLANK_INT = FIELD0_V_BLANK_INT,
         mode_banks.AP_LINE = AP_LINE,
         mode_banks.FIELD0_V_RISING_EDGE = FIELD0_V_RISING_EDGE,
         mode_banks.F_RISING_EDGE = F_RISING_EDGE,
         mode_banks.F_FALLING_EDGE = F_FALLING_EDGE,
         mode_banks.CONVERT_SEQ_TO_PAR = CONVERT_SEQ_TO_PAR,
         mode_banks.TRS_SEQUENCE = TRS_SEQUENCE,
         mode_banks.TRS_PARALLEL = TRS_PARALLEL,
         mode_banks.STD_WIDTH = STD_WIDTH,
         mode_banks.ANC_LINE = ANC_LINE,
         mode_banks.FIELD0_ANC_LINE = FIELD0_ANC_LINE;

alt_vipitc131_common_trigger_sync #(CLOCKS_ARE_SAME) av_waitrequest_trigger_sync(
    .input_rst(rst_vid_clk),
    .input_clock(vid_clk_int),
    .rst(rst),
    .sync_clock(is_clk),
    
    .trigger_in(mode_write),
    .ack_in(1'b0),
    .trigger_out(av_write_ack));

wire enable_vcount;
wire [LOG2_COLOUR_PLANES_IN_SEQUENCE-1:0] cp_ticks;
wire repeat_reset_point;
wire remove_reset_point;
wire repeat_lines_reset;
wire remove_lines_reset;
wire repeat_samples_reset;
wire remove_samples_reset;
wire lines_reset;
wire samples_reset;
wire clear_enable;
wire restart_sample_count;
wire restart_lines_count;
wire [15:0] v_reset_value;
wire restart_line_count;

localparam integer v_offset_const = V_OFFSET;
localparam integer h_offset_const = H_OFFSET;
assign repeat_reset_point = !remove_repeatn && h_count == sync_compare_h_reset && v_count == sync_compare_v_reset;
assign remove_reset_point = remove_repeatn && h_count == 16'd0 && v_count == 16'd0;

assign repeat_lines_reset = sync_lines & repeat_reset_point;
assign remove_lines_reset = sync_lines & remove_reset_point;
assign repeat_samples_reset = sync_samples & repeat_reset_point;
assign remove_samples_reset = sync_samples & remove_reset_point;

assign lines_reset = (repeat_lines_reset || remove_lines_reset) && ((cp_ticks == NUMBER_OF_COLOUR_PLANES - 1) || ~serial_output);
assign samples_reset = (repeat_samples_reset || remove_samples_reset) && ((cp_ticks == NUMBER_OF_COLOUR_PLANES - 1) || ~serial_output);

assign clear_enable = mode_change | reset_counters;
assign restart_line_count = clear_enable | lines_reset;
assign restart_sample_count = clear_enable | samples_reset;

assign v_reset_value = (genlock_enable_sync1[0]) ? (remove_repeatn) ? sync_compare_v_reset : v_offset_const[15:0] :
                                                   (interlaced_field[3] & field_prediction) ? f1_v_end_nxt : v_offset_const[15:0];

alt_vipitc131_common_generic_count
    #(.WORD_LENGTH(12),
        .RESET_VALUE(H_OFFSET),
        .TICKS_WORD_LENGTH(LOG2_COLOUR_PLANES_IN_SEQUENCE),
        .TICKS_PER_COUNT(COLOUR_PLANES_IN_SEQUENCE))
	h_counter // count pixels per line
	    (.clk(vid_clk_int),
		 .reset_n(~rst_vid_clk),
		 .enable(enable_synced_nxt),
		 .enable_ticks(serial_output),
         .max_count(h_total_minus_one),
		 .count(h_count),
         .restart_count(restart_sample_count),
         .reset_value((remove_repeatn) ? sync_compare_h_reset : H_OFFSET),
         .enable_count(enable_vcount),
         .start_count(start_of_cp),
         .cp_ticks(cp_ticks));

alt_vipitc131_common_generic_count
    #(.WORD_LENGTH(12),
        .RESET_VALUE(V_OFFSET))
	v_counter // count lines per frame
		(.clk(vid_clk_int),
		 .reset_n(~rst_vid_clk),
		 .enable(v_enable),
         .max_count(v_total_minus_one),
		 .count(v_count),
         .restart_count(restart_line_count),
         .reset_value(v_reset_value));

assign start_of_frame = (start_of_cp && h_count == H_OFFSET) && ((interlaced && v_count == f1_v_end) || v_count == V_OFFSET);

assign v_enable = enable_synced_nxt && enable_vcount && h_count == h_total_minus_one;
assign ap = h_count >= h_blank && ~vid_v_nxt;

// Generate all the blanking and sync signals based on the sample and line counters.
assign vid_h_nxt = enable_synced_nxt && h_count < h_blank;
assign vid_h_sync_nxt = enable_synced_nxt && (h_count >= h_sync_start && h_count < h_sync_end);
assign vid_v_nxt = enable_synced_nxt && (v_count >= f2_v_start ||
                                    (interlaced && (v_count >= f1_v_start && v_count < f1_v_end)));
assign vid_v_sync_nxt = enable_synced_nxt && ((v_count >= f2_v_sync_start && v_count < f2_v_sync_end) ||
                                         (interlaced && (v_count >= f1_v_sync_start && v_count < f1_v_sync_end)));
assign vid_datavalid_nxt = enable_synced_nxt & ap;
assign anc_datavalid_nxt = enable_synced_nxt && h_count >= h_blank && (v_count >= f2_anc_v_start || 
                                                                      (interlaced && v_count >= f1_anc_v_start && v_count < f1_v_end));
assign vid_f_nxt = interlaced && (v_count >= f_rising_edge && v_count < f_falling_edge);

// The sticky underflow output is set when the video interface attempts to 
// read data when the fifo is empty. 
assign underflow = underflow_reg;
assign underflow_nxt = vid_datavalid_nxt & empty;
assign anc_underflow_nxt = anc_datavalid_nxt & empty;

always @ (posedge rst_vid_clk or posedge vid_clk_int) begin
    if (rst_vid_clk) begin
        underflow_reg <= 1'b0;
    end else begin
        underflow_reg <= (underflow_nxt | underflow_reg) & ~clear_underflow_sticky_sync1;
    end
end

alt_vipitc131_common_sync #(CLOCKS_ARE_SAME) clear_underflow_sticky_sync(
    .rst(rst_vid_clk),
    .sync_clock(vid_clk_int),
    .data_in(clear_underflow_sticky),
    .data_out(clear_underflow_sticky_sync1));

// Delay all the sync and blanking lines by the fifo read latency, so that they line up with the read data.
always @ (posedge rst_vid_clk or posedge vid_clk_int) begin
	if (rst_vid_clk) begin
        enable_threshold <= 1'b0;
        frames_in_sync <= 16'd0;
        enable_synced <= 1'b0;

        vid_f_pipeline <= {READ_LATENCY{1'b0}};
        vid_h_pipeline <= {READ_LATENCY{1'b0}};
        vid_h_sync_pipeline <= {READ_LATENCY{1'b0}};
        vid_v_pipeline <= {READ_LATENCY{1'b0}};
        vid_v_sync_pipeline <= {READ_LATENCY{1'b0}}; 
        vid_datavalid_pipeline <= {READ_LATENCY{1'b0}};
        anc_valid_word_pipeline <= {READ_LATENCY{1'b0}};
        
        vid_f_reg <= 1'b0;
        vid_h_reg <= 1'b0;
        vid_h_sync_reg <= 1'b0;
        vid_v_reg <= 1'b0;
        vid_v_sync_reg <= 1'b0;
        vid_datavalid_reg <= 1'b0;
    end else begin
        if(clear_enable) begin
            enable_threshold <= 1'b0;
            frames_in_sync <= 16'd0;
        end else begin
            enable_threshold <= (threshold_reached | enable_threshold) & enable_sync1;
            if(enable_synced_nxt & start_of_frame)
                frames_in_sync <= frames_in_sync + 1'b1;
        end
        
        enable_synced <= enable_synced_nxt;
        
        vid_f_pipeline <= {vid_f_pipeline[READ_LATENCY-2:0], vid_f_nxt};
        vid_h_pipeline <= {vid_h_pipeline[READ_LATENCY-2:0], vid_h_nxt};
        vid_h_sync_pipeline <= {vid_h_sync_pipeline[READ_LATENCY-2:0], vid_h_sync_nxt};
        vid_v_pipeline <= {vid_v_pipeline[READ_LATENCY-2:0], vid_v_nxt};
        vid_v_sync_pipeline <= {vid_v_sync_pipeline[READ_LATENCY-2:0], vid_v_sync_nxt};
        vid_datavalid_pipeline <= {vid_datavalid_pipeline[READ_LATENCY-2:0], vid_datavalid_nxt};
        anc_valid_word_pipeline <= {anc_valid_word_pipeline[READ_LATENCY-2:0], anc_valid_word_nxt};
        
        // Register all the outputs.
        vid_f_reg <= vid_f_pipeline[READ_LATENCY-1];
        vid_h_reg <= vid_h_pipeline[READ_LATENCY-1];
        vid_h_sync_reg <= vid_h_sync_pipeline[READ_LATENCY-1];
        vid_v_reg <= vid_v_pipeline[READ_LATENCY-1];
        vid_v_sync_reg <= vid_v_sync_pipeline[READ_LATENCY-1];
        vid_datavalid_reg <= vid_datavalid_pipeline[READ_LATENCY-1];
	end
end

assign threshold_reached = rdusedw >= THRESHOLD_INT;
assign enable_synced_nxt = (start_of_frame) ? enable_threshold : enable_synced;

alt_vipitc131_common_sync #(CLOCKS_ARE_SAME) enable_sync(
    .rst(rst_vid_clk),
    .sync_clock(vid_clk_int),
    .data_in(enable),
    .data_out(enable_sync1));
    
alt_vipitc131_common_sync #(CLOCKS_ARE_SAME, 2) genlock_enable_sync(
    .rst(rst_vid_clk),
    .sync_clock(vid_clk_int),
    .data_in(genlock_enable),
    .data_out(genlock_enable_sync1));

generate
    if(USE_EMBEDDED_SYNCS) begin
        wire [BPS-1:0] blanking_serial;
        wire [DATA_WIDTH-1:0] blanking_parallel;
        
        assign blanking_serial = (cp_ticks == 0) ? BLANKING_SER1 :
                                 (cp_ticks == 1) ? BLANKING_SER2 :
                                 (cp_ticks == 2) ? BLANKING_SER1 :
                                                   BLANKING_SER2;
        
        if(NUMBER_OF_COLOUR_PLANES_IN_PARALLEL > 1) begin
            genvar i;
            for(i = 0; i < NUMBER_OF_COLOUR_PLANES; i=i+1) begin : xyz_creation
                if(i % 2 == 0)
                    assign blanking_parallel[(i*BPS)+BPS-1:i*BPS] = BLANKING_SER1;
                else
                    assign blanking_parallel[(i*BPS)+BPS-1:i*BPS] = BLANKING_SER2;
                
                assign blanking_value[(i*BPS)+BPS-1:i*BPS] = (serial_output) ? blanking_serial : blanking_parallel[(i*BPS)+BPS-1:i*BPS];
            end
        end else
            assign blanking_value[DATA_WIDTH-1:0] = blanking_serial;
    end else
        assign blanking_value = {DATA_WIDTH{1'b0}};
endgenerate
    
// Insert a constant blanking value during the blanking period
// sop is fed directly in for ancillary packets as we don't know their size so
// they could end at any time
assign vid_data_pre_ln = (trs) ? trs_data : (~vid_datavalid_pipeline[READ_LATENCY-1] & ~(anc_valid_word_pipeline[READ_LATENCY-1] & ~(sop | sop_reg))) ? blanking_value : q_post_swap;

// When using embedded syncs the h,v and f flags must be inserted into the
// BT656 stream.
parameter [2:0] S_IDLE      = 3'b000;
parameter [2:0] S_TRS_WORD2 = 3'b001;
parameter [2:0] S_TRS_WORD3 = 3'b010;
parameter [2:0] S_TRS_XYZ   = 3'b011;
parameter [2:0] S_TRS_LN0   = 3'b100;
parameter [2:0] S_TRS_LN1   = 3'b101;
parameter [2:0] S_TRS_CR0   = 3'b110;
parameter [2:0] S_TRS_CR1   = 3'b111;

generate
    if(USE_EMBEDDED_SYNCS) begin
        wire vid_trs_nxt;
        reg vid_trs_reg;
        reg [10:0] vid_ln_reg;
        reg [READ_LATENCY-1:0] vid_trs_pipeline;
        wire [9:0] xyz;
        wire [DATA_WIDTH-1:0] flags;
        wire vid_trs_int;
        wire trs_word2;
        wire trs_word3;
        wire trs_xyz;
        reg [2:0] emb_state;
        wire [BPS-1:0] xyz_fixed;
        wire sav_enable;
        wire [15:0] v_count_plus_ap;
        wire [15:0] v_count_minus_ap;
        
        assign sav_enable = (serial_output) ? cp_ticks == TRS_CP_OFFSET : 1'b1;
        
        assign vid_trs_nxt = enable_synced_nxt && ((start_of_cp && h_count == 0) || 
                                               (sav_enable && h_count == sav));
        assign xyz = calc_xyz({vid_f_nxt, vid_v_nxt, vid_h_nxt});
        
        always @ (posedge rst_vid_clk or posedge vid_clk_int) begin
            if (rst_vid_clk) begin
                vid_trs_pipeline <= {READ_LATENCY{1'b0}}; 
                vid_trs_reg <= 1'b0;
                vid_ln_reg <= 11'd0;
                
                emb_state <= S_IDLE;
            end else begin
                vid_trs_pipeline <= {vid_trs_pipeline[READ_LATENCY-2:0], vid_trs_nxt};
                vid_trs_reg <= vid_trs_int;
                vid_ln_reg <= (v_count <= ap_line_end) ? v_count_plus_ap[10:0] : v_count_minus_ap[10:0];
                
                if(enable_synced_nxt)
                    case (emb_state)
                        S_IDLE: begin 
                            if(vid_trs_int)
                                emb_state <= S_TRS_WORD2;
                        end
                        S_TRS_WORD2 : emb_state <= S_TRS_WORD3;
                        S_TRS_WORD3 : emb_state <= S_TRS_XYZ;
                        S_TRS_XYZ   : emb_state <= S_IDLE;
                    endcase
            end
        end
        
        assign vid_trs_int = vid_trs_pipeline[READ_LATENCY-1];
        
        if(BPS > 10)
            assign xyz_fixed = {{BPS-10{1'b0}}, xyz};
        else
            assign xyz_fixed = xyz[9:10-BPS];
        genvar i;
        if(COLOUR_PLANES_ARE_IN_PARALLEL)
            for(i = 0; i < NUMBER_OF_COLOUR_PLANES; i=i+1) begin : xyz_creation
                assign flags[(i*BPS)+BPS-1:i*BPS] = xyz_fixed;
            end
        else
            assign flags[BPS-1:0] = xyz_fixed;
        assign trs_word2 = (emb_state == S_TRS_WORD2);
        assign trs_word3 = (emb_state == S_TRS_WORD3);
        assign trs_xyz = (emb_state == S_TRS_XYZ);
        assign trs = vid_trs_int | trs_word2 | trs_word3 | trs_xyz;
        
        assign trs_data = (vid_trs_int) ? {DATA_WIDTH{1'b1}} :
                          (trs_word2)   ? {DATA_WIDTH{1'b0}} :
                          (trs_word3)   ? {DATA_WIDTH{1'b0}} :
                                          flags;
        
        assign v_count_plus_ap = v_count + ap_line;
        assign v_count_minus_ap = v_count - ap_line_end;
        assign vid_ln = vid_ln_reg;
        assign vid_trs = vid_trs_reg;
        
        assign vid_v = 1'b0;
		assign vid_h = 1'b0;
		assign vid_f = 1'b0;
		assign vid_v_sync = 1'b0;
		assign vid_h_sync = 1'b0;
        assign vid_datavalid = 1'b0;
    end else begin
		assign trs = 1'b0;
        assign trs_data = {DATA_WIDTH{1'bx}};
        assign vid_ln = 11'd0;
        assign vid_trs = 1'b0;
        
        assign vid_v = vid_v_reg;
		assign vid_h = vid_h_reg;
		assign vid_f = vid_f_reg;
		assign vid_v_sync = vid_v_sync_reg;
		assign vid_h_sync = vid_h_sync_reg;
        assign vid_datavalid = vid_datavalid_reg;
    end
endgenerate

always @ (posedge rst_vid_clk or posedge vid_clk_int) begin
    if (rst_vid_clk)
        vid_data <= {DATA_WIDTH{1'b0}};
    else
        vid_data <= vid_data_pre_ln;
end

generate
    if(CONVERT_SEQ_TO_PAR) begin
        reg stall_req;
        reg [LOG2_COLOUR_PLANES_IN_SEQUENCE-1:0] cp_ticks_pipeline[READ_LATENCY-1:0];
        wire [LOG2_COLOUR_PLANES_IN_SEQUENCE-1:0] cp_ticks_delayed;
        
        wire [BPS-1:0] q_mux[NUMBER_OF_COLOUR_PLANES-1:0];
        genvar i;
        for(i = 0; i < NUMBER_OF_COLOUR_PLANES; i=i+1) begin : q_mux_generation
            assign q_mux[i] = q_data[(i*BPS)+(BPS-1):(i*BPS)];
        end
        
        for(i = 0; i < (READ_LATENCY-1); i=i+1) begin : cp_ticks_pipeline_generation
            always @ (posedge rst_vid_clk or posedge vid_clk_int) begin
                if (rst_vid_clk) begin
                    cp_ticks_pipeline[i+1] <= {LOG2_COLOUR_PLANES_IN_SEQUENCE{1'b0}};
                end else begin
                    if(serial_output && state_next == INSERT_ANC) begin
                        cp_ticks_pipeline[i+1] <= 1;    // take the ancilliary data from the Y stream
                    end else begin
                        cp_ticks_pipeline[i+1] <= cp_ticks_pipeline[i];
                    end
                end
            end
        end
        
        assign cp_ticks_delayed = cp_ticks_pipeline[READ_LATENCY-1];
        assign q_post_swap = {q_data[DATA_WIDTH-1:BPS], q_mux[cp_ticks_delayed]};        
        assign rdreq_pre_swap = rdreq & ~stall_req;
        
        // mux the parallel data onto a signal sequential symbol
        always @ (posedge rst_vid_clk or posedge vid_clk_int) begin
            if (rst_vid_clk) begin
                cp_ticks_pipeline[0] <= {LOG2_COLOUR_PLANES_IN_SEQUENCE{1'b0}};
                stall_req <= 1'b0;
            end else begin
                cp_ticks_pipeline[0] <= cp_ticks;
                if(serial_output && state == SYNCHED) begin
                    if(cp_ticks_delayed == NUMBER_OF_COLOUR_PLANES - 2) begin
                        stall_req <= 1'b0;
                    end else begin
                        stall_req <= 1'b1;
                    end
                end else begin
                    stall_req <= 1'b0;
                end  
            end
        end
    end else begin
        assign q_post_swap = q_data;
        assign rdreq_pre_swap = rdreq;
    end
endgenerate

// Fifo depth is 3 less than max due to synchronisation issues potentially
// causing the last 3 words to be unavailable when using a dcfifo.
//
// Ready latency of 1 so we pull the ready low 1 cycle early.
assign is_ready = ~(usedw >= (FIFO_DEPTH_INT - 4));

assign {q_data, sop} = q;
assign writedata = {is_data, is_sop};

alt_vipitc131_common_fifo input_fifo(
    .wrclk(is_clk),
    .rdreq(rdreq_pre_swap),
    .aclr(rst),
    .rdclk(vid_clk_int),
    .wrreq(is_valid),
    .data(writedata),
    .rdempty(empty),
    .rdusedw(rdusedw),
    .q(q),
    .wrusedw(usedw));

defparam
    input_fifo.DATA_WIDTH = DATA_WIDTH + 1,
    input_fifo.CLOCKS_ARE_SAME = CLOCKS_ARE_SAME,
    input_fifo.FIFO_DEPTH = FIFO_DEPTH_INT;

// The fifo read latency is one, so the valid is a registered version of the 
// read request.
reg request_data_stalled;
reg sync_lost;
reg interlaced_field_valid;
wire interlaced_field_valid_nxt;
wire start_of_vsync_nxt;
wire lost_field_sync;

assign lost_field_sync = genlock_enable_sync1[0] & (vid_f_nxt ^ field_prediction);
assign ap_synched = start_of_ap_nxt & ~lost_field_sync;
assign rdreq = request_data & ~empty;
assign start_of_ap_nxt = ap & ~start_of_ap;
assign interlaced_field_valid_nxt = (state == WIDTH_3 || interlaced_field_valid) && 
        						    !(state == SYNCHED && state_next != SYNCHED); // interlaced field is valid until the end of ap
assign field_prediction_nxt = (interlaced_field_valid_nxt) ? interlaced_field[2] :
                              (state == SYNCHED && state_next != SYNCHED) ? ~field_prediction & interlaced_field[3] : 
                                                                            field_prediction & interlaced_field[3];
assign anc_valid_word_nxt = (state_next == INSERT_ANC) && anc_datavalid_nxt; // when the next packet is received we start filling with blanking
                                                                             // (state_next == INSERT_ANC) breaks if READY_LATENCY != 2

generate
    if(USE_EMBEDDED_SYNCS)
        assign start_of_vsync_nxt = vid_v_pipeline[READ_LATENCY-2] & ~vid_v_pipeline[READ_LATENCY-1];
    else
        assign start_of_vsync_nxt = vid_v_sync_pipeline[READ_LATENCY-2] & ~vid_v_sync_pipeline[READ_LATENCY-1];
endgenerate

always @ (posedge rst_vid_clk or posedge vid_clk_int) begin
    if(rst_vid_clk) begin
        start_of_ap <= 1'b0;
        start_of_vsync <= 1'b0;
        request_data <= 1'b0;
        request_data_stalled <= 1'b0;
        request_data_valid <= 1'b0;
        sync_lost <= 1'b0;
        reset_counters <= 1'b0;
        interlaced_field_valid <= 1'b0;
        field_prediction <= 1'b0;
        sop_reg <= 1'b0;
    end else begin
        start_of_ap <= (start_of_frame | vid_v_nxt | reset_counters) ? 1'b0 : ap | start_of_ap;
        start_of_vsync <= start_of_vsync_nxt;
        request_data <= ~(find_mode_nxt ||
                         wait_for_anc_nxt ||
                         state == FIND_MODE ||
                         state == WAIT_FOR_SYNCH ||
                         state == WAIT_FOR_ANC ||
                         (state == SYNCHED && ~vid_datavalid_nxt) ||
                         (state == INSERT_ANC && ~anc_datavalid_nxt)) ||
                         (request_data_stalled && ~rdreq);
        request_data_stalled <= ((state != state_next && (state_next == FIND_MODE || state_next == WAIT_FOR_ANC)) || request_data_stalled) && ~rdreq;
        request_data_valid <= rdreq;
        sync_lost <= (( (state != FIND_MODE && state != WAIT_FOR_SYNCH && start_of_ap_nxt)      			                             // late sop
                     || (state == SYNCHED && request_data_valid && sop && !vid_v_pipeline[READ_LATENCY-2])                               // early sop
                     || (underflow_nxt)                                                                                                  // underflow
        			 || (state == SYNCHED && interlaced_field_valid && interlaced_field[3] && (field_prediction != vid_f_nxt))   	     // interlaced fields have got out of sync
        			 || sync_lost) && !reset_counters && !mode_change) && !genlock_enable_sync1[0];
        reset_counters <= sync_lost && (state_next == WAIT_FOR_SYNCH);
        interlaced_field_valid <= interlaced_field_valid_nxt;
        field_prediction <= field_prediction_nxt;
        sop_reg <= sop;
    end
end

generate
    begin : generate_control_header
        genvar i;
        genvar symbol;
        for(symbol = 0; symbol < 9; symbol = symbol + NUMBER_OF_COLOUR_PLANES_IN_PARALLEL) begin : header_extraction            
            for(i = 0; i < NUMBER_OF_COLOUR_PLANES_IN_PARALLEL; i = i + 1) begin  : unpack_control_header
                always @ (posedge rst_vid_clk or posedge vid_clk_int) begin
                    if(rst_vid_clk) begin
                        case(symbol + i)
                            0 : samples[15:12] <= 4'd0;
                            1 : samples[11:8] <= 4'd0;
                            2 : samples[7:4] <= 4'd0;
                            3 : samples[3:0] <= 4'd0;
                            4 : lines[15:12] <= 4'd0;
                            5 : lines[11:8] <= 4'd0;
                            6 : lines[7:4] <= 4'd0;
                            7 : lines[3:0] <= 4'd0;
                            8 : interlaced_field <= 4'd0;
                        endcase
                    end else begin
                        if(state == (WIDTH_3 + symbol/NUMBER_OF_COLOUR_PLANES_IN_PARALLEL)) begin
                            case(symbol + i)
                                0 : samples[15:12] <= q_data[BPS*i+3:BPS*i];
                                1 : samples[11:8] <= q_data[BPS*i+3:BPS*i];
                                2 : samples[7:4] <= q_data[BPS*i+3:BPS*i];
                                3 : samples[3:0] <= q_data[BPS*i+3:BPS*i];
                                4 : lines[15:12] <= q_data[BPS*i+3:BPS*i];
                                5 : lines[11:8] <= q_data[BPS*i+3:BPS*i];
                                6 : lines[7:4] <= q_data[BPS*i+3:BPS*i];
                                7 : lines[3:0] <= q_data[BPS*i+3:BPS*i];
                                8 : interlaced_field <= q_data[BPS*i+3:BPS*i];
                            endcase
                        end
                    end
                end
            end
        end
    end
endgenerate

assign find_mode_nxt = state_next == FIND_MODE;
assign wait_for_anc_nxt = state_next == WAIT_FOR_ANC;

alt_vipitc131_IS2Vid_statemachine #(
   .USE_EMBEDDED_SYNCS(USE_EMBEDDED_SYNCS),
   .NUMBER_OF_COLOUR_PLANES_IN_PARALLEL(NUMBER_OF_COLOUR_PLANES_IN_PARALLEL),
   .IDLE(IDLE),
   .FIND_SOP(FIND_SOP),
   .WIDTH_3(WIDTH_3),
   .WIDTH_2(WIDTH_2),
   .WIDTH_1(WIDTH_1),
   .WIDTH_0(WIDTH_0),
   .HEIGHT_3(HEIGHT_3), 
   .HEIGHT_2(HEIGHT_2),
   .HEIGHT_1(HEIGHT_1),
   .HEIGHT_0(HEIGHT_0),
   .INTERLACING(INTERLACING),
   .FIND_MODE(FIND_MODE),
   .SYNCHED(SYNCHED),
   .WAIT_FOR_SYNCH(WAIT_FOR_SYNCH),
   .WAIT_FOR_ANC(WAIT_FOR_ANC),
   .INSERT_ANC(INSERT_ANC)
)
statemachine(
   .rst(rst_vid_clk),
   .clk(vid_clk_int),
   
   .request_data_valid(request_data_valid),
   .sop(sop),
   .vid_v_nxt(vid_v_nxt),
   .anc_datavalid_nxt(anc_datavalid_nxt),
   .q_data(q_data[3:0]),
   .sync_lost(sync_lost),
   .anc_underflow_nxt(anc_underflow_nxt),
   .ap_synched(ap_synched),
   .enable_synced_nxt(enable_synced_nxt),
   .state_next(state_next),
   .state(state));

generate begin : sync_generation_generate
    if(GENERATE_SYNC) begin
        wire restart_count;
        assign restart_count = restart_sample_count | restart_line_count;
    
        alt_vipitc131_common_sync_generation sync_generation(
            .rst(rst_vid_clk),
            .clk(vid_clk_int),
            
            .clear_enable(restart_count),
            .enable_count(1'b1),
            .hd_sdn(~serial_output),
            .start_of_vsync(start_of_vsync),
            .field_prediction(field_prediction),
            .interlaced(interlaced),
            .total_sample_count(h_total_minus_one[13:0]),
            .total_sample_count_valid(1'b1),
            .total_line_count(v_total_minus_one[13:0]),
            .total_line_count_valid(1'b1),
            .stable(enable_synced_nxt),
            
            .divider_value(vcoclk_divider_value),
            .sof_sample(sof_sample),
            .sof_line(sof_line),
            .sof_subsample(sof_subsample),
            
            .output_enable(genlock_enable_sync1[0]),
            .sof(vid_sof),
            .sof_locked(vid_sof_locked),
            .div(vid_vcoclk_div));

            defparam sync_generation.NUMBER_OF_COLOUR_PLANES = NUMBER_OF_COLOUR_PLANES,
                     sync_generation.COLOUR_PLANES_ARE_IN_PARALLEL = COLOUR_PLANES_ARE_IN_PARALLEL,
                     sync_generation.LOG2_NUMBER_OF_COLOUR_PLANES = LOG2_COLOUR_PLANES_IN_SEQUENCE,
                     sync_generation.TOTALS_MINUS_ONE = 1;
        
        assign sync_compare_h_reset[15:13] = 3'b000;
        assign sync_compare_v_reset[15:13] = 3'b000;
        
        wire sof_cvi_sync1;
        wire sof_cvi_locked_sync1;
        wire vid_sof_sync1;
        
        alt_vipitc131_common_sync #(0) sof_cvi_sync(
                    .rst(rst_vid_clk),
                    .sync_clock(vid_clk_int),
                    .data_in(sof),
                    .data_out(sof_cvi_sync1));
                    
        alt_vipitc131_common_sync #(0) sof_cvi_locked_sync(
                    .rst(rst_vid_clk),
                    .sync_clock(vid_clk_int),
                    .data_in(sof_locked),
                    .data_out(sof_cvi_locked_sync1));
        
        // delay vid_sof by the same amount so they are aligned when comparing
        alt_vipitc131_common_sync #(0) sof_cvo_sync(
                    .rst(rst_vid_clk),
                    .sync_clock(vid_clk_int),
                    .data_in(vid_sof),
                    .data_out(vid_sof_sync1));
        
        alt_vipitc131_IS2Vid_sync_compare sync_compare(
            .rst(rst_vid_clk),
            .clk(vid_clk_int),
            
            // control signals
            .genlock_enable(genlock_enable_sync1),
            .serial_output(serial_output),
            .h_total_minus_one(h_total_minus_one[13:0]),
            .restart_count(restart_count),
            .divider_value(vcoclk_divider_value),
            
            // control signals to is2vid
            .sync_lines(sync_lines),
            .sync_samples(sync_samples),
            .remove_repeatn(remove_repeatn),
            .sync_compare_h_reset(sync_compare_h_reset[12:0]),
            .sync_compare_v_reset(sync_compare_v_reset[12:0]),
            .genlocked(genlocked),
            
            // sync signals from CVI
            .sof_cvi(sof_cvi_sync1),
            .sof_cvi_locked(sof_cvi_locked_sync1),
            
            // sync signals from CVO
            .sof_cvo(vid_sof_sync1),
            .sof_cvo_locked(vid_sof_locked));
        
        defparam
            sync_compare.NUMBER_OF_COLOUR_PLANES = NUMBER_OF_COLOUR_PLANES,
            sync_compare.COLOUR_PLANES_ARE_IN_PARALLEL = COLOUR_PLANES_ARE_IN_PARALLEL,
            sync_compare.LOG2_NUMBER_OF_COLOUR_PLANES = LOG2_COLOUR_PLANES_IN_SEQUENCE;
            
    end else begin
        assign vid_sof = 1'b0;
        assign vid_sof_locked = 1'b0;
        assign vid_vcoclk_div = 1'b0;
        assign remove_repeatn = 1'b0;
        assign sync_compare_h_reset = v_offset_const[15:0];
        assign sync_compare_v_reset = v_offset_const[15:0];
        assign sync_samples = 1'b0;
        assign sync_lines = 1'b0;
        assign genlocked = 1'b0;
    end
end endgenerate

endmodule
