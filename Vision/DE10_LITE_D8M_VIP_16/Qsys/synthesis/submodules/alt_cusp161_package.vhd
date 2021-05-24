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

--synthesis library altera
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE STD.textio.ALL;

PACKAGE ALT_CUSP161_PACKAGE IS

CONSTANT SIMULATION_ON  : INTEGER := 1;
CONSTANT SIMULATION_OFF : INTEGER := 0;

CONSTANT OPTIMIZED_ON   : INTEGER := 1;
CONSTANT OPTIMIZED_OFF  : INTEGER := 0;

CONSTANT FAMILY_NONE    	: INTEGER := 0;
CONSTANT FAMILY_STRATIX   	: INTEGER := 10;
CONSTANT FAMILY_STRATIXII 	: INTEGER := 11;
CONSTANT FAMILY_STRATIXIII 	: INTEGER := 12;
CONSTANT FAMILY_STRATIXIV  	: INTEGER := 13;
CONSTANT FAMILY_STRATIXV  	: INTEGER := 14;
CONSTANT FAMILY_ARRIAV   	: INTEGER := 20;
CONSTANT FAMILY_CYCLONE   	: INTEGER := 30;
CONSTANT FAMILY_CYCLONEII 	: INTEGER := 31;
CONSTANT FAMILY_CYCLONEIII	: INTEGER := 32;
CONSTANT FAMILY_CYCLONELPS	: INTEGER := 33;
CONSTANT FAMILY_CYCLONEIVGX	: INTEGER := 34;
CONSTANT FAMILY_CYCLONEIVE	: INTEGER := 35;
CONSTANT FAMILY_CYCLONEV	: INTEGER := 36;
CONSTANT FAMILY_HARDCOPYII 	: INTEGER := 40;
CONSTANT FAMILY_HARDCOPYIII	: INTEGER := 41;
CONSTANT FAMILY_HARDCOPYIV	: INTEGER := 42;
CONSTANT FAMILY_MAX10FPGA	: INTEGER := 50;

CONSTANT ALT_MEM_MODE_AUTO : INTEGER := -1;
CONSTANT ALT_MEM_MODE_LE   : INTEGER := 0;
CONSTANT ALT_MEM_MODE_M512 : INTEGER := 1;
CONSTANT ALT_MEM_MODE_M4K  : INTEGER := 2;
CONSTANT ALT_MEM_MODE_MRAM : INTEGER := 3;

CONSTANT ALT_SHIFT_MODE_LOGICAL : INTEGER := 0;
CONSTANT ALT_SHIFT_MODE_ARITH : INTEGER := 1;
CONSTANT ALT_SHIFT_MODE_ROTATE  : INTEGER := 2;
CONSTANT ALT_SHIFT_DIREC_LEFT : INTEGER := 0;
CONSTANT ALT_SHIFT_DIREC_RIGHT : INTEGER := 1;
CONSTANT ALT_SHIFT_DIREC_BOTH : INTEGER := 2;

--------------------------------------------------------------------------------------  
--------------------------------------------------------------------------------------  

  function wide_enough_for(max : integer) return integer;
  function two_to_the_power(v : integer) return integer;
  function dead_bits(b : integer) return std_logic_vector;
  function maximum(a, b : integer) return integer;
  function minimum(a, b : integer) return integer;
  function calculate_be_width(be_used : boolean; data_width : integer) return integer;
  function calculate_be_width(be_used : integer; data_width : integer) return integer;
  function calculate_be_width(data_width : integer) return integer;
  function family_string(f : integer) return string;
  function to_string(slv : std_logic_vector) return string;
  function boolean_to_int(value : boolean) return integer;

COMPONENT alt_cusp161_avalon_mm_master IS
	GENERIC (
		NAME                         : STRING  := "";
		OPTIMIZED                    : INTEGER := OPTIMIZED_ON;
		FAMILY                       : INTEGER := FAMILY_STRATIX;
		ADDR_WIDTH                   : INTEGER := 16;
		DATA_WIDTH                   : INTEGER := 16;
		BYTEENABLE_WIDTH             : INTEGER := 2;
		BYTEENABLE_USED              : INTEGER := 1;
		READ_USED                    : INTEGER := 1;
		WRITE_USED                   : INTEGER := 1;
		CLOCKS_ARE_SYNC              : INTEGER := 0;
		ADDRESS_GROUP                : integer := 1;
		INTERRUPT_USED               : INTEGER := 1;
		INTERRUPT_WIDTH              : INTEGER := 8
	);
	PORT (
		clock          : IN  STD_LOGIC;
		reset          : IN  STD_LOGIC;
		ena            : IN  STD_LOGIC := '1';
		addr           : IN  STD_LOGIC_VECTOR(ADDR_WIDTH-1 DOWNTO 0) := (OTHERS=>'0');
		addr_en        : IN  STD_LOGIC := '0';
		wdata          : IN  STD_LOGIC_VECTOR(DATA_WIDTH-1 DOWNTO 0) := (OTHERS=>'0');
		wdata_en       : IN  STD_LOGIC := '0';
		byteenable     : IN  STD_LOGIC_VECTOR(BYTEENABLE_WIDTH-1 DOWNTO 0) := (OTHERS=>'1');
		byteenable_en  : IN  STD_LOGIC := '0';
		rdata          : OUT STD_LOGIC_VECTOR(DATA_WIDTH-1 DOWNTO 0);
		ready          : OUT STD_LOGIC;
		stall   	   : OUT STD_LOGIC;
		activeirqs     : OUT STD_LOGIC_VECTOR(INTERRUPT_WIDTH-1 DOWNTO 0) := (OTHERS=>'0');
		av_address     : OUT STD_LOGIC_VECTOR(ADDR_WIDTH-1 DOWNTO 0) ;
		av_writedata   : OUT STD_LOGIC_VECTOR(DATA_WIDTH-1 DOWNTO 0);
		av_byteenable  : OUT STD_LOGIC_VECTOR(BYTEENABLE_WIDTH-1 DOWNTO 0);
		av_write       : OUT STD_LOGIC;
		av_read        : OUT STD_LOGIC;
		av_clock       : IN  STD_LOGIC;
		av_reset       : IN  STD_LOGIC := '0';
		av_readdata    : IN  STD_LOGIC_VECTOR(DATA_WIDTH-1 DOWNTO 0) := (OTHERS=>'0');
		av_waitrequest : IN  STD_LOGIC := '0';
		av_interrupt   : IN  STD_LOGIC_VECTOR(INTERRUPT_WIDTH-1 DOWNTO 0) := (OTHERS=>'0')
	);
END COMPONENT;


COMPONENT alt_cusp161_avalon_mm_master_fifo IS
	GENERIC (
		NAME                         : STRING := "";
		OPTIMIZED                    : INTEGER := OPTIMIZED_ON;
		FAMILY                       : INTEGER := FAMILY_STRATIX;
		ADDR_WIDTH                   : INTEGER := 16;
		DATA_WIDTH                   : INTEGER := 16;
		BYTEENABLE_WIDTH             : INTEGER := 2;
		BYTEENABLE_USED              : INTEGER := 1;
		READ_USED                    : INTEGER := 1;
		WRITE_USED                   : INTEGER := 1;
		OLD_STYLE                    : INTEGER := 1
	);
	PORT (
		clock            : IN STD_LOGIC;
		reset            : IN STD_LOGIC;
		ena              : IN STD_LOGIC := '1';
		addr             : IN  STD_LOGIC_VECTOR( ADDR_WIDTH-1 DOWNTO 0) := (OTHERS=>'0');
		addr_en          : IN  STD_LOGIC := '0';
		wdata            : IN  STD_LOGIC_VECTOR( DATA_WIDTH-1 DOWNTO 0) := (OTHERS=>'0');
		wdata_en         : IN  STD_LOGIC := '0';
		rdata_en         : IN  STD_LOGIC := '0';
		byteenable       : IN  STD_LOGIC_VECTOR( BYTEENABLE_WIDTH-1 DOWNTO 0) := (OTHERS=>'1');
		byteenable_en    : IN  STD_LOGIC := '0';
		rdata            : OUT STD_LOGIC_VECTOR( DATA_WIDTH-1 DOWNTO 0);
		ready            : OUT STD_LOGIC;
		stall            : OUT STD_LOGIC;
		av_address       : OUT STD_LOGIC_VECTOR( ADDR_WIDTH-1 DOWNTO 0) ;
		av_writedata     : OUT STD_LOGIC_VECTOR( DATA_WIDTH-1 DOWNTO 0);
		av_byteenable    : OUT STD_LOGIC_VECTOR( BYTEENABLE_WIDTH-1 DOWNTO 0);
		av_write         : OUT STD_LOGIC;
		av_read          : OUT STD_LOGIC;
		av_clock         : IN  STD_LOGIC;
		av_reset         : IN  STD_LOGIC := '0';
		av_readdata      : IN  STD_LOGIC_VECTOR( DATA_WIDTH-1 DOWNTO 0):= (OTHERS=>'0');
		av_readdatavalid : IN  STD_LOGIC := '0';
		av_waitrequest   : IN  STD_LOGIC := '0'
	);
END COMPONENT;


COMPONENT alt_cusp161_avalon_mm_mem_slave IS
	GENERIC (
		NAME         : STRING := "";
		SIMULATION   : INTEGER := SIMULATION_OFF;
		OPTIMIZED    : INTEGER := OPTIMIZED_ON;
		FAMILY       : INTEGER := FAMILY_STRATIX;
		INIT_FILE : STRING := "UNUSED";
		WIDTH : INTEGER := 16;
		ADDRESS_WIDTH : INTEGER := 16;
		DEPTH : INTEGER := -1;
		INTERRUPT_USED : INTEGER := 1;
		DELAY_SLOTS : INTEGER := 0;
		LATENCY : INTEGER := 1;
		MODE : INTEGER := ALT_MEM_MODE_AUTO;
		CLOCKS_ARE_SYNC : INTEGER := 1
	);
	PORT (
		clock : IN STD_LOGIC;
		reset : IN STD_LOGIC;
		ena   : IN STD_LOGIC := '1';
		addr     : IN  STD_LOGIC_VECTOR( ADDRESS_WIDTH-1 DOWNTO 0) := (others=>'0');
		addr_en  : IN  STD_LOGIC := '0';
		rdata    : OUT STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0);
		wdata    : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		wdata_en : IN  STD_LOGIC := '0';
		setirq   : IN  STD_LOGIC := '0';
		setirq_en : IN  STD_LOGIC := '0';
		irqactive : IN  STD_LOGIC := '0';
		av_address   : IN  STD_LOGIC_VECTOR( ADDRESS_WIDTH-1 DOWNTO 0) := (others=>'0');
		av_writedata : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0)  := (others=>'0');
		av_readdata  : OUT STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0);
		av_clock     : IN  STD_LOGIC := '0';
		av_write     : IN  STD_LOGIC := '0';
		av_chipselect: IN  STD_LOGIC := '0';
		av_reset     : IN  STD_LOGIC := '0';
		av_waitrequest : OUT  STD_LOGIC := '0';
		av_interrupt : OUT  STD_LOGIC := '0'
	);
END COMPONENT;


COMPONENT alt_cusp161_avalon_st_credit_user IS
	GENERIC (
		NAME                         : STRING  := "";
		OPTIMIZED                    : INTEGER := OPTIMIZED_ON;
		FAMILY                       : INTEGER := FAMILY_STRATIX;
		ADDR_WIDTH                   : INTEGER := 32;
		DATA_WIDTH                   : INTEGER := 32;
		CREDIT_WIDTH                 : INTEGER := 10;
		CREDIT_INCREMENT             : INTEGER := 1
	);
	PORT (
		clock          : IN  STD_LOGIC;
		reset          : IN  STD_LOGIC;
		ena            : IN  STD_LOGIC := '1';
		hascredit      : OUT STD_LOGIC;
		getcredit      : IN  STD_LOGIC := '0';
		getcredit_en   : IN  STD_LOGIC := '0';
		trygetcredit   : IN  STD_LOGIC := '0';
		trygetcredit_en: IN  STD_LOGIC := '0';
		gotcredit      : OUT STD_LOGIC;
		stall   	   : OUT STD_LOGIC;
		read           : OUT  STD_LOGIC;
		address        : OUT  STD_LOGIC_VECTOR( ADDR_WIDTH-1 DOWNTO 0);
		waitrequest    : IN  STD_LOGIC := '0';
		readdatavalid  : IN  STD_LOGIC := '0';
		readdata       : IN STD_LOGIC_VECTOR( DATA_WIDTH-1 DOWNTO 0):= (OTHERS=>'0')
	);
END COMPONENT;


COMPONENT alt_cusp161_avalon_st_input IS
	generic (
	NAME            : string  := "";
	OPTIMIZED       : integer := OPTIMIZED_ON;
	FAMILY          : integer := FAMILY_STRATIX;
	WIDTH           : integer := 16;
	END_PACKET_USED : integer := 0;
	SYM_PER_BEAT    : integer := 0;
	READY_LATENCY   : integer := 1
	);
	port (
	clock         : in std_logic;
	reset         : in std_logic;
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
	ready         : out std_logic;
	valid         : in  std_logic := '1';
	data          : in  std_logic_vector(width-1 downto 0);
	startofpacket : in  std_logic := '0';
	endofpacket   : in  std_logic := '0'
	);
END COMPONENT;


COMPONENT alt_cusp161_avalon_st_output IS
	GENERIC (
		NAME            : STRING := "";
		WIDTH           : INTEGER := 16;
		READY_USED      : INTEGER := 1;
		END_PACKET_USED : INTEGER := 0;
		SYM_PER_BEAT    : integer := 0;
		READY_LATENCY   : INTEGER := 1
	);
	PORT (
		clock : IN STD_LOGIC;
		reset : IN STD_LOGIC;
		ena          : IN  STD_LOGIC := '1';
		spaceavail   : OUT STD_LOGIC;
		wdata        : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		wdata_en     : IN  STD_LOGIC := '0';
		takeb        : IN  STD_LOGIC := '0';
		takeb_en     : IN  STD_LOGIC := '0';
		takenb       : IN  STD_LOGIC := '0';
		takenb_en    : IN  STD_LOGIC := '0';
		eop          : IN  STD_LOGIC := '0';
		seteop       : IN  STD_LOGIC := '0';
		seteop_en    : IN  STD_LOGIC := '0';
		stall        : OUT STD_LOGIC;
		ready : IN STD_LOGIC  := '1';
		valid : OUT STD_LOGIC;
		data  : OUT STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0);
		startofpacket : OUT STD_LOGIC;
		endofpacket : OUT STD_LOGIC
	);
END COMPONENT;


COMPONENT alt_cusp161_select IS
	GENERIC (
		NAME         : STRING := "";
		WIDTH_D : INTEGER := 16;
		WIDTH_Q : INTEGER := 16;
		SELECT_LOW : INTEGER := 0;
		SIGN_EXTEND : INTEGER := 1
	);
	PORT (
		d        : IN  STD_LOGIC_VECTOR( WIDTH_D-1 DOWNTO 0) := (others =>'0');
		q        : OUT STD_LOGIC_VECTOR( WIDTH_Q-1 DOWNTO 0)
	);
END COMPONENT;


COMPONENT alt_cusp161_stack IS
	GENERIC (
		NAME         : STRING  := "";
		DEPTH        : INTEGER := 16;
		WIDTH        : INTEGER := 16
	);
	PORT (
		clock      : IN  STD_LOGIC;
		reset      : IN  STD_LOGIC := '0';
		ena        : IN  STD_LOGIC := '1';
		enable     : IN  STD_LOGIC := '0';
		enable_en  : IN  STD_LOGIC := '0';
		pushNpop   : IN  STD_LOGIC := '0';
		d          : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (OTHERS=>'0');
		q          : OUT STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0)
	);
END COMPONENT;


COMPONENT alt_cusp161_trigger_to_synced_pulse IS
	port (
	signal reset : IN STD_LOGIC;
	signal clk : IN STD_LOGIC;
	signal sync_reset : IN STD_LOGIC;
	signal sync_clk : IN STD_LOGIC;
	signal trigger : IN STD_LOGIC;
	signal return_pulse : IN STD_LOGIC;
	signal synced_pulse : OUT STD_LOGIC
	);
END COMPONENT;


