module alt_vipitc131_common_frame_counter
    #(parameter
        NUMBER_OF_COLOUR_PLANES = 0,
        COLOUR_PLANES_ARE_IN_PARALLEL = 0,
        LOG2_NUMBER_OF_COLOUR_PLANES = 0,
        CONVERT_SEQ_TO_PAR = 0,
        TOTALS_MINUS_ONE = 0)
    (
    input wire rst,
    input wire clk,
    input wire sclr,
    
    // control signals
    input wire enable,
    input wire hd_sdn,
    
    // frame sizes
    input wire [13:0] h_total,
    input wire [12:0] v_total,
    
    // reset values
    input wire [13:0] h_reset,
    input wire [12:0] v_reset,
    
    // outputs
    output wire new_line,
    output wire start_of_sample,
    output wire [LOG2_NUMBER_OF_COLOUR_PLANES-1:0] sample_ticks,
    output reg [13:0] h_count,
    output reg [12:0] v_count);

wire count_sample;

alt_vipitc131_common_sample_counter sample_counter(
    .rst(rst),
    .clk(clk),
    .sclr(sclr),
    .hd_sdn(hd_sdn),
    .count_cycle(enable),
    .count_sample(count_sample),
    .start_of_sample(start_of_sample),
    .sample_ticks(sample_ticks));

defparam sample_counter.NUMBER_OF_COLOUR_PLANES = NUMBER_OF_COLOUR_PLANES,
         sample_counter.COLOUR_PLANES_ARE_IN_PARALLEL = COLOUR_PLANES_ARE_IN_PARALLEL,
         sample_counter.LOG2_NUMBER_OF_COLOUR_PLANES = LOG2_NUMBER_OF_COLOUR_PLANES;
    
wire [13:0] h_total_int;
wire [12:0] v_total_int;
    
generate 
    if(TOTALS_MINUS_ONE) begin : totals_minus_one_generate
        assign h_total_int = h_total;
        assign v_total_int = v_total;
    end else begin
        assign h_total_int = h_total - 14'd1;
        assign v_total_int = v_total - 13'd1;
    end
endgenerate

always @ (posedge rst or posedge clk) begin
    if(rst) begin
        h_count <= 14'd0;
        v_count <= 13'd0;
    end else begin
        if(sclr) begin
            h_count <= h_reset + {{13{1'b0}}, count_sample & hd_sdn};
            v_count <= v_reset;
        end else if(enable) begin
            if(new_line) begin
                h_count <= 14'd0;
                if(v_count >= v_total_int)
                    v_count <= 13'd0;
                else
                    v_count <= v_count + 13'd1;
            end else if(count_sample)
                h_count <= h_count + 14'd1;
        end
    end
end

assign new_line = (h_count >= h_total_int) && count_sample;

endmodule
