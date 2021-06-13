// Testbench
module rgb_to_hsv_tb;

  reg  clk, rst_n;
  reg [7:0] rgb_r, rgb_g, rgb_b;
  wire [8:0] hsv_h;
  wire [7:0] hsv_s, hsv_v;
  
  // Instantiate device under test
  rgb_to_hsv FSM(
          .clk(clk),
          .rst_n(rst_n),
          .rgb_r(rgb_r),
          .rgb_g(rgb_g),
          .rgb_b(rgb_b),
          .hsv_h(hsv_h),
          .hsv_s(hsv_s),
          .hsv_v(hsv_v));
  
  initial begin
    // Dump waves
    $dumpfile("dump.vcd");
    $dumpvars(1);

    clk = 0;
    rgb_r = 13;
    rgb_g = 4;
    rgb_b = 32;
    $display("Initial out1: %0d, out2: %0d, out3:%0h",
      hsv_h, hsv_s, hsv_v);

    toggle_clk;
    $display("IDLE out1: %0d, out2: %0d, out3:%0d",
      hsv_h, hsv_s, hsv_v);
    
    toggle_clk;
    $display("STATE_1 out1: %0d, out2: %0d, out3:%0d",
      hsv_h, hsv_s, hsv_v);

    toggle_clk;
    $display("FINAL out1: %0d, out2: %0d, out3:%0d",
      hsv_h, hsv_s, hsv_v);

    toggle_clk;
    $display("FINAL out1: %0d, out2: %0d, out3:%0d",
      hsv_h, hsv_s, hsv_v);
    
    toggle_clk;
    $display("IDLE out1: %0d, out2: %0d, out3:%0d",
      hsv_h, hsv_s, hsv_v);
  end
  
  task toggle_clk;
    begin
      #10 clk = ~clk;
      #10 clk = ~clk;
    end
  endtask
  
endmodule