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

entity alt_cusp161_general_fifo is
	generic
	(
		WIDTH	           : integer := 8;
		DEPTH	           : integer := 4;
		CLOCKS_ARE_SAME    : boolean := TRUE;
		DEVICE_FAMILY      : string;
		RDREQ_TO_Q_LATENCY : integer := 1
	);
	port
	(
		-- clocks, enables and reset
        rdreset	     : in  std_logic;
		rdclock	     : in  std_logic;
		rdena        : in  std_logic;
        wrreset	     : in  std_logic;
		wrclock      : in  std_logic;
		wrena        : in  std_logic;

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

architecture rtl of alt_cusp161_general_fifo is

    -- ASSUMPTIONS --
    -- note that these constants are really prerequisites
    -- they are stating things that the code requires to be true
    -- if any of the other modules should change and make
    -- these untrue then the code may well fail
    constant RAM_FIFO_RDREQ_TO_Q_LATENCY   : integer := 3;
    constant LOGIC_FIFO_RDREQ_TO_Q_LATENCY : integer := 1;
    -- the code assumes that if this many clock cycles have elapsed
    -- between a write and a read to the same location in the ram
    -- then the new data will be seen
    -- must be at least 1 or the logic won't work
    -- the code also assumes that the delay associated with getting
    -- numbers across clock domains is significantly more than this
    constant RAM_READ_AFTER_WRITE_LATENCY : integer := 3;

	-- wide enough to express the maximum number of words in the whole fifo
	constant USEDW_WIDTH : integer := wide_enough_for(DEPTH);

	-- true when the fifo requested is small enough that if it is single-clocked,
	-- a logic only implementation is a good idea
	constant SMALL_FIFO : boolean := ((WIDTH * DEPTH) <= 32) or (DEPTH < 4);
    
    -- if a lower RDREQ_TO_Q_LATENCY is requested than the ram ordinarily
    -- provides then an output logic fifo is required to plug the gap
    -- this constant defines the required depth of this fifo
    -- the plus one is required because the fifo must be one element larger
    -- than the difference in latency it's trying to eliminate, because
    -- there is a one cycle read after write latency on the logic fifo
    -- N.B. if the ram fifo is not in use then these constants are ignored
    constant OUTPUT_LOGIC_FIFO_DEPTH  : integer := RAM_FIFO_RDREQ_TO_Q_LATENCY + 1 - RDREQ_TO_Q_LATENCY;
    constant OUTPUT_LOGIC_FIFO_IN_USE : boolean := OUTPUT_LOGIC_FIFO_DEPTH > 1;

	-- if the requested RDREQ_TO_Q_LATENCY is higher than that provided by the
	-- fifo components we intend to use to build the fifo then the general fifo
	-- must insert some delaying on the input signal to take this into account
	-- (and must model this delay in its own usedw calculation)
	function calculate_rdreq_to_q_latency_inc return integer is
		variable natural_rdreq_to_q_latency : integer;
	begin
		if CLOCKS_ARE_SAME and SMALL_FIFO then
			natural_rdreq_to_q_latency := LOGIC_FIFO_RDREQ_TO_Q_LATENCY;
		else
			natural_rdreq_to_q_latency := RAM_FIFO_RDREQ_TO_Q_LATENCY;
		end if;
		if RDREQ_TO_Q_LATENCY > natural_rdreq_to_q_latency then
			return RDREQ_TO_Q_LATENCY - natural_rdreq_to_q_latency;
		else
			return 0;
		end if;
	end function;
	constant RDREQ_TO_Q_LATENCY_INC : integer := calculate_rdreq_to_q_latency_inc;
	-- this holds the delayed rdreq
	signal rdreq_delay : std_logic;
	
	-- the general fifo needs to model the read to write and write to read latencies
	-- of the fifo as a whole, to update its usedw and so on correctly
	-- this can be quite complex as it depends on the combination of individual fifo
	-- components used
	function calculate_fifo_read_to_write_delay return integer is
	begin
		return RDREQ_TO_Q_LATENCY_INC;
	end function;
	constant FIFO_READ_TO_WRITE_DELAY : integer := calculate_fifo_read_to_write_delay;
	function calculate_fifo_write_to_read_delay return integer is
	begin
		if CLOCKS_ARE_SAME then
			if SMALL_FIFO then
				-- logic fifo only, very simple!
				return 0;
			elsif OUTPUT_LOGIC_FIFO_IN_USE then
				-- if an output logic fifo is in use then we need enough time from write to
				-- read to allow for a) data has been written into the ram, b) data gets from
				-- the ram to the output logic fifo, c) the output logic fifo fills
				-- minus one because the fifo can get data in one less than q latency, due to showahead
				return RAM_READ_AFTER_WRITE_LATENCY + RAM_FIFO_RDREQ_TO_Q_LATENCY - 1 + OUTPUT_LOGIC_FIFO_DEPTH;
			else
				-- if no output logic fifo is in use, then we just have to make sure that we
				-- don't rdreq from the ram before the data has updated in the ram
				return RAM_READ_AFTER_WRITE_LATENCY;
			end if;
		else
			-- in the dual clock case, we assume that the delay associated with crossing
			-- clock domains will always outweigh the read after write latency of the ram,
			-- so we only have to concern ourselves with additional delay incurred by the
			-- output logic fifo
			if OUTPUT_LOGIC_FIFO_IN_USE then
				-- minus one because the fifo can get data in one less than q latency, due to showahead
				return RAM_FIFO_RDREQ_TO_Q_LATENCY - 1 + OUTPUT_LOGIC_FIFO_DEPTH;
			else
				return 0;
			end if;
		end if;
	end function;
	constant FIFO_WRITE_TO_READ_DELAY : integer := calculate_fifo_write_to_read_delay;