COMPONENT alt_loadable_pc IS
	GENERIC (
		NAME         : STRING := "";
		SIMULATION   : INTEGER := SIMULATION_OFF;
		OPTIMIZED    : INTEGER := OPTIMIZED_ON;
		FAMILY       : INTEGER := FAMILY_STRATIX;
		PROGRAM_FILE : STRING := "program.mif";
		PROGRAM_TRACE: STRING := "program.trace";
		LATENCY      : INTEGER := 3;
		PC_WIDTH     : INTEGER := 16;
		PC_NUM_WORDS : INTEGER := 256;
		PCW_WIDTH    : INTEGER := 32;
		PCW_ROUND    : INTEGER := 0;
		TTA_WIDTH     : INTEGER := 16;
		TTA_NUM_WORDS : INTEGER := 256;
		TTAW_WIDTH    : INTEGER := 32;
		AV_WIDTH     : INTEGER := 15;
		AV_NUM_WORDS : INTEGER := 128;
		AVW_WIDTH    : INTEGER := 32
	);
	PORT (
		clock        : IN STD_LOGIC;
		reset        : IN STD_LOGIC;
		reset_req    : OUT STD_LOGIC;
		ena          : IN STD_LOGIC := '1';
		pcw          : OUT STD_LOGIC_VECTOR( PCW_WIDTH-1 DOWNTO 0);
		pc           : OUT STD_LOGIC_VECTOR( PC_WIDTH-1  DOWNTO 0);
		stall        : OUT STD_LOGIC;
		nextpc       : IN  STD_LOGIC_VECTOR( PC_WIDTH-1 DOWNTO 0) := (OTHERS=>'0');
		usenextpc    : IN  STD_LOGIC := '0';
		usenextpc_en : IN  STD_LOGIC := '0';
		hold         : IN  STD_LOGIC := '0';
		hold_en      : IN  STD_LOGIC := '0';
		av_address   : IN  STD_LOGIC_VECTOR( AV_WIDTH-1 DOWNTO 0) := (others=>'0');
		av_writedata : IN  STD_LOGIC_VECTOR( AVW_WIDTH-1 DOWNTO 0)  := (others=>'0');
		av_readdata  : OUT STD_LOGIC_VECTOR( AVW_WIDTH-1 DOWNTO 0);
		av_clock     : IN  STD_LOGIC := '0';
		av_write     : IN  STD_LOGIC := '0';
		av_chipselect: IN  STD_LOGIC := '0';
		av_reset     : IN  STD_LOGIC := '0';
		av_byteenable : IN STD_LOGIC_VECTOR( (AVW_WIDTH/8)-1 DOWNTO 0)  := (others=>'1')
	);
END COMPONENT;


COMPONENT tta_x_addwithsload IS
	GENERIC (
		SIMULATION   : INTEGER := SIMULATION_OFF;
		OPTIMIZED    : INTEGER := OPTIMIZED_ON;
		FAMILY       : INTEGER := FAMILY_STRATIX;
		L : INTEGER
	);
	PORT (
		clk, reset : IN STD_LOGIC;
		ena : IN STD_LOGIC := '1';
		sreset : IN STD_LOGIC := '0';
		sload : IN STD_LOGIC;
		loadval_in : IN UNSIGNED(L-1 DOWNTO 0);
		doAddnSub : IN STD_LOGIC := '1';
		addL_in : IN UNSIGNED(L-1 DOWNTO 0);
		addR_in : IN UNSIGNED(L-1 DOWNTO 0);
		sum_out : OUT UNSIGNED(L-1 DOWNTO 0)
	);
END COMPONENT;


COMPONENT tta_x_acounter IS
	GENERIC (
		NAME : STRING := "";
		SIMULATION   : INTEGER := SIMULATION_OFF;
		OPTIMIZED    : INTEGER := OPTIMIZED_ON;
		FAMILY       : INTEGER := FAMILY_STRATIX;
		WIDTH : INTEGER := 16
	);
	PORT (
		clock : IN STD_LOGIC;
		reset : IN STD_LOGIC;
		ena : IN STD_LOGIC := '1';
		d    : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		d_en : IN  STD_LOGIC := '0';
		q    : OUT STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0);
		q_en : IN  STD_LOGIC := '1'
	);
END COMPONENT;


COMPONENT tta_x_au IS
	GENERIC (
		NAME         : STRING := "";
		SIMULATION   : INTEGER := SIMULATION_OFF;
		OPTIMIZED    : INTEGER := OPTIMIZED_ON;
		FAMILY       : INTEGER := FAMILY_STRATIX;
		WIDTH : INTEGER := 16;
		LATENCY : INTEGER := 1
	);
	PORT (
		clock : IN STD_LOGIC;
		reset : IN STD_LOGIC;
		ena : IN STD_LOGIC := '1';
		a    : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		a_en : IN  STD_LOGIC := '0';
		b    : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		c    : IN  STD_LOGIC := '0';
		c_en : IN  STD_LOGIC := '0';
		l    : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		l_en : IN  STD_LOGIC := '0';
		q    : OUT STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0);
		S    : OUT STD_LOGIC;
		nS   : OUT STD_LOGIC;
		CC   : OUT STD_LOGIC;
		nCC  : OUT STD_LOGIC;
		sclr : IN STD_LOGIC := '0';
		subNadd : IN STD_LOGIC := '0'
	);
END COMPONENT;


COMPONENT tta_x_av_master_fifo_16_16 IS
	PORT
	(
	data		: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
	wrreq		: IN STD_LOGIC ;
	rdreq		: IN STD_LOGIC ;
	rdclk		: IN STD_LOGIC ;
	wrclk		: IN STD_LOGIC ;
	aclr		: IN STD_LOGIC  := '0';
	q		: OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
	rdfull		: OUT STD_LOGIC ;
	rdempty		: OUT STD_LOGIC ;
	rdusedw		: OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
	wrfull		: OUT STD_LOGIC ;
	wrempty		: OUT STD_LOGIC ;
	wrusedw		: OUT STD_LOGIC_VECTOR (3 DOWNTO 0)
	);
END COMPONENT;


COMPONENT tta_x_av_master_fifo_16_16_cii IS
	PORT
	(
	data		: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
	wrreq		: IN STD_LOGIC ;
	rdreq		: IN STD_LOGIC ;
	rdclk		: IN STD_LOGIC ;
	wrclk		: IN STD_LOGIC ;
	aclr		: IN STD_LOGIC  := '0';
	q		: OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
	rdfull		: OUT STD_LOGIC ;
	rdempty		: OUT STD_LOGIC ;
	rdusedw		: OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
	wrfull		: OUT STD_LOGIC ;
	wrempty		: OUT STD_LOGIC ;
	wrusedw		: OUT STD_LOGIC_VECTOR (3 DOWNTO 0)
	);
END COMPONENT;


COMPONENT tta_x_av_master_fifo_36_16 IS
	PORT
	(
	data		: IN STD_LOGIC_VECTOR (35 DOWNTO 0);
	wrreq		: IN STD_LOGIC ;
	rdreq		: IN STD_LOGIC ;
	rdclk		: IN STD_LOGIC ;
	wrclk		: IN STD_LOGIC ;
	aclr		: IN STD_LOGIC  := '0';
	q		: OUT STD_LOGIC_VECTOR (35 DOWNTO 0);
	rdfull		: OUT STD_LOGIC ;
	rdempty		: OUT STD_LOGIC ;
	rdusedw		: OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
	wrfull		: OUT STD_LOGIC ;
	wrempty		: OUT STD_LOGIC ;
	wrusedw		: OUT STD_LOGIC_VECTOR (3 DOWNTO 0)
	);
END COMPONENT;


COMPONENT tta_x_av_master_fifo_36_16_cii IS
	PORT
	(
	data		: IN STD_LOGIC_VECTOR (35 DOWNTO 0);
	wrreq		: IN STD_LOGIC ;
	rdreq		: IN STD_LOGIC ;
	rdclk		: IN STD_LOGIC ;
	wrclk		: IN STD_LOGIC ;
	aclr		: IN STD_LOGIC  := '0';
	q		: OUT STD_LOGIC_VECTOR (35 DOWNTO 0);
	rdfull		: OUT STD_LOGIC ;
	rdempty		: OUT STD_LOGIC ;
	rdusedw		: OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
	wrfull		: OUT STD_LOGIC ;
	wrempty		: OUT STD_LOGIC ;
	wrusedw		: OUT STD_LOGIC_VECTOR (3 DOWNTO 0)
	);
END COMPONENT;


COMPONENT tta_x_bshift IS
	GENERIC (
		NAME         : STRING := "";
		SIMULATION   : INTEGER := SIMULATION_OFF;
		OPTIMIZED    : INTEGER := OPTIMIZED_ON;
		FAMILY       : INTEGER := FAMILY_STRATIX;
		SEL_WIDTH : INTEGER := 2;
		WIDTH : INTEGER := 16
	);
	PORT (
		clock : IN STD_LOGIC;
		reset : IN STD_LOGIC;
		ena : IN STD_LOGIC := '1';
		d    : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		d_en : IN  STD_LOGIC := '0';
		sel    : IN  STD_LOGIC_VECTOR( SEL_WIDTH-1 DOWNTO 0) := (others=>'0');
		arithNlogic    : IN  STD_LOGIC := '0';
		q    : OUT STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0);
		sclr : IN STD_LOGIC := '0';
		sclr_en : IN STD_LOGIC := '0'
	);
END COMPONENT;


COMPONENT tta_x_channel IS
	GENERIC (
		NAME         : STRING := "";
		SIMULATION   : INTEGER := SIMULATION_OFF;
		OPTIMIZED    : INTEGER := OPTIMIZED_ON;
		FAMILY       : INTEGER := FAMILY_STRATIX;
		WAIT_STATES	 : INTEGER := 0;
		WIDTH : INTEGER := 16
	);
	PORT (
		clock  : IN STD_LOGIC;
		reset  : IN STD_LOGIC;
		d      : IN STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		d_en   : IN STD_LOGIC := '0';
		d_ena  : IN STD_LOGIC := '1';
		d_ready: OUT STD_LOGIC;
		d_stall: OUT STD_LOGIC;
		q      : OUT STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0);
		q_ready: OUT STD_LOGIC;
		q_en   : IN STD_LOGIC := '0';
		q_ena  : IN STD_LOGIC := '1';
		q_stall: OUT STD_LOGIC
	);
END COMPONENT;


COMPONENT tta_x_cmult IS
	generic (
	NAME         : STRING := "";
	SIMULATION   : INTEGER := SIMULATION_OFF;
	OPTIMIZED    : INTEGER := OPTIMIZED_ON;
	FAMILY       : INTEGER := FAMILY_STRATIX;
	DELAY_SLOTS : integer := 2;
	WIDTH : integer := 32;
	USE_COMPLEX_INPUT_PORTS : STRING := "TRUE"
	);
	port (
	clock : in std_logic;
	ena : in std_logic := '1';
	reset : in std_logic;
	aR_en : in std_logic := '0';
	aR: in std_logic_vector((WIDTH/2)-1 downto 0) := (others=>'0');
	aI: in std_logic_vector((WIDTH/2)-1 downto 0) := (others=>'0');
	bR: in std_logic_vector((WIDTH/2)-1 downto 0) := (others=>'0');
	bI: in std_logic_vector((WIDTH/2)-1 downto 0) := (others=>'0');
	a_en : in std_logic := '0';
	a: in std_logic_vector(WIDTH-1 downto 0) := (others=>'0');
	b: in std_logic_vector(WIDTH-1 downto 0) := (others=>'0');
	q   : out std_logic_vector((2*WIDTH)-1 downto 0);
	q_hi: out std_logic_vector(WIDTH-1 downto 0);
	q_lo: out std_logic_vector(WIDTH-1 downto 0);
	qs   : out std_logic_vector((2*WIDTH)-1 downto 0);
	qs_hi: out std_logic_vector(WIDTH-1 downto 0);
	qs_lo: out std_logic_vector(WIDTH-1 downto 0);
	qR: out std_logic_vector(WIDTH-1 downto 0);
	qI: out std_logic_vector(WIDTH-1 downto 0);
	qR_hi: out std_logic_vector((WIDTH/2)-1 downto 0);
	qI_hi: out std_logic_vector((WIDTH/2)-1 downto 0);
	qR_lo: out std_logic_vector((WIDTH/2)-1 downto 0);
	qI_lo: out std_logic_vector((WIDTH/2)-1 downto 0);
	qsR: out std_logic_vector(WIDTH-1 downto 0);
	qsI: out std_logic_vector(WIDTH-1 downto 0);
	qsR_hi: out std_logic_vector((WIDTH/2)-1 downto 0);
	qsI_hi: out std_logic_vector((WIDTH/2)-1 downto 0);
	qsR_lo: out std_logic_vector((WIDTH/2)-1 downto 0);
	qsI_lo: out std_logic_vector((WIDTH/2)-1 downto 0)
	);
END COMPONENT;


COMPONENT tta_x_combine_vec_vec IS
	GENERIC (
		NAME         : STRING := "";
		SIMULATION   : INTEGER := SIMULATION_OFF;
		OPTIMIZED    : INTEGER := OPTIMIZED_ON;
		FAMILY       : INTEGER := FAMILY_STRATIX;
		A_WIDTH : INTEGER := 16;
		B_WIDTH : INTEGER := 16
	);
	PORT (
		a        : IN STD_LOGIC_VECTOR( A_WIDTH-1 DOWNTO 0) := (others=>'0');
		b        : IN STD_LOGIC_VECTOR( B_WIDTH-1 DOWNTO 0) := (others=>'0');
		q        : OUT STD_LOGIC_VECTOR( A_WIDTH+B_WIDTH-1 DOWNTO 0)
	);
END COMPONENT;


COMPONENT tta_x_constant IS
	GENERIC (
		NAME         : STRING := "";
		SIMULATION   : INTEGER := SIMULATION_OFF;
		OPTIMIZED    : INTEGER := OPTIMIZED_ON;
		FAMILY       : INTEGER := FAMILY_STRATIX;
		WIDTH : INTEGER := 16;
		VALUE : INTEGER := 0
	);
	PORT (
		q        : OUT STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0)
	);
END COMPONENT;


COMPONENT tta_x_constant_accumulator IS
	GENERIC (
		NAME         : STRING := "";
		SIMULATION   : INTEGER := SIMULATION_OFF;
		OPTIMIZED    : INTEGER := OPTIMIZED_ON;
		FAMILY       : INTEGER := FAMILY_STRATIX;
		CSEL : INTEGER := 0;
		CNSEL : INTEGER := 1;
		WIDTH : INTEGER := 16
	);
	PORT (
		clock : IN STD_LOGIC;
		reset : IN STD_LOGIC;
		ena : IN STD_LOGIC := '1';
		d    : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		d_en : IN  STD_LOGIC := '0';
		l    : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		l_en : IN  STD_LOGIC := '0';
		vsel : IN  STD_LOGIC := '0';
		q    : OUT STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0);
		S    : OUT STD_LOGIC;
		nS   : OUT STD_LOGIC;
		sclr : IN STD_LOGIC := '0'
	);
END COMPONENT;


COMPONENT tta_x_dmem IS
	GENERIC (
		NAME         : STRING := "";
		SIMULATION   : INTEGER := SIMULATION_OFF;
		OPTIMIZED    : INTEGER := OPTIMIZED_ON;
		FAMILY       : INTEGER := FAMILY_STRATIX;
		INIT_FILE : STRING := "UNUSED";
		WIDTH : INTEGER := 16;
		ADDRESS_WIDTH : INTEGER := 16;
		DELAY_SLOTS : INTEGER := 0
	);
	PORT (
		clock : IN STD_LOGIC;
		reset : IN STD_LOGIC;
		ena   : IN STD_LOGIC := '1';
		Aaddr     : IN  STD_LOGIC_VECTOR( ADDRESS_WIDTH-1 DOWNTO 0) := (others=>'0');
		Aaddr_en  : IN  STD_LOGIC := '0';
		Ardata    : OUT STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0);
		Awdata    : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		Awdata_en : IN  STD_LOGIC := '0';
		Baddr     : IN  STD_LOGIC_VECTOR( ADDRESS_WIDTH-1 DOWNTO 0) := (others=>'0');
		Baddr_en  : IN  STD_LOGIC := '0';
		Brdata    : OUT STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0);
		Bwdata    : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		Bwdata_en : IN  STD_LOGIC := '0'
	);
END COMPONENT;


COMPONENT tta_x_hdmem IS
	GENERIC (
		NAME         : STRING := "";
		SIMULATION   : INTEGER := SIMULATION_OFF;
		OPTIMIZED    : INTEGER := OPTIMIZED_ON;
		FAMILY       : INTEGER := FAMILY_STRATIX;
		INIT_FILE : STRING := "UNUSED";
		WIDTH : INTEGER := 16;
		ADDRESS_WIDTH : INTEGER := 8;
		DELAY_SLOTS : INTEGER := 0
	);
	PORT (
		clock : IN STD_LOGIC;
		reset : IN STD_LOGIC;
		ena   : IN STD_LOGIC := '1';
		Aaddr     : IN  STD_LOGIC_VECTOR( ADDRESS_WIDTH-1 DOWNTO 0) := (others=>'0');
		Aaddr_en  : IN  STD_LOGIC := '0';
		Ardata    : OUT STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0);
		Awdata    : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		Awdata_en : IN  STD_LOGIC := '0';
		Baddr     : IN  STD_LOGIC_VECTOR( ADDRESS_WIDTH-1 DOWNTO 0) := (others=>'0');
		Baddr_en  : IN  STD_LOGIC := '0';
		Brdata    : OUT STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0)
	);
END COMPONENT;


COMPONENT tta_x_immed IS
	GENERIC (
		NAME         : STRING := "";
		SIMULATION   : INTEGER := SIMULATION_OFF;
		OPTIMIZED    : INTEGER := OPTIMIZED_ON;
		FAMILY       : INTEGER := FAMILY_STRATIX;
		WIDTH : INTEGER := 16
	);
	PORT (
		value      : IN STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		q        : OUT STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0)
	);
END COMPONENT;


COMPONENT tta_x_immed_wire IS
	GENERIC (
		NAME         : STRING := "";
		SIMULATION   : INTEGER := SIMULATION_OFF;
		OPTIMIZED    : INTEGER := OPTIMIZED_ON;
		FAMILY       : INTEGER := FAMILY_STRATIX
	);
	PORT (
		value      : IN STD_LOGIC := '0';
		q        : OUT STD_LOGIC
	);
END COMPONENT;


