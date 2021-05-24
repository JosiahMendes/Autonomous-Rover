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

entity alt_cusp161_fifo_usedw_calculator is
	generic
	(
		WIDTH	            : integer := 8;
		DEPTH               : integer := 9;
		READ_TO_WRITE_DELAY : integer := 3;
		WRITE_TO_READ_DELAY : integer := 3;
		CLOCKS_ARE_SAME     : boolean := TRUE
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

		-- triggers
		wrreq	     : in  std_logic;
		rdreq	     : in  std_logic;

		-- information signals calculated (write side)
		wrusedw	     : out std_logic_vector(wide_enough_for(DEPTH) - 1 downto 0);
		full	     : out std_logic;
		almost_full  : out std_logic;
		-- information signals calculated (read side)
		rdusedw      : out std_logic_vector(wide_enough_for(DEPTH) - 1 downto 0);
		empty	     : out std_logic;
		almost_empty : out std_logic
	);
end entity;

architecture rtl of alt_cusp161_fifo_usedw_calculator is

    -- internal registers for the fullness/emptiness monitoring output ports
    signal rdusedw_reg      : unsigned(WIDTH - 1 downto 0);
    signal wrusedw_reg      : unsigned(WIDTH - 1 downto 0);
    signal full_reg         : std_logic;
    signal almost_full_reg  : std_logic;
    signal empty_reg        : std_logic;
    signal almost_empty_reg : std_logic;
    
