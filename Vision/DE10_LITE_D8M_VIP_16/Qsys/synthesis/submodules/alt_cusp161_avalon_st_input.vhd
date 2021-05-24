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

library ieee, altera;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use altera.alt_cusp161_package.all;

entity alt_cusp161_avalon_st_input is
	generic (
        -- all cusp function units have these
		NAME            : string  := "";
		OPTIMIZED       : integer := OPTIMIZED_ON;
        FAMILY          : integer := FAMILY_STRATIX;
        
        -- properties of the avalon-st port
        WIDTH           : integer := 16;
        END_PACKET_USED : integer := 0;
        SYM_PER_BEAT    : integer := 0;
        READY_LATENCY   : integer := 1
  	);
  	port (
  		-- cusp system clock, reset
        clock         : in std_logic;
        reset         : in std_logic;

		-- interface to cusp
        ena           : in  std_logic := '1';
        stall         : out std_logic;
        dataavail     : out std_logic;
        datavalid     : out std_logic;
        rdata         : out std_logic_vector(WIDTH - 1 downto 0);
        takeb         : in  std_logic;
        takeb_en      : in  std_logic;
        takenb        : in  std_logic;
        takenb_en     : in  std_logic;
        expecteop     : in  std_logic := '1';
        eop           : out std_logic;

        -- interface to avalon
        ready         : out std_logic;
        valid         : in  std_logic := '1';
        data          : in  std_logic_vector(width-1 downto 0);
        startofpacket : in  std_logic := '0';
        endofpacket   : in  std_logic := '0'
  	);
end;

architecture rtl of alt_cusp161_avalon_st_input is

	-- high when the cusp core wants data - note that this is one
	-- clock cycle after the cycle where the takeb... lines are asserted
	signal take, take_nb, take_expects_eop : std_logic;
	-- combinational versions of the above
	signal take_comb, take_nb_comb, take_expects_eop_comb : std_logic;
	-- high when the cusp core is successfully requesting data
	signal taking : std_logic;
	-- the case where the core wasn't expecting an end of packet but there is one
	signal unexpected_eop : std_logic;
	
	-- registered ready signal
	signal ready_int : std_logic;

	-- the size of the fifo to use to buffer input, a function of ready latency
	constant FIFO_DEPTH : integer := 3;
	
	-- storage for the fifo itself, and the usedw tracker for the fifo
	type fifo_type is array(integer range <>) of std_logic_vector((WIDTH + END_PACKET_USED) - 1 downto 0);
	signal fifo_data       : fifo_type(FIFO_DEPTH - 1 downto 0);
	-- fifo_usedw(0) = '1' indicates that there is data in element zero of the fifo (the fifo output),
	-- fifo_usedw(1) says the same about element one and so on
	signal fifo_usedw      : std_logic_vector(FIFO_DEPTH - 1 downto 0);
	-- there is a need to be able to pick up the front word of the fifo combinationally
	-- to make it simple to share the code, we have a separate combinational image of the fifo
	signal fifo_data_comb  : fifo_type(FIFO_DEPTH - 1 downto 0);
	signal fifo_usedw_comb : std_logic_vector(FIFO_DEPTH - 1 downto 0);
	
	-- triggered output ports have to be held for cusp, to obey tta rules
	signal datavalid_int : std_logic;
	signal rdata_int : std_logic_vector(WIDTH - 1 downto 0);
	signal eop_int   : std_logic;

