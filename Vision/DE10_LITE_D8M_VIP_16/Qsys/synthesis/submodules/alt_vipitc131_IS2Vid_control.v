module alt_vipitc131_IS2Vid_control
    #(parameter
        USE_CONTROL = 1,
        NO_OF_MODES_INT = 1,
        USED_WORDS_WIDTH = 15)
    (
    input   wire rst,
    input   wire clk,
    
    // From mode registers
    input   wire av_write_ack,
    input   wire mode_change,
    input   wire [NO_OF_MODES_INT-1:0] mode_match,
    
    // From FIFO
    input   wire [USED_WORDS_WIDTH-1:0] usedw,
    input   wire underflow_sticky,
    input   wire enable_resync, // from the outgoing state machine
    input   wire genlocked,
    
    // IS2Vid control signals
    output  wire enable,
    output  wire clear_underflow_sticky,
    output  wire write_trigger,
    output  wire write_trigger_ack,
    output  wire [1:0] genlock_enable,
    
    // Aavalon-MM slave port
    input   wire [7:0] av_address,
    input   wire av_read,
    output  wire [15:0] av_readdata,
    input   wire av_write,
    input   wire [15:0] av_writedata,
    output  wire av_waitrequest,
    
    output  wire status_update_int);

// The control interface has one register bit 0 of which (when set to a 1) 
// enables the ImageStream output.
generate
    if(USE_CONTROL) begin
        reg enable_reg;
        reg write_trigger_ack_reg;
        
        wire is_side_registers;
        reg [1:0] interrupt_enable;
        reg status_update_int_reg;
        reg genlocked_reg;
        reg genlocked_int_reg;
        reg [1:0] genlock_enable_reg;
        
        wire [15:0] usedw_output;
        wire [15:0] is_mode_match_output;
        
        reg [NO_OF_MODES_INT-1:0] is_mode_match;
        wire clear_interrupts;
        
        reg clear_underflow_sticky_reg;
        
        wire mode_write;
        
        if(USED_WORDS_WIDTH >= 16)
            assign usedw_output = usedw[15:0];
        else
            assign usedw_output = {{16-USED_WORDS_WIDTH{1'b0}}, usedw};
        
        if(NO_OF_MODES_INT >= 16) begin
            assign is_mode_match_output = is_mode_match[15:0];
        end else begin
            assign is_mode_match_output = {{16-NO_OF_MODES_INT{1'b0}}, is_mode_match};
        end
        
        assign enable = enable_reg;
        assign av_readdata = (av_address == 8'd1) ? {{12{1'b0}}, genlocked,
                                                                 underflow_sticky,
                                                                 1'b0,
                                                                 enable_resync} :
                             (av_address == 8'd2) ? {{13{1'b0}}, genlocked_int_reg,
                                                                 status_update_int_reg,
                                                                 1'b0} :
                             (av_address == 8'd3) ? usedw_output :
                             (av_address == 8'd4) ? is_mode_match_output :
                             {{11{1'b0}}, genlock_enable, interrupt_enable, enable_reg};
        assign av_waitrequest = av_write & ~(av_write_ack | is_side_registers);
        assign is_side_registers = av_address <= 8'd4;
        assign write_trigger = av_write & ~is_side_registers;
        assign write_trigger_ack = write_trigger_ack_reg;
        assign status_update_int = status_update_int_reg | genlocked_int_reg;
        assign clear_interrupts = av_write && av_address == 8'd2;
        assign clear_underflow_sticky = clear_underflow_sticky_reg;
        assign genlock_enable = genlock_enable_reg;
        
        always @ (posedge rst or posedge clk) begin
            if (rst) begin
                genlock_enable_reg <= 2'b0;
                interrupt_enable <= 2'b0;
                enable_reg <= 1'b0;
                status_update_int_reg <= 1'b0;
                genlocked_int_reg <= 1'b0;
                
                is_mode_match <= {NO_OF_MODES_INT{1'b0}};
                genlocked_reg <= 1'b0;
                clear_underflow_sticky_reg <= 1'b0;
                write_trigger_ack_reg <= 1'b0;
            end else begin
                {genlock_enable_reg, interrupt_enable, enable_reg} <= (av_write && av_address == 8'd0) ? av_writedata[4:0] : {genlock_enable_reg, interrupt_enable, enable_reg};
                status_update_int_reg <= (mode_change | status_update_int_reg) & ~(clear_interrupts & av_writedata[1]) & interrupt_enable[0];
                genlocked_int_reg <= ((genlocked ^ genlocked_reg) | genlocked_int_reg) & ~(clear_interrupts & av_writedata[2]) & interrupt_enable[1];
                
                is_mode_match <= (mode_change) ? mode_match : is_mode_match;
                genlocked_reg <= genlocked;
                clear_underflow_sticky_reg <= ((av_write && av_address == 8'd1 && av_writedata[2]) | clear_underflow_sticky_reg) & underflow_sticky;
                write_trigger_ack_reg <= av_write_ack;
            end
        end
    end else begin
        assign enable = 1'b1;
        assign status_update_int = 1'b0;
        assign clear_underflow_sticky = 1'b0;
        assign write_trigger = 1'b0;
        assign write_trigger_ack = 1'b0;
        assign genlock_enable = 2'b00;
        assign av_readdata = 16'b0;
        assign av_waitrequest = 1'b0;
    end
endgenerate

endmodule
