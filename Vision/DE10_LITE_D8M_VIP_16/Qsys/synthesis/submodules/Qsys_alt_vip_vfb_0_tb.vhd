-- Qsys_alt_vip_vfb_0_tb.vhd


library IEEE;
library altera;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use altera.alt_cusp161_package.all;

entity Qsys_alt_vip_vfb_0_tb is
end entity Qsys_alt_vip_vfb_0_tb;

architecture rtl of Qsys_alt_vip_vfb_0_tb is
	component alt_cusp161_clock_reset is
		port (
			clock : out std_logic;
			reset : out std_logic
		);
	end component alt_cusp161_clock_reset;

	component Qsys_alt_vip_vfb_0 is
		generic (
			PARAMETERISATION                      : string := "<frameBufferParams><VFB_NAME>MyFrameBuffer</VFB_NAME><VFB_MAX_WIDTH>640</VFB_MAX_WIDTH><VFB_MAX_HEIGHT>480</VFB_MAX_HEIGHT><VFB_BPS>8</VFB_BPS><VFB_CHANNELS_IN_SEQ>3</VFB_CHANNELS_IN_SEQ><VFB_CHANNELS_IN_PAR>1</VFB_CHANNELS_IN_PAR><VFB_WRITER_RUNTIME_CONTROL>0</VFB_WRITER_RUNTIME_CONTROL><VFB_DROP_FRAMES>1</VFB_DROP_FRAMES><VFB_READER_RUNTIME_CONTROL>0</VFB_READER_RUNTIME_CONTROL><VFB_REPEAT_FRAMES>1</VFB_REPEAT_FRAMES><VFB_FRAMEBUFFERS_ADDR>00000000</VFB_FRAMEBUFFERS_ADDR><VFB_MEM_PORT_WIDTH>64</VFB_MEM_PORT_WIDTH><VFB_MEM_MASTERS_USE_SEPARATE_CLOCK>0</VFB_MEM_MASTERS_USE_SEPARATE_CLOCK><VFB_RDATA_FIFO_DEPTH>64</VFB_RDATA_FIFO_DEPTH><VFB_RDATA_BURST_TARGET>32</VFB_RDATA_BURST_TARGET><VFB_WDATA_FIFO_DEPTH>64</VFB_WDATA_FIFO_DEPTH><VFB_WDATA_BURST_TARGET>32</VFB_WDATA_BURST_TARGET><VFB_MAX_NUMBER_PACKETS>0</VFB_MAX_NUMBER_PACKETS><VFB_MAX_SYMBOLS_IN_PACKET>10</VFB_MAX_SYMBOLS_IN_PACKET><VFB_INTERLACED_SUPPORT>0</VFB_INTERLACED_SUPPORT><VFB_CONTROLLED_DROP_REPEAT>0</VFB_CONTROLLED_DROP_REPEAT><VFB_BURST_ALIGNMENT>0</VFB_BURST_ALIGNMENT><VFB_DROP_INVALID_FIELDS>0</VFB_DROP_INVALID_FIELDS></frameBufferParams>";
			AUTO_DEVICE_FAMILY                    : string := "";
			AUTO_READER_CONTROL_CLOCKS_SAME       : string := "0";
			AUTO_READ_MASTER_CLOCKS_SAME          : string := "0";
			AUTO_READ_MASTER_INTERRUPT_USED_MASK  : string := "-1";
			AUTO_READ_MASTER_MAX_READ_LATENCY     : string := "2";
			AUTO_READ_MASTER_NEED_ADDR_WIDTH      : string := "62";
			AUTO_WRITER_CONTROL_CLOCKS_SAME       : string := "0";
			AUTO_WRITE_MASTER_CLOCKS_SAME         : string := "0";
			AUTO_WRITE_MASTER_INTERRUPT_USED_MASK : string := "-1";
			AUTO_WRITE_MASTER_MAX_READ_LATENCY    : string := "2";
			AUTO_WRITE_MASTER_NEED_ADDR_WIDTH     : string := "62"
		);
		port (
			clock                        : in  std_logic                     := 'X';
			din_data                     : in  std_logic_vector(23 downto 0) := (others => 'X');
			din_endofpacket              : in  std_logic                     := 'X';
			din_ready                    : out std_logic;
			din_startofpacket            : in  std_logic                     := 'X';
			din_valid                    : in  std_logic                     := 'X';
			dout_data                    : out std_logic_vector(23 downto 0);
			dout_endofpacket             : out std_logic;
			dout_ready                   : in  std_logic                     := 'X';
			dout_startofpacket           : out std_logic;
			dout_valid                   : out std_logic;
			read_master_av_address       : out std_logic_vector(31 downto 0);
			read_master_av_burstcount    : out std_logic_vector(2 downto 0);
			read_master_av_read          : out std_logic;
			read_master_av_readdata      : in  std_logic_vector(31 downto 0) := (others => 'X');
			read_master_av_readdatavalid : in  std_logic                     := 'X';
			read_master_av_waitrequest   : in  std_logic                     := 'X';
			reset                        : in  std_logic                     := 'X';
			write_master_av_address      : out std_logic_vector(31 downto 0);
			write_master_av_burstcount   : out std_logic_vector(2 downto 0);
			write_master_av_waitrequest  : in  std_logic                     := 'X';
			write_master_av_write        : out std_logic;
			write_master_av_writedata    : out std_logic_vector(31 downto 0)
		);
	end component Qsys_alt_vip_vfb_0;

	signal dut_din_ready     : std_logic;                    -- dut:din_ready -> din_tester:data
	signal din_tester_q      : std_logic_vector(0 downto 0); -- din_tester:q -> dut:din_valid
	signal builtin_1_w1_q    : std_logic_vector(0 downto 0); -- ["1", builtin_1_w1:q, "1"] -> [din_tester:ena, dut:dout_ready]
	signal clocksource_clock : std_logic;                    -- clocksource:clock -> [dut:clock, din_tester:clock]
	signal clocksource_reset : std_logic;                    -- clocksource:reset -> din_tester:reset