COMPONENT tta_x_mac IS
	GENERIC (
		NAME         : STRING := "";
		SIMULATION   : INTEGER := SIMULATION_OFF;
		OPTIMIZED    : INTEGER := OPTIMIZED_ON;
		FAMILY       : INTEGER := FAMILY_STRATIX;
		WIDTH_2 : INTEGER := 32;
		WIDTH : INTEGER := 16
	);
	PORT (
		clock : IN STD_LOGIC;
		reset : IN STD_LOGIC;
		ena : IN STD_LOGIC := '1';
		a    : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		a_en : IN  STD_LOGIC := '1';
		b    : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		q_hi : OUT STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0);
		q_lo : OUT STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0);
		q    : OUT STD_LOGIC_VECTOR( (2*WIDTH)-1 DOWNTO 0);
		qs_hi : OUT STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0);
		qs_lo : OUT STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0);
		qs    : OUT STD_LOGIC_VECTOR( (2*WIDTH)-1 DOWNTO 0);
		mulNmac  : IN STD_LOGIC := '0';
		subNadd : IN STD_LOGIC := '0'
	);
END COMPONENT;


COMPONENT tta_x_mod_counter IS
	GENERIC (
		NAME         : STRING := "";
		SIMULATION   : INTEGER := SIMULATION_OFF;
		OPTIMIZED    : INTEGER := OPTIMIZED_ON;
		FAMILY       : INTEGER := FAMILY_STRATIX;
		MODULO : INTEGER := 66;
		WIDTH : INTEGER := 16
	);
	PORT (
		clock		: IN STD_LOGIC ;
		ena 		: IN STD_LOGIC := '1';
		reset		: IN STD_LOGIC := '0' ;
		cnt			: IN STD_LOGIC := '0';
		cnt_en		: IN STD_LOGIC := '0';
		sclr		: IN STD_LOGIC := '0';
		sclr_en		: IN STD_LOGIC := '0';
		d			: IN STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0) := (others => '0');
		d_en		: IN STD_LOGIC := '0';
		q		    : OUT STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0)
	);
END COMPONENT;


COMPONENT tta_x_mult IS
	GENERIC (
		NAME         : STRING := "";
		SIMULATION   : INTEGER := SIMULATION_OFF;
		OPTIMIZED    : INTEGER := OPTIMIZED_ON;
		FAMILY       : INTEGER := FAMILY_STRATIX;
		WIDTH        : INTEGER := 16;
		DELAY_SLOTS  : INTEGER := 1
	);
	PORT (
		clock : IN STD_LOGIC;
		reset : IN STD_LOGIC;
		ena : IN STD_LOGIC := '1';
		a    : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		a_en : IN  STD_LOGIC := '1';
		b    : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		q_hi : OUT STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0);
		q_lo : OUT STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0);
		q    : OUT STD_LOGIC_VECTOR( WIDTH*2-1 DOWNTO 0);
		qs_hi : OUT STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0);
		qs_lo : OUT STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0);
		qs    : OUT STD_LOGIC_VECTOR( WIDTH*2-1 DOWNTO 0)
	);
END COMPONENT;


COMPONENT tta_x_register IS
	GENERIC (
		NAME         : STRING := "";
		SIMULATION   : INTEGER := SIMULATION_OFF;
		OPTIMIZED    : INTEGER := OPTIMIZED_ON;
		FAMILY       : INTEGER := FAMILY_STRATIX;
		WIDTH : INTEGER := 16
	);
	PORT (
		clock : IN STD_LOGIC;
		reset : IN STD_LOGIC;
		ena : IN STD_LOGIC := '1';
		d : IN STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		q : OUT STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0);
		d_en : IN STD_LOGIC := '1'
	);
END COMPONENT;


COMPONENT tta_x_register3 IS
	GENERIC (
		NAME         : STRING := "";
		SIMULATION   : INTEGER := SIMULATION_OFF;
		OPTIMIZED    : INTEGER := OPTIMIZED_ON;
		FAMILY       : INTEGER := FAMILY_STRATIX;
		WIDTH : INTEGER := 16
	);
	PORT (
		clock : IN STD_LOGIC;
		reset : IN STD_LOGIC;
		ena : IN STD_LOGIC := '1';
		a : IN STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		a_en : IN STD_LOGIC := '1';
		b : IN STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		b_en : IN STD_LOGIC := '0';
		c : IN STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		c_en : IN STD_LOGIC := '0';
		sclr : IN STD_LOGIC := '0';
		q : OUT STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0)
	);
END COMPONENT;


COMPONENT tta_x_rshift IS
	GENERIC (
		NAME         : STRING := "";
		SIMULATION   : INTEGER := SIMULATION_OFF;
		OPTIMIZED    : INTEGER := OPTIMIZED_ON;
		FAMILY       : INTEGER := FAMILY_STRATIX;
		WIDTH : INTEGER := 16
	);
	PORT (
		clock : IN STD_LOGIC;
		reset : IN STD_LOGIC;
		ena : IN STD_LOGIC := '1';
		d : IN STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		logicalNarithmetic : IN STD_LOGIC := '1';
		l : IN STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		l_en : IN STD_LOGIC := '0';
		q : OUT STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0);
		d_en : IN STD_LOGIC := '1'
	);
END COMPONENT;


COMPONENT tta_x_smem IS
	GENERIC (
		NAME         : STRING := "";
		SIMULATION   : INTEGER := SIMULATION_OFF;
		OPTIMIZED    : INTEGER := OPTIMIZED_ON;
		FAMILY       : INTEGER := FAMILY_STRATIX;
		INIT_FILE : STRING := "UNUSED";
		WIDTH : INTEGER := 16;
		ADDRESS_WIDTH : INTEGER := 16;
		DELAY_SLOTS : INTEGER := 0
	);
	PORT (
		clock : IN STD_LOGIC;
		reset : IN STD_LOGIC;
		ena   : IN STD_LOGIC := '1';
		addr     : IN  STD_LOGIC_VECTOR( ADDRESS_WIDTH-1 DOWNTO 0) := (others=>'0');
		addr_en  : IN  STD_LOGIC := '0';
		rdata    : OUT STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0);
		wdata    : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		wdata_en : IN  STD_LOGIC := '0'
	);
END COMPONENT;


COMPONENT tta_x_smem_av IS
	GENERIC (
		NAME         : STRING := "";
		SIMULATION   : INTEGER := SIMULATION_OFF;
		OPTIMIZED    : INTEGER := OPTIMIZED_ON;
		FAMILY       : INTEGER := FAMILY_STRATIX;
		INIT_FILE : STRING := "UNUSED";
		WIDTH : INTEGER := 16;
		ADDRESS_WIDTH : INTEGER := 16;
		DEPTH : INTEGER := -1;
		DELAY_SLOTS : INTEGER := 0;
		MODE : INTEGER := ALT_MEM_MODE_AUTO;
		ASYNC : INTEGER := 0
	);
	PORT (
		clock : IN STD_LOGIC;
		reset : IN STD_LOGIC;
		ena   : IN STD_LOGIC := '1';
		addr     : IN  STD_LOGIC_VECTOR( ADDRESS_WIDTH-1 DOWNTO 0) := (others=>'0');
		addr_en  : IN  STD_LOGIC := '0';
		rdata    : OUT STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0);
		wdata    : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		wdata_en : IN  STD_LOGIC := '0';
		av_address   : IN  STD_LOGIC_VECTOR( ADDRESS_WIDTH-1 DOWNTO 0) := (others=>'0');
		av_writedata : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0)  := (others=>'0');
		av_readdata  : OUT STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0);
		av_clock     : IN  STD_LOGIC := '0';
		av_write     : IN  STD_LOGIC := '0';
		av_chipselect: IN  STD_LOGIC := '0';
		av_reset     : IN  STD_LOGIC := '0';
		av_waitrequest : OUT  STD_LOGIC := '0';
		test_writetog : OUT STD_LOGIC;
		test_writeack : IN  STD_LOGIC := '0'
	);
END COMPONENT;


COMPONENT tta_x_smem_av_db IS
	GENERIC (
		NAME         : STRING := "";
		SIMULATION   : INTEGER := SIMULATION_OFF;
		OPTIMIZED    : INTEGER := OPTIMIZED_ON;
		FAMILY       : INTEGER := FAMILY_STRATIX;
		INIT_FILE : STRING := "UNUSED";
		WIDTH : INTEGER := 16;
		ADDRESS_WIDTH : INTEGER := 16;
		DELAY_SLOTS : INTEGER := 0
	);
	PORT (
		clock : IN STD_LOGIC;
		reset : IN STD_LOGIC;
		ena   : IN STD_LOGIC := '1';
		addr     : IN  STD_LOGIC_VECTOR( ADDRESS_WIDTH-1 DOWNTO 0) := (others=>'0');
		addr_en  : IN  STD_LOGIC := '0';
		rdata    : OUT STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0);
		wdata    : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		wdata_en : IN  STD_LOGIC := '0';
		setHalf	 : IN  STD_LOGIC := '0';
		setHalf_en : IN STD_LOGIC := '0';
		getHalf	 : OUT STD_LOGIC ;
		machineHalf  : OUT STD_LOGIC := '0';
		av_address   : IN  STD_LOGIC_VECTOR( ADDRESS_WIDTH DOWNTO 0) := (others=>'0');
		av_writedata : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0)  := (others=>'0');
		av_readdata  : OUT STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0);
		av_clock     : IN  STD_LOGIC := '0';
		av_write     : IN  STD_LOGIC := '0';
		av_chipselect: IN  STD_LOGIC := '0';
		av_reset     : IN  STD_LOGIC := '0'
	);
END COMPONENT;


COMPONENT tta_x_wire IS
	GENERIC (
		NAME         : STRING := "";
		SIMULATION   : INTEGER := SIMULATION_OFF;
		OPTIMIZED    : INTEGER := OPTIMIZED_ON;
		FAMILY       : INTEGER := FAMILY_STRATIX;
		WIDTH : INTEGER := 16
	);
	PORT (
		d : IN STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		q : OUT STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0)
	);
END COMPONENT;


COMPONENT alt_cusp161_addsubcarry IS
	GENERIC (
		SIMULATION   : INTEGER := SIMULATION_OFF;
		OPTIMIZED    : INTEGER := OPTIMIZED_ON;
		FAMILY       : INTEGER := FAMILY_STRATIX;
		L : INTEGER
	);
	PORT (
		clk, reset : IN STD_LOGIC;
		ena : IN STD_LOGIC := '1';
		sreset : IN STD_LOGIC := '0';
		sload : IN STD_LOGIC;
		loadval_in : IN UNSIGNED(L-1 DOWNTO 0);
		doAddnSub : IN STD_LOGIC := '1';
		addL_in : IN UNSIGNED(L-1 DOWNTO 0);
		addR_in : IN UNSIGNED(L-1 DOWNTO 0);
		sum_out : OUT UNSIGNED(L-1 DOWNTO 0)
	);
END COMPONENT;


COMPONENT alt_cusp161_atlantic_reporter IS
	GENERIC (
		NAME         : STRING := "";
		SIMULATION   : INTEGER := SIMULATION_OFF;
		OPTIMIZED    : INTEGER := OPTIMIZED_ON;
		FAMILY       : INTEGER := FAMILY_STRATIX;
		ISSIGNED : INTEGER := 1;
		CONSTANT WIDTH : INTEGER := 16
	);
	PORT (
		clock  : IN STD_LOGIC;
		reset  : IN STD_LOGIC;
		data   : IN STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		valid     : IN STD_LOGIC := '1';
		ready     : OUT STD_LOGIC
	);
END COMPONENT;


COMPONENT alt_cusp161_au IS
	GENERIC (
		NAME         : STRING := "";
		SIMULATION   : INTEGER := SIMULATION_OFF;
		OPTIMIZED    : INTEGER := OPTIMIZED_ON;
		FAMILY       : INTEGER := FAMILY_STRATIX;
		WIDTH        : INTEGER := 16;
		LATENCY      : INTEGER := 1
	);
	PORT (
		clock     : IN STD_LOGIC;
		reset     : IN STD_LOGIC;
		ena       : IN STD_LOGIC := '1';
		a         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (OTHERS=>'0');
		b         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (OTHERS=>'0');
		l         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (OTHERS=>'0');
		q         : OUT STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0);
		enable    : IN STD_LOGIC := '0';
		enable_en : IN STD_LOGIC := '0';
		sclr      : IN STD_LOGIC := '0';
		sload     : IN STD_LOGIC := '0';
		subNadd   : IN STD_LOGIC := '0'
	);
END COMPONENT;


COMPONENT alt_cusp161_avalon_mm_bursting_master_fifo IS
	generic (
	NAME                         : string  := "";
	OPTIMIZED                    : integer := OPTIMIZED_ON;
	FAMILY                       : integer := FAMILY_STRATIX;
	ADDR_WIDTH                   : integer := 16;
	DATA_WIDTH                   : integer := 16;
	READ_USED                    : integer := 1;
	WRITE_USED                   : integer := 1;
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
	INTERRUPT_USED               : INTEGER := 1;
	INTERRUPT_WIDTH              : INTEGER := 8
	);
	port (
	clock            : in std_logic;
	reset            : in std_logic;
	ena              : in  std_logic := '1';
	ready            : out std_logic;
	stall            : out std_logic;
	addr             : in  std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
	write            : in  std_logic := '0';
	burst            : in  std_logic := '0';
	len_be           : in  std_logic_vector(LEN_BE_WIDTH-1 downto 0) := (others => '0');
	cenable          : in  std_logic;
	cenable_en       : in  std_logic;
	wdata            : in  std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
	wenable          : in  std_logic;
	wenable_en       : in  std_logic := '0';
	rdata            : out std_logic_vector(DATA_WIDTH-1 downto 0);
	renable          : in  std_logic := '0';
	renable_en       : in  std_logic := '0';
	activeirqs       : out std_logic_vector(INTERRUPT_WIDTH-1 DOWNTO 0) := (OTHERS=>'0');
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
END COMPONENT;


COMPONENT alt_cusp161_avalon_mm_raw_slave IS
	GENERIC (
		NAME            : STRING := "";
		WIDTH           : INTEGER := 16;
		ADDRESS_WIDTH   : INTEGER := 16;
		READ_USED       : INTEGER := 1;
		WRITE_USED      : INTEGER := 1;
		INTERRUPT_USED  : INTEGER := 1;
		CLOCKS_ARE_SYNC : INTEGER := 1
	);
	PORT (
		clock        : IN  STD_LOGIC;
		reset        : IN  STD_LOGIC;
		ena          : IN  STD_LOGIC := '1';
		stall        : OUT STD_LOGIC;
		waitaccess   : IN  STD_LOGIC := '0';
		waitaccess_en: IN  STD_LOGIC := '0';
		finish       : IN  STD_LOGIC := '0';
		finish_en    : IN  STD_LOGIC := '0';
		hasaccess    : OUT STD_LOGIC;
		isread       : OUT STD_LOGIC;
		address      : OUT STD_LOGIC_VECTOR( ADDRESS_WIDTH-1 DOWNTO 0);
		wdata        : OUT STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0);
		rdata        : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		setirq       : IN  STD_LOGIC := '0';
		setirq_en    : IN  STD_LOGIC := '0';
		setirq_ena   : IN  STD_LOGIC := '1';
		av_address   : IN  STD_LOGIC_VECTOR( ADDRESS_WIDTH-1 DOWNTO 0) := (others=>'0');
		av_writedata : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0)  := (others=>'0');
		av_readdata  : OUT STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0);
		av_clock     : IN  STD_LOGIC := '0';
		av_write     : IN  STD_LOGIC := '0';
		av_chipselect: IN  STD_LOGIC := '0';
		av_reset     : IN  STD_LOGIC := '0';
		av_waitrequest : OUT  STD_LOGIC := '0';
		av_interrupt : OUT  STD_LOGIC := '0'
	);
END COMPONENT;


COMPONENT alt_cusp161_clock_reset IS
	GENERIC (
		NAME         : STRING := "";
		SIMULATION   : INTEGER := SIMULATION_OFF;
		OPTIMIZED    : INTEGER := OPTIMIZED_ON;
		FAMILY       : INTEGER := FAMILY_STRATIX;
		PERIOD : TIME := 10 ns
	);
	PORT (
		clock      : OUT STD_LOGIC;
		reset      : OUT STD_LOGIC
	);
END COMPONENT;


COMPONENT alt_cusp161_cmp IS
	GENERIC (
		NAME         : STRING := "";
		OPTIMIZED    : INTEGER := OPTIMIZED_ON;
		FAMILY       : INTEGER := FAMILY_STRATIX;
		WIDTH        : INTEGER := 16
	);
	PORT (
		a    : IN  STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0) := (others=>'0');
		b    : IN  STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0) := (others=>'0');
		sign : IN  STD_LOGIC :='0';
		equals : IN STD_LOGIC := '1';
		less   : IN STD_LOGIC := '0';
		invert : IN STD_LOGIC := '0';
		q    : OUT STD_LOGIC
	);
END COMPONENT;


COMPONENT alt_cusp161_debug IS
	GENERIC (
		NAME         : STRING := "";
		OPTIMIZED    : INTEGER := OPTIMIZED_ON;
		FAMILY       : INTEGER := FAMILY_STRATIX;
		WIDTH        : INTEGER := 16;
		LATENCY      : INTEGER := 1;
		RESTART      : INTEGER := 1
	);
	PORT (
		clock     : IN STD_LOGIC;
		reset     : IN STD_LOGIC;
		ena       : IN STD_LOGIC := '1';
		a         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		a_en      : IN STD_LOGIC := '0';
		b         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0')
	);
