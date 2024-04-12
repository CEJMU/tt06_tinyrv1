library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity regs is
  port (
    clk   : in std_logic;
    reset : in std_logic;

    addr     : in std_logic_vector(4 downto 0);
    datain   : in std_logic_vector(31 downto 0);
    regwrite : in std_logic;

    dataout : out std_logic_vector(31 downto 0)
    );
end entity;

architecture rtl of regs is

  type reg_array is array (0 to 31) of std_logic_vector(31 downto 0);
  signal registers : reg_array := (others => (others => '0'));

begin
  process (clk, reset)
  begin
    if reset = '1' then
      -- Reset Outputs
      dataout <= (others => '0');

    elsif rising_edge(clk) then
      -- Only write, if regwrite is set
      -- Don't write, if the x0 register would be overwritten
      if regwrite = '1' then
        if unsigned(addr) /= 0 then
          registers(to_integer(unsigned(addr))) <= datain;
        end if;
      else
        dataout <= registers(to_integer(unsigned(addr)));
      end if;

    end if;
  end process;
end architecture;
