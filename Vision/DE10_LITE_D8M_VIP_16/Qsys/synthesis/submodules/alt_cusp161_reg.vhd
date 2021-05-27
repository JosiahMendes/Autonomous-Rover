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
USE IEEE.numeric_std.ALL;
USE STD.textio.ALL;

USE altera.ALT_CUSP161_PACKAGE.ALL;

ENTITY alt_cusp161_reg IS
  GENERIC (
        NAME         : STRING  := "";
        OPTIMIZED    : INTEGER := OPTIMIZED_ON;
        FAMILY       : INTEGER := FAMILY_STRATIX;
        WIDTH        : INTEGER := 16;
        RESET_VALUE  : INTEGER := 0
  );
  PORT (
        clock      : IN  STD_LOGIC;
        ena        : IN  STD_LOGIC := '1';         -- chip enable
        enable     : IN  STD_LOGIC := '0';
        enable_en  : IN  STD_LOGIC := '0';
        reset      : IN  STD_LOGIC := '0';         -- chip reset
        sclr       : IN  STD_LOGIC := '0';
        d          : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (OTHERS=>'0');
        q          : OUT STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0)
  );
END;


ARCHITECTURE rtl OF alt_cusp161_reg IS
    SIGNAL trigger : STD_LOGIC;
BEGIN

  trigger <= ena AND enable AND enable_en;

  PROCESS (clock, reset)
  BEGIN
    IF (reset = '1') THEN
      q <= std_logic_vector(to_signed(RESET_VALUE, WIDTH));
    ELSIF clock'EVENT AND clock = '1' THEN
      IF(trigger = '1') THEN
          IF (sclr = '1') THEN
              -- If sclr is used then RESET_VALUE will always be 0
              q <= std_logic_vector(to_signed(RESET_VALUE, WIDTH));
          ELSE
              q <= d;
          END IF;
      END IF;
    END IF;
  END PROCESS;
  
END ;


