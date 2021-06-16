module alt_vipitc131_IS2Vid_mode_banks
    #(parameter
        USE_CONTROL = 0,
        NO_OF_MODES_INT = 0,
        LOG2_NO_OF_MODES = 0,
        COLOUR_PLANES_ARE_IN_PARALLEL = 0,
        TRS = 0,
        INTERLACED = 0,
        H_ACTIVE_PIXELS = 0,
        F0_LINE_COUNT = 0,
        F1_LINE_COUNT = 0,
        H_FRONT_PORCH = 0,
        H_SYNC_LENGTH = 0,
        H_BLANK_INT = 0,
        V_FRONT_PORCH = 0,
        V_SYNC_LENGTH = 0,
        V_BLANK_INT = 0,
        FIELD0_V_FRONT_PORCH = 0,
        FIELD0_V_SYNC_LENGTH = 0,
        FIELD0_V_BLANK_INT = 0,
        AP_LINE = 0,
        FIELD0_V_RISING_EDGE = 0,
        F_RISING_EDGE = 0,
        F_FALLING_EDGE = 0,
        CONVERT_SEQ_TO_PAR = 0,
        TRS_SEQUENCE = 0,
        TRS_PARALLEL = 0,
        STD_WIDTH = 1,
        ANC_LINE = 0,
        FIELD0_ANC_LINE = 0)
    (
    input   wire rst,
    input   wire clk,
    
    // From control
    input   wire mode_write,
    input   wire find_mode_nxt,
    input   wire [7:0] av_address,
    input   wire [15:0] av_writedata,
    
    // To control
    output  wire [NO_OF_MODES_INT-1:0] mode_match_safe,
    output  wire dirty_modes,
    output  wire mode_change,
    
    // To video output
    output  wire [STD_WIDTH-1:0] vid_std,
    output  wire vid_mode_change,
    
    // From video output
    input   wire [3:0] interlaced_field,
    input   wire field_prediction,
    input   wire [15:0] samples,
    input   wire [15:0] lines,
    
    // To video output
    output  wire interlaced,
    output  wire serial_output,
    output  wire [15:0] h_total_minus_one,
    output  wire [15:0] v_total_minus_one,
    output  wire [15:0] ap_line,
    output  wire [15:0] ap_line_end,
    output  wire [15:0] h_blank,
    output  wire [15:0] sav,
    output  wire [15:0] h_sync_start,
    output  wire [15:0] h_sync_end,
    output  wire [15:0] f2_v_start,
    output  wire [15:0] f1_v_start,
    output  wire [15:0] f1_v_end,
    output  wire [15:0] f2_v_sync_start,
    output  wire [15:0] f2_v_sync_end,
    output  wire [15:0] f1_v_sync_start,
    output  wire [15:0] f1_v_sync_end,
    output  wire [15:0] f_rising_edge,
    output  wire [15:0] f_falling_edge,
    output  wire [15:0] f1_v_end_nxt,
    output  wire [13:0] sof_sample,
    output  wire [12:0] sof_line,
    output  wire [1:0] sof_subsample,
    output  wire [13:0] vcoclk_divider_value,
    output  wire [15:0] f2_anc_v_start,
    output  wire [15:0] f1_anc_v_start);
    
localparam REGISTERS_PER_MODE = 23;
    
function integer get_register_address;
    input integer mode;
    input integer register_no;
    begin
        get_register_address = (mode*(REGISTERS_PER_MODE+1))+5+register_no;
    end
endfunction

wire interlaced_rst;
wire serial_output_rst;
wire [15:0] h_total_minus_one_rst;
wire [15:0] v_total_minus_one_rst;
wire [15:0] ap_line_rst;
wire [15:0] ap_line_end_rst;
wire [15:0] h_blank_rst;
wire [15:0] sav_rst;
wire [15:0] h_sync_start_rst;
wire [15:0] h_sync_end_rst;
wire [15:0] f2_v_start_rst;
wire [15:0] f1_v_start_rst;
wire [15:0] f1_v_end_rst;
wire [15:0] f2_v_sync_start_rst;
wire [15:0] f2_v_sync_end_rst;
wire [15:0] f1_v_sync_start_rst;
wire [15:0] f1_v_sync_end_rst;
wire [15:0] f_rising_edge_rst;
wire [15:0] f_falling_edge_rst;
wire [15:0] f2_anc_v_start_rst;
wire [15:0] f1_anc_v_start_rst;

