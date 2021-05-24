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

entity alt_cusp161_pushing_width_adapter is
	generic (
        -- all cusp function units have these
        NAME      : string  := "";
        OPTIMIZED : integer := OPTIMIZED_ON;
        FAMILY    : integer := FAMILY_STRATIX;
        
        -- configuring the input and output widths
        IN_WIDTH  : integer := 16;
        OUT_WIDTH : integer := 16
  	);
  	port (
  		-- cusp system clock, reset
        clock            : in std_logic;
        reset            : in std_logic;
        
        -- interface to cusp
        ena              : in  std_logic := '1';
        
        -- input side
        input            : in  std_logic_vector(IN_WIDTH - 1 downto 0) := (others => '0');
        push             : in  std_logic;
        push_en          : in  std_logic;
        flush            : in  std_logic;
        flush_en         : in  std_logic;
        
        -- output port
        output           : out std_logic_vector(OUT_WIDTH - 1 downto 0) := (others => '0');
        output_valid     : out std_logic
  	);
end entity;

architecture rtl of alt_cusp161_pushing_width_adapter is

	-- the number of input words which will fit (wholly) into an output word
	constant N : integer := OUT_WIDTH / IN_WIDTH;

begin
	
	-- check validity of inputs
	assert IN_WIDTH <= OUT_WIDTH
		report "Currently only widening input adapters are supported"
		severity ERROR;
	
	n_more_than_one_gen :
	if N > 1 generate
		-- enough buffers to store N - 1 input words
		type buffers_type is array(integer range <>) of std_logic_vector(IN_WIDTH - 1 downto 0);
		signal buffers : buffers_type(N - 2 downto 0);
		
		-- a counter counts how many inputs we've buffered up in a one-hot format
		signal inputs_waiting : std_logic_vector(N - 1 downto 0);
	begin
		-- low bits of output come from the buffers, the high bits come from input
		-- using a combinational process for this so that we can loop
		assign_output : process (input, buffers)
		begin
			output <= (others => '0'); -- to ensure that any spare bits at the top are zeros
			for i in 0 to N - 2 loop
				output((i + 1) * IN_WIDTH - 1 downto i * IN_WIDTH) <= buffers(i);
			end loop;
			output(N * IN_WIDTH - 1 downto (N - 1) * IN_WIDTH) <= input;
		end process;
		
		-- output_valid is derived combinationally, but only very simply
		output_valid <= (push and push_en and inputs_waiting(N - 1)) or (flush and flush_en and not inputs_waiting(0));
		
		-- every time push is pulsed the counter rotates round and (unless it is
		-- time to produce an output word) one of the buffers captures what's on input
		update_buffers : process (clock, reset)
		begin
			if reset = '1' then
				buffers <= (others => (others => '0'));
				inputs_waiting(0) <= '1';
				inputs_waiting(N - 1 downto 1) <= (others => '0');
			elsif clock'EVENT and clock = '1' then
				if ena = '1' then
					if push = '1' and push_en = '1' and inputs_waiting(N - 1) = '0' then
						for i in 0 to N - 2 loop
							if inputs_waiting(i) = '1' then
								buffers(i) <= input;
							end if;
						end loop;
						inputs_waiting <= inputs_waiting(N - 2 downto 0) & inputs_waiting(N - 1);
					elsif (push = '1' and push_en = '1') or (flush = '1' and flush_en = '1') then
						-- outputting causes what is effectively a reset
						buffers <= (others => (others => '0'));
						inputs_waiting(0) <= '1';
						inputs_waiting(N - 1 downto 1) <= (others => '0');
					end if;
				end if;
			end if;
		end process;
	end generate;
	
	n_is_one_gen :
	if N = 1 generate
	begin
		-- pad the input word with zeros to make this output
		assign_output : process (input)
		begin
			output <= (others => '0'); -- to ensure that any spare bits at the top are zeros
			output(IN_WIDTH - 1 downto 0) <= input;
		end process;
		
		-- output_valid is derived combinationally, but only very simply
		output_valid <= push and push_en;
	end generate;
	
end architecture rtl;
