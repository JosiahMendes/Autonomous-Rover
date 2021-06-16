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

entity alt_cusp161_fifo is
 	generic (
	    NAME                                    : string  := "";
        OPTIMIZED                               : integer := OPTIMIZED_ON;
        FAMILY                                  : integer := FAMILY_STRATIX;
        WIDTH                                   : integer := 16;
        READ_TRIGGER_TO_READ_DATA_CHANGE_CYCLES : integer := 2;
        DEPTH                                   : integer := 16
	);
	port (
    	clock         : in  std_logic;        
    	reset         : in  std_logic := '0';
    
    	-- read side
    	ena_read      : in  std_logic := '1';
    	stall_read    : out std_logic := '0';
    	readnext      : in  std_logic := '0';
    	readnext_en   : in  std_logic := '0';
    	rdata         : out std_logic_vector(width - 1 downto 0);
    	
    	-- write side
		ena_write     : in  std_logic := '1';
		stall_write   : out std_logic := '0';
        writenext     : in  std_logic := '0';
    	writenext_en  : in  std_logic := '0';
    	wdata         : in  std_logic_vector(width - 1 downto 0) := (others => '0');
    
    	-- output ports which are untriggered
    	-- can vary at will and be shared between threads
    	dataavail     : out std_logic;
    	spaceavail    : out std_logic
	);
end entity;

architecture rtl of alt_cusp161_fifo is
		
	-- signals (almost) directly corresponding to the alt_cusp_general_fifo ports
	signal wrusedw      : std_logic_vector(wide_enough_for(DEPTH) - 1 downto 0);
	signal full	        : std_logic;
	signal almost_full  : std_logic;
	signal rdusedw      : std_logic_vector(wide_enough_for(DEPTH) - 1 downto 0);
	signal empty	    : std_logic;
	signal almost_empty : std_logic;
	signal wrreq	    : std_logic;
	signal data	        : std_logic_vector(WIDTH - 1 downto 0);		
	signal rdreq	    : std_logic;
	signal q		    : std_logic_vector(WIDTH - 1 downto 0);
	signal rdena_fifo   : std_logic;
	signal wrena_fifo   : std_logic;

