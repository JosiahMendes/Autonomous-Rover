module alt_vipitc131_IS2Vid_statemachine(
   input wire rst,
   input wire clk,
   input wire request_data_valid,
   input wire sop,
   input wire vid_v_nxt,
   input wire anc_datavalid_nxt,
   input wire [3:0] q_data,
   input wire sync_lost,
   input wire anc_underflow_nxt,
   input wire ap_synched,
   input wire enable_synced_nxt,
   output wire [3:0] state_next,
   output wire [3:0] state
);

parameter USE_EMBEDDED_SYNCS = 0;
parameter NUMBER_OF_COLOUR_PLANES_IN_PARALLEL = 0;
parameter [3:0] IDLE            = 4'd0;
parameter [3:0] FIND_SOP        = 4'd1;
parameter [3:0] WIDTH_3         = 4'd2;
parameter [3:0] WIDTH_2         = 4'd3;
parameter [3:0] WIDTH_1         = 4'd4;
parameter [3:0] WIDTH_0         = 4'd5;
parameter [3:0] HEIGHT_3        = 4'd6;
parameter [3:0] HEIGHT_2        = 4'd7;
parameter [3:0] HEIGHT_1        = 4'd8;
parameter [3:0] HEIGHT_0        = 4'd9;
parameter [3:0] INTERLACING     = 4'd10;
parameter [3:0] FIND_MODE       = 4'd11;
parameter [3:0] SYNCHED         = 4'd12;
parameter [3:0] WAIT_FOR_SYNCH  = 4'd13;
parameter [3:0] WAIT_FOR_ANC    = 4'd14;
parameter [3:0] INSERT_ANC      = 4'd15;

reg [3:0] state_int;
reg [3:0] state_next_int;

always @ (posedge rst or posedge clk) begin
    if(rst) begin
        state_int <= FIND_SOP;
    end else begin
        state_int <= state_next_int;
    end
end

assign state_next = state_next_int;
assign state = state_int;
   
/*assign state_next = (state == FIND_SOP) ? (request_data_valid & sop) ? (q_data == 0) ? FIND_MODE :
                                                                       (q_data == 13 && USE_EMBEDDED_SYNCS == 1) ? (vid_v_nxt) ? WAIT_FOR_ANC : FIND_SOP :
                                                                       (q_data == 15) ? WIDTH_3 : FIND_SOP :
                                          FIND_SOP :
                    (state == WIDTH_3) ? (request_data_valid) ? control_header_state[0] : WIDTH_3 :
                    (state == WIDTH_2) ? (request_data_valid) ? control_header_state[1] : WIDTH_2 :
                    (state == WIDTH_1) ? (request_data_valid) ? control_header_state[2] : WIDTH_1 :
                    (state == WIDTH_0) ? (request_data_valid) ? control_header_state[3] : WIDTH_0 :
                    (state == HEIGHT_3) ? (request_data_valid) ? control_header_state[4] : HEIGHT_3 :
                    (state == HEIGHT_2) ? (request_data_valid) ? control_header_state[5] : HEIGHT_2 :
                    (state == HEIGHT_1) ? (request_data_valid) ? control_header_state[6] : HEIGHT_1 :
                    (state == HEIGHT_0) ? (request_data_valid) ? control_header_state[7] : HEIGHT_0 :
                    (state == INTERLACING) ? (request_data_valid) ? FIND_SOP : INTERLACING :
                    (state == WAIT_FOR_ANC) ? (~vid_v_nxt) ? FIND_SOP : (anc_datavalid_nxt) ? INSERT_ANC : WAIT_FOR_ANC :
                    (state == INSERT_ANC) ? (request_data_valid & sop) ? (q_data == 0) ? FIND_MODE :
                                                                         (q_data == 13) ? (vid_v_nxt) ? WAIT_FOR_ANC : FIND_SOP :
                                                                         (q_data == 15) ? WIDTH_3 : FIND_SOP :
                                            (~vid_v_nxt | sync_lost | anc_underflow_nxt) ? FIND_SOP : INSERT_ANC :  // underflow indicates end of ancilliary
                    (state == FIND_MODE) ? (ap_synched) ? SYNCHED : (enable_synced_nxt) ? WAIT_FOR_SYNCH : FIND_MODE :
                    (state == SYNCHED) ? (request_data_valid & sop) ? (q_data == 0) ? FIND_MODE :           // early sop?
                                                                      (q_data == 13 && USE_EMBEDDED_SYNCS == 1) ? (vid_v_nxt) ? WAIT_FOR_ANC : FIND_SOP :
                                                                      (q_data == 15) ? WIDTH_3 : FIND_SOP :
                                         (vid_v_nxt | sync_lost) ? FIND_SOP : SYNCHED :                     // early eop?
                    (state == WAIT_FOR_SYNCH) ? (ap_synched) ? SYNCHED : WAIT_FOR_SYNCH : IDLE;*/