END COMPONENT;


COMPONENT alt_cusp161_exit IS
	GENERIC (
		NAME         : STRING := "";
		WIDTH : INTEGER := 16
	);
	PORT (
		clock : IN STD_LOGIC;
		reset : IN STD_LOGIC;
		ena : IN STD_LOGIC := '1';
		return_code : IN STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		return_code_en : IN STD_LOGIC := '0';
		test_stopped : OUT STD_LOGIC;
		test_return_code : OUT STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0)
	);
END COMPONENT;


COMPONENT alt_cusp161_fifo IS
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
	ena_read      : in  std_logic := '1';
	stall_read    : out std_logic := '0';
	readnext      : in  std_logic := '0';
	readnext_en   : in  std_logic := '0';
	rdata         : out std_logic_vector(width - 1 downto 0);
	ena_write     : in  std_logic := '1';
	stall_write   : out std_logic := '0';
	writenext     : in  std_logic := '0';
	writenext_en  : in  std_logic := '0';
	wdata         : in  std_logic_vector(width - 1 downto 0) := (others => '0');
	dataavail     : out std_logic;
	spaceavail    : out std_logic
	);
END COMPONENT;


COMPONENT alt_cusp161_fifo_paged IS
	GENERIC (
		NAME         : STRING := "";
		OPTIMIZED    : INTEGER := OPTIMIZED_ON;
		FAMILY       : INTEGER := FAMILY_STRATIX;
		WIDTH        : INTEGER := 16;
		ADDRESS_WIDTH  : INTEGER := 8;
		PAGE_SIZE      : INTEGER := 8;
		PAGES          : INTEGER := 4;
		LOG2_PAGES     : INTEGER := 2;
		FULL_BIDIR     : INTEGER := 1;
		SINK_ACTIVE_PAGES   : INTEGER := 1;
		SOURCE_ACTIVE_PAGES   : INTEGER := 1;
		FULL_AT_START  : INTEGER := 0
	);
	PORT (
		clock : IN STD_LOGIC;
		reset : IN STD_LOGIC;
		a_ena          : IN  STD_LOGIC := '1';
		a_addr         : IN  STD_LOGIC_VECTOR( ADDRESS_WIDTH-1 DOWNTO 0) := (others=>'0');
		a_rdata        : OUT STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0);
		a_wdata        : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		a_wdataen      : IN  STD_LOGIC := '0';
		a_wdataen_en   : IN  STD_LOGIC := '0';
		a_takeb        : IN  STD_LOGIC := '0';
		a_takeb_en     : IN  STD_LOGIC := '0';
		a_takenb       : IN  STD_LOGIC := '0';
		a_takenb_en    : IN  STD_LOGIC := '0';
		a_returnnb     : IN  STD_LOGIC := '0';
		a_returnnb_en  : IN  STD_LOGIC := '0';
		a_pagesel      : IN  STD_LOGIC_VECTOR(1 DOWNTO 0) := (others=>'0');
		a_pagesel_en   : IN  STD_LOGIC := '0';
		a_page_to_take : OUT STD_LOGIC;
		a_stall        : OUT STD_LOGIC;
		b_ena          : IN  STD_LOGIC := '1';
		b_addr         : IN  STD_LOGIC_VECTOR( ADDRESS_WIDTH-1 DOWNTO 0) := (others=>'0');
		b_rdata        : OUT STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0);
		b_wdata        : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		b_wdataen      : IN  STD_LOGIC := '0';
		b_wdataen_en   : IN  STD_LOGIC := '0';
		b_takeb        : IN  STD_LOGIC := '0';
		b_takeb_en     : IN  STD_LOGIC := '0';
		b_takenb       : IN  STD_LOGIC := '0';
		b_takenb_en    : IN  STD_LOGIC := '0';
		b_returnnb     : IN  STD_LOGIC := '0';
		b_returnnb_en  : IN  STD_LOGIC := '0';
		b_pagesel      : IN  STD_LOGIC_VECTOR(1 DOWNTO 0) := (others=>'0');
		b_pagesel_en   : IN  STD_LOGIC := '0';
		b_page_to_take : OUT STD_LOGIC;
		b_stall        : OUT STD_LOGIC
	);
END COMPONENT;


COMPONENT alt_cusp161_fifo_usedw_calculator IS
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
	rdreset	     : in  std_logic;
	rdclock	     : in  std_logic;
	rdena        : in  std_logic;
	wrreset	     : in  std_logic;
	wrclock      : in  std_logic;
	wrena        : in  std_logic;
	wrreq	     : in  std_logic;
	rdreq	     : in  std_logic;
	wrusedw	     : out std_logic_vector(wide_enough_for(DEPTH) - 1 downto 0);
	full	     : out std_logic;
	almost_full  : out std_logic;
	rdusedw      : out std_logic_vector(wide_enough_for(DEPTH) - 1 downto 0);
	empty	     : out std_logic;
	almost_empty : out std_logic
	);
END COMPONENT;


COMPONENT alt_cusp161_fp_addsub_dp_l7 IS
	PORT
	(
	add_sub		: IN STD_LOGIC ;
	dataa		: IN STD_LOGIC_VECTOR (63 DOWNTO 0);
	datab		: IN STD_LOGIC_VECTOR (63 DOWNTO 0);
	clk_en		: IN STD_LOGIC ;
	aclr		: IN STD_LOGIC ;
	clock		: IN STD_LOGIC ;
	overflow		: OUT STD_LOGIC ;
	nan		: OUT STD_LOGIC ;
	underflow		: OUT STD_LOGIC ;
	result		: OUT STD_LOGIC_VECTOR (63 DOWNTO 0)
	);
END COMPONENT;


COMPONENT alt_cusp161_fp_addsub_dp_l8 IS
	PORT
	(
	add_sub		: IN STD_LOGIC ;
	dataa		: IN STD_LOGIC_VECTOR (63 DOWNTO 0);
	datab		: IN STD_LOGIC_VECTOR (63 DOWNTO 0);
	clk_en		: IN STD_LOGIC ;
	aclr		: IN STD_LOGIC ;
	clock		: IN STD_LOGIC ;
	overflow		: OUT STD_LOGIC ;
	nan		: OUT STD_LOGIC ;
	underflow		: OUT STD_LOGIC ;
	result		: OUT STD_LOGIC_VECTOR (63 DOWNTO 0)
	);
END COMPONENT;


COMPONENT alt_cusp161_fp_addsub_sp_l7 IS
	PORT
	(
	add_sub		: IN STD_LOGIC ;
	dataa		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
	datab		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
	clk_en		: IN STD_LOGIC ;
	aclr		: IN STD_LOGIC ;
	clock		: IN STD_LOGIC ;
	overflow		: OUT STD_LOGIC ;
	nan		: OUT STD_LOGIC ;
	underflow		: OUT STD_LOGIC ;
	result		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
	);
END COMPONENT;


COMPONENT alt_cusp161_fp_addsub_sp_l8 IS
	PORT
	(
	add_sub		: IN STD_LOGIC ;
	dataa		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
	datab		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
	clk_en		: IN STD_LOGIC ;
	aclr		: IN STD_LOGIC ;
	clock		: IN STD_LOGIC ;
	overflow		: OUT STD_LOGIC ;
	nan		: OUT STD_LOGIC ;
	underflow		: OUT STD_LOGIC ;
	result		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
	);
END COMPONENT;


COMPONENT alt_cusp161_fp_au IS
	GENERIC (
		NAME         : STRING := "";
		SIMULATION   : INTEGER := SIMULATION_OFF;
		OPTIMIZED    : INTEGER := OPTIMIZED_ON;
		FAMILY       : INTEGER := FAMILY_STRATIX;
		WIDTH        : INTEGER := 32;
		LATENCY      : INTEGER := 5
	);
	PORT (
		clock     : IN STD_LOGIC;
		reset     : IN STD_LOGIC;
		ena       : IN STD_LOGIC := '1';
		enable    : IN STD_LOGIC := '0';
		enable_en : IN STD_LOGIC := '0';
		subNadd   : IN STD_LOGIC := '0';
		a         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (OTHERS=>'0');
		b         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (OTHERS=>'0');
		q         : OUT STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0)
	);
END COMPONENT;


COMPONENT alt_cusp161_fp_cmp IS
	GENERIC (
		NAME         : STRING := "";
		SIMULATION   : INTEGER := SIMULATION_OFF;
		OPTIMIZED    : INTEGER := OPTIMIZED_ON;
		FAMILY       : INTEGER := FAMILY_STRATIX;
		LATENCY      : INTEGER := 7;
		WIDTH        : INTEGER := 32
	);
	PORT (
		clock : IN STD_LOGIC;
		reset : IN STD_LOGIC;
		ena   : IN STD_LOGIC := '1';
		a    : IN  STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0) := (others=>'0');
		a_en : IN STD_LOGIC;
		b    : IN  STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0) := (others=>'0');
		sel  : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
		q   : OUT STD_LOGIC
	);
END COMPONENT;


COMPONENT alt_cusp161_fp_mult IS
	GENERIC (
		NAME         : STRING := "";
		OPTIMIZED    : INTEGER := OPTIMIZED_ON;
		FAMILY       : INTEGER := FAMILY_STRATIX;
		WIDTH        : INTEGER := 32;
		LATENCY      : INTEGER := 5;
		RESTART      : INTEGER := 1
	);
	PORT (
		clock : IN STD_LOGIC;
		reset : IN STD_LOGIC;
		ena   : IN STD_LOGIC := '1';
		a     : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (OTHERS=>'0');
		a_en  : IN  STD_LOGIC := '0';
		b     : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (OTHERS=>'0');
		q     : OUT STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0)
	);
END COMPONENT;


COMPONENT alt_cusp161_general_fifo IS
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
	rdreset	     : in  std_logic;
	rdclock	     : in  std_logic;
	rdena        : in  std_logic;
	wrreset	     : in  std_logic;
	wrclock      : in  std_logic;
	wrena        : in  std_logic;
	wrusedw	     : out std_logic_vector(wide_enough_for(DEPTH) - 1 downto 0);
	full	     : out std_logic;
	almost_full  : out std_logic;
	rdusedw      : out std_logic_vector(wide_enough_for(DEPTH) - 1 downto 0);
	empty	     : out std_logic;
	almost_empty : out std_logic;
	wrreq	     : in  std_logic;
	data	     : in  std_logic_vector(WIDTH - 1 downto 0);
	rdreq	     : in  std_logic;
	q		     : out std_logic_vector(WIDTH - 1 downto 0)
	);
END COMPONENT;


COMPONENT alt_cusp161_gpi IS
	GENERIC (
		NAME         : STRING := "";
		SIMULATION   : INTEGER := SIMULATION_OFF;
		OPTIMIZED    : INTEGER := OPTIMIZED_ON;
		FAMILY       : INTEGER := FAMILY_STRATIX;
		DATATYPE     : STRING := "";
		MODE         : STRING := "REGISTERED";
		WIDTH        : INTEGER := 16
	);
	PORT (
		clock : IN STD_LOGIC;
		reset : IN STD_LOGIC;
		ena : IN STD_LOGIC := '1';
		gpio_in : IN STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		q : OUT STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0);
		q_en: IN STD_LOGIC := '0';
		wait_change: IN STD_LOGIC := '0';
		wait_change_en: IN STD_LOGIC := '0';
		stall : OUT STD_LOGIC
	);
END COMPONENT;


COMPONENT alt_cusp161_gpio IS
	GENERIC (
		NAME         : STRING := "";
		SIMULATION   : INTEGER := SIMULATION_OFF;
		OPTIMIZED    : INTEGER := OPTIMIZED_ON;
		FAMILY       : INTEGER := FAMILY_STRATIX;
		DATATYPE     : STRING := "";
		MODE         : STRING := "REGISTERED";
		WIDTH        : INTEGER := 16
	);
	PORT (
		clock : IN STD_LOGIC;
		reset : IN STD_LOGIC;
		ena : IN STD_LOGIC := '1';
		enable : IN STD_LOGIC := '1';
		enable_en : IN STD_LOGIC := '1';
		d : IN STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		q : OUT STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0);
		q_en: IN STD_LOGIC := '0';
		wait_change: IN STD_LOGIC := '0';
		wait_change_en: IN STD_LOGIC := '0';
		stall : OUT STD_LOGIC
	);
END COMPONENT;


COMPONENT alt_cusp161_gpo IS
	GENERIC (
		NAME         : STRING := "";
		SIMULATION   : INTEGER := SIMULATION_OFF;
		OPTIMIZED    : INTEGER := OPTIMIZED_ON;
		FAMILY       : INTEGER := FAMILY_STRATIX;
		DATATYPE     : STRING := "";
		MODE         : STRING := "REGISTERED";
		WIDTH        : INTEGER := 16
	);
	PORT (
		clock : IN STD_LOGIC;
		reset : IN STD_LOGIC;
		ena : IN STD_LOGIC := '1';
		enable : IN STD_LOGIC := '1';
		enable_en : IN STD_LOGIC := '1';
		d : IN STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		gpio_out : OUT STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0)
	);
END COMPONENT;


COMPONENT alt_cusp161_gray_clock_crosser IS
	generic
	(
	WIDTH : integer := 8
	);
	port
	(
	inclock	 : in  std_logic;
	outclock : in  std_logic;
	inena    : in  std_logic;
	outena   : in  std_logic;
	inreset	 : in  std_logic;
	outreset : in  std_logic;
	data     : in  std_logic_vector(WIDTH - 1 downto 0);
	q        : out std_logic_vector(WIDTH - 1 downto 0)
	);
END COMPONENT;


COMPONENT alt_cusp161_logic_fifo IS
	generic
	(
	WIDTH	           : integer := 8;
	DEPTH	           : integer := 3
	);
	port
	(
	clock	     : in  std_logic;
	rdena        : in  std_logic := '1';
	wrena        : in  std_logic := '1';
	reset	     : in  std_logic;
	wrusedw	     : out std_logic_vector(wide_enough_for(DEPTH) - 1 downto 0);
	full	     : out std_logic;
	almost_full  : out std_logic;
	rdusedw      : out std_logic_vector(wide_enough_for(DEPTH) - 1 downto 0);
	empty	     : out std_logic;
	almost_empty : out std_logic;
	wrreq	     : in  std_logic;
	data	     : in  std_logic_vector(WIDTH - 1 downto 0);
	rdreq	     : in  std_logic;
	q		     : out std_logic_vector(WIDTH - 1 downto 0)
	);
END COMPONENT;


COMPONENT alt_cusp161_lu IS
	GENERIC (
		NAME         : STRING := "";
		SIMULATION   : INTEGER := SIMULATION_OFF;
		OPTIMIZED    : INTEGER := OPTIMIZED_ON;
		FAMILY       : INTEGER := FAMILY_STRATIX;
		WIDTH : INTEGER := 16
	);
	PORT (
		a        : IN STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		b        : IN STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		andNor   : IN STD_LOGIC := '0';
		invert   : IN STD_LOGIC := '0';
		q        : OUT STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0)
	);
END COMPONENT;


COMPONENT alt_cusp161_lu_wire IS
	GENERIC (
		NAME         : STRING := "";
		SIMULATION   : INTEGER := SIMULATION_OFF;
		OPTIMIZED    : INTEGER := OPTIMIZED_ON;
		FAMILY       : INTEGER := FAMILY_STRATIX;
		WIDTH : INTEGER := 16
	);
	PORT (
		a        : IN STD_LOGIC := '0';
		b        : IN STD_LOGIC := '0';
		andNor   : IN STD_LOGIC := '0';
		invert   : IN STD_LOGIC := '0';
		q        : OUT STD_LOGIC
	);
END COMPONENT;


COMPONENT alt_cusp161_mac IS
	GENERIC (
		NAME         : STRinG := "";
		SIMULATION   : INTEGER := SIMULATION_OFF;
		OPTIMIZED    : INTEGER := OPTIMIZED_ON;
		FAMILY       : INTEGER := FAMILY_STRATIX;
		WIDTH        : INTEGER := 16;
		WIDTHOUT     : INTEGER := 32;
		LATENCY      : INTEGER := 3
	);
	PORT (
		clock : IN STD_LOGIC;
		reset : IN STD_LOGIC;
		ena   : IN STD_LOGIC := '1';
		a     : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (OTHERS=>'0');
		a_en  : IN  STD_LOGIC := '1';
		b     : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (OTHERS=>'0');
		signa  : IN  STD_LOGIC                           := '0';
		signb  : IN  STD_LOGIC                           := '0';
		mulNmac  : IN STD_LOGIC := '0';
		q     : OUT STD_LOGIC_VECTOR( WIDTHOUT-1 DOWNTO 0)
	);
END COMPONENT;


