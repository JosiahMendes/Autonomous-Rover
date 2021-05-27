module alt_vipitc131_common_sync
    #(parameter
        CLOCKS_ARE_SAME = 0,
        WIDTH = 1)
    (
    input wire rst,
    input wire sync_clock,
    
    input wire [WIDTH-1:0] data_in,
    output wire [WIDTH-1:0] data_out);

(* altera_attribute = "-name SYNCHRONIZER_IDENTIFICATION FORCED_IF_ASYNCHRONOUS; -name SDC_STATEMENT \"set_false_path -to [get_keepers *data_out_sync0*]\"" *) reg [WIDTH-1:0] data_out_sync0;
(* altera_attribute = "-name SYNCHRONIZER_IDENTIFICATION FORCED_IF_ASYNCHRONOUS" *) reg [WIDTH-1:0] data_out_sync1;

generate
    if(CLOCKS_ARE_SAME) 
        assign data_out = data_in;
    else begin
        always @ (posedge rst or posedge sync_clock) begin
            if(rst) begin
                data_out_sync0 <= {WIDTH{1'b0}};
                data_out_sync1 <= {WIDTH{1'b0}};
            end else begin
                data_out_sync0 <= data_in;
                data_out_sync1 <= data_out_sync0;
            end
        end
        
        assign data_out = data_out_sync1;
    end
endgenerate

endmodule

