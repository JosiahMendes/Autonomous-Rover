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

entity alt_cusp161_avalon_mm_bursting_master_fifo is
	generic (
        -- all cusp function units have these
        NAME                         : string  := "";
        OPTIMIZED                    : integer := OPTIMIZED_ON;
        FAMILY                       : integer := FAMILY_STRATIX;
        
        -- configuring the avalon port type
        ADDR_WIDTH                   : integer := 16;
        DATA_WIDTH                   : integer := 16;
        READ_USED                    : integer := 1;
        WRITE_USED                   : integer := 1;
        
        -- configuring optimisations
        CMD_FIFO_DEPTH               : integer := 8;
        RDATA_FIFO_DEPTH             : integer := 8;
        WDATA_FIFO_DEPTH             : integer := 8;
        WDATA_TARGET_BURST_SIZE      : integer := 5;
        RDATA_TARGET_BURST_SIZE      : integer := 5;
        CLOCKS_ARE_SYNC              : integer := 1;
        ADDRESS_GROUP                : integer := 1;
        BYTEENABLE_USED              : integer := 1;
        LEN_BE_WIDTH                 : integer := 11;
        BURST_WIDTH                  : integer := 6;
        
        -- interrupts
        INTERRUPT_USED               : INTEGER := 1;
        INTERRUPT_WIDTH              : INTEGER := 8
  	);
  	port (
  		-- cusp system clock, reset
        clock            : in std_logic;
        reset            : in std_logic;
        
        -- interface to cusp
        ena              : in  std_logic := '1';
        ready            : out std_logic; -- ???
        stall            : out std_logic;
        -- cmd port
        addr             : in  std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
        write            : in  std_logic := '0';
        burst            : in  std_logic := '0';
        len_be           : in  std_logic_vector(LEN_BE_WIDTH-1 downto 0) := (others => '0');
        cenable          : in  std_logic;
        cenable_en       : in  std_logic;
        -- wdata port
        wdata            : in  std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
        wenable          : in  std_logic;
        wenable_en       : in  std_logic := '0';
        -- rdata port
        rdata            : out std_logic_vector(DATA_WIDTH-1 downto 0);
        renable          : in  std_logic := '0';
        renable_en       : in  std_logic := '0';
        -- interrupt port
        activeirqs       : out std_logic_vector(INTERRUPT_WIDTH-1 DOWNTO 0) := (OTHERS=>'0');
        
        
        -- interface to avalon
        av_address       : out std_logic_vector(ADDR_WIDTH-1 downto 0);
        av_burstcount    : out std_logic_vector(BURST_WIDTH-1 downto 0);
        av_writedata     : out std_logic_vector(DATA_WIDTH-1 downto 0);
        av_byteenable    : out std_logic_vector((DATA_WIDTH/8)-1 downto 0);
        av_write         : out std_logic;
        av_read          : out std_logic;
        av_clock         : in  std_logic;
        av_reset         : in  std_logic := '0';
        av_readdata      : in  std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
        av_readdatavalid : in  std_logic := '0';
        av_waitrequest   : in  std_logic := '0';
        av_interrupt     : in  std_logic_vector(INTERRUPT_WIDTH-1 DOWNTO 0) := (OTHERS=>'0')
  	);
end entity;