COMPONENT alt_cusp161_mem IS
	GENERIC (
		NAME             : STRING  := "";
		OPTIMIZED        : INTEGER := OPTIMIZED_ON;
		FAMILY           : INTEGER := FAMILY_STRATIX;
		INIT_FILE        : STRING  := "UNUSED";
		INIT_CONTENTS    : STRING  := "UNUSED";
		DATA_WIDTH       : INTEGER := 16;
		ADDRESS_WIDTH    : INTEGER := 16;
		DEPTH            : INTEGER := 16;
		LATENCY          : INTEGER := 2;
		READ_PORTS       : INTEGER := 0;
		WRITE_PORTS      : INTEGER := 0;
		READ_WRITE_PORTS : INTEGER := 2;
		MODE             : INTEGER := ALT_MEM_MODE_AUTO;
		ALLOW_MULTI_THREAD : INTEGER := 0
	);
	PORT (
		clock : IN STD_LOGIC;
		reset : IN STD_LOGIC;
		Aena  : IN STD_LOGIC := '1';
		Bena  : IN STD_LOGIC := '0';
		Cena  : IN STD_LOGIC := '0';
		Aenable    : IN STD_LOGIC := '0';
		Aenable_en : IN STD_LOGIC := '0';
		Aaddr     : IN  STD_LOGIC_VECTOR( ADDRESS_WIDTH-1 DOWNTO 0) := (OTHERS=>'0');
		Awdata    : IN  STD_LOGIC_VECTOR( DATA_WIDTH-1 DOWNTO 0) := (OTHERS=>'0');
		Awdata_en : IN  STD_LOGIC := '0';
		Ardata    : OUT STD_LOGIC_VECTOR( DATA_WIDTH-1 DOWNTO 0);
		Benable    : IN STD_LOGIC := '0';
		Benable_en : IN STD_LOGIC := '0';
		Baddr     : IN  STD_LOGIC_VECTOR( ADDRESS_WIDTH-1 DOWNTO 0) := (OTHERS=>'0');
		Bwdata    : IN  STD_LOGIC_VECTOR( DATA_WIDTH-1 DOWNTO 0) := (OTHERS=>'0');
		Bwdata_en : IN  STD_LOGIC := '0';
		Brdata    : OUT STD_LOGIC_VECTOR( DATA_WIDTH-1 DOWNTO 0);
		Cenable    : IN STD_LOGIC := '0';
		Cenable_en : IN STD_LOGIC := '0';
		Caddr     : IN  STD_LOGIC_VECTOR( ADDRESS_WIDTH-1 DOWNTO 0) := (OTHERS=>'0');
		Crdata    : OUT STD_LOGIC_VECTOR( DATA_WIDTH-1 DOWNTO 0)
	);
END COMPONENT;


COMPONENT alt_cusp161_mult IS
	GENERIC (
		NAME         : STRinG := "";
		SIMULATION   : INTEGER := SIMULATION_OFF;
		OPTIMIZED    : INTEGER := OPTIMIZED_ON;
		FAMILY       : INTEGER := FAMILY_STRATIX;
		WIDTH        : INTEGER := 16;
		WIDTHX2      : INTEGER := 32;
		LATENCY      : INTEGER := 2;
		RESTART      : INTEGER := 1
	);
	PORT (
		clock : IN STD_LOGIC;
		reset : IN STD_LOGIC;
		ena   : IN STD_LOGIC := '1';
		a     : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (OTHERS=>'0');
		a_en  : IN  STD_LOGIC := '1';
		b     : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (OTHERS=>'0');
		signa  : IN  STD_LOGIC                           := '0';
		signb  : IN  STD_LOGIC                           := '0';
		q     : OUT STD_LOGIC_VECTOR( WIDTHx2-1 DOWNTO 0)
	);
END COMPONENT;


COMPONENT alt_cusp161_multadd IS
	GENERIC (
		NAME         : STRinG := "";
		SIMULATION   : INTEGER := SIMULATION_OFF;
		OPTIMIZED    : INTEGER := OPTIMIZED_ON;
		FAMILY       : INTEGER := FAMILY_STRATIXII;
		WIDTH        : INTEGER := 16;
		WIDTHOUT     : INTEGER := 33;
		LATENCY      : INTEGER := 3;
		RESTART      : INTEGER := 1
	);
	PORT (
		clock : IN STD_LOGIC;
		reset : IN STD_LOGIC;
		ena   : IN STD_LOGIC := '1';
		a     : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (OTHERS=>'0');
		a_en  : IN  STD_LOGIC := '1';
		b     : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (OTHERS=>'0');
		c     : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (OTHERS=>'0');
		d     : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (OTHERS=>'0');
		signa  : IN  STD_LOGIC                           := '0';
		signb  : IN  STD_LOGIC                           := '0';
		signc  : IN  STD_LOGIC                           := '0';
		signd  : IN  STD_LOGIC                           := '0';
		q     : OUT STD_LOGIC_VECTOR( WIDTHOUT-1 DOWNTO 0)
	);
END COMPONENT;


COMPONENT alt_cusp161_mux2 IS
	GENERIC (
		NAME         : STRING := "";
		SIMULATION   : INTEGER := SIMULATION_OFF;
		OPTIMIZED    : INTEGER := OPTIMIZED_ON;
		FAMILY       : INTEGER := FAMILY_STRATIX;
		WIDTH        : INTEGER := 16
	);
	PORT (
		sel            : IN  STD_LOGIC := '0';
		data0          : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data1          : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		q              : OUT STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0)
	);
END COMPONENT;


COMPONENT alt_cusp161_mux2_wire IS
	GENERIC (
		NAME         : STRING := "";
		SIMULATION   : INTEGER := SIMULATION_OFF;
		OPTIMIZED    : INTEGER := OPTIMIZED_ON;
		FAMILY       : INTEGER := FAMILY_STRATIX;
		CONSTANT PORTS        : INTEGER := 2
	);
	PORT (
		sel            : IN  STD_LOGIC;
		data           : IN  STD_LOGIC_VECTOR( PORTS-1 DOWNTO 0):= (others => '0');
		q              : OUT STD_LOGIC
	);
END COMPONENT;


COMPONENT alt_cusp161_mux3 IS
	GENERIC (
		NAME         : STRING := "";
		SIMULATION   : INTEGER := SIMULATION_OFF;
		OPTIMIZED    : INTEGER := OPTIMIZED_ON;
		FAMILY       : INTEGER := FAMILY_STRATIX;
		WIDTH        : INTEGER := 16
	);
	PORT (
		sel            : IN  STD_LOGIC_VECTOR( 2 DOWNTO 0) := (others=>'0');
		data0          : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data1          : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data2          : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		q              : OUT STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0)
	);
END COMPONENT;


COMPONENT alt_cusp161_mux4 IS
	GENERIC (
		NAME         : STRING := "";
		SIMULATION   : INTEGER := SIMULATION_OFF;
		OPTIMIZED    : INTEGER := OPTIMIZED_ON;
		FAMILY       : INTEGER := FAMILY_STRATIX;
		WIDTH        : INTEGER := 16
	);
	PORT (
		sel            : IN  STD_LOGIC_VECTOR( 3 DOWNTO 0) := (others=>'0');
		data0          : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data1          : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data2          : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data3          : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		q              : OUT STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0)
	);
END COMPONENT;


COMPONENT alt_cusp161_mux5 IS
	GENERIC (
		NAME         : STRING := "";
		SIMULATION   : INTEGER := SIMULATION_OFF;
		OPTIMIZED    : INTEGER := OPTIMIZED_ON;
		FAMILY       : INTEGER := FAMILY_STRATIX;
		WIDTH        : INTEGER := 16
	);
	PORT (
		sel            : IN  STD_LOGIC_VECTOR( 4 DOWNTO 0) := (others=>'0');
		data0          : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data1          : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data2          : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data3          : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data4          : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		q              : OUT STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0)
	);
END COMPONENT;


COMPONENT alt_cusp161_mux_wire IS
	GENERIC (
		NAME         : STRING := "";
		SIMULATION   : INTEGER := SIMULATION_OFF;
		OPTIMIZED    : INTEGER := OPTIMIZED_ON;
		FAMILY       : INTEGER := FAMILY_STRATIX;
		PORTS        : INTEGER := 16
	);
	PORT (
		sel            : IN  STD_LOGIC_VECTOR( PORTS-1 DOWNTO 0):= (others => '0');
		data           : IN  STD_LOGIC_VECTOR( PORTS-1 DOWNTO 0):= (others => '0');
		q              : OUT STD_LOGIC
	);
END COMPONENT;


COMPONENT alt_cusp161_mux_x20 IS
	GENERIC (
		NAME         : STRING := "";
		SIMULATION   : INTEGER := SIMULATION_OFF;
		OPTIMIZED    : INTEGER := OPTIMIZED_ON;
		FAMILY       : INTEGER := FAMILY_STRATIX;
		PORTS        : INTEGER := 21;
		WIDTH        : INTEGER := 16
	);
	PORT (
		sel            : IN  STD_LOGIC_VECTOR( PORTS-1 DOWNTO 0) := (others=>'0');
		data0          : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data1          : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data2          : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data3          : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data4          : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data5          : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data6          : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data7          : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data8          : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data9          : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data10         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data11         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data12         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data13         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data14         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data15         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data16         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data17         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data18         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data19         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data20         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		q              : OUT STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0)
	);
END COMPONENT;


COMPONENT alt_cusp161_mux_x40 IS
	GENERIC (
		NAME         : STRING := "";
		SIMULATION   : INTEGER := SIMULATION_OFF;
		OPTIMIZED    : INTEGER := OPTIMIZED_ON;
		FAMILY       : INTEGER := FAMILY_STRATIX;
		PORTS        : INTEGER := 41;
		WIDTH        : INTEGER := 16
	);
	PORT (
		sel            : IN  STD_LOGIC_VECTOR( PORTS-1 DOWNTO 0) := (others=>'0');
		data0          : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data1          : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data2          : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data3          : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data4          : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data5          : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data6          : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data7          : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data8          : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data9          : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data10         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data11         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data12         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data13         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data14         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data15         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data16         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data17         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data18         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data19         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data20         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data21         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data22         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data23         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data24         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data25         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data26         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data27         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data28         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data29         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data30         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data31         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data32         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data33         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data34         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data35         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data36         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data37         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data38         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data39         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data40         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		q              : OUT STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0)
	);
END COMPONENT;


COMPONENT alt_cusp161_mux_x80 IS
	GENERIC (
		NAME         : STRING := "";
		SIMULATION   : INTEGER := SIMULATION_OFF;
		OPTIMIZED    : INTEGER := OPTIMIZED_ON;
		FAMILY       : INTEGER := FAMILY_STRATIX;
		PORTS        : INTEGER := 81;
		WIDTH        : INTEGER := 16
	);
	PORT (
		sel            : IN  STD_LOGIC_VECTOR( PORTS-1 DOWNTO 0) := (others=>'0');
		data0          : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data1          : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data2          : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data3          : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data4          : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data5          : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data6          : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data7          : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data8          : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data9          : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data10         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data11         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data12         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data13         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data14         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data15         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data16         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data17         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data18         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data19         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data20         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data21         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data22         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data23         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data24         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data25         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data26         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data27         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data28         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data29         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data30         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data31         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data32         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data33         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data34         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data35         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data36         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data37         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data38         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data39         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data40         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data41         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data42         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data43         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data44         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data45         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data46         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data47         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data48         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data49         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data50         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data51         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data52         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data53         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data54         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data55         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data56         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data57         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data58         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data59         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data60         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data61         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data62         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data63         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data64         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data65         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data66         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data67         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data68         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data69         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data70         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data71         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data72         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data73         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data74         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data75         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data76         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data77         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data78         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data79         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data80         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		data81         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (others=>'0');
		q              : OUT STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0)
	);
END COMPONENT;


COMPONENT alt_cusp161_muxfast4 IS
	GENERIC (
		NAME         : STRING := "";
		SIMULATION   : INTEGER := SIMULATION_OFF;
		OPTIMIZED    : INTEGER := OPTIMIZED_ON;
		FAMILY       : INTEGER := FAMILY_STRATIX;
		PORTS        : INTEGER := 4;
		WIDTH : INTEGER := 16
	);
	PORT (
		sel : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		data0 : IN STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0) := (others=>'0');
		data1 : IN STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0) := (others=>'0');
		data2 : IN STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0) := (others=>'0');
		data3 : IN STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0) := (others=>'0');
		q : OUT STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0)
	);
END COMPONENT;


COMPONENT alt_cusp161_muxfast8 IS
	GENERIC (
		NAME         : STRING := "";
		SIMULATION   : INTEGER := SIMULATION_OFF;
		OPTIMIZED    : INTEGER := OPTIMIZED_ON;
		FAMILY       : INTEGER := FAMILY_STRATIX;
		PORTS        : INTEGER := 8;
		WIDTH : INTEGER := 16
	);
	PORT (
		sel : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		data0 : IN STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0) := (others=>'0');
		data1 : IN STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0) := (others=>'0');
		data2 : IN STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0) := (others=>'0');
		data3 : IN STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0) := (others=>'0');
		data4 : IN STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0) := (others=>'0');
		data5 : IN STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0) := (others=>'0');
		data6 : IN STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0) := (others=>'0');
		data7 : IN STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0) := (others=>'0');
		q : OUT STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0)
	);
END COMPONENT;


COMPONENT alt_cusp161_one_bit_delay IS
	generic
	(
	DELAY : integer := 0
	);
	port
	(
	clock : in  std_logic;
	reset : in  std_logic;
	ena   : in  std_logic := '1';
	data  : in  std_logic;
	q     : out std_logic
	);
END COMPONENT;


COMPONENT alt_cusp161_pc IS
	GENERIC (
		NAME         : STRING := "";
		OPTIMIZED    : INTEGER := OPTIMIZED_ON;
		FAMILY       : INTEGER := FAMILY_STRATIX;
		PROGRAM_FILE : STRING := "";
		PROGRAM_TRACE: STRING := "program.trace";
		LATENCY      : INTEGER := 3;
		DECODE_LATENCY : INTEGER := 2;
		INFER_MEMORY : INTEGER := 0;
		PC_WIDTH     : INTEGER := 16;
		PC_NUM_WORDS : INTEGER := 256;
		PCW_WIDTH    : INTEGER := 32
	);
	PORT (
		clock        : IN STD_LOGIC;
		reset        : IN STD_LOGIC;
		ena          : IN STD_LOGIC := '1';
		pcw          : OUT STD_LOGIC_VECTOR( PCW_WIDTH-1 DOWNTO 0);
		pc           : OUT STD_LOGIC_VECTOR( PC_WIDTH-1  DOWNTO 0);
		pcf          : OUT STD_LOGIC_VECTOR( PC_WIDTH-1  DOWNTO 0);
		step         : OUT STD_LOGIC;
		stallnext    : OUT STD_LOGIC;
		nextpc       : IN  STD_LOGIC_VECTOR( PC_WIDTH-1 DOWNTO 0) := (OTHERS=>'0');
		usenextpc    : IN  STD_LOGIC := '0';
		usenextpc_en : IN  STD_LOGIC := '0';
		hold         : IN  STD_LOGIC := '0';
		hold_en      : IN  STD_LOGIC := '0'
	);
END COMPONENT;


COMPONENT alt_cusp161_pulling_width_adapter IS
	generic (
	NAME      : string  := "";
	OPTIMIZED : integer := OPTIMIZED_ON;
	FAMILY    : integer := FAMILY_STRATIX;
	IN_WIDTH  : integer := 16;
	OUT_WIDTH : integer := 16
	);
	port (
	clock            : in std_logic;
	reset            : in std_logic;
	ena              : in  std_logic := '1';
	input            : in  std_logic_vector(IN_WIDTH - 1 downto 0) := (others => '0');
	need_input       : out std_logic;
	output           : out std_logic_vector(OUT_WIDTH - 1 downto 0) := (others => '0');
	pull             : in std_logic;
	pull_en          : in  std_logic;
	discard          : in  std_logic;
	discard_en       : in  std_logic
	);
END COMPONENT;


COMPONENT alt_cusp161_pushing_width_adapter IS
	generic (
	NAME      : string  := "";
	OPTIMIZED : integer := OPTIMIZED_ON;
	FAMILY    : integer := FAMILY_STRATIX;
	IN_WIDTH  : integer := 16;
	OUT_WIDTH : integer := 16
	);
	port (
	clock            : in std_logic;
	reset            : in std_logic;
	ena              : in  std_logic := '1';
	input            : in  std_logic_vector(IN_WIDTH - 1 downto 0) := (others => '0');
	push             : in  std_logic;
	push_en          : in  std_logic;
	flush            : in  std_logic;
	flush_en         : in  std_logic;
	output           : out std_logic_vector(OUT_WIDTH - 1 downto 0) := (others => '0');
	output_valid     : out std_logic
	);
END COMPONENT;


COMPONENT alt_cusp161_ram_fifo IS
	generic
	(
	WIDTH	        : integer := 8;
	DEPTH	        : integer := 3;
	CLOCKS_ARE_SAME : boolean := TRUE;
	DEVICE_FAMILY   : string
	);
	port
	(
	rdclock	     : in  std_logic;
	rdena        : in  std_logic;
	wrclock      : in  std_logic;
	wrena        : in  std_logic;
	rdreset	     : in  std_logic;
	wrreset	     : in  std_logic;
	wrusedw	     : out std_logic_vector(wide_enough_for(DEPTH) - 1 downto 0);
	full	     : out std_logic;
	almost_full  : out std_logic;
	rdusedw      : out std_logic_vector(wide_enough_for(DEPTH) - 1 downto 0);
	empty	     : out std_logic;
	almost_empty : out std_logic;
	wrreq	     : in  std_logic;
	data	     : in  std_logic_vector(WIDTH - 1 downto 0);
	rdreq	     : in  std_logic;
	q		     : out std_logic_vector(WIDTH - 1 downto 0)
	);
END COMPONENT;


