module alt_vipitc131_common_trigger_sync(
    input wire input_rst,
    input wire input_clock,
    input wire rst,
    input wire sync_clock,
    
    input wire trigger_in,
    input wire ack_in,
    output wire trigger_out);

parameter CLOCKS_ARE_SAME = 0;

generate
    if(CLOCKS_ARE_SAME) 
        assign trigger_out = trigger_in;
    else begin
        reg trigger_in_reg;
        reg toggle;
        reg toggle_synched_reg;
        wire toggle_synched;
        
        always @ (posedge input_rst or posedge input_clock) begin
            if(input_rst) begin
                trigger_in_reg <= 1'b0;
                toggle <= 1'b0;
            end else begin
                trigger_in_reg <= trigger_in;
                toggle <= toggle ^ (trigger_in & (~trigger_in_reg | ack_in));
            end
        end
        
        alt_vipitc131_common_sync #(CLOCKS_ARE_SAME) toggle_sync(
            .rst(rst),
            .sync_clock(sync_clock),
            .data_in(toggle),
            .data_out(toggle_synched));
            
        always @ (posedge rst or posedge sync_clock) begin
            if(rst) begin
                toggle_synched_reg <= 1'b0;
            end else begin
                toggle_synched_reg <= toggle_synched;
            end
        end
        
        assign trigger_out = toggle_synched ^ toggle_synched_reg;
    end
endgenerate

endmodule
