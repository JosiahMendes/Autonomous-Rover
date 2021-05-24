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

ENTITY alt_cusp161_cmp IS
    GENERIC (
        NAME         : STRING := "";
        OPTIMIZED    : INTEGER := OPTIMIZED_ON;
        FAMILY       : INTEGER := FAMILY_STRATIX;
        WIDTH        : INTEGER := 16
    );
    
    PORT (
        a    : IN  STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0) := (others=>'0');
        b    : IN  STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0) := (others=>'0');
        sign : IN  STD_LOGIC :='0'; -- 0 for unsigned and 1 for signed.
        equals : IN STD_LOGIC := '1';
        less   : IN STD_LOGIC := '0';
        invert : IN STD_LOGIC := '0';
        q    : OUT STD_LOGIC
    );
END;
   
   
ARCHITECTURE rtl OF alt_cusp161_cmp IS
   SIGNAL a_int   : STD_LOGIC_VECTOR(WIDTH DOWNTO 0);
   SIGNAL b_int   : STD_LOGIC_VECTOR(WIDTH DOWNTO 0);
   SIGNAL sub_out : STD_LOGIC_VECTOR(WIDTH DOWNTO 0);
   SIGNAL lt_int  : STD_LOGIC;
   SIGNAL eq_int  : STD_LOGIC;
BEGIN

   sign_ext : PROCESS (a, b, sign)
   BEGIN
      a_int(WIDTH) <= a(WIDTH-1) AND sign;
      b_int(WIDTH) <= b(WIDTH-1) AND sign;
      a_int(WIDTH-1 DOWNTO 0) <= a;
      b_int(WIDTH-1 DOWNTO 0) <= b;
   END PROCESS;
   
   sub : PROCESS (a_int, b_int)
   BEGIN
      sub_out <= std_logic_vector(SIGNED(a_int) - SIGNED(b_int)); 
   END PROCESS;
   
   sign_bit : PROCESS (sub_out)
   BEGIN
      lt_int <= sub_out(WIDTH);
   END PROCESS;
   
   equality : PROCESS (a_int, b_int)
   BEGIN
      IF (a_int = b_int) THEN
         eq_int <= '1';
      ELSE
         eq_int <= '0';
      END IF;
   END PROCESS;
   
   q_drive : PROCESS(eq_int, lt_int, equals, less, invert)
   BEGIN
      IF (equals = '0') THEN
         IF (less = '0') THEN
            q <= '0';
         ELSE
            -- equals = '0', less = '1' => LESS (or GREATER_EQUAL)
            q <= lt_int XOR invert;
         END IF;
      ELSE
         IF (less = '0') THEN
            -- equals = '1', less = '0' => EQUALS (or NOT_EQUALS)
            q <= eq_int XOR invert;
         ELSE
            -- equals = '1', less = '1' => LESS_EQUALS (or GREATER)
            q <= (lt_int OR eq_int) XOR invert;
         END IF;
      END IF;
   END PROCESS;
   
END;