always @ * begin
	case(state_int)
      FIND_SOP: begin
         if(request_data_valid & sop) begin
            case(q_data[3:0])
               0: begin
                  state_next_int = FIND_MODE;
               end
               13: begin
                  if(vid_v_nxt && USE_EMBEDDED_SYNCS == 1)
                     state_next_int = WAIT_FOR_ANC;
						else
							state_next_int = FIND_SOP;
               end
               15: begin
                  state_next_int = WIDTH_3;
               end
					default: begin
						state_next_int = FIND_SOP;
					end
            endcase
         end else
				state_next_int = FIND_SOP;
      end
      WIDTH_3: begin
         if(request_data_valid)
            if(NUMBER_OF_COLOUR_PLANES_IN_PARALLEL < 9)
               state_next_int = WIDTH_2;
            else
               state_next_int = FIND_SOP;
			else
				state_next_int = WIDTH_3;
      end
      WIDTH_2: begin
         if(request_data_valid)
            if(2 * NUMBER_OF_COLOUR_PLANES_IN_PARALLEL < 9)
               state_next_int = WIDTH_1;
            else
               state_next_int = FIND_SOP;
			else
				state_next_int = WIDTH_2;
      end
      WIDTH_1: begin
         if(request_data_valid)
            if(3 * NUMBER_OF_COLOUR_PLANES_IN_PARALLEL < 9)
               state_next_int = WIDTH_0;
            else
               state_next_int = FIND_SOP;
			else
				state_next_int = WIDTH_1;
      end
      WIDTH_0: begin
         if(request_data_valid)
            if(4 * NUMBER_OF_COLOUR_PLANES_IN_PARALLEL < 9)
               state_next_int = HEIGHT_3;
            else
               state_next_int = FIND_SOP;
			else
				state_next_int = WIDTH_0;
      end
      HEIGHT_3: begin
         if(request_data_valid)
            if(5 * NUMBER_OF_COLOUR_PLANES_IN_PARALLEL < 9)
               state_next_int = HEIGHT_2;
            else
               state_next_int = FIND_SOP;
			else
				state_next_int = HEIGHT_3;
      end
      HEIGHT_2: begin
         if(request_data_valid)
            if(6 * NUMBER_OF_COLOUR_PLANES_IN_PARALLEL < 9)
               state_next_int = HEIGHT_1;
            else
               state_next_int = FIND_SOP;
			else
				state_next_int = HEIGHT_2;
      end
      HEIGHT_1: begin
         if(request_data_valid)
            if(7 * NUMBER_OF_COLOUR_PLANES_IN_PARALLEL < 9)
               state_next_int = HEIGHT_0;
            else
               state_next_int = FIND_SOP;
			else
				state_next_int = HEIGHT_1;
      end
      HEIGHT_0: begin
         if(request_data_valid)
            if(8 * NUMBER_OF_COLOUR_PLANES_IN_PARALLEL < 9)
               state_next_int = INTERLACING;
            else
               state_next_int = FIND_SOP;
			else
				state_next_int = HEIGHT_0;
      end
      INTERLACING: begin
         if(request_data_valid)
            state_next_int = FIND_SOP;
			else
				state_next_int = INTERLACING;
      end
      WAIT_FOR_ANC: begin
         if(~vid_v_nxt)
            state_next_int = FIND_SOP;
         else if(anc_datavalid_nxt)
            state_next_int = INSERT_ANC;
			else
				state_next_int = WAIT_FOR_ANC;
      end
      INSERT_ANC: begin
         if(request_data_valid & sop) begin
            case(q_data[3:0])
               0: begin
                  state_next_int = FIND_MODE;
               end
               13: begin
                  if(vid_v_nxt && USE_EMBEDDED_SYNCS == 1)
                     state_next_int = WAIT_FOR_ANC;
					   else
							state_next_int = FIND_SOP;
               end
               15: begin
                  state_next_int = WIDTH_3;
               end
					default: begin
						state_next_int = INSERT_ANC;
					end
            endcase
         end else if(~vid_v_nxt | sync_lost | anc_underflow_nxt)
            state_next_int = FIND_SOP;
         else
				state_next_int = INSERT_ANC;
      end
      FIND_MODE: begin
         if(ap_synched)
            state_next_int = SYNCHED;
         else if(enable_synced_nxt)
            state_next_int = WAIT_FOR_SYNCH;
			else
				state_next_int = FIND_MODE;
      end
      SYNCHED: begin
         if(request_data_valid & sop) begin
            case(q_data[3:0])
               0: begin
                  state_next_int = FIND_MODE;
               end
               13: begin
                  if(vid_v_nxt && USE_EMBEDDED_SYNCS == 1)
                     state_next_int = WAIT_FOR_ANC;
						else
							state_next_int = FIND_SOP;
               end
               15: begin
                  state_next_int = WIDTH_3;
               end
					default: begin
						state_next_int = SYNCHED;
					end
            endcase
         end else if(vid_v_nxt | sync_lost)
            state_next_int = FIND_SOP;
         else
				state_next_int = SYNCHED;
      end
      WAIT_FOR_SYNCH: begin
         if(ap_synched)
            state_next_int = SYNCHED;
			else
				state_next_int = WAIT_FOR_SYNCH;
      end
		default: begin
			state_next_int = FIND_SOP;
		end
   endcase
end

endmodule
