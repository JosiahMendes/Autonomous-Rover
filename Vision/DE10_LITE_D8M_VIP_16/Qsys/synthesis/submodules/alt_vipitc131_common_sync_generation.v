module alt_vipitc131_common_sync_generation(
    input wire rst,
    input wire clk,
    
    input wire clear_enable,
    input wire enable_count,
    input wire hd_sdn,
    input wire start_of_vsync,
    input wire field_prediction,
    input wire interlaced,
    input wire [13:0] total_sample_count,
    input wire total_sample_count_valid,
    input wire [12:0] total_line_count,
    input wire total_line_count_valid,
    input wire stable,
    
    input wire [13:0] divider_value,
    input wire [13:0] sof_sample,
    input wire [12:0] sof_line,
    input wire [1:0] sof_subsample,
    
    input  wire output_enable,
    output reg  sof,
    output reg  sof_locked,
    output wire div);
    
parameter NUMBER_OF_COLOUR_PLANES = 0;
parameter COLOUR_PLANES_ARE_IN_PARALLEL = 0;
parameter LOG2_NUMBER_OF_COLOUR_PLANES = 0;
parameter CONVERT_SEQ_TO_PAR = 0;
parameter TOTALS_MINUS_ONE = 0;

wire enable_next;
reg enable_reg;
wire enable;
wire sof_next;
reg sclr;
wire [LOG2_NUMBER_OF_COLOUR_PLANES-1:0] sample_ticks;
wire [13:0] h_count;
wire [12:0] v_count;
wire div_next;
wire count;
wire count_div;
wire sof_subsample_next;
reg first_sof;
reg div_reg;
reg [3:0] sof_count;
wire start_of_vsync_f0;

assign enable_next = stable & total_sample_count_valid;
assign start_of_vsync_f0 = start_of_vsync & ~field_prediction;
assign enable = (start_of_vsync_f0) ? enable_next : enable_next & enable_reg & ~clear_enable;
assign count = enable & enable_count;
assign count_div = count & first_sof;
assign sof_subsample_next = (sample_ticks == sof_subsample[LOG2_NUMBER_OF_COLOUR_PLANES-1:0]) | hd_sdn;
assign sof_next = (count && sof_subsample_next && h_count == sof_sample && v_count == sof_line) ? 1'b1 : 1'b0;
assign div = div_reg;

always @ (posedge rst or posedge clk) begin
    if(rst) begin
        enable_reg <= 1'b0;
        
        sof_count <= 4'd0;
        sof <= 1'b0;
        sof_locked <= 1'b0;
        div_reg <= 1'b0;
        sclr <= 1'b0;
        first_sof <= 1'b0;
    end else begin
        enable_reg <= enable;
        
        if(output_enable) begin
            if(sof_count == 4'd0) begin
                sof <= sof_next;
                if(sof_next)
                    sof_count = 4'b1111;
            end else begin
                sof_count = sof_count - 4'd1;
            end
            sof_locked <= enable & total_line_count_valid;
            div_reg <= div_next;
            sclr <= sof_next;
            first_sof <= enable & (sof_next | first_sof);
        end else begin
            sof <= 1'b0;
            sof_locked <= 1'b0;
            div_reg <= 1'b0;
            sclr <= 1'b0;
            first_sof <= 1'b0;
        end
    end
end

alt_vipitc131_common_frame_counter frame_counter(
    .rst(rst),
    .clk(clk),
    .sclr(start_of_vsync_f0),
    
    .enable(count),
    .hd_sdn(hd_sdn),
    
    .h_total(total_sample_count),
    .v_total(total_line_count),
    
    .h_reset(14'd0),
    .v_reset(13'd0),
    
    .sample_ticks(sample_ticks),
    .h_count(h_count),
    .v_count(v_count));

defparam frame_counter.NUMBER_OF_COLOUR_PLANES = NUMBER_OF_COLOUR_PLANES,
         frame_counter.COLOUR_PLANES_ARE_IN_PARALLEL = COLOUR_PLANES_ARE_IN_PARALLEL,
         frame_counter.LOG2_NUMBER_OF_COLOUR_PLANES = LOG2_NUMBER_OF_COLOUR_PLANES,
         frame_counter.CONVERT_SEQ_TO_PAR = CONVERT_SEQ_TO_PAR,
         frame_counter.TOTALS_MINUS_ONE = TOTALS_MINUS_ONE;

alt_vipitc131_common_frame_counter divider_counter(
    .rst(rst),
    .clk(clk),
    .sclr(sclr),
    
    .enable(count_div),
    .hd_sdn(hd_sdn),
    
    .h_total(divider_value),
    .v_total(13'd0),
    
    .h_reset(14'd0),
    .v_reset(13'd0),
    
    .new_line(div_next));

defparam divider_counter.NUMBER_OF_COLOUR_PLANES = NUMBER_OF_COLOUR_PLANES,
         divider_counter.COLOUR_PLANES_ARE_IN_PARALLEL = COLOUR_PLANES_ARE_IN_PARALLEL,
         divider_counter.LOG2_NUMBER_OF_COLOUR_PLANES = LOG2_NUMBER_OF_COLOUR_PLANES,
         divider_counter.CONVERT_SEQ_TO_PAR = CONVERT_SEQ_TO_PAR,
         divider_counter.TOTALS_MINUS_ONE = 1;

endmodule
