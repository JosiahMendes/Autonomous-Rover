-- alt_cusp161_muxhot16.vhd

library ieee, altera;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity alt_cusp161_muxhot16 is
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
end entity;


architecture rtl of alt_cusp161_muxhot16 is
    signal masks : STD_LOGIC_VECTOR(16 downto 0);
begin
    assert PORTS <= 16
        report "PORTS generic must be 16 or less"
        severity ERROR;

    unused_mask_gen: masks(16 downto PORTS) <= (others=>'0');
	used_mask_gen:   masks(PORTS-1 downto 0) <= sel;

with masks select
    q <= data0   when "00000000000000001",
         data1   when "00000000000000010",
         data2   when "00000000000000100",
         data3   when "00000000000001000",
         data4   when "00000000000010000",
         data5   when "00000000000100000",
         data6   when "00000000001000000",
         data7   when "00000000010000000",
         data8   when "00000000100000000",
         data9   when "00000001000000000",
         data10  when "00000010000000000",
         data11  when "00000100000000000",
         data12  when "00001000000000000",
         data13  when "00010000000000000",
         data14  when "00100000000000000",
         data15  when "01000000000000000",
         (others => '0') when "00000000000000000",
         (others => 'X') when others;

end architecture;
