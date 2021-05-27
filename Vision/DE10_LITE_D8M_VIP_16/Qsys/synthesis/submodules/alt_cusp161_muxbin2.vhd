-- alt_cusp161_muxbin2.vhd

library ieee, altera;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity alt_cusp161_muxbin2 is
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
end entity;


architecture rtl of alt_cusp161_muxbin2 is
begin
    assert PORTS <= 2
        report "PORTS generic must be 2 or less"
        severity ERROR;

with sel select
    q <= data0   when '0',
         data1   when '1',
         (others => 'X') when others;

end architecture;
