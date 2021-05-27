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

ENTITY alt_cusp161_atlantic_reporter IS
  GENERIC (
        NAME         : STRING := "";
        SIMULATION   : INTEGER := SIMULATION_OFF;
        OPTIMIZED    : INTEGER := OPTIMIZED_ON;
        FAMILY       : INTEGER := FAMILY_STRATIX;
        ISSIGNED : INTEGER := 1;
        CONSTANT WIDTH : INTEGER := 16
  );
  PORT (
        clock  : IN STD_LOGIC;
        reset  : IN STD_LOGIC;
    
        data   : IN STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
        valid     : IN STD_LOGIC := '1';
        ready     : OUT STD_LOGIC
  );
END ENTITY;


ARCHITECTURE rtl OF alt_cusp161_atlantic_reporter IS

-- convert integer to string
function TIntegerToString( value : integer ) return string is
variable ivalue : integer := 0;
variable index : integer := 1;
variable digit : integer := 0;
variable temp: string(10 downto 1) := "0000000000";  

begin
    index := 1;
    
    if (value < 0 ) then
      ivalue := -value;
    else
      ivalue := value;
    end if;
    
    while (ivalue > 0) loop
        digit := ivalue mod 10;
        ivalue := ivalue/10;

        case digit is
            when 0 =>    temp(index) := '0';
            when 1 =>    temp(index) := '1';
            when 2 =>    temp(index) := '2';
            when 3 =>    temp(index) := '3';
            when 4 =>    temp(index) := '4';
            when 5 =>    temp(index) := '5';
            when 6 =>    temp(index) := '6';
            when 7 =>    temp(index) := '7';
            when 8 =>    temp(index) := '8';
            when 9 =>    temp(index) := '9';
            when others => ASSERT FALSE
                           REPORT "Illegal number!"
                           SEVERITY ERROR;
        end case;

        index := index + 1;
    end loop;
    
    if value /= 0 then
      index := index - 1;
    end if;

    if (value < 0) then
        return ('-'& temp(index downto 1));
    else
        return temp(index downto 1);
    end if;    
end ;


BEGIN

ready_drive: ready <= '1';

unsigned_reporter_gen:  if  ISSIGNED = 0 generate
	us_reporter:  PROCESS (clock, reset)
	  BEGIN
	    IF (reset = '1') THEN
	      report NAME & " reset" severity note;
	    ELSIF clock'EVENT AND clock = '1' THEN
	      if valid = '1' then
	        report NAME & " : " & TIntegerToString(To_integer(unsigned(data))) severity note;
	      end if ;
	    END IF;
	  END PROCESS;
  end generate;

signed_reporter_gen:  if  ISSIGNED = 1 generate
  s_reporter:  PROCESS (clock, reset)
    BEGIN
      IF (reset = '1') THEN
        report NAME & " reset" severity note;
      ELSIF clock'EVENT AND clock = '1' THEN
        if valid = '1' then
          report NAME & " : " & TIntegerToString(To_integer(signed(data))) severity note;
        end if ;
      END IF;
    END PROCESS;
  end generate;

    
END;