begin

	-- check generics
	assert WIDTH > 0
		report "Generic WIDTH must greater than zero"
		severity ERROR;
	assert READ_TO_WRITE_DELAY >= 0
		report "Generic READ_TO_WRITE_DELAY must greater than or equal to zero"
		severity ERROR;
	assert WRITE_TO_READ_DELAY >= 0
		report "Generic WRITE_TO_READ_DELAY must greater than or equal to zero"
		severity ERROR;
		
	-- in single clock mode, just delay the signals using shift registers and
	-- update rdusedw and wrusedw accordingly
	-- if both delays are zero, rdusedw and wrusedw will be the same, however
	-- we need do nothing about this because any synthesis tool will fold such
	-- obvious bits of identical logic together
	single_clock_gen :
	if CLOCKS_ARE_SAME generate
		
		-- delayed (possibly by zero cycles!) versions of rdreq and wrreq
		signal rdreq_delay, wrreq_delay : std_logic;
		signal wrreq_to_delayer : std_logic;
		
	begin
		
		-- delaying unit for read
		rdreq_delayer : alt_cusp161_one_bit_delay
		generic map
		(
			DELAY => READ_TO_WRITE_DELAY
		)
		port map
		(
			clock => rdclock,
			ena   => rdena,
			reset => rdreset,
			data  => rdreq,
			q     => rdreq_delay
		);
		
		-- delaying unit for write
		-- note that this is enabled on the rdena, because the rdena stalls all of the interesting
		-- logic of the fifo, whereas the wrena just stalls a little bit of write logic
		wrreq_delayer : alt_cusp161_one_bit_delay
		generic map
		(
			DELAY => WRITE_TO_READ_DELAY
		)
		port map
		(
			clock => rdclock,
			ena   => '1',
			reset => rdreset,
			data  => wrreq_to_delayer,
			q     => wrreq_delay
		);
		wrreq_to_delayer <= wrreq and wrena;
		
		-- this process updates the wrusedw and full signals
		update_write_fullness_signals : process (wrclock, wrreset)
		begin
			if wrreset = '1' then
				-- start empty
				full_reg <= '0';
				almost_full_reg <= '0';
				wrusedw_reg <= (others => '0');
			elsif wrclock'EVENT and wrclock = '1' then
				-- update based on (possibly) delayed rdreq and up to date wrreq values
				if (rdreq_delay = '1' and rdena = '1') and (wrreq = '0' or wrena = '0') then
					-- reading and not writing decreases the used words in a fifo
					full_reg <= '0';
					if wrusedw_reg = to_unsigned(DEPTH - 1, WIDTH) then
						almost_full_reg <= '0';
					end if;
					wrusedw_reg <= wrusedw_reg - 1;
				elsif (rdreq_delay = '0' or rdena = '0') and (wrreq = '1' and wrena = '1') then
					-- writing and not reading increases the used words in a fifo
					if wrusedw_reg = to_unsigned(DEPTH - 1, WIDTH) then
						full_reg <= '1';
					end if;
					if wrusedw_reg = to_unsigned(maximum(DEPTH - 2, 0), WIDTH) then
						almost_full_reg <= '1';
					end if;
					wrusedw_reg <= wrusedw_reg + 1;
				end if;
			end if;
		end process;
		-- drive output lines from registers
		wrusedw <= std_logic_vector(wrusedw_reg);
		full <= full_reg;
		almost_full <= almost_full_reg when DEPTH > 1 else '1';

		-- this process updates the read side rdusedw and empty signals	
		update_read_emptiness_signals : process (rdclock, rdreset)
		begin
			if rdreset = '1' then
				-- start empty
				empty_reg <= '1';
				almost_empty_reg <= '1';
				rdusedw_reg <= (others => '0');
			elsif rdclock'EVENT and rdclock = '1' then
				-- update based on up to date rdreq and (possibly) delayed wrreq values
				-- update based on up to date rdreq and (possibly) delayed wrreq values
				if (rdreq = '1' and rdena = '1') and wrreq_delay = '0' then
					-- reading and not writing decreases the used words in the fifo
					if rdusedw_reg = to_unsigned(1, WIDTH) then
						empty_reg <= '1';
					end if;
					if rdusedw_reg = to_unsigned(2, WIDTH) then
						almost_empty_reg <= '1';
					end if;
					rdusedw_reg <= rdusedw_reg - 1;
				elsif (rdreq = '0' or rdena = '0') and wrreq_delay = '1' then
					-- writing and not reading increases the used words in the fifo
					empty_reg <= '0';
					if rdusedw_reg = to_unsigned(1, WIDTH) then
						almost_empty_reg <= '0';
					end if;
					rdusedw_reg <= rdusedw_reg + 1;
				end if;
			end if;
		end process;
		-- drive output lines from registers
		rdusedw <= std_logic_vector(rdusedw_reg);
		empty <= empty_reg;
		almost_empty <= almost_empty_reg when DEPTH > 1 else '1';
	
	end generate;
	
	-- in dual clock mode, need to maintain separate counters which only increment
	-- cross clock domains by converting to gray, avoiding metastability with shift
	-- registers and converting back
	dual_clock_gen :
	if CLOCKS_ARE_SAME = FALSE generate
		
		-- these counters are incremented when rdreqs and wrreqs happen
		-- they are then propagated across the clock domains and positive
		-- deltas in their values are looked for at the other side
		signal wrcounter, rdcounter : unsigned(WIDTH - 1 downto 0);
		
		-- the counters in their destination once they've crossed the clock domains
		signal clock_crossed_wrcounter, clock_crossed_rdcounter : std_logic_vector(WIDTH - 1 downto 0);
		
		-- monitoring how much the counters have changed
		signal clock_crossed_wrcounter_prev, clock_crossed_rdcounter_prev : std_logic_vector(WIDTH - 1 downto 0);
		signal writes_this_read_cycle, reads_this_write_cycle : std_logic_vector(WIDTH - 1 downto 0);
		
		-- sometimes extra delay is required after the clock crossing delay
		signal writes_this_read_cycle_delay, reads_this_write_cycle_delay : std_logic_vector(WIDTH - 1 downto 0);
	
	begin
	
		-- update the rdcounter in response to rdreq on the rdclock
		update_rdcounter : process (rdclock, rdreset)
		begin
			if rdreset = '1' then
				rdcounter <= (others => '0');
			elsif rdclock'EVENT and rdclock = '1' then
				if rdena = '1' then
					if rdreq = '1' then
						rdcounter <= rdcounter + 1;
					end if;
				end if;
			end if;
		end process;
		
		-- update the wrcounter in response to wrreq on the wrclock
		update_wrcounter : process (wrclock, wrreset)
		begin
			if wrreset = '1' then
				wrcounter <= (others => '0');
			elsif wrclock'EVENT and wrclock = '1' then
				if wrena = '1' then
					if wrreq = '1' then
						wrcounter <= wrcounter + 1;
					end if;
				end if;
			end if;
		end process;
	
		-- propagate the wrcounter across to the read clock domain and monitor
		-- how much it advances each cycle
		wrcounter_to_rdclock : alt_cusp161_gray_clock_crosser
		generic map
		(
			WIDTH => WIDTH
		)
		port map
		(
			inclock  => wrclock,
			outclock => rdclock,
			inena    => wrena,
			outena   => '1',
			inreset  => wrreset,
            outreset => rdreset,
			data     => std_logic_vector(wrcounter),
			q        => clock_crossed_wrcounter
		);
		-- track the previous value of clock_crossed_wrcounter
		update_clock_crossed_wrcounter_prev : process (rdclock, rdreset)
		begin
			if rdreset = '1' then
				clock_crossed_wrcounter_prev <= (others => '0');
			elsif rdclock'EVENT and rdclock = '1' then
				clock_crossed_wrcounter_prev <= clock_crossed_wrcounter;
			end if;
		end process;
		-- combinationally update the wrcounter delta this read cycle
		writes_this_read_cycle <= std_logic_vector(unsigned(clock_crossed_wrcounter) - unsigned(clock_crossed_wrcounter_prev));
		
		-- propagate the rdcounter across to the write clock domain and monitor
		-- how much it advances each cycle
		rdcounter_to_wrclock : alt_cusp161_gray_clock_crosser
		generic map
		(
			WIDTH => WIDTH
		)
		port map
		(
			inclock  => rdclock,
			outclock => wrclock,
			inena    => rdena,
			outena   => '1',
			inreset  => rdreset,
            outreset => wrreset,
			data     => std_logic_vector(rdcounter),
			q        => clock_crossed_rdcounter
		);
		-- track the previous value of clock_crossed_rdcounter
		update_clock_crossed_rdcounter_prev : process (wrclock, wrreset)
		begin
			if wrreset = '1' then
				clock_crossed_rdcounter_prev <= (others => '0');
			elsif wrclock'EVENT and wrclock = '1' then
				clock_crossed_rdcounter_prev <= clock_crossed_rdcounter;
			end if;
		end process;
		-- combinationally update the rdcounter delta this read cycle
		reads_this_write_cycle <= std_logic_vector(unsigned(clock_crossed_rdcounter) - unsigned(clock_crossed_rdcounter_prev));
		
		-- delay writes_this_read_cycle as requested
		writes_this_read_cycle_delayer : alt_cusp161_std_logic_vector_delay
		generic map
		(
			WIDTH => WIDTH,
			DELAY => WRITE_TO_READ_DELAY
		)
		port map
		(
			clock => rdclock,
			ena   => '1',
			reset => rdreset,
			data  => writes_this_read_cycle,
			q     => writes_this_read_cycle_delay
		);
		
		-- delay reads_this_write_cycle as requested
		reads_this_write_cycle_delayer : alt_cusp161_std_logic_vector_delay
		generic map
		(
			WIDTH => WIDTH,
			DELAY => READ_TO_WRITE_DELAY
		)
		port map
		(
			clock => wrclock,
			ena   => '1',
			reset => wrreset,
			data  => reads_this_write_cycle,
			q     => reads_this_write_cycle_delay
		);
		
		-- this process updates the wrusedw and full signals
		update_write_fullness_signals : process (wrclock, wrreset)
			variable new_wrusedw : unsigned(WIDTH - 1 downto 0);
		begin
			if wrreset = '1' then
				-- start empty
				full_reg <= '0';
				almost_full_reg <= '0';
				wrusedw_reg <= (others => '0');
			elsif wrclock'EVENT and wrclock = '1' then
				-- update based on wrreq and the number of reads which we've been told about
				-- this write cycle
				new_wrusedw := wrusedw_reg;
				if wrreq = '1' and wrena = '1' then
					new_wrusedw := new_wrusedw + 1;
				end if;
				new_wrusedw := new_wrusedw - unsigned(reads_this_write_cycle_delay); -- should not be possible for this to make it go negative
				-- update full
				if new_wrusedw = to_unsigned(DEPTH, WIDTH) then
					full_reg <= '1';
				else
					full_reg <= '0';
				end if;
				-- update almost full
				if new_wrusedw >= to_unsigned(DEPTH - 1, WIDTH) then
					almost_full_reg <= '1';
				else
					almost_full_reg <= '0';
				end if;
				-- update wrusedw_reg itself
				wrusedw_reg <= new_wrusedw;
			end if;
		end process;
		-- drive output lines from registers
		wrusedw <= std_logic_vector(wrusedw_reg);
		full <= full_reg;
		almost_full <= almost_full_reg when DEPTH > 1 else '1';
		
		-- this process updates the rdusedw and empty signals
		update_read_emptiness_signals : process (rdclock, rdreset)
			variable new_rdusedw : unsigned(WIDTH - 1 downto 0);
		begin
			if rdreset = '1' then
				-- start empty
				empty_reg <= '1';
				almost_empty_reg <= '1';
				rdusedw_reg <= (others => '0');
			elsif rdclock'EVENT and rdclock = '1' then
				-- update based on wrreq and the number of reads which we've been told about
				-- this write cycle
				new_rdusedw := rdusedw_reg;
				if rdreq = '1' and rdena = '1' then
					new_rdusedw := new_rdusedw - 1;
				end if;
				new_rdusedw := new_rdusedw + unsigned(writes_this_read_cycle_delay); -- should not be possible for this to make it wrap
				-- update empty
				if new_rdusedw = to_unsigned(0, WIDTH) then
					empty_reg <= '1';
				else
					empty_reg <= '0';
				end if;
				-- update almost empty
				if new_rdusedw <= to_unsigned(1, WIDTH) then
					almost_empty_reg <= '1';
				else
					almost_empty_reg <= '0';
				end if;                            
				-- update rdusedw_reg itself
				rdusedw_reg <= new_rdusedw;
			end if;
		end process;
		-- drive output lines from registers
		rdusedw <= std_logic_vector(rdusedw_reg);
		empty <= empty_reg;
		almost_empty <= almost_empty_reg when DEPTH > 1 else '1';
	
	end generate;
  
end;
