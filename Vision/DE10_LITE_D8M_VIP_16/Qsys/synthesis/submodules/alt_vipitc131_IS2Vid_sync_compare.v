`define SC_IDLE 2'b00
`define SC_CVI 2'b01
`define SC_CVO 2'b10

module alt_vipitc131_IS2Vid_sync_compare(
    input wire rst,
    input wire clk,
    
    // control signals
    input wire [1:0] genlock_enable,
    input wire serial_output,
    input wire [13:0] h_total_minus_one,
    input wire restart_count,
    input wire [13:0] divider_value,
    
    // control signals to is2vid
    output reg  sync_lines,
    output reg  sync_samples,
    output reg  remove_repeatn,
    output reg  [12:0] sync_compare_h_reset,
    output reg  [12:0] sync_compare_v_reset,
    output reg  genlocked,
    
    // sync signals from CVI
    input wire sof_cvi,
    input wire sof_cvi_locked,
    
    // sync signals from CVO
    input wire sof_cvo,
    input wire sof_cvo_locked);

parameter NUMBER_OF_COLOUR_PLANES = 0;
parameter COLOUR_PLANES_ARE_IN_PARALLEL = 0;
parameter LOG2_NUMBER_OF_COLOUR_PLANES = 0;

wire sof_cvi_int;
wire sof_cvo_int;
reg sof_cvi_reg;
reg sof_cvo_reg;

always @ (posedge rst or posedge clk) begin
    if(rst) begin
        sof_cvi_reg <= 1'b0;
        sof_cvo_reg <= 1'b0;
    end else begin
        sof_cvi_reg <= sof_cvi;
        sof_cvo_reg <= sof_cvo;
    end
end

assign sof_cvi_int = sof_cvi & ~sof_cvi_reg;
assign sof_cvo_int = sof_cvo & ~sof_cvo_reg;

wire enable;
wire sclr;
wire sclr_frame_counter;
wire sclr_state;

assign enable = sof_cvi_locked & sof_cvo_locked & genlock_enable[1] & genlock_enable[0];
assign sclr = ~enable | restart_count;
assign sclr_frame_counter = sclr | sof_cvi_int | sof_cvo_int;
assign sclr_state = (sof_cvi_int & sof_cvo_int);

reg [13:0] h_count_repeat;
reg [13:0] h_count_remove;
reg [12:0] v_count_repeat;
reg [12:0] v_count_remove;
reg [1:0] next_state;
reg [1:0] state;
wire [13:0] h_count;
wire [12:0] v_count;
wire remove_lines_next;
wire [12:0] sync_compare_v_reset_next;
wire [12:0] sync_compare_h_reset_next;
wire valid;
reg v_count_remove_valid;
reg v_count_repeat_valid;
wire syncing_lines;
wire remove_samples_next;

// double register the outputs to allow register retiming
reg sync_lines0;
reg sync_samples0;
reg remove_repeatn0;
reg [13:0] sync_compare_h_reset0;
reg [12:0] sync_compare_v_reset0;
reg genlocked0;

reg sync_lines1;
reg sync_samples1;
reg remove_repeatn1;
reg [13:0] sync_compare_h_reset1;
reg [12:0] sync_compare_v_reset1;
reg genlocked1;

always @ (posedge rst or posedge clk) begin
    if(rst) begin
        h_count_repeat <= 14'd0;
        h_count_remove <= 14'd0;
        v_count_repeat <= 13'd0;
        v_count_repeat_valid <= 1'b0;
        v_count_remove <= 13'd0;
        v_count_remove_valid <= 1'b0;
        state <= `SC_IDLE;
        sync_lines0 <= 1'b0;
        sync_samples0 <= 1'b0;
        sync_compare_v_reset0 <= 13'd0;
        sync_compare_h_reset0 <= 14'd0;
        remove_repeatn0 <= 1'b0;
        genlocked0 <= 1'b0;
		  sync_lines1 <= 1'b0;
        sync_samples1 <= 1'b0;
        sync_compare_v_reset1 <= 13'd0;
        sync_compare_h_reset1 <= 14'd0;
        remove_repeatn1 <= 1'b0;
        genlocked1 <= 1'b0;
		  sync_lines <= 1'b0;
        sync_samples <= 1'b0;
        sync_compare_v_reset <= 13'd0;
        sync_compare_h_reset <= 14'd0;
        remove_repeatn <= 1'b0;
        genlocked <= 1'b0;
    end else begin
        if(sclr) begin
            h_count_repeat <= 14'd0;
            h_count_remove <= 14'd0;
            v_count_repeat <= 13'd0;
            v_count_repeat_valid <= 1'b0;
            v_count_remove <= 13'd0;
            v_count_remove_valid <= 1'b0;
            state <= `SC_IDLE;
        end else begin
            if(sclr_state) begin
                h_count_repeat <= 14'd0;
                h_count_remove <= 14'd0;
                v_count_repeat <= 13'd0;
                v_count_repeat_valid <= (14'd0 == h_count_repeat) && (13'd0 == v_count_repeat);
                v_count_remove <= 13'd0;
                v_count_remove_valid <= (14'd0 == h_count_remove) && (13'd0 == v_count_remove);
            end else begin
                if(state == `SC_CVI && next_state == `SC_CVO) begin
                    h_count_remove <= h_count;
                    v_count_remove <= v_count;
                    v_count_remove_valid <= (h_count == h_count_remove) && (v_count == v_count_remove);
                end
                if(state == `SC_CVO && next_state == `SC_CVI) begin
                    h_count_repeat <= h_count;
                    v_count_repeat <= v_count;
                    v_count_repeat_valid <= (h_count == h_count_repeat) && (v_count == v_count_repeat);
                end
            end
        
            state <= next_state;
        end
        
        if(sclr | ~valid) begin
            sync_lines0 <= 1'b0;
            sync_samples0 <= 1'b0;
            sync_compare_v_reset0 <= 13'd0;
            sync_compare_h_reset0 <= 14'd0;
            genlocked0 <= 1'b0;
        end else begin
            if(syncing_lines) begin
                sync_compare_v_reset0 <= sync_compare_v_reset_next;
                sync_lines0 <= 1'b1;
                
                sync_compare_h_reset0 <= sync_compare_h_reset_next;
                sync_samples0 <= 1'b1;
                
                genlocked0 <= 1'b0;
            end else begin
                sync_compare_v_reset0 <= 13'd0;
                sync_lines0 <= 1'b0;
                
                if(sync_compare_h_reset_next > divider_value) begin
                    sync_compare_h_reset0 <= sync_compare_h_reset_next;
                    sync_samples0 <= 1'b1;
                    
                    genlocked0 <= 1'b0;
                end else begin
                    sync_compare_h_reset0 <= 14'd0;
                    sync_samples0 <= 1'b0;
                    
                    genlocked0 <= 1'b1;
                end
            end
            
        end
        
        remove_repeatn0 <= remove_samples_next;
		  
		  sync_lines1 <= sync_lines0;
		  sync_samples1 <= sync_samples0;
        remove_repeatn1 <= remove_repeatn0;
        sync_compare_h_reset1 <= sync_compare_h_reset0;
        sync_compare_v_reset1 <= sync_compare_v_reset0;
        genlocked1 <= genlocked0;
		  
		  sync_lines <= sync_lines1;
		  sync_samples <= sync_samples1;
        remove_repeatn <= remove_repeatn1;
        sync_compare_h_reset <= sync_compare_h_reset1;
        sync_compare_v_reset <= sync_compare_v_reset1;
        genlocked <= genlocked1;
    end
end

assign valid = v_count_remove_valid & v_count_repeat_valid;
assign remove_lines_next = v_count_remove < v_count_repeat;
assign sync_compare_v_reset_next = (remove_lines_next) ? v_count_remove : v_count_repeat;
assign syncing_lines = sync_compare_v_reset_next > 13'd0;

assign remove_samples_next = (syncing_lines) ? remove_lines_next : h_count_remove < h_count_repeat;
assign sync_compare_h_reset_next = (remove_lines_next) ? h_count_remove : h_count_repeat;

always @ (state or sof_cvi_int or sof_cvo_int) begin
    next_state = state;
    case(state)
        `SC_CVI: begin
            if(sof_cvo_int & sof_cvi_int)
                next_state = `SC_IDLE;
            else if(sof_cvo_int)
                next_state = `SC_CVO;
        end
        `SC_CVO: begin
             if(sof_cvi_int & sof_cvo_int)
                 next_state = `SC_IDLE;
             else if(sof_cvi_int)
                 next_state = `SC_CVI;
        end
        default: begin
            if(sof_cvi_int & ~sof_cvo_int)
                next_state = `SC_CVI;
            else if(~sof_cvi_int & sof_cvo_int)
                next_state = `SC_CVO;
        end
    endcase
end

alt_vipitc131_common_frame_counter frame_counter(
    .rst(rst),
    .clk(clk),
    .sclr(sclr_frame_counter),
    
    .enable(enable),
    .hd_sdn(~serial_output),
    
    .h_total(h_total_minus_one),
    .v_total({13{1'b1}}),
    
    .h_reset(14'd0),
    .v_reset(13'd0),
    
    .h_count(h_count),
    .v_count(v_count));

defparam frame_counter.NUMBER_OF_COLOUR_PLANES = NUMBER_OF_COLOUR_PLANES,
         frame_counter.COLOUR_PLANES_ARE_IN_PARALLEL = COLOUR_PLANES_ARE_IN_PARALLEL,
         frame_counter.LOG2_NUMBER_OF_COLOUR_PLANES = LOG2_NUMBER_OF_COLOUR_PLANES,
         frame_counter.TOTALS_MINUS_ONE = 1;

endmodule