COMPONENT alt_cusp161_reg IS
	GENERIC (
		NAME         : STRING  := "";
		OPTIMIZED    : INTEGER := OPTIMIZED_ON;
		FAMILY       : INTEGER := FAMILY_STRATIX;
		WIDTH        : INTEGER := 16;
		RESET_VALUE  : INTEGER := 0
	);
	PORT (
		clock      : IN  STD_LOGIC;
		ena        : IN  STD_LOGIC := '1';
		enable     : IN  STD_LOGIC := '0';
		enable_en  : IN  STD_LOGIC := '0';
		reset      : IN  STD_LOGIC := '0';
		sclr       : IN  STD_LOGIC := '0';
		d          : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (OTHERS=>'0');
		q          : OUT STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0)
	);
END COMPONENT;


COMPONENT alt_cusp161_shift IS
	GENERIC (
		NAME         : STRING := "";
		OPTIMIZED    : INTEGER := OPTIMIZED_ON;
		FAMILY       : INTEGER := FAMILY_STRATIX;
		DATA_WIDTH   : POSITIVE := 16;
		SHIFT_WIDTH  : POSITIVE := 4;
		LATENCY      : INTEGER := 0;
		MODE         : INTEGER := ALT_SHIFT_MODE_LOGICAL;
		DIRECTION    : INTEGER := ALT_SHIFT_DIREC_RIGHT
	);
	PORT (
		clock        : IN STD_LOGIC := '0';
		ena          : IN STD_LOGIC := '0';
		reset          : IN STD_LOGIC := '0';
		data         : IN  STD_LOGIC_VECTOR(DATA_WIDTH-1 DOWNTO 0) := (OTHERS=>'0');
		data_en      : IN STD_LOGIC := '1';
		shift        : IN STD_LOGIC_VECTOR(SHIFT_WIDTH-1 DOWNTO 0) := (OTHERS=>'0');
		direc    : IN STD_LOGIC := '0';
		result       : OUT  STD_LOGIC_VECTOR(DATA_WIDTH-1 DOWNTO 0)
	);
END COMPONENT;


COMPONENT alt_cusp161_std_logic_vector_delay IS
	generic
	(
	WIDTH : integer := 1;
	DELAY : integer := 0
	);
	port
	(
	clock : in  std_logic;
	reset : in  std_logic;
	ena   : in  std_logic := '1';
	data  : in  std_logic_vector(WIDTH - 1 downto 0);
	q     : out std_logic_vector(WIDTH - 1 downto 0)
	);
END COMPONENT;


COMPONENT alt_cusp161_muxbin2_wire IS
	generic (
	NAME    : string := "";
	PORTS   : integer := 2;
	WIDTH   : integer := 1
	);
	port (
	sel     : in  std_logic := '0';
	data0   : in  std_logic := '0';
	data1   : in  std_logic := '0';
	q       : out std_logic
	);
END COMPONENT;


COMPONENT alt_cusp161_muxbin2 IS
	generic (
	NAME    : string := "";
	PORTS   : integer := 2;
	WIDTH   : integer := 16
	);
	port (
	sel     : in  std_logic := '0';
	data0   : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data1   : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	q       : out std_logic_vector(WIDTH-1 downto 0)
	);
END COMPONENT;


COMPONENT alt_cusp161_muxbin4_wire IS
	generic (
	NAME    : string := "";
	PORTS   : integer := 4;
	WIDTH   : integer := 1
	);
	port (
	sel     : in  std_logic_vector(1 downto 0) := (others => '0');
	data0   : in  std_logic := '0';
	data1   : in  std_logic := '0';
	data2   : in  std_logic := '0';
	data3   : in  std_logic := '0';
	q       : out std_logic
	);
END COMPONENT;


COMPONENT alt_cusp161_muxbin4 IS
	generic (
	NAME    : string := "";
	PORTS   : integer := 4;
	WIDTH   : integer := 16
	);
	port (
	sel     : in  std_logic_vector(1 downto 0) := (others => '0');
	data0   : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data1   : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data2   : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data3   : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	q       : out std_logic_vector(WIDTH-1 downto 0)
	);
END COMPONENT;


COMPONENT alt_cusp161_muxbin8_wire IS
	generic (
	NAME    : string := "";
	PORTS   : integer := 8;
	WIDTH   : integer := 1
	);
	port (
	sel     : in  std_logic_vector(2 downto 0) := (others => '0');
	data0   : in  std_logic := '0';
	data1   : in  std_logic := '0';
	data2   : in  std_logic := '0';
	data3   : in  std_logic := '0';
	data4   : in  std_logic := '0';
	data5   : in  std_logic := '0';
	data6   : in  std_logic := '0';
	data7   : in  std_logic := '0';
	q       : out std_logic
	);
END COMPONENT;


COMPONENT alt_cusp161_muxbin8 IS
	generic (
	NAME    : string := "";
	PORTS   : integer := 8;
	WIDTH   : integer := 16
	);
	port (
	sel     : in  std_logic_vector(2 downto 0) := (others => '0');
	data0   : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data1   : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data2   : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data3   : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data4   : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data5   : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data6   : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data7   : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	q       : out std_logic_vector(WIDTH-1 downto 0)
	);
END COMPONENT;


COMPONENT alt_cusp161_muxbin16_wire IS
	generic (
	NAME    : string := "";
	PORTS   : integer := 16;
	WIDTH   : integer := 1
	);
	port (
	sel     : in  std_logic_vector(3 downto 0) := (others => '0');
	data0   : in  std_logic := '0';
	data1   : in  std_logic := '0';
	data2   : in  std_logic := '0';
	data3   : in  std_logic := '0';
	data4   : in  std_logic := '0';
	data5   : in  std_logic := '0';
	data6   : in  std_logic := '0';
	data7   : in  std_logic := '0';
	data8   : in  std_logic := '0';
	data9   : in  std_logic := '0';
	data10  : in  std_logic := '0';
	data11  : in  std_logic := '0';
	data12  : in  std_logic := '0';
	data13  : in  std_logic := '0';
	data14  : in  std_logic := '0';
	data15  : in  std_logic := '0';
	q       : out std_logic
	);
END COMPONENT;


COMPONENT alt_cusp161_muxbin16 IS
	generic (
	NAME    : string := "";
	PORTS   : integer := 16;
	WIDTH   : integer := 16
	);
	port (
	sel     : in  std_logic_vector(3 downto 0) := (others => '0');
	data0   : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data1   : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data2   : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data3   : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data4   : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data5   : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data6   : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data7   : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data8   : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data9   : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data10  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data11  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data12  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data13  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data14  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data15  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	q       : out std_logic_vector(WIDTH-1 downto 0)
	);
END COMPONENT;


COMPONENT alt_cusp161_muxbin32_wire IS
	generic (
	NAME    : string := "";
	PORTS   : integer := 32;
	WIDTH   : integer := 1
	);
	port (
	sel     : in  std_logic_vector(4 downto 0) := (others => '0');
	data0   : in  std_logic := '0';
	data1   : in  std_logic := '0';
	data2   : in  std_logic := '0';
	data3   : in  std_logic := '0';
	data4   : in  std_logic := '0';
	data5   : in  std_logic := '0';
	data6   : in  std_logic := '0';
	data7   : in  std_logic := '0';
	data8   : in  std_logic := '0';
	data9   : in  std_logic := '0';
	data10  : in  std_logic := '0';
	data11  : in  std_logic := '0';
	data12  : in  std_logic := '0';
	data13  : in  std_logic := '0';
	data14  : in  std_logic := '0';
	data15  : in  std_logic := '0';
	data16  : in  std_logic := '0';
	data17  : in  std_logic := '0';
	data18  : in  std_logic := '0';
	data19  : in  std_logic := '0';
	data20  : in  std_logic := '0';
	data21  : in  std_logic := '0';
	data22  : in  std_logic := '0';
	data23  : in  std_logic := '0';
	data24  : in  std_logic := '0';
	data25  : in  std_logic := '0';
	data26  : in  std_logic := '0';
	data27  : in  std_logic := '0';
	data28  : in  std_logic := '0';
	data29  : in  std_logic := '0';
	data30  : in  std_logic := '0';
	data31  : in  std_logic := '0';
	q       : out std_logic
	);
END COMPONENT;


COMPONENT alt_cusp161_muxbin32 IS
	generic (
	NAME    : string := "";
	PORTS   : integer := 32;
	WIDTH   : integer := 16
	);
	port (
	sel     : in  std_logic_vector(4 downto 0) := (others => '0');
	data0   : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data1   : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data2   : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data3   : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data4   : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data5   : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data6   : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data7   : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data8   : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data9   : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data10  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data11  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data12  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data13  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data14  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data15  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data16  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data17  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data18  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data19  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data20  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data21  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data22  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data23  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data24  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data25  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data26  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data27  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data28  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data29  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data30  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data31  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	q       : out std_logic_vector(WIDTH-1 downto 0)
	);
END COMPONENT;


COMPONENT alt_cusp161_muxbin64_wire IS
	generic (
	NAME    : string := "";
	PORTS   : integer := 64;
	WIDTH   : integer := 1
	);
	port (
	sel     : in  std_logic_vector(5 downto 0) := (others => '0');
	data0   : in  std_logic := '0';
	data1   : in  std_logic := '0';
	data2   : in  std_logic := '0';
	data3   : in  std_logic := '0';
	data4   : in  std_logic := '0';
	data5   : in  std_logic := '0';
	data6   : in  std_logic := '0';
	data7   : in  std_logic := '0';
	data8   : in  std_logic := '0';
	data9   : in  std_logic := '0';
	data10  : in  std_logic := '0';
	data11  : in  std_logic := '0';
	data12  : in  std_logic := '0';
	data13  : in  std_logic := '0';
	data14  : in  std_logic := '0';
	data15  : in  std_logic := '0';
	data16  : in  std_logic := '0';
	data17  : in  std_logic := '0';
	data18  : in  std_logic := '0';
	data19  : in  std_logic := '0';
	data20  : in  std_logic := '0';
	data21  : in  std_logic := '0';
	data22  : in  std_logic := '0';
	data23  : in  std_logic := '0';
	data24  : in  std_logic := '0';
	data25  : in  std_logic := '0';
	data26  : in  std_logic := '0';
	data27  : in  std_logic := '0';
	data28  : in  std_logic := '0';
	data29  : in  std_logic := '0';
	data30  : in  std_logic := '0';
	data31  : in  std_logic := '0';
	data32  : in  std_logic := '0';
	data33  : in  std_logic := '0';
	data34  : in  std_logic := '0';
	data35  : in  std_logic := '0';
	data36  : in  std_logic := '0';
	data37  : in  std_logic := '0';
	data38  : in  std_logic := '0';
	data39  : in  std_logic := '0';
	data40  : in  std_logic := '0';
	data41  : in  std_logic := '0';
	data42  : in  std_logic := '0';
	data43  : in  std_logic := '0';
	data44  : in  std_logic := '0';
	data45  : in  std_logic := '0';
	data46  : in  std_logic := '0';
	data47  : in  std_logic := '0';
	data48  : in  std_logic := '0';
	data49  : in  std_logic := '0';
	data50  : in  std_logic := '0';
	data51  : in  std_logic := '0';
	data52  : in  std_logic := '0';
	data53  : in  std_logic := '0';
	data54  : in  std_logic := '0';
	data55  : in  std_logic := '0';
	data56  : in  std_logic := '0';
	data57  : in  std_logic := '0';
	data58  : in  std_logic := '0';
	data59  : in  std_logic := '0';
	data60  : in  std_logic := '0';
	data61  : in  std_logic := '0';
	data62  : in  std_logic := '0';
	data63  : in  std_logic := '0';
	q       : out std_logic
	);
END COMPONENT;


COMPONENT alt_cusp161_muxbin64 IS
	generic (
	NAME    : string := "";
	PORTS   : integer := 64;
	WIDTH   : integer := 16
	);
	port (
	sel     : in  std_logic_vector(5 downto 0) := (others => '0');
	data0   : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data1   : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data2   : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data3   : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data4   : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data5   : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data6   : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data7   : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data8   : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data9   : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data10  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data11  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data12  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data13  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data14  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data15  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data16  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data17  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data18  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data19  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data20  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data21  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data22  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data23  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data24  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data25  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data26  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data27  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data28  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data29  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data30  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data31  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data32  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data33  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data34  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data35  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data36  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data37  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data38  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data39  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data40  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data41  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data42  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data43  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data44  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data45  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data46  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data47  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data48  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data49  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data50  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data51  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data52  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data53  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data54  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data55  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data56  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data57  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data58  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data59  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data60  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data61  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data62  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data63  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	q       : out std_logic_vector(WIDTH-1 downto 0)
	);
END COMPONENT;


COMPONENT alt_cusp161_muxbin128_wire IS
	generic (
	NAME    : string := "";
	PORTS   : integer := 128;
	WIDTH   : integer := 1
	);
	port (
	sel     : in  std_logic_vector(6 downto 0) := (others => '0');
	data0   : in  std_logic := '0';
	data1   : in  std_logic := '0';
	data2   : in  std_logic := '0';
	data3   : in  std_logic := '0';
	data4   : in  std_logic := '0';
	data5   : in  std_logic := '0';
	data6   : in  std_logic := '0';
	data7   : in  std_logic := '0';
	data8   : in  std_logic := '0';
	data9   : in  std_logic := '0';
	data10  : in  std_logic := '0';
	data11  : in  std_logic := '0';
	data12  : in  std_logic := '0';
	data13  : in  std_logic := '0';
	data14  : in  std_logic := '0';
	data15  : in  std_logic := '0';
	data16  : in  std_logic := '0';
	data17  : in  std_logic := '0';
	data18  : in  std_logic := '0';
	data19  : in  std_logic := '0';
	data20  : in  std_logic := '0';
	data21  : in  std_logic := '0';
	data22  : in  std_logic := '0';
	data23  : in  std_logic := '0';
	data24  : in  std_logic := '0';
	data25  : in  std_logic := '0';
	data26  : in  std_logic := '0';
	data27  : in  std_logic := '0';
	data28  : in  std_logic := '0';
	data29  : in  std_logic := '0';
	data30  : in  std_logic := '0';
	data31  : in  std_logic := '0';
	data32  : in  std_logic := '0';
	data33  : in  std_logic := '0';
	data34  : in  std_logic := '0';
	data35  : in  std_logic := '0';
	data36  : in  std_logic := '0';
	data37  : in  std_logic := '0';
	data38  : in  std_logic := '0';
	data39  : in  std_logic := '0';
	data40  : in  std_logic := '0';
	data41  : in  std_logic := '0';
	data42  : in  std_logic := '0';
	data43  : in  std_logic := '0';
	data44  : in  std_logic := '0';
	data45  : in  std_logic := '0';
	data46  : in  std_logic := '0';
	data47  : in  std_logic := '0';
	data48  : in  std_logic := '0';
	data49  : in  std_logic := '0';
	data50  : in  std_logic := '0';
	data51  : in  std_logic := '0';
	data52  : in  std_logic := '0';
	data53  : in  std_logic := '0';
	data54  : in  std_logic := '0';
	data55  : in  std_logic := '0';
	data56  : in  std_logic := '0';
	data57  : in  std_logic := '0';
	data58  : in  std_logic := '0';
	data59  : in  std_logic := '0';
	data60  : in  std_logic := '0';
	data61  : in  std_logic := '0';
	data62  : in  std_logic := '0';
	data63  : in  std_logic := '0';
	data64  : in  std_logic := '0';
	data65  : in  std_logic := '0';
	data66  : in  std_logic := '0';
	data67  : in  std_logic := '0';
	data68  : in  std_logic := '0';
	data69  : in  std_logic := '0';
	data70  : in  std_logic := '0';
	data71  : in  std_logic := '0';
	data72  : in  std_logic := '0';
	data73  : in  std_logic := '0';
	data74  : in  std_logic := '0';
	data75  : in  std_logic := '0';
	data76  : in  std_logic := '0';
	data77  : in  std_logic := '0';
	data78  : in  std_logic := '0';
	data79  : in  std_logic := '0';
	data80  : in  std_logic := '0';
	data81  : in  std_logic := '0';
	data82  : in  std_logic := '0';
	data83  : in  std_logic := '0';
	data84  : in  std_logic := '0';
	data85  : in  std_logic := '0';
	data86  : in  std_logic := '0';
	data87  : in  std_logic := '0';
	data88  : in  std_logic := '0';
	data89  : in  std_logic := '0';
	data90  : in  std_logic := '0';
	data91  : in  std_logic := '0';
	data92  : in  std_logic := '0';
	data93  : in  std_logic := '0';
	data94  : in  std_logic := '0';
	data95  : in  std_logic := '0';
	data96  : in  std_logic := '0';
	data97  : in  std_logic := '0';
	data98  : in  std_logic := '0';
	data99  : in  std_logic := '0';
	data100 : in  std_logic := '0';
	data101 : in  std_logic := '0';
	data102 : in  std_logic := '0';
	data103 : in  std_logic := '0';
	data104 : in  std_logic := '0';
	data105 : in  std_logic := '0';
	data106 : in  std_logic := '0';
	data107 : in  std_logic := '0';
	data108 : in  std_logic := '0';
	data109 : in  std_logic := '0';
	data110 : in  std_logic := '0';
	data111 : in  std_logic := '0';
	data112 : in  std_logic := '0';
	data113 : in  std_logic := '0';
	data114 : in  std_logic := '0';
	data115 : in  std_logic := '0';
	data116 : in  std_logic := '0';
	data117 : in  std_logic := '0';
	data118 : in  std_logic := '0';
	data119 : in  std_logic := '0';
	data120 : in  std_logic := '0';
	data121 : in  std_logic := '0';
	data122 : in  std_logic := '0';
	data123 : in  std_logic := '0';
	data124 : in  std_logic := '0';
	data125 : in  std_logic := '0';
	data126 : in  std_logic := '0';
	data127 : in  std_logic := '0';
	q       : out std_logic
	);
