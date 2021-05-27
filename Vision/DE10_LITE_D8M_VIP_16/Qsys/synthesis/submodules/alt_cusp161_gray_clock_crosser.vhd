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

entity alt_cusp161_gray_clock_crosser is
	generic
	(
		WIDTH : integer := 8
	);
	port
	(
		-- clock and reset
		inclock	 : in  std_logic;
		outclock : in  std_logic;
		inena    : in  std_logic;
		outena   : in  std_logic;
		inreset	 : in  std_logic;
        outreset : in  std_logic;
		
		-- data input and output
		data     : in  std_logic_vector(WIDTH - 1 downto 0);
		q        : out std_logic_vector(WIDTH - 1 downto 0)
	);
end entity;

architecture rtl of alt_cusp161_gray_clock_crosser is

	-- this signal holds the input data converted to gray format
	signal gray_data : std_logic_vector(WIDTH - 1 downto 0);
		
	-- a shift register, to carry the gray data across the clock domains avoiding metastability
	constant SHIFT_REGISTER_LENGTH : integer := 3;
	type shift_register_type is array(integer range <>) of std_logic_vector(WIDTH - 1 downto 0);
	signal shift_register : shift_register_type(SHIFT_REGISTER_LENGTH - 1 downto 0);
    attribute altera_attribute : string;
    attribute altera_attribute OF shift_register: SIGNAL IS "-name SYNCHRONIZER_IDENTIFICATION FORCED_IF_ASYNCHRONOUS";
	attribute preserve: boolean;
	attribute preserve of shift_register: signal is true;
	
	-- a register for the output, converted back to binary
	signal q_reg : std_logic_vector(WIDTH - 1 downto 0);

begin

	-- check generics
	assert WIDTH > 0
		report "Generic WIDTH must greater than zero"
		severity ERROR;
		
	-- convert input to gray format
	to_gray : process (inclock, inreset)
	begin
		if inreset = '1' then
			gray_data <= (others => '0');
		elsif inclock'EVENT and inclock = '1' then
			if inena = '1' then
				gray_data <= data xor ('0' & data(WIDTH - 1 downto 1));
			end if;
		end if;
	end process;
	
	-- shift register to cross clock domains and avoid metastability
	shift_reg : process (outclock, outreset)
	begin
		if outreset = '1' then
			shift_register <= (others => (others => '0'));
		elsif outclock'EVENT and outclock = '1' then
			--if outena = '1' then
				for i in 0 to SHIFT_REGISTER_LENGTH - 2 loop
					shift_register(i) <= shift_register(i + 1);
				end loop;
				shift_register(SHIFT_REGISTER_LENGTH - 1) <= gray_data; -- this statement crosses clock domains
			--end if;
		end if;
	end process;
	
	-- convert the output of the shift register back to binary for output
	from_gray : process (outclock, outreset)
		constant ZEROS       : std_logic_vector(WIDTH - 1 downto 0) := (others => '0');
		variable partial_xor : std_logic_vector(WIDTH - 1 downto 0);
		variable i           : integer;
	begin
		if outreset = '1' then
			q_reg <= (others => '0');
		elsif outclock'EVENT and outclock = '1' then
			if outena = '1' then
				partial_xor := shift_register(0);
				i := 1;
				while i < WIDTH loop
					partial_xor := partial_xor xor (ZEROS(i - 1 downto 0) & shift_register(0)(WIDTH - 1 downto i));
					i := i + 1;
				end loop;
				q_reg <= partial_xor;
			end if;
		end if;
	end process;
	
	-- drive output lines
	q <= q_reg;

end architecture rtl;
