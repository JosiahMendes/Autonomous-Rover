module alt_vipitc131_IS2Vid_calculate_mode(
    input [3:0] trs,
    input is_interlaced,
    input is_serial_output,
    input [15:0] is_sample_count_f0,
    input [15:0] is_line_count_f0,
    input [15:0] is_sample_count_f1,
    input [15:0] is_line_count_f1,
    input [15:0] is_h_front_porch,
    input [15:0] is_h_sync_length,
    input [15:0] is_h_blank,
    input [15:0] is_v_front_porch,
    input [15:0] is_v_sync_length,
    input [15:0] is_v_blank,
    input [15:0] is_v1_front_porch,
    input [15:0] is_v1_sync_length,
    input [15:0] is_v1_blank,
    input [15:0] is_ap_line,
    input [15:0] is_v1_rising_edge,
    input [15:0] is_f_rising_edge,
    input [15:0] is_f_falling_edge,
    input [15:0] is_anc_line,
    input [15:0] is_v1_anc_line,
    
    output interlaced_nxt,
    output serial_output_nxt,
    output [15:0] h_total_minus_one_nxt,
    output [15:0] v_total_minus_one_nxt,
    output [15:0] ap_line_nxt,
    output [15:0] ap_line_end_nxt,
    output [15:0] h_blank_nxt,
    output [15:0] sav_nxt,
    output [15:0] h_sync_start_nxt,
    output [15:0] h_sync_end_nxt,
    output [15:0] f2_v_start_nxt,
    output [15:0] f1_v_start_nxt,
    output [15:0] f1_v_end_nxt,
    output [15:0] f2_v_sync_start_nxt,
    output [15:0] f2_v_sync_end_nxt,
    output [15:0] f1_v_sync_start_nxt,
    output [15:0] f1_v_sync_end_nxt,
    output [15:0] f_rising_edge_nxt,
    output [15:0] f_falling_edge_nxt,
    output [12:0] total_line_count_f0_nxt,
    output [12:0] total_line_count_f1_nxt,
    output [15:0] f2_anc_v_start_nxt,
    output [15:0] f1_anc_v_start_nxt
);

wire [15:0] v_active_lines;
wire [15:0] v_total;
wire [15:0] v1_rising_edge;
wire [15:0] v2_rising_edge;
wire [15:0] f1_v_sync;
wire [15:0] f2_v_sync;
wire [15:0] total_line_count_f0_nxt_full;
wire [15:0] total_line_count_f1_nxt_full;

assign v_active_lines = (is_interlaced ? is_line_count_f1 : 16'd0) + is_line_count_f0;
assign v_total = v_active_lines + (is_interlaced ? is_v1_blank : 16'd0) + is_v_blank;
assign v1_rising_edge = is_v1_rising_edge - is_ap_line;
assign v2_rising_edge = v_active_lines + (is_interlaced ? is_v1_blank : 16'd0);
assign f1_v_sync = v1_rising_edge + is_v1_front_porch;
assign f2_v_sync = v2_rising_edge + is_v_front_porch;

assign interlaced_nxt = is_interlaced;
assign serial_output_nxt = is_serial_output;

// counter wrapping
assign h_total_minus_one_nxt = is_sample_count_f0 + is_h_blank - 16'd1;
assign v_total_minus_one_nxt = v_total - 16'd1;

// line numbering
assign ap_line_nxt = is_ap_line;
assign ap_line_end_nxt = v_total - is_ap_line;

// horizontal blanking end
assign h_blank_nxt = is_h_blank;
assign sav_nxt = is_h_blank - trs;

// horizontal sync start & end
assign h_sync_start_nxt = is_h_front_porch;
assign h_sync_end_nxt = is_h_front_porch + is_h_sync_length;

// f2 vertical blanking start
assign f2_v_start_nxt = v2_rising_edge;

// f1 vertical blanking start & end
assign f1_v_start_nxt = v1_rising_edge;
assign f1_v_end_nxt = v1_rising_edge + is_v1_blank;

// f2 vertical sync start & end
assign f2_v_sync_start_nxt = f2_v_sync;
assign f2_v_sync_end_nxt = f2_v_sync + is_v_sync_length;

// f1 vertical sync start and end
assign f1_v_sync_start_nxt = f1_v_sync;
assign f1_v_sync_end_nxt = f1_v_sync + is_v1_sync_length;

// f rising edge
assign f_rising_edge_nxt = is_f_rising_edge - is_ap_line;
assign f_falling_edge_nxt = v_total - (is_ap_line - is_f_falling_edge);

// sync generation
assign total_line_count_f0_nxt_full = is_line_count_f0 + (is_v_blank - is_v_front_porch + is_v1_front_porch) - 16'd1;
assign total_line_count_f1_nxt_full = is_line_count_f1 + (is_v1_blank - is_v1_front_porch + is_v_front_porch) - 16'd1;
assign total_line_count_f0_nxt = total_line_count_f0_nxt_full[12:0];
assign total_line_count_f1_nxt = total_line_count_f1_nxt_full[12:0];

// ancilliary data position
assign f2_anc_v_start_nxt = v_total - (is_ap_line - is_anc_line);
assign f1_anc_v_start_nxt = is_v1_anc_line - is_ap_line;

endmodule