// default mode values
alt_vipitc131_IS2Vid_calculate_mode u_calculate_mode(
    .trs(TRS),
    .is_interlaced(INTERLACED),
    .is_serial_output(!COLOUR_PLANES_ARE_IN_PARALLEL),
    .is_sample_count_f0(H_ACTIVE_PIXELS),
    .is_line_count_f0(F0_LINE_COUNT),
    .is_sample_count_f1(H_ACTIVE_PIXELS),
    .is_line_count_f1(F1_LINE_COUNT),
    .is_h_front_porch(H_FRONT_PORCH),
    .is_h_sync_length(H_SYNC_LENGTH),
    .is_h_blank(H_BLANK_INT),
    .is_v_front_porch(V_FRONT_PORCH),
    .is_v_sync_length(V_SYNC_LENGTH),
    .is_v_blank(V_BLANK_INT),
    .is_v1_front_porch(FIELD0_V_FRONT_PORCH),
    .is_v1_sync_length(FIELD0_V_SYNC_LENGTH),
    .is_v1_blank(FIELD0_V_BLANK_INT),
    .is_ap_line(AP_LINE),
    .is_v1_rising_edge(FIELD0_V_RISING_EDGE),
    .is_f_rising_edge(F_RISING_EDGE),
    .is_f_falling_edge(F_FALLING_EDGE),
    .is_anc_line(ANC_LINE),
    .is_v1_anc_line(FIELD0_ANC_LINE),
    
    .interlaced_nxt(interlaced_rst),
    .serial_output_nxt(serial_output_rst),
    .h_total_minus_one_nxt(h_total_minus_one_rst),
    .v_total_minus_one_nxt(v_total_minus_one_rst),
    .ap_line_nxt(ap_line_rst),
    .ap_line_end_nxt(ap_line_end_rst),
    .h_blank_nxt(h_blank_rst),
    .sav_nxt(sav_rst),
    .h_sync_start_nxt(h_sync_start_rst),
    .h_sync_end_nxt(h_sync_end_rst),
    .f2_v_start_nxt(f2_v_start_rst),
    .f1_v_start_nxt(f1_v_start_rst),
    .f1_v_end_nxt(f1_v_end_rst),
    .f2_v_sync_start_nxt(f2_v_sync_start_rst),
    .f2_v_sync_end_nxt(f2_v_sync_end_rst),
    .f1_v_sync_start_nxt(f1_v_sync_start_rst),
    .f1_v_sync_end_nxt(f1_v_sync_end_rst),
    .f_rising_edge_nxt(f_rising_edge_rst),
    .f_falling_edge_nxt(f_falling_edge_rst),
    .f2_anc_v_start_nxt(f2_anc_v_start_rst),
    .f1_anc_v_start_nxt(f1_anc_v_start_rst));
    