begin

	builtin_1_w1_q <= "1";

	clocksource : component alt_cusp161_clock_reset
		port map (
			clock => clocksource_clock, -- clock.clk
			reset => clocksource_reset  --      .reset
		);

	dut : component Qsys_alt_vip_vfb_0
		generic map (
			PARAMETERISATION                      => "<frameBufferParams><VFB_NAME>MyFrameBuffer</VFB_NAME><VFB_MAX_WIDTH>640</VFB_MAX_WIDTH><VFB_MAX_HEIGHT>480</VFB_MAX_HEIGHT><VFB_BPS>8</VFB_BPS><VFB_CHANNELS_IN_SEQ>1</VFB_CHANNELS_IN_SEQ><VFB_CHANNELS_IN_PAR>3</VFB_CHANNELS_IN_PAR><VFB_WRITER_RUNTIME_CONTROL>false</VFB_WRITER_RUNTIME_CONTROL><VFB_DROP_FRAMES>true</VFB_DROP_FRAMES><VFB_READER_RUNTIME_CONTROL>0</VFB_READER_RUNTIME_CONTROL><VFB_REPEAT_FRAMES>true</VFB_REPEAT_FRAMES><VFB_FRAMEBUFFERS_ADDR>00000000</VFB_FRAMEBUFFERS_ADDR><VFB_MEM_PORT_WIDTH>32</VFB_MEM_PORT_WIDTH><VFB_MEM_MASTERS_USE_SEPARATE_CLOCK>false</VFB_MEM_MASTERS_USE_SEPARATE_CLOCK><VFB_RDATA_FIFO_DEPTH>1024</VFB_RDATA_FIFO_DEPTH><VFB_RDATA_BURST_TARGET>4</VFB_RDATA_BURST_TARGET><VFB_WDATA_FIFO_DEPTH>1024</VFB_WDATA_FIFO_DEPTH><VFB_WDATA_BURST_TARGET>4</VFB_WDATA_BURST_TARGET><VFB_MAX_NUMBER_PACKETS>1</VFB_MAX_NUMBER_PACKETS><VFB_MAX_SYMBOLS_IN_PACKET>10</VFB_MAX_SYMBOLS_IN_PACKET><VFB_INTERLACED_SUPPORT>0</VFB_INTERLACED_SUPPORT><VFB_CONTROLLED_DROP_REPEAT>0</VFB_CONTROLLED_DROP_REPEAT><VFB_BURST_ALIGNMENT>0</VFB_BURST_ALIGNMENT><VFB_DROP_INVALID_FIELDS>false</VFB_DROP_INVALID_FIELDS></frameBufferParams>",
			AUTO_DEVICE_FAMILY                    => "MAX 10",
			AUTO_READER_CONTROL_CLOCKS_SAME       => "0",
			AUTO_READ_MASTER_CLOCKS_SAME          => "0",
			AUTO_READ_MASTER_INTERRUPT_USED_MASK  => "0",
			AUTO_READ_MASTER_MAX_READ_LATENCY     => "2",
			AUTO_READ_MASTER_NEED_ADDR_WIDTH      => "27",
			AUTO_WRITER_CONTROL_CLOCKS_SAME       => "0",
			AUTO_WRITE_MASTER_CLOCKS_SAME         => "0",
			AUTO_WRITE_MASTER_INTERRUPT_USED_MASK => "0",
			AUTO_WRITE_MASTER_MAX_READ_LATENCY    => "2",
			AUTO_WRITE_MASTER_NEED_ADDR_WIDTH     => "27"
		)
		port map (
			clock                        => clocksource_clock, --        clock.clk
			reset                        => open,              --        reset.reset
			din_ready                    => dut_din_ready,     --          din.ready
			din_valid                    => din_tester_q(0),   --             .valid
			din_data                     => open,              --             .data
			din_startofpacket            => open,              --             .startofpacket
			din_endofpacket              => open,              --             .endofpacket
			dout_ready                   => '1',               --         dout.ready
			dout_valid                   => open,              --             .valid
			dout_data                    => open,              --             .data
			dout_startofpacket           => open,              --             .startofpacket
			dout_endofpacket             => open,              --             .endofpacket
			read_master_av_address       => open,              --  read_master.address
			read_master_av_read          => open,              --             .read
			read_master_av_waitrequest   => open,              --             .waitrequest
			read_master_av_readdatavalid => open,              --             .readdatavalid
			read_master_av_readdata      => open,              --             .readdata
			read_master_av_burstcount    => open,              --             .burstcount
			write_master_av_address      => open,              -- write_master.address
			write_master_av_write        => open,              --             .write
			write_master_av_writedata    => open,              --             .writedata
			write_master_av_waitrequest  => open,              --             .waitrequest
			write_master_av_burstcount   => open               --             .burstcount
		);

	din_tester : process (clocksource_clock, clocksource_reset)
	begin
		if clocksource_reset = '1' then
			din_tester_q(0) <= '0';
		elsif clocksource_clock'EVENT and clocksource_clock = '1' and builtin_1_w1_q(0) = '1' then
			din_tester_q(0) <= dut_din_ready;
		end if;
	end process;

end architecture rtl; -- of Qsys_alt_vip_vfb_0_tb