END COMPONENT;


COMPONENT alt_cusp161_muxbin128 IS
	generic (
	NAME    : string := "";
	PORTS   : integer := 128;
	WIDTH   : integer := 16
	);
	port (
	sel     : in  std_logic_vector(6 downto 0) := (others => '0');
	data0   : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data1   : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data2   : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data3   : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data4   : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data5   : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data6   : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data7   : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data8   : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data9   : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data10  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data11  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data12  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data13  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data14  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data15  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data16  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data17  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data18  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data19  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data20  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data21  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data22  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data23  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data24  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data25  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data26  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data27  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data28  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data29  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data30  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data31  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data32  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data33  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data34  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data35  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data36  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data37  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data38  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data39  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data40  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data41  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data42  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data43  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data44  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data45  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data46  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data47  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data48  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data49  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data50  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data51  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data52  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data53  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data54  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data55  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data56  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data57  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data58  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data59  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data60  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data61  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data62  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data63  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data64  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data65  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data66  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data67  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data68  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data69  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data70  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data71  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data72  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data73  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data74  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data75  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data76  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data77  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data78  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data79  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data80  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data81  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data82  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data83  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data84  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data85  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data86  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data87  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data88  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data89  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data90  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data91  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data92  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data93  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data94  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data95  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data96  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data97  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data98  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data99  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data100 : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data101 : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data102 : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data103 : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data104 : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data105 : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data106 : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data107 : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data108 : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data109 : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data110 : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data111 : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data112 : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data113 : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data114 : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data115 : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data116 : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data117 : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data118 : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data119 : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data120 : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data121 : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data122 : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data123 : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data124 : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data125 : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data126 : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data127 : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	q       : out std_logic_vector(WIDTH-1 downto 0)
	);
END COMPONENT;


COMPONENT alt_cusp161_muxhot16_wire IS
	generic (
	NAME    : string := "";
	PORTS   : integer := 16;
	WIDTH   : integer := 1
	);
	port (
	sel     : in  std_logic_vector(PORTS-1 downto 0) := (others => '0');
	data0   : in  std_logic := '0';
	data1   : in  std_logic := '0';
	data2   : in  std_logic := '0';
	data3   : in  std_logic := '0';
	data4   : in  std_logic := '0';
	data5   : in  std_logic := '0';
	data6   : in  std_logic := '0';
	data7   : in  std_logic := '0';
	data8   : in  std_logic := '0';
	data9   : in  std_logic := '0';
	data10  : in  std_logic := '0';
	data11  : in  std_logic := '0';
	data12  : in  std_logic := '0';
	data13  : in  std_logic := '0';
	data14  : in  std_logic := '0';
	data15  : in  std_logic := '0';
	q       : out std_logic
	);
END COMPONENT;


COMPONENT alt_cusp161_muxhot16 IS
	generic (
	NAME    : string := "";
	PORTS   : integer := 16;
	WIDTH   : integer := 16
	);
	port (
	sel     : in  std_logic_vector(PORTS-1 downto 0) := (others => '0');
	data0   : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data1   : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data2   : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data3   : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data4   : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data5   : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data6   : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data7   : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data8   : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data9   : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data10  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data11  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data12  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data13  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data14  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data15  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	q       : out std_logic_vector(WIDTH-1 downto 0)
	);
END COMPONENT;


COMPONENT alt_cusp161_muxhot32_wire IS
	generic (
	NAME    : string := "";
	PORTS   : integer := 32;
	WIDTH   : integer := 1
	);
	port (
	sel     : in  std_logic_vector(PORTS-1 downto 0) := (others => '0');
	data0   : in  std_logic := '0';
	data1   : in  std_logic := '0';
	data2   : in  std_logic := '0';
	data3   : in  std_logic := '0';
	data4   : in  std_logic := '0';
	data5   : in  std_logic := '0';
	data6   : in  std_logic := '0';
	data7   : in  std_logic := '0';
	data8   : in  std_logic := '0';
	data9   : in  std_logic := '0';
	data10  : in  std_logic := '0';
	data11  : in  std_logic := '0';
	data12  : in  std_logic := '0';
	data13  : in  std_logic := '0';
	data14  : in  std_logic := '0';
	data15  : in  std_logic := '0';
	data16  : in  std_logic := '0';
	data17  : in  std_logic := '0';
	data18  : in  std_logic := '0';
	data19  : in  std_logic := '0';
	data20  : in  std_logic := '0';
	data21  : in  std_logic := '0';
	data22  : in  std_logic := '0';
	data23  : in  std_logic := '0';
	data24  : in  std_logic := '0';
	data25  : in  std_logic := '0';
	data26  : in  std_logic := '0';
	data27  : in  std_logic := '0';
	data28  : in  std_logic := '0';
	data29  : in  std_logic := '0';
	data30  : in  std_logic := '0';
	data31  : in  std_logic := '0';
	q       : out std_logic
	);
END COMPONENT;


COMPONENT alt_cusp161_muxhot32 IS
	generic (
	NAME    : string := "";
	PORTS   : integer := 32;
	WIDTH   : integer := 16
	);
	port (
	sel     : in  std_logic_vector(PORTS-1 downto 0) := (others => '0');
	data0   : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data1   : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data2   : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data3   : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data4   : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data5   : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data6   : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data7   : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data8   : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data9   : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data10  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data11  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data12  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data13  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data14  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data15  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data16  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data17  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data18  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data19  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data20  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data21  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data22  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data23  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data24  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data25  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data26  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data27  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data28  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data29  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data30  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data31  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	q       : out std_logic_vector(WIDTH-1 downto 0)
	);
END COMPONENT;


COMPONENT alt_cusp161_muxhot64_wire IS
	generic (
	NAME    : string := "";
	PORTS   : integer := 64;
	WIDTH   : integer := 1
	);
	port (
	sel     : in  std_logic_vector(PORTS-1 downto 0) := (others => '0');
	data0   : in  std_logic := '0';
	data1   : in  std_logic := '0';
	data2   : in  std_logic := '0';
	data3   : in  std_logic := '0';
	data4   : in  std_logic := '0';
	data5   : in  std_logic := '0';
	data6   : in  std_logic := '0';
	data7   : in  std_logic := '0';
	data8   : in  std_logic := '0';
	data9   : in  std_logic := '0';
	data10  : in  std_logic := '0';
	data11  : in  std_logic := '0';
	data12  : in  std_logic := '0';
	data13  : in  std_logic := '0';
	data14  : in  std_logic := '0';
	data15  : in  std_logic := '0';
	data16  : in  std_logic := '0';
	data17  : in  std_logic := '0';
	data18  : in  std_logic := '0';
	data19  : in  std_logic := '0';
	data20  : in  std_logic := '0';
	data21  : in  std_logic := '0';
	data22  : in  std_logic := '0';
	data23  : in  std_logic := '0';
	data24  : in  std_logic := '0';
	data25  : in  std_logic := '0';
	data26  : in  std_logic := '0';
	data27  : in  std_logic := '0';
	data28  : in  std_logic := '0';
	data29  : in  std_logic := '0';
	data30  : in  std_logic := '0';
	data31  : in  std_logic := '0';
	data32  : in  std_logic := '0';
	data33  : in  std_logic := '0';
	data34  : in  std_logic := '0';
	data35  : in  std_logic := '0';
	data36  : in  std_logic := '0';
	data37  : in  std_logic := '0';
	data38  : in  std_logic := '0';
	data39  : in  std_logic := '0';
	data40  : in  std_logic := '0';
	data41  : in  std_logic := '0';
	data42  : in  std_logic := '0';
	data43  : in  std_logic := '0';
	data44  : in  std_logic := '0';
	data45  : in  std_logic := '0';
	data46  : in  std_logic := '0';
	data47  : in  std_logic := '0';
	data48  : in  std_logic := '0';
	data49  : in  std_logic := '0';
	data50  : in  std_logic := '0';
	data51  : in  std_logic := '0';
	data52  : in  std_logic := '0';
	data53  : in  std_logic := '0';
	data54  : in  std_logic := '0';
	data55  : in  std_logic := '0';
	data56  : in  std_logic := '0';
	data57  : in  std_logic := '0';
	data58  : in  std_logic := '0';
	data59  : in  std_logic := '0';
	data60  : in  std_logic := '0';
	data61  : in  std_logic := '0';
	data62  : in  std_logic := '0';
	data63  : in  std_logic := '0';
	q       : out std_logic
	);
END COMPONENT;


COMPONENT alt_cusp161_muxhot64 IS
	generic (
	NAME    : string := "";
	PORTS   : integer := 64;
	WIDTH   : integer := 16
	);
	port (
	sel     : in  std_logic_vector(PORTS-1 downto 0) := (others => '0');
	data0   : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data1   : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data2   : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data3   : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data4   : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data5   : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data6   : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data7   : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data8   : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data9   : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data10  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data11  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data12  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data13  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data14  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data15  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data16  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data17  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data18  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data19  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data20  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data21  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data22  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data23  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data24  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data25  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data26  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data27  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data28  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data29  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data30  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data31  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data32  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data33  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data34  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data35  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data36  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data37  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data38  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data39  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data40  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data41  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data42  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data43  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data44  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data45  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data46  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data47  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data48  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data49  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data50  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data51  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data52  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data53  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data54  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data55  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data56  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data57  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data58  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data59  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data60  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data61  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data62  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data63  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	q       : out std_logic_vector(WIDTH-1 downto 0)
	);
END COMPONENT;


COMPONENT alt_cusp161_muxhot128_wire IS
	generic (
	NAME    : string := "";
	PORTS   : integer := 128;
	WIDTH   : integer := 1
	);
	port (
	sel     : in  std_logic_vector(PORTS-1 downto 0) := (others => '0');
	data0   : in  std_logic := '0';
	data1   : in  std_logic := '0';
	data2   : in  std_logic := '0';
	data3   : in  std_logic := '0';
	data4   : in  std_logic := '0';
	data5   : in  std_logic := '0';
	data6   : in  std_logic := '0';
	data7   : in  std_logic := '0';
	data8   : in  std_logic := '0';
	data9   : in  std_logic := '0';
	data10  : in  std_logic := '0';
	data11  : in  std_logic := '0';
	data12  : in  std_logic := '0';
	data13  : in  std_logic := '0';
	data14  : in  std_logic := '0';
	data15  : in  std_logic := '0';
	data16  : in  std_logic := '0';
	data17  : in  std_logic := '0';
	data18  : in  std_logic := '0';
	data19  : in  std_logic := '0';
	data20  : in  std_logic := '0';
	data21  : in  std_logic := '0';
	data22  : in  std_logic := '0';
	data23  : in  std_logic := '0';
	data24  : in  std_logic := '0';
	data25  : in  std_logic := '0';
	data26  : in  std_logic := '0';
	data27  : in  std_logic := '0';
	data28  : in  std_logic := '0';
	data29  : in  std_logic := '0';
	data30  : in  std_logic := '0';
	data31  : in  std_logic := '0';
	data32  : in  std_logic := '0';
	data33  : in  std_logic := '0';
	data34  : in  std_logic := '0';
	data35  : in  std_logic := '0';
	data36  : in  std_logic := '0';
	data37  : in  std_logic := '0';
	data38  : in  std_logic := '0';
	data39  : in  std_logic := '0';
	data40  : in  std_logic := '0';
	data41  : in  std_logic := '0';
	data42  : in  std_logic := '0';
	data43  : in  std_logic := '0';
	data44  : in  std_logic := '0';
	data45  : in  std_logic := '0';
	data46  : in  std_logic := '0';
	data47  : in  std_logic := '0';
	data48  : in  std_logic := '0';
	data49  : in  std_logic := '0';
	data50  : in  std_logic := '0';
	data51  : in  std_logic := '0';
	data52  : in  std_logic := '0';
	data53  : in  std_logic := '0';
	data54  : in  std_logic := '0';
	data55  : in  std_logic := '0';
	data56  : in  std_logic := '0';
	data57  : in  std_logic := '0';
	data58  : in  std_logic := '0';
	data59  : in  std_logic := '0';
	data60  : in  std_logic := '0';
	data61  : in  std_logic := '0';
	data62  : in  std_logic := '0';
	data63  : in  std_logic := '0';
	data64  : in  std_logic := '0';
	data65  : in  std_logic := '0';
	data66  : in  std_logic := '0';
	data67  : in  std_logic := '0';
	data68  : in  std_logic := '0';
	data69  : in  std_logic := '0';
	data70  : in  std_logic := '0';
	data71  : in  std_logic := '0';
	data72  : in  std_logic := '0';
	data73  : in  std_logic := '0';
	data74  : in  std_logic := '0';
	data75  : in  std_logic := '0';
	data76  : in  std_logic := '0';
	data77  : in  std_logic := '0';
	data78  : in  std_logic := '0';
	data79  : in  std_logic := '0';
	data80  : in  std_logic := '0';
	data81  : in  std_logic := '0';
	data82  : in  std_logic := '0';
	data83  : in  std_logic := '0';
	data84  : in  std_logic := '0';
	data85  : in  std_logic := '0';
	data86  : in  std_logic := '0';
	data87  : in  std_logic := '0';
	data88  : in  std_logic := '0';
	data89  : in  std_logic := '0';
	data90  : in  std_logic := '0';
	data91  : in  std_logic := '0';
	data92  : in  std_logic := '0';
	data93  : in  std_logic := '0';
	data94  : in  std_logic := '0';
	data95  : in  std_logic := '0';
	data96  : in  std_logic := '0';
	data97  : in  std_logic := '0';
	data98  : in  std_logic := '0';
	data99  : in  std_logic := '0';
	data100 : in  std_logic := '0';
	data101 : in  std_logic := '0';
	data102 : in  std_logic := '0';
	data103 : in  std_logic := '0';
	data104 : in  std_logic := '0';
	data105 : in  std_logic := '0';
	data106 : in  std_logic := '0';
	data107 : in  std_logic := '0';
	data108 : in  std_logic := '0';
	data109 : in  std_logic := '0';
	data110 : in  std_logic := '0';
	data111 : in  std_logic := '0';
	data112 : in  std_logic := '0';
	data113 : in  std_logic := '0';
	data114 : in  std_logic := '0';
	data115 : in  std_logic := '0';
	data116 : in  std_logic := '0';
	data117 : in  std_logic := '0';
	data118 : in  std_logic := '0';
	data119 : in  std_logic := '0';
	data120 : in  std_logic := '0';
	data121 : in  std_logic := '0';
	data122 : in  std_logic := '0';
	data123 : in  std_logic := '0';
	data124 : in  std_logic := '0';
	data125 : in  std_logic := '0';
	data126 : in  std_logic := '0';
	data127 : in  std_logic := '0';
	q       : out std_logic
	);
END COMPONENT;


COMPONENT alt_cusp161_muxhot128 IS
	generic (
	NAME    : string := "";
	PORTS   : integer := 128;
	WIDTH   : integer := 16
	);
	port (
	sel     : in  std_logic_vector(PORTS-1 downto 0) := (others => '0');
	data0   : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data1   : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data2   : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data3   : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data4   : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data5   : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data6   : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data7   : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data8   : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data9   : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data10  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data11  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data12  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data13  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data14  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data15  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data16  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data17  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data18  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data19  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data20  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data21  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data22  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data23  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data24  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data25  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data26  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data27  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data28  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data29  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data30  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data31  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data32  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data33  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data34  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data35  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data36  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data37  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data38  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data39  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data40  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data41  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data42  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data43  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data44  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data45  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data46  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data47  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data48  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data49  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data50  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data51  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data52  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data53  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data54  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data55  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data56  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data57  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data58  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data59  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data60  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data61  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data62  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data63  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data64  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data65  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data66  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data67  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data68  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data69  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data70  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data71  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data72  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data73  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data74  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data75  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data76  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data77  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data78  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data79  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data80  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data81  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data82  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data83  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data84  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data85  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data86  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data87  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data88  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data89  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data90  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data91  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data92  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data93  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data94  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data95  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data96  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data97  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data98  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data99  : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data100 : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data101 : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data102 : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data103 : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data104 : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data105 : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data106 : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data107 : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data108 : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data109 : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data110 : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data111 : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data112 : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data113 : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data114 : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data115 : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data116 : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data117 : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data118 : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data119 : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data120 : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data121 : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data122 : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data123 : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data124 : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data125 : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data126 : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	data127 : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	q       : out std_logic_vector(WIDTH-1 downto 0)
	);
END COMPONENT;



--------------------------------------------------------------------------------------  
--------------------------------------------------------------------------------------  

 -- synopsys synthesis_off

  TYPE TTA_X_D_STRING_PTR IS ACCESS STRING;
  TYPE TTA_X_D_SLV_PTR IS ACCESS STD_LOGIC_VECTOR;

  TYPE TTA_X_D_RN_T IS ARRAY ( INTEGER RANGE <> ) OF TTA_X_D_STRING_PTR;
  TYPE TTA_X_D_RV_T IS ARRAY ( INTEGER RANGE <> ) OF TTA_X_D_SLV_PTR;


  PROCEDURE TTA_X_D_registerTrace (
       opAddress : IN STRING;
       opCode : IN STRING;
       opDecode: IN STRING
       );

  PROCEDURE TTA_X_D_registerDump ( 
       fuName : IN STRING;
       registerNames  : INOUT TTA_X_D_RN_T;
       registerValues : INOUT TTA_X_D_RV_T
       );

  PROCEDURE TTA_X_D_openTrace (
      fileName : IN STRING := "trace.out";
      shortFileName : IN STRING := "shorttrace.out"
      );    
 
 -- synopsys synthesis_on