begin

	-- instantiate an alt_cusp_general_fifo to do the actually fifoing
	-- this will use rams or logic to do the storage as necessary
	the_fifo : alt_cusp161_general_fifo
	generic map
	(
		WIDTH              => WIDTH,
		DEPTH              => DEPTH,
		CLOCKS_ARE_SAME    => TRUE,
		RDREQ_TO_Q_LATENCY => READ_TRIGGER_TO_READ_DATA_CHANGE_CYCLES,
		DEVICE_FAMILY      => family_string(FAMILY)
		-- NB: the requested latency could be one cycle higher
		-- (which might make RAM fifos cheaper, and would make latency zero possible)
		-- if we didn't have to obey tta rules
	)
	port map
	(
		rdclock      => clock,
		wrclock      => clock,
		rdena        => rdena_fifo,
		wrena        => wrena_fifo,
		rdreset      => reset,
        wrreset      => reset,
		wrusedw  	 => wrusedw,
		full         => full,
		almost_full  => almost_full,
		rdusedw      => rdusedw,
		empty        => empty,
		almost_empty => almost_empty,
		wrreq        => wrreq,
		data         => data,
		rdreq        => rdreq,
		q            => q
	);
	
	-- assign dataavail and spaceavail based on what the fifo says
	dataavail <= not empty;
	spaceavail <= not full;
	
	-- route the write data to the fifo
	data <= wdata;
	
	-- with non-single-cycle latency, things get complicated because sometimes we have to stall the fifo
	multi_cycle_latency_gen :
	if READ_TRIGGER_TO_READ_DATA_CHANGE_CYCLES > 1 generate
		
		-- some signals for handling requests and stalling on the read side
		signal read_request_history  : std_logic_vector(READ_TRIGGER_TO_READ_DATA_CHANGE_CYCLES - 2 downto 0);
		signal read_issue_history    : std_logic_vector(READ_TRIGGER_TO_READ_DATA_CHANGE_CYCLES - 2 downto 0);
		signal unissued_requests     : unsigned(wide_enough_for(READ_TRIGGER_TO_READ_DATA_CHANGE_CYCLES - 1) - 1 downto 0);
		signal are_unissued_requests : std_logic;
		signal cusp_rdreq            : std_logic;
		signal stall_fifo            : std_logic;
	
	begin
	
		-- read requests to the fifo and stalling
		-- issue a read request if there are outstanding read requests we didn't issue or a read has been requested
		-- this cycle, and the fifo is able to accept reads
		are_unissued_requests <= '1' when unissued_requests > 0 else '0';
		cusp_rdreq <= readnext and readnext_en and ena_read;
		rdreq <= (are_unissued_requests or cusp_rdreq) and not empty and rdena_fifo;
		-- stall the cusp read thread when it is expecting some data which it isn't going to get
		stall_read <= read_request_history(0) and not read_issue_history(0);
		-- stall the fifo when it is about to throw away data which cusp isn't ready for
		stall_fifo <= read_issue_history(0) and not (read_request_history(0) and ena_read);
		rdena_fifo <= not stall_fifo;
		
		-- write requests to the fifo and stalling
		-- never need to stall the fifo because of the write side
		wrreq <= writenext and writenext_en and ena_write and not full and wrena_fifo;
		stall_write <= writenext and writenext_en and (full or not wrena_fifo);
		wrena_fifo <= '1';
		
		-- keep track of read requests and read issues
		-- update rdata in accordance with tta rules
		process (clock, reset)
		begin
			if reset = '1' then
				read_request_history <= (others => '0');
				read_issue_history <= (others => '0');
				unissued_requests <= (others => '0');
				rdata <= (others => '0');
			elsif clock'EVENT and clock = '1' then
				-- rdata must change on cycles where readnext and readnext_en
				-- were both high READ_TRIGGER_TO_READ_DATA_CHANGE_CYCLES read enabled cycles earlier
				-- read_request_history tracks this			
				if ena_read = '1' then
					for i in 0 to READ_TRIGGER_TO_READ_DATA_CHANGE_CYCLES - 3 loop
						read_request_history(i) <= read_request_history(i + 1);
					end loop;
					read_request_history(READ_TRIGGER_TO_READ_DATA_CHANGE_CYCLES - 2) <= readnext and readnext_en;
					-- pull data into rdata if it's time
					if read_request_history(0) = '1' then
						rdata <= q;
					end if;
				end if;
				
				-- data can be pulled from this fifo if a request was issued through to it
				-- READ_TRIGGER_TO_READ_DATA_CHANGE_CYCLES fifo enabled cycles earlier
				-- read_issue_history tracks this
				if rdena_fifo = '1' then
					for i in 0 to READ_TRIGGER_TO_READ_DATA_CHANGE_CYCLES - 3 loop
						read_issue_history(i) <= read_issue_history(i + 1);
					end loop;
					read_issue_history(READ_TRIGGER_TO_READ_DATA_CHANGE_CYCLES - 2) <= rdreq;
				end if;
				
				-- when we fail to issue a request from cusp we need to compensate by issuing
				-- a read request later at a time when cusp isn't requesting a read (or has
				-- been stalled, either by us because we fell too far behind or for its own
				-- reasons) - unissued_requests tracks this
				if rdreq = '1' and cusp_rdreq = '0' then
					unissued_requests <= unissued_requests - 1;
				elsif rdreq = '0' and cusp_rdreq = '1' then
					unissued_requests <= unissued_requests + 1;
				end if;
			end if;
		end process;
	
	end generate;
	
	-- latency one is handled as a special case, but it's really very simple
	single_cycle_latency_gen :
	if READ_TRIGGER_TO_READ_DATA_CHANGE_CYCLES = 1 generate
	begin
	
		-- never stall the fifo
		rdena_fifo <= '1';
		wrena_fifo <= '1';
		
		-- read requests to the fifo and stalling
		rdreq <= readnext and readnext_en and ena_read and not empty;
		stall_read <= readnext and readnext_en and empty;
		
		-- write requests to the fifo and stalling
		wrreq <= writenext and writenext_en and ena_write and not full;
		stall_write <= writenext and writenext_en and full;

		-- update rdata in accordance with tta rules		
		process (clock, reset)
		begin
			if reset = '1' then
				rdata <= (others => '0');
			elsif clock'EVENT and clock = '1' then
				-- rdata must change on enabled cycles where readnext and readnext_en are high
				if ena_read = '1' and readnext = '1' and readnext_en = '1' then
					rdata <= q;
				end if;
			end if;
		end process;				
				
	end generate;

end;