architecture rtl of alt_cusp161_avalon_mm_bursting_master_fifo is
    COMPONENT alt_cusp161_sync_vec IS
    GENERIC (
        WIDTH : INTEGER
    );
	PORT (
		reset     : IN STD_LOGIC;
		clk       : IN STD_LOGIC;
		data_in   : IN STD_LOGIC_VECTOR(WIDTH-1 downto 0);
        data_out  : OUT STD_LOGIC_VECTOR(WIDTH-1 downto 0)
	);
    END COMPONENT;

	constant BE_WIDTH      : integer := calculate_be_width(DATA_WIDTH);
	constant BE_ADDR_BITS  : integer := wide_enough_for(BE_WIDTH) - 1;
	
	-- a larger target burst size than there is space in the fifo is unsatisfiable
	-- rather than throw an error, we cap it
	constant WDATA_TARGET_BURST_SIZE_CAPPED : integer := minimum(WDATA_TARGET_BURST_SIZE, WDATA_FIFO_DEPTH);
	constant RDATA_TARGET_BURST_SIZE_CAPPED : integer := minimum(RDATA_TARGET_BURST_SIZE, RDATA_FIFO_DEPTH);
	
	-- each of the three triggers can cause a stall
	signal cmd_en_stall, wdata_en_stall, rdata_en_stall : std_logic;
	
	-- a type for "commands"
	type command is record
		-- base address
		addr   : unsigned(ADDR_WIDTH - 1 downto 0);
		-- if a range command then the range length, if a not range write command then byte enables, otherwise unused
        len_be : unsigned(LEN_BE_WIDTH - 1 downto 0);
		-- type of command, of the form (Write, Range)
		mode   : std_logic_vector(1 downto 0);
    end record;
    -- the width of a command word
    constant CMD_WIDTH    : integer := ADDR_WIDTH + LEN_BE_WIDTH + 2;
    -- the width of the command fifo - less than that of a command word if part of it is known to be constant
    function calculate_cmd_fifo_width return integer is
    begin
    	if READ_USED = 1 and WRITE_USED = 1 then
    		return ADDR_WIDTH + LEN_BE_WIDTH + 2;
    	else
    		return ADDR_WIDTH + LEN_BE_WIDTH + 1;
    	end if;
    end function calculate_cmd_fifo_width;
    constant CMD_FIFO_WIDTH : integer := calculate_cmd_fifo_width;
    -- and some functions for converting from commands to std_logic_vectors...
    function to_std_logic_vector(c : command) return std_logic_vector is
    	variable r : std_logic_vector(CMD_FIFO_WIDTH - 1 downto 0);
    begin
    	if READ_USED = 1 and WRITE_USED = 1 then
    		r := std_logic_vector(c.addr) & std_logic_vector(c.len_be) & c.mode;
    	else
    		-- no need to waste fifo space on a constant if read only or write only
    		r := std_logic_vector(c.addr) & std_logic_vector(c.len_be) & c.mode(0);
    	end if;
    	return r;
    end function to_std_logic_vector;
    -- ...and back again
    function to_command(s : std_logic_vector) return command is
		variable u : unsigned(CMD_FIFO_WIDTH - 1 downto 0);
		variable r : command;
	begin
		u := unsigned(s);
		if READ_USED = 1 and WRITE_USED = 1 then
			r.addr := u(CMD_FIFO_WIDTH - 1 downto LEN_BE_WIDTH + 2);
			r.len_be := u(LEN_BE_WIDTH + 1 downto 2);
			r.mode := s(1 downto 0);
		else
			-- either read only or write only
			r.addr := u(CMD_FIFO_WIDTH - 1 downto LEN_BE_WIDTH + 1);
			r.len_be := u(LEN_BE_WIDTH downto 1);
			if READ_USED = 1 then
				-- read only, force "write" mode bit to zero
				r.mode := '0' & s(0);
			else
				-- write only, force "write" mode bit to one
				r.mode := '1' & s(0);
			end if;
		end if;
		return r;
    end function to_command;
	
	-- signals for wdata_fifo ports
	signal wdata_fifo_wrusedw      : std_logic_vector(wide_enough_for(WDATA_FIFO_DEPTH) - 1 downto 0) := (others => '0');
	signal wdata_fifo_full         : std_logic;
	signal wdata_fifo_almost_full  : std_logic;
	signal wdata_fifo_rdusedw      : std_logic_vector(wide_enough_for(WDATA_FIFO_DEPTH) - 1 downto 0) := (others => '0');
	signal wdata_fifo_empty        : std_logic;
	signal wdata_fifo_almost_empty : std_logic;
	signal wdata_fifo_wrreq        : std_logic;
	signal wdata_fifo_data         : std_logic_vector(DATA_WIDTH - 1 downto 0);
	signal wdata_fifo_rdreq        : std_logic;
	signal wdata_fifo_q            : std_logic_vector(DATA_WIDTH - 1 downto 0);
	-- derived wdata_fifo_signals
	signal wdata_fifo_empty_next   : std_logic;
	
	-- signals for rdata_fifo ports
	signal rdata_fifo_wrusedw      : std_logic_vector(wide_enough_for(RDATA_FIFO_DEPTH) - 1 downto 0) := (others => '0');
	signal rdata_fifo_full         : std_logic;
	signal rdata_fifo_almost_full  : std_logic;
	signal rdata_fifo_rdusedw      : std_logic_vector(wide_enough_for(RDATA_FIFO_DEPTH) - 1 downto 0) := (others => '0');
	signal rdata_fifo_empty        : std_logic;
	signal rdata_fifo_almost_empty : std_logic;
	signal rdata_fifo_wrreq        : std_logic;
	signal rdata_fifo_data         : std_logic_vector(DATA_WIDTH - 1 downto 0);
	signal rdata_fifo_rdreq        : std_logic;
	signal rdata_fifo_q            : std_logic_vector(DATA_WIDTH - 1 downto 0);
	-- derived rdata_fifo signals
	signal outstanding_reads                   : unsigned(wide_enough_for(RDATA_FIFO_DEPTH + RDATA_TARGET_BURST_SIZE) - 1 downto 0) := (others => '0');
	signal rdata_fifo_wrusedw_safe             : unsigned(wide_enough_for(RDATA_FIFO_DEPTH) - 1 downto 0) := (others => '0');
	signal rdata_fifo_has_space_next_threshold : unsigned(wide_enough_for(RDATA_FIFO_DEPTH) - 1 downto 0) := (others => '0');
	signal rdata_fifo_has_space_next           : std_logic;
    signal rdata_fifo_space_available          : unsigned(wide_enough_for(RDATA_FIFO_DEPTH) - 1 downto 0) := (others => '0');
    signal outstanding_reads_next              : unsigned(wide_enough_for(RDATA_FIFO_DEPTH + RDATA_TARGET_BURST_SIZE) - 1 downto 0) := (others => '0');
	signal outstanding_reads_valid_next        : unsigned(wide_enough_for(RDATA_FIFO_DEPTH + RDATA_TARGET_BURST_SIZE) - 1 downto 0) := (others => '0');
    
	-- signals for cmd_fifo ports
	signal cmd_fifo_wrusedw      : std_logic_vector(wide_enough_for(CMD_FIFO_DEPTH) - 1 downto 0) := (others => '0');
	signal cmd_fifo_full         : std_logic;
	signal cmd_fifo_almost_full  : std_logic;
	signal cmd_fifo_rdusedw      : std_logic_vector(wide_enough_for(CMD_FIFO_DEPTH) - 1 downto 0) := (others => '0');
	signal cmd_fifo_empty        : std_logic;
	signal cmd_fifo_almost_empty : std_logic;
	signal cmd_fifo_wrreq        : std_logic;
	signal mode                  : std_logic_vector(1 downto 0);
	signal cmd_fifo_data         : command;
	signal cmd_fifo_rdreq        : std_logic;
	signal cmd_fifo_q_slv        : std_logic_vector(CMD_FIFO_WIDTH - 1 downto 0) := (others => '0');
	signal cmd_fifo_q            : command;
	
	-- signals used by the logic which controls the avalon interface itself
	signal active_cmd, active_cmd_next, calculate_active_cmd_next : command := ((others => '0'), (others => '0'), (others => '0'));
	signal have_active_cmd, have_active_cmd_next : std_logic;
	signal active_cmd_expiring                   : std_logic;
	signal writing, reading                      : std_logic;
	signal cmd_fifo_q_has_range_zero_cmd         : std_logic;
    signal trying_to_write, trying_to_read       : std_logic;
    signal byte_enable                           : std_logic_vector((DATA_WIDTH / 8) - 1 downto 0);
    signal stall_int                             : std_logic;
    signal trying_to_write_address               : std_logic;
    signal trying_to_write_address_reg           : std_logic;
    signal trying_to_write_data                  : std_logic;
    
    -- a few handy and gates to help out the cusp internals
    signal cmd_en, wdata_en, rdata_en            : std_logic;
    
    signal write_count : unsigned(BURST_WIDTH - 1 downto 0);
    signal av_burstcount_int : std_logic_vector(BURST_WIDTH-1 downto 0);
    signal av_readdatavalid_vec : std_logic_vector(0 downto 0); 
    signal trying_to_write_next : std_logic;
    signal trying_to_read_next : std_logic;
    signal write_count_next : unsigned(BURST_WIDTH - 1 downto 0);
    signal av_burstcount_int_next : std_logic_vector(BURST_WIDTH-1 downto 0);
    signal av_address_int : std_logic_vector(ADDR_WIDTH-1 downto 0);
    signal av_address_int_next : std_logic_vector(ADDR_WIDTH-1 downto 0);
    
    signal pipeline3_en : std_logic;
    signal pipeline2_en : std_logic;   
    signal target_burst_size : unsigned(LEN_BE_WIDTH - 1 downto 0);
    signal new_cmd : command := ((others => '0'), (others => '0'), (others => '0'));
    signal split_valid_next : std_logic;
    signal split_valid : std_logic;
    signal split_cmd_next : command := ((others => '0'), (others => '0'), (others => '0'));
    signal split_cmd : command := ((others => '0'), (others => '0'), (others => '0'));
    signal dont_split_burst : std_logic;
    signal byte_enable_next : std_logic_vector((DATA_WIDTH / 8) - 1 downto 0);
    signal outstanding_writes : unsigned(wide_enough_for(WDATA_FIFO_DEPTH + WDATA_TARGET_BURST_SIZE) - 1 downto 0) := (others => '0');
    signal outstanding_writes_valid_next : unsigned(wide_enough_for(WDATA_FIFO_DEPTH + WDATA_TARGET_BURST_SIZE) - 1 downto 0) := (others => '0');
	signal wdata_fifo_rdreq_vec : std_logic_vector(0 downto 0); 
    signal pipeline1_en : std_logic;
    signal cmd_fifo_q_reg : command := ((others => '0'), (others => '0'), (others => '0'));
    signal cmd_fifo_empty_reg : std_logic;
    signal pipeline2_overflow_en : std_logic;
    
    signal wdata_rdena : std_logic;
    signal trying_to_write0 : std_logic;
    signal trying_to_write1 : std_logic;
    signal av_read_int : std_logic;
    signal av_read_int0 : std_logic;
    signal av_read_int1 : std_logic;
    signal av_address0 : std_logic_vector(ADDR_WIDTH-1 downto 0);
    signal av_address1 : std_logic_vector(ADDR_WIDTH-1 downto 0);
    signal av_burstcount0 : std_logic_vector(BURST_WIDTH-1 downto 0);
    signal av_burstcount1 : std_logic_vector(BURST_WIDTH-1 downto 0);
    signal av_byteenable0 : std_logic_vector((DATA_WIDTH / 8) - 1 downto 0);
    signal av_byteenable1 : std_logic_vector((DATA_WIDTH / 8) - 1 downto 0);
    
