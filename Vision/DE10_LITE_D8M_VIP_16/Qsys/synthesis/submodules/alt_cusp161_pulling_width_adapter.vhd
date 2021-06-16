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

entity alt_cusp161_pulling_width_adapter is
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
        need_input       : out std_logic;
        
        -- output port
        output           : out std_logic_vector(OUT_WIDTH - 1 downto 0) := (others => '0');
		pull             : in std_logic;
        pull_en          : in  std_logic;
        discard          : in  std_logic;
        discard_en       : in  std_logic
  	);
end entity;

architecture rtl of alt_cusp161_pulling_width_adapter is

	-- the number of output words which will fit (wholly) into an input word
	constant N : integer := IN_WIDTH / OUT_WIDTH;

	-- enough buffers to store N output words
	type buffers_type is array(integer range <>) of std_logic_vector(OUT_WIDTH - 1 downto 0);
	signal buffers : buffers_type(N - 1 downto 0);
	
	-- a counter counts how many output words we can serve without pulling from the input
	signal outputs_waiting : std_logic_vector(N - 1 downto 0);
    
    signal perform_pull : std_logic;
    signal perform_pull_delay0 : std_logic;
    signal perform_pull_delay1 : std_logic;
    signal perform_discard : std_logic;
    signal perform_discard_delay0 : std_logic;
    signal perform_discard_delay1 : std_logic;
    signal outputs_waiting_delay0 : std_logic;
    signal outputs_waiting_delay1 : std_logic;

begin
	
	-- check validity of inputs
	assert OUT_WIDTH <= IN_WIDTH
		report "Currently only narrowing output adapters are supported"
		severity ERROR;
	
	-- always output buffer zero
	output <= buffers(0);
	
	-- input_en is derived combinationally, but only very simply
	need_input <= pull and pull_en and outputs_waiting(0);
    
    perform_pull <= pull and pull_en;
    perform_discard <= discard and discard_en;
	
	-- every time pull is triggered the counter rotates round and:
	--   if there are no words stored, input is pulled and captured
	--   if there are words stored, the stored words are shifted
	-- either way there should be a new word in buffers(0) on the next cycle
	-- discard en just causes any outputs waiting to be discarded
	respond_triggers : process (clock, reset)
	begin
		if reset = '1' then
			buffers <= (others => (others => '0'));
			outputs_waiting(0) <= '1';
			outputs_waiting(N - 1 downto 1) <= (others => '0');
            perform_pull_delay0 <= '0';
            perform_pull_delay1 <= '0';
            perform_discard_delay0 <= '0';
            perform_discard_delay1 <= '0';
            outputs_waiting_delay0 <= '0';
            outputs_waiting_delay1 <= '0';
		elsif clock'EVENT and clock = '1' then
			if ena = '1' then
                if perform_pull = '1' then
					-- either way, rotate outputs waiting around to decrease the number of
					-- outputs waiting, or replace 0 with MAX
					outputs_waiting <= outputs_waiting(0) & outputs_waiting(N - 1 downto 1);
				elsif perform_discard = '1' then
					-- discard causes what is effectively a reset
					outputs_waiting(0) <= '1';
					outputs_waiting(N - 1 downto 1) <= (others => '0');
				end if;
                
                -- delay the control signals by the latency of the read (2 cycles)
                perform_pull_delay0 <= perform_pull;
                perform_pull_delay1 <= perform_pull_delay0;
                
                perform_discard_delay0 <= perform_discard;
                perform_discard_delay1 <= perform_discard_delay0;
                
                outputs_waiting_delay0 <= outputs_waiting(0);
                outputs_waiting_delay1 <= outputs_waiting_delay0;
                
				if perform_pull_delay1 = '1' then
					if outputs_waiting_delay1 = '1' then
						-- currently no outputs waiting, so this output request will
						-- have to be serviced by passing a request for a whole new
						-- input word to the input port
						-- driving need_input high is dealt with combinationally, so
						-- all that needs to be done here is capture the resulting
						-- output
						-- THE ASSUMPTION IS THAT WHATEVER IS DRIVING THE INPUT HAS
						-- A TRIGGER TO DATA DELAY OF ZERO
						for i in 0 to N - 1 loop
							buffers(i) <= input((i + 1) * OUT_WIDTH - 1 downto i * OUT_WIDTH);
						end loop;
					else
						-- currently have outputs waiting, so just shift the buffers
						-- around to prepare output for the next clock cycle
						for i in 0 to N - 2 loop
							buffers(i) <= buffers(i + 1);
						end loop;
					end if;
				elsif perform_discard_delay1 = '1' then
					-- discard causes what is effectively a reset
					buffers <= (others => (others => '0'));
				end if;
			end if;
		end if;
	end process;
	
end architecture rtl;
