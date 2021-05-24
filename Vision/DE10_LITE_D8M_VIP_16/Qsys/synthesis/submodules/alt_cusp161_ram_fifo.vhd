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

entity alt_cusp161_ram_fifo is
	generic
	(
		WIDTH	        : integer := 8;
		DEPTH	        : integer := 3;
		CLOCKS_ARE_SAME : boolean := TRUE;
		DEVICE_FAMILY   : string
	);
	port
	(
		-- clocks, enables and reset
		rdclock	     : in  std_logic;
		rdena        : in  std_logic;
		wrclock      : in  std_logic;
		wrena        : in  std_logic;
		rdreset	     : in  std_logic;
        wrreset	     : in  std_logic;

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

architecture rtl of alt_cusp161_ram_fifo is
    
    -- ASSUMPTIONS --
    -- the code assumes that if this many clock cycles have elapsed
    -- between a write and a read to the same location in the ram
    -- then the new data will be seen
    -- must be at least 1 or the logic won't work
    constant RAM_READ_AFTER_WRITE_LATENCY : integer := 3;
    -- this code assumes that
    -- read after write delay need not be added to the usedw calculation if we're in dual clock
    -- mode, because the delay associated with crossing clock domains covers it
    function calculate_read_after_write_delay_required return integer is
    begin
    	if CLOCKS_ARE_SAME then
    		return RAM_READ_AFTER_WRITE_LATENCY;
    	else
    		return 0;
    	end if;
    end function;
    constant READ_AFTER_WRITE_DELAY_REQUIRED : integer := calculate_read_after_write_delay_required;
    
    -- note that addresses can be one bit narrower than usedw (if DEPTH is a power of two)
    constant ADDR_WIDTH  : integer := maximum(wide_enough_for(DEPTH - 1), 1);
    constant USEDW_WIDTH : integer := wide_enough_for(DEPTH);
    
    -- ram depth is 2 ^ ADDR_WIDTH rather than depth - if the fifo
    -- is not of power of two depth it wanders over the ram,
    -- but all ram words are always used, to save on comparators
    constant RAM_DEPTH : integer := two_to_the_power(ADDR_WIDTH);
    
	component altsyncram
		generic
		(
			OPERATION_MODE                     : string := "DUAL_PORT";
			WIDTH_A                            : natural := WIDTH;
			WIDTHAD_A                          : natural := ADDR_WIDTH;
			NUMWORDS_A                         : natural := RAM_DEPTH;
			WIDTH_B                            : natural := WIDTH;
			WIDTHAD_B                          : natural := ADDR_WIDTH;
			NUMWORDS_B                         : natural := RAM_DEPTH;    
			WIDTH_BYTEENA_A                    : natural := 1;
			WIDTH_BYTEENA_B                    : natural := 1;
			OUTDATA_REG_A                      : string := "CLOCK0";
			OUTDATA_REG_B                      : string := "CLOCK1";
			INDATA_REG_B                       : string := "CLOCK1";
			ADDRESS_REG_B                      : string := "CLOCK1";
			WRCONTROL_WRADDRESS_REG_B          : string := "CLOCK1";
			LPM_TYPE                           : string := "altsyncram";
			RAM_BLOCK_TYPE                     : string := "AUTO";
			INTENDED_DEVICE_FAMILY             : string := DEVICE_FAMILY;
			READ_DURING_WRITE_MODE_MIXED_PORTS : string := "OLD_DATA"
  		);
  		port
  		(
			clocken0  : in  std_logic ;
			clocken1  : in  std_logic ;
			wren_a    : in  std_logic ;
			clock0    : in  std_logic ;
			wren_b    : in  std_logic ;
			clock1    : in  std_logic ;
			address_a : in  std_logic_vector (widthad_a-1 downto 0);
			address_b : in  std_logic_vector (widthad_a-1 downto 0);
			q_a       : out std_logic_vector (width_a-1 downto 0);
			q_b       : out std_logic_vector (width_a-1 downto 0);
			data_a    : in  std_logic_vector (width_a-1 downto 0);
			data_b    : in  std_logic_vector (width_a-1 downto 0)
  		);
	end component;
    
    -- pointers into the ram used for reading and writing
    signal rdpointer      : unsigned(ADDR_WIDTH - 1 downto 0);
    signal wrpointer      : unsigned(ADDR_WIDTH - 1 downto 0);
    
    -- unused
    signal port_a_q : std_logic_vector(WIDTH - 1 downto 0);
    
begin

	-- check generics
	assert DEPTH > 0
		report "Generic DEPTH must greater than zero"
		severity ERROR;
	assert WIDTH > 0
		report "Generic WIDTH must greater than zero"
		severity ERROR;

	-- this fifo uses a ram block to store the fifo data
	-- port a is used for writing into the fifo
	-- port b is used for reading from the fifo
  	ram : altsyncram
  	port map
  	(
		clock0    => wrclock,
		clock1    => rdclock,
		clocken0  => wrena,
		clocken1  => rdena,
		wren_a    => wrreq,
		wren_b    => '0',
		address_a => std_logic_vector(wrpointer),
		address_b => std_logic_vector(rdpointer),
		q_a       => port_a_q,
		q_b       => q,
		data_a    => data,
		data_b    => (others => '0')
  	);
  	
  	-- the data in the ram does not move
  	-- two pointers, head and tail, chase each other through the ram
  	-- and define the extent of the fifo
  	-- if the read pointer catches up with the write pointer then the fifo is empty
  	-- if the write pointer catches up with the read pointer then the fifo is full
  	-- note that there is no protection here, reading from an empty fifo or
  	-- writing to a full one will cause undefined results
  	-- two processes, in case rdclock and wrclock are different
  	-- read first
	update_rdpointer : process (rdclock, rdreset)
	begin
		if rdreset = '1' then
			-- start at zero - pointers equal meaning empty
			rdpointer <= (others => '0');
		elsif rdclock'EVENT and rdclock = '1' then
			if rdena = '1' then
				if rdreq = '1' then
					rdpointer <= rdpointer + 1;
				end if;
			end if;
		end if;
	end process;
	-- ...and now write
	update_wrpointer : process (wrclock, wrreset)
	begin
		if wrreset = '1' then
			-- start at zero - pointers equal meaning empty
			wrpointer <= (others => '0');
		elsif wrclock'EVENT and wrclock = '1' then
			if wrena = '1' then
				if wrreq = '1' then
					wrpointer <= wrpointer + 1;
				end if;
			end if;
		end if;
	end process;
	
	-- instantiate a standard usedw calculator to do the usedw, empty etc. updating
	usedw_calculator : alt_cusp161_fifo_usedw_calculator
	generic map
	(
		WIDTH               => USEDW_WIDTH,
		DEPTH               => DEPTH,
		CLOCKS_ARE_SAME     => CLOCKS_ARE_SAME,
		READ_TO_WRITE_DELAY => 0,
		WRITE_TO_READ_DELAY => READ_AFTER_WRITE_DELAY_REQUIRED
	)
	port map
	(
		rdclock      => rdclock,
		wrclock      => wrclock,
		rdreset      => rdreset,
        wrreset      => wrreset,
		wrreq        => wrreq,
		rdreq        => rdreq,
		wrena        => wrena,
		rdena        => rdena,
		wrusedw      => wrusedw,
		full         => full,
		almost_full  => almost_full,
		rdusedw      => rdusedw,
		empty        => empty,
		almost_empty => almost_empty
	);
  
end ;