// The control interface has one register bit 0 of which (when set to a 1) 
// enables the ImageStream output.
generate
    if(USE_CONTROL) begin
        reg is_valid_mode[NO_OF_MODES_INT-1:0];
        reg is_interlaced[NO_OF_MODES_INT-1:0];
        reg is_serial_output[NO_OF_MODES_INT-1:0];
        reg [15:0] is_sample_count[NO_OF_MODES_INT-1:0];
        reg [15:0] is_line_count_f0[NO_OF_MODES_INT-1:0];
        reg [15:0] is_line_count_f1[NO_OF_MODES_INT-1:0];
        reg [15:0] is_h_front_porch[NO_OF_MODES_INT-1:0];
        reg [15:0] is_h_sync_length[NO_OF_MODES_INT-1:0];
        reg [15:0] is_h_blank[NO_OF_MODES_INT-1:0];
        reg [15:0] is_v_front_porch[NO_OF_MODES_INT-1:0];
        reg [15:0] is_v_sync_length[NO_OF_MODES_INT-1:0];
        reg [15:0] is_v_blank[NO_OF_MODES_INT-1:0];
        reg [15:0] is_v1_front_porch[NO_OF_MODES_INT-1:0];
        reg [15:0] is_v1_sync_length[NO_OF_MODES_INT-1:0];
        reg [15:0] is_v1_blank[NO_OF_MODES_INT-1:0];
        reg [15:0] is_ap_line[NO_OF_MODES_INT-1:0];
        reg [15:0] is_v1_rising_edge[NO_OF_MODES_INT-1:0];
        reg [15:0] is_f_rising_edge[NO_OF_MODES_INT-1:0];
        reg [15:0] is_f_falling_edge[NO_OF_MODES_INT-1:0];
        reg [STD_WIDTH-1:0] is_standard[NO_OF_MODES_INT-1:0];
        reg [13:0] is_sof_sample[NO_OF_MODES_INT-1:0];
        reg [1:0]  is_sof_subsample[NO_OF_MODES_INT-1:0];
        reg [12:0] is_sof_line[NO_OF_MODES_INT-1:0];
        reg [13:0] is_vcoclk_divider_value[NO_OF_MODES_INT-1:0];
        reg [15:0] is_anc_line[NO_OF_MODES_INT-1:0];
        reg [15:0] is_v1_anc_line[NO_OF_MODES_INT-1:0];
        reg [NO_OF_MODES_INT-1:0] dirty_mode;
        reg [NO_OF_MODES_INT-1:0] mode_match;
        reg [NO_OF_MODES_INT-1:0] mode_match_reg;
        reg find_mode;
        reg dirty_modes_reg;
        
        always @ (posedge rst or posedge clk) begin
            if(rst) begin
                find_mode <= 1'b0;
                dirty_modes_reg <= 1'b0;
            end else begin
                find_mode <= find_mode_nxt;
                dirty_modes_reg <= |dirty_mode;
            end
        end
        
        genvar i;
        for(i = 0; i < NO_OF_MODES_INT; i = i + 1) begin : is_registers
            always @ (posedge rst or posedge clk) begin
                if(rst) begin
                    is_valid_mode[i] <= 1'b0;
                    is_interlaced[i] <= 1'b0;
                    is_serial_output[i] <= 1'b0;
                    is_sample_count[i] <= 16'd0;
                    is_line_count_f0[i] <= 16'd0;
                    is_line_count_f1[i] <= 16'd0;
                    is_h_front_porch[i] <= 16'd0;
                    is_h_sync_length[i] <= 16'd0;
                    is_h_blank[i] <= 16'd0;
                    is_v_front_porch[i] <= 16'd0;
                    is_v_sync_length[i] <= 16'd0;
                    is_v_blank[i] <= 16'd0;
                    is_v1_front_porch[i] <= 16'd0;
                    is_v1_sync_length[i] <= 16'd0;
                    is_v1_blank[i] <= 16'd0;
                    is_ap_line[i] <= 16'd0;
                    is_v1_rising_edge[i] <= 16'd0;
                    is_f_rising_edge[i] <= 16'd0;
                    is_f_falling_edge[i] <= 16'd0;
                    is_standard[i] <= {STD_WIDTH{1'b0}};
                    is_sof_sample[i] <= 14'd0;
                    is_sof_subsample[i] <= 2'd0;
                    is_sof_line[i] <= 13'd0;
                    is_vcoclk_divider_value[i] <= 14'd0;
                    is_anc_line[i] <= 16'd0;
                    is_v1_anc_line[i] <= 16'd0;
                    dirty_mode[i] <= 1'b0;
                    mode_match[i] <= 1'b0;
                end else begin
                    if(mode_write) begin
                        if(~is_valid_mode[i]) begin
                            if(av_address == get_register_address(i, 0)) begin
                                is_interlaced[i] <= av_writedata[0];
                                if(CONVERT_SEQ_TO_PAR)
                                    is_serial_output[i] <= av_writedata[1];
                                else
                                    is_serial_output[i] <= serial_output_rst;
                            end
                            is_sample_count[i] <= (av_address == get_register_address(i, 1)) ? av_writedata : is_sample_count[i];
                            is_line_count_f0[i] <= (av_address == get_register_address(i, 2)) ? av_writedata : is_line_count_f0[i];
                            is_line_count_f1[i] <= (av_address == get_register_address(i, 3)) ? av_writedata : is_line_count_f1[i];
                            is_h_front_porch[i] <= (av_address == get_register_address(i, 4)) ? av_writedata : is_h_front_porch[i];
                            is_h_sync_length[i] <= (av_address == get_register_address(i, 5)) ? av_writedata : is_h_sync_length[i];
                            is_h_blank[i] <= (av_address == get_register_address(i, 6)) ? av_writedata : is_h_blank[i];
                            is_v_front_porch[i] <= (av_address == get_register_address(i, 7)) ? av_writedata : is_v_front_porch[i];
                            is_v_sync_length[i] <= (av_address == get_register_address(i, 8)) ? av_writedata : is_v_sync_length[i];
                            is_v_blank[i] <= (av_address == get_register_address(i, 9)) ? av_writedata : is_v_blank[i];
                            is_v1_front_porch[i] <= (av_address == get_register_address(i, 10)) ? av_writedata : is_v1_front_porch[i];
                            is_v1_sync_length[i] <= (av_address == get_register_address(i, 11)) ? av_writedata : is_v1_sync_length[i];
                            is_v1_blank[i] <= (av_address == get_register_address(i, 12)) ? av_writedata : is_v1_blank[i];
                            is_ap_line[i] <= (av_address == get_register_address(i, 13)) ? av_writedata : is_ap_line[i];
                            is_v1_rising_edge[i] <= (av_address == get_register_address(i, 14)) ? av_writedata : is_v1_rising_edge[i];
                            is_f_rising_edge[i] <= (av_address == get_register_address(i, 15)) ? av_writedata : is_f_rising_edge[i];
                            is_f_falling_edge[i] <= (av_address == get_register_address(i, 16)) ? av_writedata : is_f_falling_edge[i];
                            is_standard[i] <= (av_address == get_register_address(i, 17)) ? av_writedata[STD_WIDTH-1:0] : is_standard[i];
                            if(av_address == get_register_address(i, 18)) begin
                                is_sof_sample[i] <= av_writedata[15:2];
                                is_sof_subsample[i] <= av_writedata[1:0];
                            end
                            is_sof_line[i] <= (av_address == get_register_address(i, 19)) ? av_writedata[12:0] : is_sof_line[i];
                            is_vcoclk_divider_value[i] <= (av_address == get_register_address(i, 20)) ? av_writedata[13:0] : is_vcoclk_divider_value[i];
                            is_anc_line[i] <= (av_address == get_register_address(i, 21)) ? av_writedata[15:0] : is_anc_line[i];
                            is_v1_anc_line[i] <= (av_address == get_register_address(i, 22)) ? av_writedata[15:0] : is_v1_anc_line[i];
                        end
                        is_valid_mode[i] <= (av_address == get_register_address(i, 23)) ? av_writedata[0] : is_valid_mode[i];
                    end
                    dirty_mode[i] <= (mode_write && av_address == get_register_address(i, 23) && av_writedata[0]) || (dirty_mode[i] && ~mode_change);
                    
                    mode_match[i] <= ({interlaced_field[3], field_prediction} == 2'b11) ? is_valid_mode[i] & is_interlaced[i] & samples == is_sample_count[i] & lines == is_line_count_f1[i] : // f1
                                     ({interlaced_field[3], field_prediction} == 2'b10) ? is_valid_mode[i] & is_interlaced[i] & samples == is_sample_count[i] & lines == is_line_count_f0[i] : // f0
                                                                        is_valid_mode[i] & samples == is_sample_count[i] & lines == is_line_count_f0[i]; // progressive
                end
            end
        end
        
        assign dirty_modes = dirty_modes_reg;
        
        wire interlaced_nxt;
        wire serial_output_nxt;
        wire [15:0] h_total_minus_one_nxt;
        wire [15:0] v_total_minus_one_nxt;
        wire [15:0] ap_line_nxt;
        wire [15:0] ap_line_end_nxt;
        wire [15:0] h_blank_nxt;
        wire [15:0] sav_nxt;
        wire [15:0] h_sync_start_nxt;
        wire [15:0] h_sync_end_nxt;
        wire [15:0] f2_v_start_nxt;
        wire [15:0] f1_v_start_nxt;
        wire [15:0] f2_v_sync_start_nxt;
        wire [15:0] f2_v_sync_end_nxt;
        wire [15:0] f1_v_sync_start_nxt;
        wire [15:0] f1_v_sync_end_nxt;
        wire [15:0] f_rising_edge_nxt;
        wire [15:0] f_falling_edge_nxt;
        wire [15:0] f2_anc_v_start_nxt;
        wire [15:0] f1_anc_v_start_nxt;
        
        reg interlaced_reg;
        reg serial_output_reg;
        reg [15:0] h_total_minus_one_reg;
        reg [15:0] v_total_minus_one_reg;
        reg [15:0] ap_line_reg;
        reg [15:0] ap_line_end_reg;
        reg [15:0] h_blank_reg;
        reg [15:0] sav_reg;
        reg [15:0] h_sync_start_reg;
        reg [15:0] h_sync_end_reg;
        reg [15:0] f2_v_start_reg;
        reg [15:0] f1_v_start_reg;
        reg [15:0] f1_v_end_reg;
        reg [15:0] f2_v_sync_start_reg;
        reg [15:0] f2_v_sync_end_reg;
        reg [15:0] f1_v_sync_start_reg;
        reg [15:0] f1_v_sync_end_reg;
        reg [15:0] f_rising_edge_reg;
        reg [15:0] f_falling_edge_reg;
        reg [STD_WIDTH-1:0] standard_reg;
        reg [13:0] sof_sample_reg;
        reg [1:0]  sof_subsample_reg;
        reg [12:0] sof_line_reg;
        reg [13:0] vcoclk_divider_value_reg;
        reg [15:0] f2_anc_v_start_reg;
        reg [15:0] f1_anc_v_start_reg;
        
        wire [LOG2_NO_OF_MODES-1:0] mode;
        reg mode_change_reg;
        
        if(NO_OF_MODES_INT > 1) begin
            // If more than 1 mode matches the lowest indexed takes precidence
            assign mode_match_safe[0] = mode_match[0];
            for(i = 1; i < NO_OF_MODES_INT; i = i + 1) begin : is_registers
                assign mode_match_safe[i] = mode_match[i] & ~|mode_match[i-1:0];
            end
            
            alt_vipitc131_common_to_binary u_to_binary(
                .one_hot(mode_match_safe[NO_OF_MODES_INT-1:1]),
                .binary(mode)
            );

			defparam u_to_binary.NO_OF_MODES = NO_OF_MODES_INT - 1,
			         u_to_binary.LOG2_NO_OF_MODES = LOG2_NO_OF_MODES;
        end else begin
            assign mode = 1'b0;
            assign mode_match_safe = mode_match;
        end
        
        assign mode_change = find_mode & |mode_match_safe & (|(mode_match_safe ^ mode_match_reg) | dirty_mode[mode]);
        assign vid_std = standard_reg;
        assign vid_mode_change = mode_change_reg;
        
        wire [3:0] trs_mux;
        assign trs_mux = (is_serial_output[mode]) ? TRS_SEQUENCE : TRS_PARALLEL;
        
        alt_vipitc131_IS2Vid_calculate_mode u_calculate_mode_dynamic(
            .trs(trs_mux),
            .is_interlaced(is_interlaced[mode]),
            .is_serial_output(is_serial_output[mode]),
            .is_sample_count_f0(is_sample_count[mode]),
            .is_line_count_f0(is_line_count_f0[mode]),
            .is_sample_count_f1(is_sample_count[mode]),
            .is_line_count_f1(is_line_count_f1[mode]),
            .is_h_front_porch(is_h_front_porch[mode]),
            .is_h_sync_length(is_h_sync_length[mode]),
            .is_h_blank(is_h_blank[mode]),
            .is_v_front_porch(is_v_front_porch[mode]),
            .is_v_sync_length(is_v_sync_length[mode]),
            .is_v_blank(is_v_blank[mode]),
            .is_v1_front_porch(is_v1_front_porch[mode]),
            .is_v1_sync_length(is_v1_sync_length[mode]),
            .is_v1_blank(is_v1_blank[mode]),
            .is_ap_line(is_ap_line[mode]),
            .is_v1_rising_edge(is_v1_rising_edge[mode]),
            .is_f_rising_edge(is_f_rising_edge[mode]),
            .is_f_falling_edge(is_f_falling_edge[mode]),
            .is_anc_line(is_anc_line[mode]),
            .is_v1_anc_line(is_v1_anc_line[mode]),
        
            .interlaced_nxt(interlaced_nxt),
            .serial_output_nxt(serial_output_nxt),
            .h_total_minus_one_nxt(h_total_minus_one_nxt),
            .v_total_minus_one_nxt(v_total_minus_one_nxt),
            .ap_line_nxt(ap_line_nxt),
            .ap_line_end_nxt(ap_line_end_nxt),
            .h_blank_nxt(h_blank_nxt),
            .sav_nxt(sav_nxt),
            .h_sync_start_nxt(h_sync_start_nxt),
            .h_sync_end_nxt(h_sync_end_nxt),
            .f2_v_start_nxt(f2_v_start_nxt),
            .f1_v_start_nxt(f1_v_start_nxt),
            .f1_v_end_nxt(f1_v_end_nxt),
            .f2_v_sync_start_nxt(f2_v_sync_start_nxt),
            .f2_v_sync_end_nxt(f2_v_sync_end_nxt),
            .f1_v_sync_start_nxt(f1_v_sync_start_nxt),
            .f1_v_sync_end_nxt(f1_v_sync_end_nxt),
            .f_rising_edge_nxt(f_rising_edge_nxt),
            .f_falling_edge_nxt(f_falling_edge_nxt),
            .f2_anc_v_start_nxt(f2_anc_v_start_nxt),
            .f1_anc_v_start_nxt(f1_anc_v_start_nxt));
        
        always @ (posedge rst or posedge clk) begin
            if(rst) begin
                mode_change_reg <= 1'b0;
                mode_match_reg <= {NO_OF_MODES_INT{1'b0}};
                interlaced_reg <= interlaced_rst;
                serial_output_reg <= serial_output_rst;
                h_total_minus_one_reg <= h_total_minus_one_rst;
                v_total_minus_one_reg <= v_total_minus_one_rst;
                ap_line_reg <= ap_line_rst;
                ap_line_end_reg <= ap_line_end_rst;
                h_blank_reg <= h_blank_rst;
                sav_reg <= sav_rst;
                h_sync_start_reg <= h_sync_start_rst;
                h_sync_end_reg <= h_sync_end_rst;
                f2_v_start_reg <= f2_v_start_rst;
                f1_v_start_reg <= f1_v_start_rst;
                f1_v_end_reg <= f1_v_end_rst;
                f2_v_sync_start_reg <= f2_v_sync_start_rst;
                f2_v_sync_end_reg <= f2_v_sync_end_rst;
                f1_v_sync_start_reg <= f1_v_sync_start_rst;
                f1_v_sync_end_reg <= f1_v_sync_end_rst;
                f_rising_edge_reg <= f_rising_edge_rst;
                f_falling_edge_reg <= f_falling_edge_rst;
                standard_reg <= {STD_WIDTH{1'b0}};
                sof_sample_reg <= 14'd0;
                sof_subsample_reg <= 2'd0;
                sof_line_reg <= 13'd0;
                vcoclk_divider_value_reg <= 14'd0;
                f2_anc_v_start_reg <= f2_anc_v_start_rst;
                f1_anc_v_start_reg <= f1_anc_v_start_rst;
            end else begin
                mode_change_reg <= mode_change;
                mode_match_reg <= (mode_change) ? mode_match_safe : mode_match_reg;
                
                if(mode_change) begin
                    interlaced_reg <= interlaced_nxt;
                    serial_output_reg = serial_output_nxt;

                    // counter wrapping
                    h_total_minus_one_reg <= h_total_minus_one_nxt;
                    v_total_minus_one_reg <= v_total_minus_one_nxt;

                    // line numbering
                    ap_line_reg <= ap_line_nxt;
                    ap_line_end_reg <= ap_line_end_nxt;

                    // horizontal blanking end
                    h_blank_reg <= h_blank_nxt;
                    sav_reg <= sav_nxt;

                    // horizontal sync start & end
                    h_sync_start_reg <= h_sync_start_nxt;
                    h_sync_end_reg <= h_sync_end_nxt;

                    // f2 vertical blanking start
                    f2_v_start_reg <= f2_v_start_nxt;

                    // f1 vertical blanking start & end
                    f1_v_start_reg <= f1_v_start_nxt;
                    f1_v_end_reg <= f1_v_end_nxt;

                    // f2 vertical sync start & end
                    f2_v_sync_start_reg <= f2_v_sync_start_nxt;
                    f2_v_sync_end_reg <= f2_v_sync_end_nxt;

                    // f1 vertical sync start and end
                    f1_v_sync_start_reg <= f1_v_sync_start_nxt;
                    f1_v_sync_end_reg <= f1_v_sync_end_nxt;

                    // f rising edge
                    f_rising_edge_reg <= f_rising_edge_nxt;
                    f_falling_edge_reg <= f_falling_edge_nxt;
                    
                    // for sync generation
                    standard_reg <= is_standard[mode];
                    sof_sample_reg <= is_sof_sample[mode];
                    sof_subsample_reg <= is_sof_subsample[mode];
                    sof_line_reg <= is_sof_line[mode];
                    vcoclk_divider_value_reg <= is_vcoclk_divider_value[mode];
                    
                    // ancilliary data position
                    f2_anc_v_start_reg <= f2_anc_v_start_nxt;
                    f1_anc_v_start_reg <= f1_anc_v_start_nxt;
                end
            end
        end
        
        assign interlaced = interlaced_reg;
        assign serial_output = serial_output_reg;

        // counter wrapping
        assign h_total_minus_one = h_total_minus_one_reg;
        assign v_total_minus_one = v_total_minus_one_reg;

        // line numbering
        assign ap_line = ap_line_reg;
        assign ap_line_end = ap_line_end_reg;

        // horizontal blanking end
        assign h_blank = h_blank_reg;
        assign sav = sav_reg;

        // horizontal sync start & end
        assign h_sync_start = h_sync_start_reg;
        assign h_sync_end = h_sync_end_reg;

        // f2 vertical blanking start
        assign f2_v_start = f2_v_start_reg;

        // f1 vertical blanking start & end
        assign f1_v_start = f1_v_start_reg;
        assign f1_v_end = f1_v_end_reg;

        // f2 vertical sync start & end
        assign f2_v_sync_start = f2_v_sync_start_reg;
        assign f2_v_sync_end = f2_v_sync_end_reg;

        // f1 vertical blanking start and end
        assign f1_v_sync_start = f1_v_sync_start_reg;
        assign f1_v_sync_end = f1_v_sync_end_reg;

        // f rising edge
        assign f_rising_edge = f_rising_edge_reg;
        assign f_falling_edge = f_falling_edge_reg;
        
        // for sync generation
        assign sof_sample = sof_sample_reg;
        assign sof_subsample = sof_subsample_reg;
        assign sof_line = sof_line_reg;
        assign vcoclk_divider_value = vcoclk_divider_value_reg;
        
        // ancilliary data position
        assign f2_anc_v_start = f2_anc_v_start_reg;
        assign f1_anc_v_start = f1_anc_v_start_reg;
    end else begin
        assign mode_change = 1'b0;
        assign vid_std = {STD_WIDTH{1'b0}};
        assign vid_mode_change = 1'b0;
        assign dirty_modes = 1'b0;
        
        assign interlaced = interlaced_rst;
        assign serial_output = serial_output_rst;

        // counter wrapping
        assign h_total_minus_one = h_total_minus_one_rst;
        assign v_total_minus_one = v_total_minus_one_rst;

        // line numbering
        assign ap_line = ap_line_rst;
        assign ap_line_end = ap_line_end_rst;

        // horizontal blanking end
        assign h_blank = h_blank_rst;
        assign sav = sav_rst;

        // horizontal sync start & end
        assign h_sync_start = h_sync_start_rst;
        assign h_sync_end = h_sync_end_rst;

        // f2 vertical blanking start
        assign f2_v_start = f2_v_start_rst;

        // f1 vertical blanking start & end
        assign f1_v_start = f1_v_start_rst;
        assign f1_v_end = f1_v_end_rst;
        assign f1_v_end_nxt = f1_v_end_rst;

        // f2 vertical sync start & end
        assign f2_v_sync_start = f2_v_sync_start_rst;
        assign f2_v_sync_end = f2_v_sync_end_rst;

        // f1 vertical blanking start and end
        assign f1_v_sync_start = f1_v_sync_start_rst;
        assign f1_v_sync_end = f1_v_sync_end_rst;

        // f rising edge
        assign f_rising_edge = f_rising_edge_rst;
        assign f_falling_edge = f_falling_edge_rst;
        
        // for sync generation
        assign sof_sample = 14'd0;
        assign sof_subsample = 2'd0;
        assign sof_line = 13'd0;
        assign vcoclk_divider_value = 14'd0;
        
        // ancilliary data position
        assign f2_anc_v_start = f2_anc_v_start_rst;
        assign f1_anc_v_start = f1_anc_v_start_rst;
        
        // this signal is not used in this mode
        assign mode_match_safe = {NO_OF_MODES_INT{1'b0}};
        
    end
endgenerate

endmodule
