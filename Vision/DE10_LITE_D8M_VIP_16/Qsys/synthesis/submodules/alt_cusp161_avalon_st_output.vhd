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

ENTITY ALT_CUSP161_AVALON_ST_OUTPUT IS
  GENERIC (
        NAME            : STRING := "";
        WIDTH           : INTEGER := 16;
        
        READY_USED      : INTEGER := 1;
        END_PACKET_USED : INTEGER := 0;
        SYM_PER_BEAT    : integer := 0;
        READY_LATENCY   : INTEGER := 1
  );
  PORT (
        clock : IN STD_LOGIC;
        reset : IN STD_LOGIC;

----------------- CUSP SIDE SIGNALS
---------------------------------------------------------------------------- 
        ena          : IN  STD_LOGIC := '1';

        spaceavail   : OUT STD_LOGIC;
           
        wdata        : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
        wdata_en     : IN  STD_LOGIC := '0';
        takeb        : IN  STD_LOGIC := '0';              -- take a page - block if not there
        takeb_en     : IN  STD_LOGIC := '0';              -- 
        takenb       : IN  STD_LOGIC := '0';              -- take a page - do not worry
        takenb_en    : IN  STD_LOGIC := '0';              -- 
        
        eop          : IN  STD_LOGIC := '0';
        seteop       : IN  STD_LOGIC := '0';            -- set the EOP value
        seteop_en    : IN  STD_LOGIC := '0';

        stall        : OUT STD_LOGIC;
----------------- Avalon st SIDE SIGNALS
---------------------------------------------------------------------------- 
        
        -- avalon st signals
        ready : IN STD_LOGIC  := '1';
        valid : OUT STD_LOGIC;
        data  : OUT STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0);
        
        startofpacket : OUT STD_LOGIC;
        endofpacket : OUT STD_LOGIC
  );
END;


ARCHITECTURE rtl OF ALT_CUSP161_AVALON_ST_OUTPUT IS
  SIGNAL skid : STD_LOGIC;

  SIGNAL ready_ext : STD_LOGIC;
  SIGNAL ready_int : STD_LOGIC;
  
  SIGNAL trigger : STD_LOGIC;
  SIGNAL space : STD_LOGIC;
  SIGNAL valid_int : STD_LOGIC;
  SIGNAL endofpacket_int : STD_LOGIC;
BEGIN

-- This FU only sends data if it is written and dispatched at the same time.
-- This is what the Cusp FU does when the user calls write()
trigger <= ((takeb AND takeb_en) OR (takenb AND takenb_en)) AND wdata_en AND ena;

ready_used_generate: IF READY_USED /= 0 GENERATE
  ready_ext <= ready;
END GENERATE;

ready_unused_generate: IF READY_USED = 0 GENERATE
  ready_ext <= '1';
END GENERATE;


ready_latency_1_generate: IF READY_LATENCY=1 GENERATE
  ready_int <= ready_ext;
END GENERATE;

ready_latency_2_generate: IF READY_LATENCY=2 GENERATE

  PROCESS(clock, reset)
  BEGIN
    IF reset = '1' THEN
      ready_int  <= '0';
    ELSIF clock'EVENT AND clock = '1' THEN
      ready_int <= ready_ext;
    END IF;
  END PROCESS;
  
END GENERATE;

-- Will there be space in the skid buffer on the next cycle.
-- Yes if it's empty or if its being emptied this cycle
space <= (NOT skid) OR valid_int;

valid <= valid_int;

-- Work out whether or not we have data available
PROCESS(clock, reset)
BEGIN
  IF reset = '1' THEN
	spaceavail <= '0'; 
  ELSIF clock'EVENT AND clock = '1' THEN
  	spaceavail <= space;
  END IF;
END PROCESS;

-- Ensure there is no combinatorial logic after our final register so the
-- connection to the next block (sink or adapter) won't slow us down.
PROCESS(clock, reset)
BEGIN
  IF reset = '1' THEN

    valid_int <= '0';
    data  <= (others => '0');
    skid  <= '0';

  ELSIF clock'EVENT AND clock = '1' THEN
  
    -- Send data if the sink is ready and we have some
    valid_int <= ready_int AND (skid OR trigger);
  
    IF (trigger AND space) = '1' THEN
      data <= wdata;
    END IF;

    IF ready_ext = '1' THEN
      skid <= '0';
    ELSIF (trigger AND NOT ready_int) = '1' THEN
 	  skid <= '1';
 	END IF;

  END IF;
END PROCESS;

-- Stall if the output is not taking data from us and the output buffer
-- is full
stall <= ((takeb AND takeb_en AND wdata_en) OR (seteop AND seteop_en)) AND NOT space;


-- An indication that there is space for one beat
-- TODO: Register this...
-- spaceavail <= space;

no_eop_generate: IF END_PACKET_USED = 0 GENERATE
  startofpacket <= '0';
  endofpacket <= '0';
END GENERATE;

eop_generate: IF END_PACKET_USED = 1 GENERATE

endofpacket <= endofpacket_int;

PROCESS(clock, reset)
BEGIN
  IF reset = '1' THEN
    startofpacket <= '1'; -- First data beat is always start of packet
    endofpacket_int  <= '0';
  ELSIF clock'EVENT AND clock = '1' THEN

    IF valid_int = '1' THEN
      startofpacket <= endofpacket_int;
    END IF;
  
    IF (seteop AND seteop_en AND space) = '1' THEN
      endofpacket_int <= eop;
    END IF;
  
  END IF;
END PROCESS;

END GENERATE;


END ARCHITECTURE;