begin

	-- instantiate a standard usedw calculator to do the usedw, empty etc. updating
	-- for the whole fifo - this may be the same as the usedw calculations for the
	-- components which make up this fifo (in which case any decent synthesis tool
	-- will optimise away the redundancy) or may be different
	usedw_calculator : alt_cusp161_fifo_usedw_calculator
	generic map
	(
		WIDTH => USEDW_WIDTH,
		DEPTH => DEPTH,
		CLOCKS_ARE_SAME => CLOCKS_ARE_SAME,
		READ_TO_WRITE_DELAY => FIFO_READ_TO_WRITE_DELAY,
		WRITE_TO_READ_DELAY => FIFO_WRITE_TO_READ_DELAY
	)
	port map
	(
		rdclock      => rdclock,
		rdena        => rdena,
		wrclock      => wrclock,
		wrena        => wrena,
		rdreset      => rdreset,
        wrreset      => wrreset,
		wrreq        => wrreq,
		rdreq        => rdreq,
		wrusedw      => wrusedw,
		full         => full,
		almost_full  => almost_full,
		rdusedw      => rdusedw,
		empty        => empty,
		almost_empty => almost_empty
	);
	
	-- delay incoming rdreq signal as necessary
	rdreq_delayer : alt_cusp161_one_bit_delay
	generic map
	(
		DELAY => RDREQ_TO_Q_LATENCY_INC
	)
	port map
	(
		clock => rdclock,
		ena   => rdena,
		reset => rdreset,
		data  => rdreq,
		q     => rdreq_delay
	);

	single_clock_small_gen :
	if CLOCKS_ARE_SAME and SMALL_FIFO generate
	begin

		-- use the logic fifo alone for really small single clock fifos
		logic_fifo : alt_cusp161_logic_fifo
		generic map
		(
			WIDTH              => WIDTH,
			DEPTH              => DEPTH
		)
		port map
		(
			clock => rdclock,
			rdena => rdena,
			wrena => wrena,
			reset => rdreset,
			wrreq => wrreq,
			data  => data,
			rdreq => rdreq_delay,
			q     => q
		);
	
	end generate;

	-- use a ram fifo for larger fifos or dual clock fifos
	dual_clock_or_large_gen :
	if not CLOCKS_ARE_SAME or not SMALL_FIFO generate			
		-- signals for ram fifo
		signal ram_fifo_q     : std_logic_vector(WIDTH - 1 downto 0);
		signal ram_fifo_empty : std_logic;
		signal ram_fifo_rdreq : std_logic;			
		signal ram_fifo_rdena : std_logic;
	begin
		-- this ram fifo can hold most of the data
		ram_fifo : alt_cusp161_ram_fifo
		generic map
		(
			WIDTH           => WIDTH,
			DEPTH           => DEPTH,
			CLOCKS_ARE_SAME => CLOCKS_ARE_SAME,
			DEVICE_FAMILY   => DEVICE_FAMILY
		)
		port map
		(
			rdclock => rdclock,
			wrclock => wrclock,
			rdreset => rdreset,
            wrreset => wrreset,
			empty   => ram_fifo_empty,
			wrreq   => wrreq,
			wrena   => wrena,
			data    => data,
			rdreq   => ram_fifo_rdreq,
			rdena   => ram_fifo_rdena,
			q       => ram_fifo_q
		);

		-- the RDREQ_TO_Q_LATENCY of the ram fifo is three
		-- if the user has requested a lower RDREQ_TO_Q_LATENCY,
		-- we need to instantiate an output logic fifo to smooth
		-- things out
		output_logic_fifo_gen :
		if OUTPUT_LOGIC_FIFO_IN_USE generate	
			-- signals for output logic fifo ports
			signal logic_fifo_data    : std_logic_vector(WIDTH - 1 downto 0);
			signal logic_fifo_full    : std_logic;
			signal logic_fifo_wrreq   : std_logic;
			signal logic_fifo_rdreq   : std_logic;
			signal logic_fifo_wrusedw : std_logic_vector(wide_enough_for(OUTPUT_LOGIC_FIFO_DEPTH) - 1 downto 0);
			signal data_in_transit    : unsigned(wide_enough_for(OUTPUT_LOGIC_FIFO_DEPTH) - 1 downto 0);
            signal data_total         : unsigned(wide_enough_for(OUTPUT_LOGIC_FIFO_DEPTH) downto 0);
		begin	
			-- feed the ram fifo output into the logic fifo input
			logic_fifo_data <= ram_fifo_q;
            data_total <= resize(unsigned(logic_fifo_wrusedw), wide_enough_for(OUTPUT_LOGIC_FIFO_DEPTH) + 1) + 
                          resize(data_in_transit, wide_enough_for(OUTPUT_LOGIC_FIFO_DEPTH) + 1);
			ram_fifo_rdena <= '1' when ((logic_fifo_rdreq = '1' and rdena = '1') or data_total <= OUTPUT_LOGIC_FIFO_DEPTH) else '0';
            
			-- instantiate logic fifo
			output_logic_fifo : alt_cusp161_logic_fifo
			generic map
			(
				WIDTH              => WIDTH,
				DEPTH              => OUTPUT_LOGIC_FIFO_DEPTH
			)
			port map
			(
				clock   => rdclock,
				rdena   => rdena,
				wrena   => ram_fifo_rdena, -- because this is entirely on the read side
				reset   => rdreset,
				full    => logic_fifo_full,
				wrreq   => logic_fifo_wrreq,
				wrusedw => logic_fifo_wrusedw,
				data    => logic_fifo_data,
				rdreq   => logic_fifo_rdreq,
				q       => q
			);

			-- in the situation where the user is requesting lower RDREQ_TO_Q_LATENCY
			-- than the ram fifo can provide, but more than the one cycle latency that
			-- the logic fifo provides, we need to delay the logic fifo rdreq
			logic_fifo_rdreq_delayer : alt_cusp161_one_bit_delay
			generic map
			(
				DELAY => RDREQ_TO_Q_LATENCY - 1
			)
			port map
			(
				clock => rdclock,
				ena   => rdena,
				reset => rdreset,
				data  => rdreq,
				q     => logic_fifo_rdreq
			);

			-- a shift register is used to delay the rdreq signal going into the ram
			-- to make a wrreq signal for the logic fifo
			-- this is required because of the high RDREQ_TO_Q_LATENCY of the ram fifo
			ram_fifo_rdreq_delayer : alt_cusp161_one_bit_delay
			generic map
			(
				DELAY => RAM_FIFO_RDREQ_TO_Q_LATENCY - 1 -- minus one because showahead
			)
			port map
			(
				clock => rdclock,
				ena   => ram_fifo_rdena,
				reset => rdreset,
				data  => ram_fifo_rdreq,
				q     => logic_fifo_wrreq
			);

			-- keep a count of how many words have been requested from the ram
			-- but not yet input into the logic fifo
			-- this is required because of the high RDREQ_TO_Q_LATENCY of the ram fifo
			update_data_in_transit : process (rdclock, rdreset)
			begin
				if rdreset = '1' then
					data_in_transit <= (others => '0');
				elsif rdclock'EVENT and rdclock = '1' then
					if ram_fifo_rdena = '1' then
						if ram_fifo_rdreq = '1' and logic_fifo_wrreq = '0' then
							-- requested but didn't receive, increase
							data_in_transit <= data_in_transit + 1;
						elsif ram_fifo_rdreq = '0' and logic_fifo_wrreq = '1' then
							-- didn't request but did receive, decrease
							data_in_transit <= data_in_transit - 1;
						end if;
					end if;
				end if;
			end process;

			-- calculate when the ram fifo should read (a combination of when the user
			-- requests reads and when the output logic fifo is not full)
			ram_fifo_rdreq <= '1' when ram_fifo_rdena = '1' and ram_fifo_empty = '0' else '0';
         
		end generate;

		-- alternatively just make sure the ram fifo is connected directly
		no_output_logic_fifo_gen :
		if not OUTPUT_LOGIC_FIFO_IN_USE generate
		begin
			q <= ram_fifo_q;
			ram_fifo_rdreq <= rdreq_delay;
			ram_fifo_rdena <= rdena;
		end generate;

	end generate;

end architecture rtl;