--------------------------------------------------------------------------------------  
--------------------------------------------------------------------------------------  
  
END ALT_CUSP161_PACKAGE;

PACKAGE BODY ALT_CUSP161_PACKAGE IS

    -- -----------------------------------------------------------
    -- Fifo functions
    -- -----------------------------------------------------------
    
	-- find the width of a signal of "unsigned" type wide
	-- enough to hold numbers as big as "max"
	-- this is equivalent to log-2 max rounded up
	function wide_enough_for(max : integer) return integer is
		variable r : integer := 0;
		variable m : integer := max;
	begin
		while m > 0 loop
			m := m / 2;
			r := r + 1;
		end loop;
		return r;
	end function wide_enough_for;
	
	function two_to_the_power(v : integer) return integer is
		variable r : integer := 1;
		variable i : integer := v;
	begin
		while i > 0 loop
			r := r * 2;
			i := i - 1;
		end loop;
		return r;
	end function two_to_the_power;
	
	-- generate as many repeating copies of the hexadecimal string
	-- DEAD as will fit into a "b" bit std_logic_vector
	function dead_bits(b : integer) return std_logic_vector is
		variable r : std_logic_vector(b - 1 downto 0);
		constant DEAD : std_logic_vector(15 downto 0) := "1101111010101101";
	begin
		for i in 0 to b - 1 loop
			r(i) := DEAD(i mod 16);
		end loop;
		return r;
	end function dead_bits;
	
	-- return the higher of the two passed integers
	-- can't believe there isn't a handy library function for this,
	-- but a quick google couldn't find it
	function maximum(a, b : integer) return integer is
	begin
		if (a > b) then
			return a;
		else
			return b;
		end if;
	end function maximum;
	
	-- find the minimum, likewise
	function minimum(a, b : integer) return integer is
	begin
		if (a > b) then
			return b;
		else
			return a;
		end if;
	end function minimum;

	-- calculate the width of a byte enable port
	-- depends on whether byte enables are required and what the
	-- data width of the quantity to be byte enabled is
	function calculate_be_width(be_used : boolean; data_width : integer) return integer is
	begin
		if not be_used then
			return 0;
		else
			assert data_width mod 8 = 0
				report "Tried to calculate the byte enable width of a data width not divisble by 8"
				severity warning;
			return data_width / 8;
		end if;
	end function calculate_be_width;
	function calculate_be_width(be_used : integer; data_width : integer) return integer is
	begin
		if (be_used = 1) then
			return calculate_be_width(true, data_width);
		else
			return calculate_be_width(false, data_width);
		end if;
	end function calculate_be_width;
	function calculate_be_width(data_width : integer) return integer is
	begin
		return calculate_be_width(true, data_width);
	end function calculate_be_width;
	
	-- translate from cusp integer representation of families to the
	-- string representation used by altera megafunctions and the like
	function family_string(f : integer) return string is
	begin
		case f is
        when FAMILY_STRATIX => return "Stratix";
        when FAMILY_STRATIXII => return "Stratix II";
        when FAMILY_STRATIXIII => return "Stratix III";
        when FAMILY_STRATIXIV => return "Stratix IV";
        when FAMILY_STRATIXV => return "Stratix V";
        when FAMILY_ARRIAV => return "Arria V";
        when FAMILY_CYCLONE => return "Cyclone";
        when FAMILY_CYCLONEII => return "Cyclone II";
        when FAMILY_CYCLONEIII => return "Cyclone III";
        when FAMILY_CYCLONELPS => return "Cyclone LPS";
        when FAMILY_CYCLONEIVGX  => return "Cyclone IV GX";
        when FAMILY_CYCLONEIVE  => return "Cyclone IV E";
        when FAMILY_HARDCOPYII => return "HardCopy II";
        when FAMILY_HARDCOPYIII => return "HardCopy III";
        when FAMILY_HARDCOPYIV => return "HardCopy IV";
		when others => return "Stratix";
		end case;		
	end function family_string;
	
	-- translate a std_logic_vector into a binary string represenation of same
	function to_string(slv : std_logic_vector) return string is
		variable s : string(slv'LENGTH downto 1);
	begin
		for i in slv'HIGH downto slv'LOW loop
			if slv(i) = '1' then
				s(1 + i) := '1';
			else
				s(1 + i) := '0';
			end if;
		end loop;
		return s;
	end function to_string;
	
	function boolean_to_int(value : boolean) return integer is
	begin
		if value then
			return 1;
		else 
			return 0;
		end if;
	end function boolean_to_int;

-- synopsys synthesis_off

  type reg_list_t;
  type reg_list_ptr_t is access reg_list_t;
  type reg_list_t is record
    reg_name : TTA_X_D_string_ptr;
    reg_value : TTA_X_D_slv_ptr;
    next_elem : reg_list_ptr_t;
  end record;


  type fu_list_t;
  type fu_list_ptr_t is access fu_list_t;
  type fu_list_t is record
    fu_name : TTA_X_D_string_ptr;
    reg_values : reg_list_ptr_t;
    next_elem : fu_list_ptr_t;
  end record;


    shared variable fu_state : fu_list_ptr_t := null;
    shared variable fu_state_previous : fu_list_ptr_t := null;
    
    shared variable ENABLE_DEBUG_TRACE : INTEGER := 0;
    
    constant CURRENT_STATE : INTEGER := 0;
    constant PREVIOUS_STATE : INTEGER := 1;


-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
    -----------------------------------------
    -- Convert Integer to Hex
    -----------------------------------------
    FUNCTION TIntegerToHex(i : INTEGER; ndigits : INTEGER) RETURN STRING IS
        VARIABLE s : STRING(1 TO 256) := (others => '0');
        VARIABLE Num, ThisDigit, si : INTEGER;
    BEGIN
        Num := i;
        si := 256;
        WHILE (Num > 0) LOOP
            ThisDigit := Num - ((Num / 16) * 16);
            CASE ThisDigit IS
            WHEN 1 => s(si) := '1';
            WHEN 2 => s(si) := '2';
            WHEN 3 => s(si) := '3';
            WHEN 4 => s(si) := '4';
            WHEN 5 => s(si) := '5';
            WHEN 6 => s(si) := '6';
            WHEN 7 => s(si) := '7';
            WHEN 8 => s(si) := '8';
            WHEN 9 => s(si) := '9';
            WHEN 10 => s(si) := 'A';
            WHEN 11 => s(si) := 'B';
            WHEN 12 => s(si) := 'C';
            WHEN 13 => s(si) := 'D';
            WHEN 14 => s(si) := 'E';
            WHEN 15 => s(si) := 'F';
            WHEN OTHERS  =>  s(si) := '0';
            END CASE;
            si := si - 1;
            Num := Num / 16;
        END LOOP;
        IF (i = 0) THEN
            si := si - 1;
        END IF;
        RETURN s(257-ndigits TO 256);
    END ;
    -----------------------------------------


-- convert integer to string
function TIntegerToString( value : integer ) return string is
variable ivalue : integer := 0;
variable index : integer := 1;
variable digit : integer := 0;
variable temp: string(10 downto 1) := "0000000000";  

begin
    index := 1;
    
    if (value < 0 ) then
      ivalue := -value;
    else
      ivalue := value;
    end if;
    
    while (ivalue > 0) loop
        digit := ivalue mod 10;
        ivalue := ivalue/10;

        case digit is
            when 0 =>    temp(index) := '0';
            when 1 =>    temp(index) := '1';
            when 2 =>    temp(index) := '2';
            when 3 =>    temp(index) := '3';
            when 4 =>    temp(index) := '4';
            when 5 =>    temp(index) := '5';
            when 6 =>    temp(index) := '6';
            when 7 =>    temp(index) := '7';
            when 8 =>    temp(index) := '8';
            when 9 =>    temp(index) := '9';
            when others => ASSERT FALSE
                           REPORT "Illegal number!"
                           SEVERITY ERROR;
        end case;

        index := index + 1;
    end loop;
    
    if value /= 0 then
      index := index - 1;
    end if;

    if (value < 0) then
        return ('-'& temp(index downto 1));
    else
        return temp(index downto 1);
    end if;    
  end ;

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------



    -- search along the state looking for an FU with name fu_name
    -- if not found create a new fu record, set the name, and
    -- place it at the head of the list
    procedure findFU ( fu_name : IN STRING;
                       fu : OUT fu_list_ptr_t ) is
      variable iter : fu_list_ptr_t;
    begin
      iter := fu_state;

      find: loop
        if iter = null then
          iter := new fu_list_t;
          iter.fu_name := new String(fu_name'high downto fu_name'low);
          iter.fu_name.all := fu_name;
          iter.next_elem := fu_state;
          fu_state := iter; 
        end if;
        exit when iter.fu_name.all = fu_name;
        iter := iter.next_elem;
      end loop;      
      fu := iter;
    end;

    -- like FU - works on _previous state
    procedure findFU_previous ( fu_name : IN STRING;
                                fu : OUT fu_list_ptr_t ) is
      variable iter : fu_list_ptr_t;
    begin
      iter := fu_state_previous;

      find: loop
        if iter = null then
          iter := new fu_list_t;
          iter.fu_name := new String(fu_name'high downto fu_name'low);
          iter.fu_name.all := fu_name;
          iter.next_elem := fu_state;
          fu_state_previous := iter; 
        end if;
        exit when iter.fu_name.all = fu_name;
        iter := iter.next_elem;
      end loop;      
      fu := iter;
    end;


    
    -- search along the FU looking for an reg with name reg_name
    -- if not found create a new reg record, set the name, and
    -- place it at the head of the list
    procedure findReg ( fu_name : IN STRING;
                        state : IN INTEGER;
                       reg_name : INOUT TTA_X_D_string_ptr;
                       reg : OUT reg_list_ptr_t ) is
      variable iter : reg_list_ptr_t;
      variable fu : fu_list_ptr_t;
    begin
    
      if state = CURRENT_STATE then
        findFu(fu_name, fu);
      else
        findFu_previous(fu_name, fu);
      end if;
      
      iter := fu.reg_values;
      find: loop
        if iter = null then
          iter := new reg_list_t;
          iter.reg_name := new String(reg_name.all'high downto reg_name.all'low);
          iter.reg_name.all := reg_name.all;
          iter.next_elem := fu.reg_values;
          fu.reg_values := iter;
        end if;
        exit when iter.reg_name.all = reg_name.all;
        iter := iter.next_elem;
      end loop;      
      reg := iter;
    end;


    -- update the value for (fu_name, reg_name) creating a new record if one is needed
    procedure updateReg ( fu_name : IN STRING;
                       state : IN INTEGER;
                       reg_name : INOUT TTA_X_D_string_ptr;
                       reg_value : INOUT TTA_X_D_slv_ptr ) is
      variable reg : reg_list_ptr_t;
    begin
      findReg(fu_name, state, reg_name, reg);
      if reg.reg_value = null then
        reg.reg_value := new std_logic_vector(reg_value.all'high downto reg_value.all'low);
      end if;
      reg.reg_value.all := reg_value.all;
    end;



  PROCEDURE TTA_X_D_registerDump ( 
       fuName : IN STRING;
       registerNames : INOUT  TTA_X_D_RN_T;
       registerValues : INOUT TTA_X_D_RV_T
       ) IS
  BEGIN 
    if ENABLE_DEBUG_TRACE /= 0 then
      for count in registerNames'high downto registerNames'low loop
        updateReg ( fuName, CURRENT_STATE, registerNames(count), registerValues(count) );
      end loop;
    end if; -- debug trace enabled
  END;
    

  -- ----------------------------------------------
  FILE traceFile : TEXT;
  FILE shortTraceFile : TEXT;
  shared variable traceFileOpen : integer := 0;

  PROCEDURE TTA_X_D_openTrace (
      fileName : IN STRING := "trace.out";
      shortFileName : IN STRING := "shorttrace.out"
      ) IS
  BEGIN
    if ENABLE_DEBUG_TRACE /= 0 then
      FILE_OPEN (traceFile, fileName, WRITE_MODE);
      FILE_OPEN (shorttraceFile, shortFileName, WRITE_MODE);
      traceFileOpen := 1;
    end if; -- debug trace enabled
  END;



  -- create / update 
  procedure save_fu_state is
    variable last_fu_iter : fu_list_ptr_t;
    variable last_reg_iter : reg_list_ptr_t;
    variable fu_iter : fu_list_ptr_t;
    variable reg_iter : reg_list_ptr_t;
  begin
    
    fu_iter := fu_state;
    fu_loop: loop
      exit fu_loop when fu_iter = null;

      reg_iter := fu_iter.reg_values;
      reg_loop: loop
        exit reg_loop when reg_iter = null;
        updateReg ( fu_iter.fu_name.all, PREVIOUS_STATE, reg_iter.reg_name, reg_iter.reg_value );
        reg_iter := reg_iter.next_elem;
        end loop;
      fu_iter := fu_iter.next_elem;
    end loop;

  end;


  -- generate trace information for the specified address, opcode, operation
  -- 
  PROCEDURE TTA_X_D_registerTrace (
       opAddress : IN STRING;
       opCode : IN STRING;
       opDecode: IN STRING
       ) IS
    variable fu_iter : fu_list_ptr_t;
    variable reg_iter : reg_list_ptr_t;
    variable l:line;
    variable current_reg_value : reg_list_ptr_t;
  BEGIN

    if ENABLE_DEBUG_TRACE /= 0 then


    if traceFileOpen = 0 then
      TTA_X_D_openTrace;
    end if;


    -- -----------------------------------------------------------
    -- COMPLETE REGISTER DUMP
    -- -----------------------------------------------------------
    fu_iter := fu_state;

    write(l, opAddress);
    write(l, STRING'(" ") );
    write(l, opCode);
    write(l, STRING'(" ") );

    fu_loop: loop
      exit fu_loop when fu_iter = null;

      reg_iter := fu_iter.reg_values;
      reg_loop: loop
        exit reg_loop when reg_iter = null;
        write(l, fu_iter.fu_name.all);
        write(l, STRING'("."));
        write(l, reg_iter.reg_name.all);
        write(l, STRING'("="));
--        write(l, TIntegerToHex(To_Integer(unsigned(reg_iter.reg_value.all)),
--                     (reg_iter.reg_value.all'length+3)/4) );
        if reg_iter.reg_value.all'length = 1 then 
          write(l, TIntegerToString(To_Integer(unsigned(reg_iter.reg_value.all))));
        elsif Is_X(reg_iter.reg_value.all) then
          assert false report ("Register " & fu_iter.fu_name.all & STRING'(".") & reg_iter.reg_name.all & " contains undefined value trace shows 0" ) severity warning;
          write(l, STRING'("."));
        else
          write(l, TIntegerToString(To_Integer(signed(reg_iter.reg_value.all))));
        end if;
        write(l, STRING'(" "));
        reg_iter := reg_iter.next_elem;
        end loop;

      fu_iter := fu_iter.next_elem;
    end loop;

    write(l, opDecode);

    writeline(traceFile, l);


    -- -----------------------------------------------------------
    -- REGISTER CHANGE DUMP
    -- -----------------------------------------------------------
    if fu_state_previous /= null then

        fu_iter := fu_state_previous;
    
        write(l, "0x" & opAddress);
        write(l, STRING'(" ") );
    --    write(l, opCode);
    --    write(l, STRING'(" ") );
        write(l, opDecode);
        writeline(shortTraceFile, l);
    
    
        short_fu_loop: loop
          exit short_fu_loop when fu_iter = null;
    
          reg_iter := fu_iter.reg_values;
          short_reg_loop: loop
            exit short_reg_loop when reg_iter = null;
            
            findReg( fu_iter.fu_name.all, CURRENT_STATE, reg_iter.reg_name, current_reg_value );
    
            if current_reg_value.reg_value /= null and reg_iter.reg_value /= null then
    
              if  current_reg_value.reg_value.all /= reg_iter.reg_value.all then
      
                write(l, fu_iter.fu_name.all);
                write(l, STRING'("."));
                write(l, reg_iter.reg_name.all);
                write(l, STRING'("="));
    --            write(l, TIntegerToHex(To_Integer(unsigned(current_reg_value.reg_value.all)),
    --                       (reg_iter.reg_value.all'length+3)/4) );
    		        if current_reg_value.reg_value.all'length = 1 then 
    		          write(l, TIntegerToString(To_Integer(unsigned(current_reg_value.reg_value.all))));
    		        else
    		          write(l, TIntegerToString(To_Integer(signed(current_reg_value.reg_value.all))));
    		        end if;
                write(l, STRING'(" "));
              end if;
            end if;
    
            reg_iter := reg_iter.next_elem;
            end loop;
    
          fu_iter := fu_iter.next_elem;
        end loop;
    
        writeline(shortTraceFile, l);
    end if;


    -- -----------------------------------------------------------
    -- SAVE STATE TO COMPUTE REGISTER CHANGES
    -- -----------------------------------------------------------
    save_fu_state;

    end if; -- debug trace enabled

  END;

-- synopsys synthesis_on
END ALT_CUSP161_PACKAGE;
