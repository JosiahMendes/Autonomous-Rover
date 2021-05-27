module alt_vipitc131_common_fifo(
    wrclk,
    rdreq,
    aclr,
    rdclk,
    wrreq,
    data,
    rdusedw,
    rdempty,
    wrusedw,
    wrfull,
    q);

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

parameter DATA_WIDTH = 20;
parameter FIFO_DEPTH = 1920;
parameter CLOCKS_ARE_SAME = 0;

parameter DATA_WIDTHU = alt_clogb2(FIFO_DEPTH);    

input wrclk;
input rdreq;
input aclr;
input rdclk;
input wrreq;
input [DATA_WIDTH-1:0] data;
output [DATA_WIDTHU-1:0] rdusedw;
output rdempty;
output [DATA_WIDTHU-1:0] wrusedw;
output wrfull;
output [DATA_WIDTH-1:0] q;

generate
    if(CLOCKS_ARE_SAME) begin
        assign rdusedw = wrusedw;
        
        scfifo input_fifo(
		    .rdreq(rdreq),
            .aclr(aclr),
			.clock(wrclk),
			.wrreq(wrreq),
			.data(data),
			.empty(rdempty),
			.full(wrfull),
            .usedw(wrusedw),
            .q(q));

        defparam
		    input_fifo.add_ram_output_register = "OFF",
            input_fifo.lpm_hint = "MAXIMIZE_SPEED=7,",      
            input_fifo.lpm_numwords = FIFO_DEPTH,
            input_fifo.lpm_showahead = "OFF",
            input_fifo.lpm_type = "scfifo",
            input_fifo.lpm_width = DATA_WIDTH,
            input_fifo.lpm_widthu = DATA_WIDTHU,
            input_fifo.overflow_checking = "OFF",
            input_fifo.underflow_checking = "OFF",
            input_fifo.use_eab = "ON";
    end else begin
        dcfifo input_fifo(
            .wrclk(wrclk),
            .rdreq(rdreq),
            .aclr(aclr),
            .rdclk(rdclk),
            .wrreq(wrreq),
            .data(data),
            .rdusedw(rdusedw),
            .rdempty(rdempty),
            .wrfull(wrfull),
            .wrusedw(wrusedw),
            .q(q));

        defparam
            input_fifo.lpm_hint = "MAXIMIZE_SPEED=7,",
            input_fifo.lpm_numwords = FIFO_DEPTH,
            input_fifo.lpm_showahead = "OFF",
            input_fifo.lpm_type = "dcfifo",
            input_fifo.lpm_width = DATA_WIDTH,
            input_fifo.lpm_widthu = DATA_WIDTHU,
            input_fifo.overflow_checking = "OFF",
            input_fifo.rdsync_delaypipe = 5,
            input_fifo.underflow_checking = "OFF",
            input_fifo.use_eab = "ON",
            input_fifo.wrsync_delaypipe = 5,
            input_fifo.read_aclr_synch = "ON";
    end
endgenerate

endmodule
