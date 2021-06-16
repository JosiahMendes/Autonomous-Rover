-- Legal Notice: (C)2006 Altera Corporation. All rights reserved.  Your
-- use of Altera Corporation's design tools, logic functions and other
-- software and tools, and its AMPP partner logic functions, and any
-- output files any of the foregoing (including device programming or
-- simulation files), and any associated documentation or information are
-- expressly subject to the terms and conditions of the Altera Program
-- License Subscription Agreement or other applicable license agreement,
-- including, without limitation, that your use is for the sole purpose
-- of programming logic devices manufactured by Altera and sold by Altera
-- or its authorized distributors.  Please refer to the applicable
-- agreement for further details.


LIBRARY IEEE, ALTERA;
USE IEEE.std_logic_1164.ALL;
USE altera.ALT_CUSP161_PACKAGE.ALL;

ENTITY alt_cusp161_clock_reset IS
  GENERIC (
        NAME         : STRING := "";
        SIMULATION   : INTEGER := SIMULATION_OFF;
        OPTIMIZED    : INTEGER := OPTIMIZED_ON;
        FAMILY       : INTEGER := FAMILY_STRATIX;
        PERIOD : TIME := 10 ns
  );
  PORT (
      clock      : OUT STD_LOGIC;
      reset      : OUT STD_LOGIC
  );
END ENTITY;


ARCHITECTURE rtl OF alt_cusp161_clock_reset IS
  
BEGIN

clock_and_reset: PROCESS
  BEGIN
    clock <= '0';
    reset <= '0';
    wait for PERIOD/2;
    
    clock <= '0';       -- 1 clock cycle
    wait for PERIOD/2;
    clock <= '1';
    wait for PERIOD/2;

    clock <= '0';       -- reset the dut    
    reset <= '1';
    wait for PERIOD;
    reset <= '0';
    
    while true loop     -- run the clock
	    clock <= '0';
	    wait for PERIOD/2;
	    clock <= '1';
	    wait for PERIOD/2;
    end loop; 
  END PROCESS;

END ARCHITECTURE;