begin

	-- this is currently a very limited implementation, check limits
	assert (READY_LATENCY = 1) report "This version of the Avalon-ST input module only supports ready latency one" severity failure;
	assert (take_nb = '0') report "Non-blocking reads were not supported by CusP at implementation time, and are untested" severity warning;
	
	-- check legality of generics
	assert (END_PACKET_USED = 1 or END_PACKET_USED = 0) report "The value of END_PACKED_USED must be zero or one" severity failure;
	
	-- resolve the two triggers provided by this module from their consituent parts and
	-- record them so that if we cause a stall we don't lose track of what we were asked
	-- to do
	-- this is done as a combinational process and a latch process so that the latching
	-- to obey tta rules logic can use the triggers combinationally
	process (ena, takeb, takeb_en, takenb, takenb_en, expecteop, take, take_nb, take_expects_eop)
	begin
		if ena = '1' then
			take_comb <= takeb and takeb_en;
			take_nb_comb <= takenb and takenb_en;
			if END_PACKET_USED = 1 then
				take_expects_eop_comb <= expecteop;
			else
				take_expects_eop_comb <= take_expects_eop;
			end if;
		else
			take_comb <= take;
			take_nb_comb <= take_nb;
			take_expects_eop_comb <= take_expects_eop;
		end if;
	end process;
	-- latching for the above
	process (clock, reset)
	begin
		if reset = '1' then
			take <= '0';
			take_nb <= '0';
			take_expects_eop <= '0';
		elsif clock'EVENT and clock = '1' then
			take <= take_comb;
			take_nb <= take_nb_comb;
			take_expects_eop <= take_expects_eop_comb;
		end if;
	end process;
	
	-- taking should be high when the cusp core is successfully requesting data
	taking <= (take or take_nb) and fifo_usedw(0) and ena and not unexpected_eop;
	-- if the cusp core is requesting data in a blocking fashion but we don't have any, stall it
	stall <= take and not fifo_usedw(0);
	-- data available means "if you assert take now I'll give you data next cycle"
	-- therefore we need to know if there'll be an element in the fifo next cycle
	dataavail <=           '1' when valid = '1' and taking = '0' else
			 	 fifo_usedw(1) when valid = '0' and taking = '1' else
			 	 fifo_usedw(0);
	-- spot unexpected end of packet
	unexpected_eop <= not take_expects_eop and fifo_data(0)(WIDTH + END_PACKET_USED - 1) when END_PACKET_USED = 1 else '0';
	
	-- a fifo of size FIFO_DEPTH x WIDTH fed directly by the data and valid input ports, split into
	-- a combinational process and a latching process so that the front words of the fifo can be
	-- latched independently to obey cusp's tta rules
	process (fifo_data, fifo_usedw, valid, taking, data, endofpacket)
		variable is_first_space, is_last_used : std_logic;
	begin
		for i in 0 to FIFO_DEPTH - 1 loop
			-- calculate whether word i is the closest space to the head of the fifo
			if i = 0 then
				is_first_space := not fifo_usedw(0);
			else
				is_first_space := not fifo_usedw(i) and fifo_usedw(i - 1);
			end if;
			-- calculate whether word i is the furthest used word from the head of the fifo
			if i = FIFO_DEPTH - 1 then
				is_last_used := fifo_usedw(FIFO_DEPTH - 1);
			else
				is_last_used := fifo_usedw(i) and not fifo_usedw(i + 1);
			end if;
			-- each word in the fifo will do one of three
			-- things:
			-- 1. take the contents of data
			if valid = '1' and ((taking = '1' and is_last_used = '1')
							or  (taking = '0' and is_first_space = '1')) then
				fifo_data_comb(i)(WIDTH - 1 downto 0) <= data;
				if END_PACKET_USED = 1 then
					fifo_data_comb(i)(WIDTH + END_PACKET_USED - 1) <= endofpacket;
				end if;
				fifo_usedw_comb(i) <= '1';
			-- 2. take the word from the previous element in the
			--    shift register (or all 1s for nothing)
			elsif taking = '1' then
				if i < FIFO_DEPTH - 1 then
					fifo_data_comb(i) <= fifo_data(i + 1);
					fifo_usedw_comb(i) <= fifo_usedw(i + 1);
				else
					fifo_data_comb(i) <= (others => '1');
					fifo_usedw_comb(i) <= '0';
				end if;
			-- 3. hold its value
			else
				fifo_data_comb(i) <= fifo_data(i);
				fifo_usedw_comb(i) <= fifo_usedw(i);
			end if;
		end loop;
	end process;
	-- the separate clocking process
	process (clock, reset)
	begin
		if reset = '1' then
			fifo_data <= (others => (others => '0'));
			fifo_usedw <= (others => '0');
		elsif clock'EVENT and clock = '1' then
			fifo_data <= fifo_data_comb;
			fifo_usedw <= fifo_usedw_comb;
		end if;
	end process;
	
	-- the data to cusp is always registered, but can't use the head of the fifo even
	-- though it is showahead, because the head of the fifo does not obey tta rules
	-- instead use something which is always the same as the head of the fifo just
	-- after a trigger, but holds its value the rest of the time
	process (clock, reset)
	begin
		if reset = '1' then
			datavalid_int <= '0';
			rdata_int <= (others => '0');
			eop_int <= '0';
		elsif clock'EVENT and clock = '1' then
			-- values may only change on the enabled cycle following a take request
			if take_comb = '1' or take_nb_comb = '1' then
				datavalid_int <= fifo_usedw_comb(0);
				rdata_int <= fifo_data_comb(0)(WIDTH - 1 downto 0);
				if END_PACKET_USED = 1 then
					eop_int <= fifo_data_comb(0)(WIDTH + END_PACKET_USED - 1);
				else
					eop_int <= '0';
				end if;
			end if;
		end if;
	end process;
	datavalid <= datavalid_int;
	rdata <= rdata_int;
	eop <= eop_int;
	
	-- now for the interesting bit - when to assert ready
	-- this is complex so some explanation is probably warranted:
	--   1. this process is responsible for driving the ready output
	--   2. avalon-st says that ready must be registered, to it's a
	--      clocked process and what we're actually calculating is
	--      whether ready should be high next clock cycle
	--   3. ready latency is one, so whether or not ready is high on
	--      the next clock cycle actually determines whether or not
	--      we (might) get data on the cycle after that
	--   4. to maximise throughput, we want to assert ready as often
	--      as possible, but we must not assert it unless we can
	--      guarantee that we will be able to cope with the data should
	--      it arrive
	--   5. so in essence what we're looking for is the answer to the
	--      question "can i guarantee that there will be at least one
	--      space in the fifo two cycles from now?"
	-- let
	--   s0 = the number of spaces in the fifo right now
	--   s1 = the number of spaces in the fifo next clock cycle
	--      = (taking & !valid) ? s0 + 1 :
	--        (valid & !taking) ? s0 - 1 : s0
	--  ws2 = the worst case (minimum) number of spaces in the fifo two
	--        clock cycles from now (for worst case, assume cusp does not
	--        take next cycle, and that if ready is high this cycle then
	--        valid will be high next cycle)
	--  ws2 = (ready) ? s1 - 1 : s1
	-- so from (5) above what we are looking for is (ws2 >= 1), and ws2
	-- is a function of taking, valid, ready and s0
	-- if you substitute the comparisons through the equations above
	-- you should get the code below
	readiness : process (clock, reset)
	begin
		if reset = '1' then
			ready_int <= '0';
		else
			if clock'EVENT and clock = '1' then
				if ready_int = '1' then
					if taking = '1' and valid = '0' then
						ready_int <= not fifo_usedw(FIFO_DEPTH - 1);
					elsif taking = '0' and valid = '1' then
						ready_int <= not fifo_usedw(FIFO_DEPTH - 3);
					else
						ready_int <= not fifo_usedw(FIFO_DEPTH - 2);
					end if;
				else
					if taking = '1' and valid = '0' then
						ready_int <= '1';
					elsif taking = '0' and valid = '1' then
						ready_int <= not fifo_usedw(FIFO_DEPTH - 2);
					else
						ready_int <= not fifo_usedw(FIFO_DEPTH - 1);
					end if;
				end if;
			end if;
		end if;
	end process;
	ready <= ready_int;
	
	-- synthesis translate_off
	-- this process checks that valid was not asserted on a cycle when it wasn't permitted
	-- if this report is triggering then the ready handling in your testbench is probably broken.
	process (clock, reset)
		variable ready_delay : std_logic_vector(READY_LATENCY - 1 downto 0);
	begin
		if reset = '1' then
			ready_delay := (others => '0');
		elsif clock'EVENT and clock = '1' then
			if valid = '1' and ready_delay(READY_LATENCY - 1) = '0' THEN
				report "Avalon streaming valid signal may only be asserted if ready was asserted READY_LATENCY cycle(s) earlier" severity warning;
			end if;
			ready_delay := ready_delay(READY_LATENCY - 2 downto 0) & ready_int;
		end if;
	end process;
	-- synthesis translate_on

end architecture;
