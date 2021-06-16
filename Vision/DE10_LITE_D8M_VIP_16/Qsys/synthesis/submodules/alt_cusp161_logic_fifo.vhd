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
use ieee.math_real.all;
use altera.alt_cusp161_package.all;

entity alt_cusp161_logic_fifo is
	generic
	(
		WIDTH	           : integer := 8;
		DEPTH	           : integer := 3
	);
	port
	(
		-- clock, enable and reset
		clock	     : in  std_logic;
		rdena        : in  std_logic := '1';
		wrena        : in  std_logic := '1';
		reset	     : in  std_logic;

		-- information signals from the fifo (write side)
		wrusedw	     : out std_logic_vector(wide_enough_for(DEPTH) - 1 downto 0);
		full	     : out std_logic;
		almost_full  : out std_logic;
		-- information signals from the fifo (read side)
		rdusedw      : out std_logic_vector(wide_enough_for(DEPTH) - 1 downto 0);
		empty	     : out std_logic;
		almost_empty : out std_logic;
		
		-- getting data into the fifo
		wrreq	     : in  std_logic;
		data	     : in  std_logic_vector(WIDTH - 1 downto 0);
		
		-- ...and back out again
		rdreq	     : in  std_logic;
		q		     : out std_logic_vector(WIDTH - 1 downto 0)
	);
end entity;

architecture rtl of alt_cusp161_logic_fifo is

	constant USEDW_WIDTH : integer := wide_enough_for(DEPTH);
	
	-- the number of words in the fifo
	-- also indicates where the next write should go
	signal wrusedw_for_internal_use     : unsigned(USEDW_WIDTH - 1 downto 0) := (others => '0');
	signal wrusedw_for_internal_use_slv : std_logic_vector(USEDW_WIDTH - 1 downto 0) := (others => '0');
	
	-- shift register, to actually store the fifo data
	type shift_register_type is array(integer range <>) of std_logic_vector(WIDTH - 1 downto 0);
	signal shift_register : shift_register_type(DEPTH - 1 downto 0);
	
	-- rather than using the clock enables as clock enables, we use them as enables
	-- on the two signals, rdreq and wrreq, since these are the only signals which actually
	-- cause the fifo to do anything
	signal enabled_rdreq, enabled_wrreq : std_logic;

begin

	-- check generics
	assert DEPTH > 0
		report "Generic DEPTH must greater than zero"
		severity ERROR;
	assert WIDTH > 0
		report "Generic WIDTH must greater than zero"
		severity ERROR;

	-- instantiate a standard usedw calculator to do the usedw, empty etc. updating
	usedw_calculator : alt_cusp161_fifo_usedw_calculator
	generic map
	(
		WIDTH => USEDW_WIDTH,
		DEPTH => DEPTH,
		CLOCKS_ARE_SAME => TRUE,
		READ_TO_WRITE_DELAY => 0,
		WRITE_TO_READ_DELAY => 0
	)
	port map
	(
		rdclock      => clock,
		wrclock      => clock,
		rdena        => rdena,
		wrena        => wrena,
		rdreset      => reset,
        wrreset      => reset,
		wrreq        => wrreq,
		rdreq        => rdreq,
		wrusedw      => wrusedw_for_internal_use_slv,
		full         => full,
		almost_full  => almost_full,
		rdusedw      => rdusedw,
		empty        => empty,
		almost_empty => almost_empty
	);
	-- the logic below needs access to the wrusedw value, so this cannot be direcly connected out
	wrusedw_for_internal_use <= unsigned(wrusedw_for_internal_use_slv);
	wrusedw <= wrusedw_for_internal_use_slv;
	
	-- rather than using the clock enables as clock enables, we use them as enables
	-- on the two signals, rdreq and wrreq, since these are the only signals which actually
	-- cause the fifo to do anything
	enabled_rdreq <= rdreq and rdena;
	enabled_wrreq <= wrreq and wrena;

	-- a shift register, containing DEPTH words each of
	-- which is WIDTH bits wide
	process (clock, reset)
	begin
		if reset = '1' then
			shift_register <= (others => dead_bits(WIDTH));
		elsif clock'EVENT and clock = '1' then
			for i in 0 to DEPTH - 1 loop
				-- each word in the fifo will do one of three
				-- things:
				-- 1. take the contents of data int
				if enabled_wrreq = '1' and ((enabled_rdreq = '1' and wrusedw_for_internal_use = i + 1)
				                        or  (enabled_rdreq = '0' and wrusedw_for_internal_use = i)) then
				    shift_register(i) <= data;
				-- 2. take the word from the previous element in the
				--    shift register (or all 1s for nothing)
				elsif enabled_rdreq = '1' then
					if i < DEPTH - 1 then
						shift_register(i) <= shift_register(i + 1);
					else
						shift_register(i) <= dead_bits(WIDTH);
					end if;
				end if;
				-- 3. hold its value
			end loop;
		end if;
	end process;
	q <= shift_register(0);

end architecture rtl;