begin

	byteenable_used_check_gen :
	if BYTEENABLE_USED = 1 generate 
		assert (BE_WIDTH <= LEN_BE_WIDTH) report "LEN_BE_WIDTH is less than the required byteenable width" SEVERITY failure;
	end generate;
    
    assert (LEN_BE_WIDTH >= BURST_WIDTH) report "MAX_BURST is less than the TARGET_BURST_SIZE" SEVERITY failure;
    
	-- a few handy and gates to help out the cusp internals
	cmd_en <= cenable and cenable_en;
	rdata_en <= renable and renable_en;
	wdata_en <= wenable and wenable_en;
	
	-- this generate groups together the largest chunks of code which are only
	-- required if this master performs write operations
	write_used_gen :
	if WRITE_USED = 1 generate

		-- wdata_fifo stores words of data waiting to be written
		-- input side connected to cusp wdata triggered port
		-- output side feeds avalon interface
		wdata_fifo : alt_cusp161_general_fifo
		generic map
		(
			WIDTH              => DATA_WIDTH,
			DEPTH              => WDATA_FIFO_DEPTH,
			CLOCKS_ARE_SAME    => CLOCKS_ARE_SYNC = 1,
			DEVICE_FAMILY      => family_string(FAMILY),
			RDREQ_TO_Q_LATENCY => 3
		)
		port map
		(
			rdclock      => av_clock,
			wrclock      => clock,
			rdena        => wdata_rdena,
			wrena        => '1',
            rdreset      => av_reset,
			wrreset      => reset,
			wrusedw      => wdata_fifo_wrusedw,
			full         => wdata_fifo_full,
			almost_full  => wdata_fifo_almost_full,
			rdusedw      => wdata_fifo_rdusedw,
			empty        => wdata_fifo_empty,
			almost_empty => wdata_fifo_almost_empty,
			wrreq        => wdata_fifo_wrreq,
			data         => wdata_fifo_data,
			rdreq        => wdata_fifo_rdreq,
			q            => wdata_fifo_q
		);
        
        -- delay the output of the avalon signals when writes are enabled due
        -- to the latency in the fifo
        write_delay : process (av_clock, av_reset)
		begin
			if av_reset = '1' then
				trying_to_write0 <= '0';
                trying_to_write1 <= '0';
                
                av_read_int0 <= '0';
                av_read_int1 <= '0';
                
                av_address0 <= (others => '0');
                av_address1 <= (others => '0');
                
                av_burstcount0 <= (others => '0');
                av_burstcount1 <= (others => '0');
                
                av_byteenable0 <= (others => '0');
                av_byteenable1 <= (others => '0');
			elsif av_clock'EVENT and av_clock = '1' then
                if(wdata_rdena = '1') then
                    trying_to_write0 <= trying_to_write;
                    trying_to_write1 <= trying_to_write0;
                    
                    av_read_int0 <= av_read_int;
                    av_read_int1 <= av_read_int0;
                    
                    av_address0 <= av_address_int;
                    av_address1 <= av_address0;
                    
                    av_burstcount0 <= av_burstcount_int;
                    av_burstcount1 <= av_burstcount0;
                    
                    av_byteenable0 <= byte_enable;
                    av_byteenable1 <= av_byteenable0;
                end if;
            end if;
        end process;
        wdata_rdena <= not ((trying_to_write1 or av_read_int1) and av_waitrequest);
        
		-- cusp interface
		-- wdata port drives data on to wdata_fifo, stalls when
		-- there is an attempt to drive data but the fifo is full
		wdata_fifo_data <= wdata;
		wdata_fifo_wrreq <= wdata_en and ena; -- this protects us from overwrite
		wdata_en_stall <= wdata_en and wdata_fifo_full;
		
		-- avalon interface (signals used only by writing)
		-- pull data from the wdata fifo
		wdata_fifo_rdreq <= writing;
		av_writedata <= wdata_fifo_q;
		av_write <= trying_to_write1;
        av_read <= av_read_int1;
        av_address <= av_address1;
        av_burstcount <= av_burstcount1;
        av_byteenable <= av_byteenable1;     
		-- and track whether it will be empty next non-waitrequested cycle
		wdata_fifo_empty_next <= wdata_fifo_empty or (trying_to_write and wdata_fifo_almost_empty);
        
		-- keep track of how many write requests are waiting to go out onto the avalon switch fabric
        wdata_fifo_rdreq_vec(0) <= wdata_fifo_rdreq;
        outstanding_writes_valid_next <= to_unsigned(to_integer(outstanding_writes) - to_integer(unsigned(wdata_fifo_rdreq_vec)), outstanding_writes_valid_next'length);
        
        update_outstanding_writes : process (av_clock, av_reset)
		begin
			if av_reset = '1' then
				outstanding_writes <= (others => '0');
			elsif av_clock'EVENT and av_clock = '1' then
                if have_active_cmd_next = '1' and active_cmd_next.mode(1) = '1' and pipeline2_en = '1' then
                    if active_cmd_next.mode(0) = '0' then
                        -- single
                        outstanding_writes <= to_unsigned(to_integer(outstanding_writes_valid_next) + 1, outstanding_writes'length);
                    else
                        -- burst
                        outstanding_writes <= to_unsigned(to_integer(outstanding_writes_valid_next) + to_integer(active_cmd_next.len_be), outstanding_writes'length);
                    end if;
                else
                    outstanding_writes <= outstanding_writes_valid_next;
                end if;              
			end if;
		end process;
		
	end generate;
	
	-- this generate ties off signals not used when not writing to constants
	-- doing this prevents there being Xs in the simulation (which can have undesired effects
	-- if they are used in command calculations) but ensures that appropriate bits of the
	-- command logic are optimised away
	write_not_used_gen :
	if WRITE_USED /= 1 generate
	
		-- setting the wdata fifo signals to model an empty and inactive fifo should be harmless
		wdata_fifo_wrusedw <= (others => '0');
		wdata_fifo_rdusedw <= (others => '0');
		wdata_fifo_full <= '0';
		wdata_fifo_empty <= '1';
		wdata_fifo_almost_full <= '0';
		wdata_fifo_almost_empty <= '1';
		wdata_fifo_q <= (others => '0');
		wdata_fifo_data <= (others => '0');
		wdata_fifo_wrreq <= '0';
		wdata_fifo_rdreq <= '0';
		wdata_fifo_empty_next <= '0';
		
        -- no outstanding writes
		outstanding_writes <= (others => '0');
		-- there can be no wdata stall
		wdata_en_stall <= '0';
		
		-- write side of avalon interface is inactive
		av_writedata <= (others => '0');
		av_write <= '0';
        av_read <= av_read_int;
        av_address <= av_address_int;
        av_burstcount <= av_burstcount_int;
        av_byteenable <= byte_enable;
        
	   wdata_rdena <= not (av_read_int and av_waitrequest);
	end generate;
	
	-- this generate groups together the largest chunks of code which are only
	-- required if this master performs read operations	
	read_used_gen_gen :
	if READ_USED = 1 generate
	
		-- rdata_fifo stores words of data which have been received
		-- from the avalon interface and a waiting to be read by cusp
		-- input side connected to avalon readdata port
		-- output side feeds cusp rdata triggered port
		rdata_fifo : alt_cusp161_general_fifo
		generic map
		(
			WIDTH              => DATA_WIDTH,
			DEPTH              => RDATA_FIFO_DEPTH,
			CLOCKS_ARE_SAME    => CLOCKS_ARE_SYNC = 1,
			DEVICE_FAMILY      => family_string(FAMILY),
			RDREQ_TO_Q_LATENCY => 3
		)
		port map
		(
			rdclock      => clock,
			wrclock      => av_clock,
			rdena        => ena,
			wrena        => '1',
            rdreset      => reset,
            wrreset      => av_reset,
			wrusedw      => rdata_fifo_wrusedw,
			full         => rdata_fifo_full,
			almost_full  => rdata_fifo_almost_full,
			rdusedw      => rdata_fifo_rdusedw,
			empty        => rdata_fifo_empty,
			almost_empty => rdata_fifo_almost_empty,
			wrreq        => rdata_fifo_wrreq,
			data         => rdata_fifo_data,
			rdreq        => rdata_fifo_rdreq,
			q            => rdata_fifo_q
		);
		
		-- cusp interface
		-- rdata port reads data from rdata_fifo
		rdata <= rdata_fifo_q;
		rdata_fifo_rdreq <= rdata_en;
		rdata_en_stall <= rdata_en and rdata_fifo_empty;
		
		-- to help control at avalon interface end
		-- keep track of how many read requests are out in the avalon switch fabric
		-- somewhere - requested but not yet received
		av_readdatavalid_vec(0) <= av_readdatavalid;
        outstanding_reads_valid_next <= to_unsigned(to_integer(outstanding_reads) - to_integer(unsigned(av_readdatavalid_vec)), outstanding_reads_valid_next'length);
        
        update_outstanding_reads : process (av_clock, av_reset)
		begin
			if av_reset = '1' then
				outstanding_reads <= (others => '0');
			elsif av_clock'EVENT and av_clock = '1' then
                if have_active_cmd_next = '1' and active_cmd_next.mode(1) = '0' and pipeline2_en = '1' then
                    if active_cmd_next.mode(0) = '0' then
                        -- single
                        outstanding_reads <= to_unsigned(to_integer(outstanding_reads_valid_next) + 1, outstanding_reads'length);
                    else
                        -- burst
                        outstanding_reads <= to_unsigned(to_integer(outstanding_reads_valid_next) + to_integer(active_cmd_next.len_be), outstanding_reads'length);
                    end if;
                else
                    outstanding_reads <= outstanding_reads_valid_next;
                end if;              
			end if;
		end process;      
		
		-- calculate number of used words in the rdata fifo, taking into account words
		-- that may be used before the next cusp read by read requests already issued       
        rdata_fifo_space_available <= RDATA_FIFO_DEPTH - unsigned(rdata_fifo_wrusedw);

		-- avalon interface (signals used only be reading)
		-- accept read data from the avalon interface and put it in the rdata_fifo
		-- note that there is no protection from overwrite here - we protect ourselves
		-- by ensuring that we don't issue more read requests than we can cope with
		rdata_fifo_data <= av_readdata;
		rdata_fifo_wrreq <= av_readdatavalid;
		av_read_int <= trying_to_read;
		
	end generate;
	
	-- this generate ties off signals not used when not reading to constants
	-- doing this prevents there being Xs in the simulation (which can have undesired effects
	-- if they are used in command calculations) but ensures that appropriate bits of the
	-- command logic are optimised away
	read_not_used_gen :
	if READ_USED /= 1 generate
	
		-- setting the rdata fifo signals to model an empty and inactive fifo should be harmless
		rdata_fifo_wrusedw <= (others => '0');
		rdata_fifo_rdusedw <= (others => '0');
		rdata_fifo_full <= '0';
		rdata_fifo_empty <= '1';
		rdata_fifo_almost_full <= '0';
		rdata_fifo_almost_empty <= '1';
		rdata_fifo_q <= (others => '0');
		rdata_fifo_data <= (others => '0');
		rdata_fifo_wrreq <= '0';
		rdata_fifo_rdreq <= '0';
		
		-- rdata port is inactive, there can be no rdata stall
		rdata <= (others => '0');
		rdata_en_stall <= '0';
		
		-- no outstanding reads
		outstanding_reads <= (others => '0');
		-- zero the bits of logic which are used to help the command system know whether reads are ok
		rdata_fifo_wrusedw_safe <= (others => '0');
		rdata_fifo_has_space_next_threshold <= (others => '0');
		rdata_fifo_has_space_next <= '0';
		
		-- read side of avalon interface is inactive
		av_read_int <= '0';

	end generate;
	
	-- cmd_fifo stores "commands" from cusp to be processed by
	-- the avalon side
	-- each command consists of an address, a len_be word and two mode bits
	cmd_fifo : alt_cusp161_general_fifo
	generic map
	(
		WIDTH              => CMD_FIFO_WIDTH,
		DEPTH              => CMD_FIFO_DEPTH,
		CLOCKS_ARE_SAME    => CLOCKS_ARE_SYNC = 1,
		DEVICE_FAMILY      => family_string(FAMILY),
		RDREQ_TO_Q_LATENCY => 1
	)
	port map
	(
		rdclock      => av_clock,
		wrclock      => clock,
		rdena        => '1',
		wrena        => '1',
        rdreset      => av_reset,
		wrreset      => reset,
		wrusedw      => cmd_fifo_wrusedw,
		full         => cmd_fifo_full,
		almost_full  => cmd_fifo_almost_full,
		rdusedw      => cmd_fifo_rdusedw,
		empty        => cmd_fifo_empty,
		almost_empty => cmd_fifo_almost_empty,
		wrreq        => cmd_fifo_wrreq,
		data         => to_std_logic_vector(cmd_fifo_data),
		rdreq        => cmd_fifo_rdreq,
		q            => cmd_fifo_q_slv
	);
	
	-- the cusp interface consists of three triggered ports
	-- cmd (command), wdata (write data) and rdata (read data)
	-- plus some stall and enable signals and so on
	
	-- stall when any of the triggers have caused a stall
	stall_int <= cmd_en_stall or wdata_en_stall or rdata_en_stall;
	ready <= not stall_int;
	stall <= stall_int;
	
	-- cmd port drives commands on to cmd_fifo, stalls when
	-- there is an attempt to drive data but the fifo is full
	mode <= write & burst;
	cmd_fifo_data <= (unsigned(addr), unsigned(len_be), mode);
	cmd_fifo_wrreq <= '1' when cmd_en = '1'
						   and ena = '1' -- this protects us from overflow
						   and (burst = '0' or unsigned(len_be) > to_unsigned(0, LEN_BE_WIDTH)) else -- this discards range zero commands
					  '0';
	cmd_en_stall <= cmd_en and cmd_fifo_full;
	
	-- the avalon interface reads commands from the command fifo
	-- and issues read and write requests, using data from the wdata
	-- fifo for the writes
	-- it also responds to the requested read data coming back from
	-- the avalon switch fabric by putting it into the rdata fifo
	
    -- pipeline3, issues reads and writes to the avalon mm switch fabric
    pipeline3_en <= '1' when wdata_rdena = '1' and write_count = to_unsigned(1, BURST_WIDTH) else '0';
    -- pipeline2, decides whether there is enough space/data available to issue the next command
    pipeline2_en <= pipeline3_en and not (have_active_cmd and not (trying_to_read_next or trying_to_write_next));
    -- pipeline2_overflow, uses the split_cmd register to store an extra cmd, allowing pipeline1 to stall later than pipeline 2 and 3
    -- this breaks the combinatorial path to cmd_fifo_rdreq which greatly improves fmax
    pipeline2_overflow_en <= pipeline3_en or (not pipeline2_en and not split_valid);
    -- pipeline1, splits commands into smaller bursts
    pipeline1_en <= not split_valid;
    
	update_active_cmd : process (av_clock, av_reset)
	begin
		if av_reset = '1' then
            write_count <= to_unsigned(1, BURST_WIDTH);
            trying_to_write <= '0';
			trying_to_read <= '0';
            av_burstcount_int <= (others => '0');
            av_address_int <= (others => '0');
            byte_enable <= (others => '0');       
            
            active_cmd <= ((others => '0'), (others => '0'), (others => '0'));
			have_active_cmd <= '0';
            split_valid <= '0';
            split_cmd <= ((others => '0'), (others => '0'), (others => '0'));
            
            cmd_fifo_q_reg <= ((others => '0'), (others => '0'), (others => '0'));
            cmd_fifo_empty_reg <= '1';
		elsif av_clock'EVENT and av_clock = '1' then
            if pipeline3_en = '1' then
                write_count <= write_count_next;
                trying_to_write <= trying_to_write_next;
                trying_to_read <= trying_to_read_next;
                av_burstcount_int <= av_burstcount_int_next;
                av_address_int <= av_address_int_next;
                byte_enable <= byte_enable_next;
            else
                if wdata_rdena = '1' then
                    write_count <= write_count - 1;
                end if;
            end if;
            
            if pipeline2_en = '1' then
                active_cmd <= active_cmd_next;
                have_active_cmd <= have_active_cmd_next; 
            end if;
            
            if pipeline2_overflow_en = '1' then
                split_valid <= split_valid_next;
                split_cmd <= split_cmd_next;
            end if;
            
            if pipeline1_en = '1' then
                cmd_fifo_q_reg <= cmd_fifo_q;
                cmd_fifo_empty_reg <= cmd_fifo_empty;
            end if;
		end if;
	end process;
    
    -- pipeline stage 0
    
    -- the pipeline stage 1 needs data from the fifo under the following conditions
    cmd_fifo_rdreq <= pipeline1_en and not cmd_fifo_empty;
    cmd_fifo_q <= to_command(cmd_fifo_q_slv);
    
    -- pipeline stage 1
    
	-- if there is a split (burst than needs to be cut down) or a stall further up the pipeline we use the split cmd registers to save the
    -- new_cmd. This is then used as the next active cmd.
	active_cmd_next <= new_cmd when dont_split_burst = '1' else
                       (addr => new_cmd.addr, len_be => target_burst_size, mode => new_cmd.mode);
    target_burst_size <= to_unsigned(WDATA_TARGET_BURST_SIZE_CAPPED, LEN_BE_WIDTH) when new_cmd.mode(1) = '1' else
                         to_unsigned(RDATA_TARGET_BURST_SIZE_CAPPED, LEN_BE_WIDTH);
    new_cmd <= split_cmd when split_valid = '1' else
               cmd_fifo_q_reg;
    split_valid_next <= have_active_cmd_next and (not dont_split_burst or not pipeline2_en);
    split_cmd_next <= new_cmd when pipeline2_en = '0' else
                      (addr => (((new_cmd.addr srl BE_ADDR_BITS) + resize(target_burst_size, ADDR_WIDTH)) sll BE_ADDR_BITS), len_be => new_cmd.len_be - target_burst_size, mode => new_cmd.mode);
    have_active_cmd_next <= not cmd_fifo_empty_reg or split_valid;  
    dont_split_burst <= '1' when new_cmd.len_be <= target_burst_size or new_cmd.mode(0) = '0' else '0';	
    
    -- pipeline stage 2
    
	-- if byte enables are in use and the next command will be
    -- a single write, then pull its byte enables from the bottom
    -- bits of len_be
    byte_enable_next <= std_logic_vector(active_cmd.len_be(BE_WIDTH - 1 downto 0)) when BYTEENABLE_USED = 1 and active_cmd.mode = "10" else
                        (others => '1');
	
	-- decide whether trying_to_write and trying_to_read should be high on
	-- the next non-waitrequested cycle
	update_try_to_write : process (have_active_cmd, active_cmd, wdata_fifo_rdusedw, rdata_fifo_space_available, outstanding_reads, outstanding_writes,
                                   trying_to_write, trying_to_read, write_count, av_burstcount_int, av_address_int)
	begin
        trying_to_write_next <= trying_to_write;
		trying_to_read_next <= trying_to_read;
        write_count_next <= write_count;
        av_burstcount_int_next <= av_burstcount_int;   
        av_address_int_next <= av_address_int;       
        
        if have_active_cmd = '0' then
		    -- if no active command next cycle, then no reading and no writing
			trying_to_write_next <= '0';
			trying_to_read_next <= '0';   
		else
            av_address_int_next <= std_logic_vector(active_cmd.addr);
            if active_cmd.mode(1) = '1' then	
                -- if there is enough data available then issue the write
                if to_integer(unsigned(wdata_fifo_rdusedw)) >= to_integer(outstanding_writes) then
                    if active_cmd.mode(0) = '0' then
                        trying_to_write_next <= '1';
                        write_count_next <= to_unsigned(1, BURST_WIDTH);
                        av_burstcount_int_next <= std_logic_vector(to_unsigned(1, BURST_WIDTH));                               
                    else
                        trying_to_write_next <= '1';
                        write_count_next <= to_unsigned(to_integer(unsigned(active_cmd.len_be)), BURST_WIDTH);
                        av_burstcount_int_next <= std_logic_vector(resize(active_cmd.len_be, BURST_WIDTH)); 
                    end if;
                else
                    trying_to_write_next <= '0';
                end if;
                -- definitely won't read
                trying_to_read_next <= '0';
            else
			    -- if there is enough space available then issue the read
                if to_integer(rdata_fifo_space_available) >= to_integer(outstanding_reads) then
                    if active_cmd.mode(0) = '0'  then
                        trying_to_read_next <= '1';
                        av_burstcount_int_next <= std_logic_vector(to_unsigned(1, BURST_WIDTH));
                    else
                        trying_to_read_next <= '1';
                        av_burstcount_int_next <= std_logic_vector(resize(active_cmd.len_be, BURST_WIDTH));     
                    end if;
                else
                    trying_to_read_next <= '0';
                end if;
                -- definitely won't write
                trying_to_write_next <= '0';
            end if;
        end if;
	end process;
	
    -- pipeline stage 3
    
	-- determining what the avalon side of the interface is actually doing -
	-- a combination of intent and avalon's permission
	writing <= trying_to_write and wdata_rdena;
	reading <= trying_to_read and wdata_rdena;
    
    -- interrupts
    sync_clocks: IF (CLOCKS_ARE_SYNC /= 0) GENERATE
       has_irq: IF (INTERRUPT_USED /= 0) GENERATE
            activeirq_reg: PROCESS (clock, reset)
       	    BEGIN
           	    IF reset = '1' THEN
               	    activeirqs <= (OTHERS=>'1');
                ELSIF Rising_edge(clock) THEN
               	    activeirqs <= av_interrupt;     
                END IF;
            END PROCESS;
        END GENERATE;     
	END GENERATE;

    async_clocks: IF (CLOCKS_ARE_SYNC = 0) GENERATE
        has_irq: IF (INTERRUPT_USED /= 0) GENERATE
            activeirq_reg: alt_cusp161_sync_vec
                GENERIC MAP (WIDTH=>INTERRUPT_WIDTH) PORT MAP (clk=>clock, reset=>reset, data_in=>av_interrupt, data_out=>activeirqs);
        END GENERATE;     
	END GENERATE;
end architecture rtl;
