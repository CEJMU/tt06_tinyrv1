library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity regs is
  port (
    clk        : in  std_logic;
    reset      : in  std_logic;

    rs1adr     : in  std_logic_vector(4 downto 0);
    rs2adr     : in  std_logic_vector(4 downto 0);
    rdadr      : in  std_logic_vector(4 downto 0);

    rd         : in  std_logic_vector(31 downto 0);
    regwrite   : in  std_logic;

    rs1        : out std_logic_vector(31 downto 0);
    rs2        : out std_logic_vector(31 downto 0)
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
      rs1 <= (others => '0');
      rs2 <= (others => '0');

    elsif rising_edge(clk) then
      -- Only write, if regwrite is set
      -- Don't write, if the x0 register would be overwritten
      if regwrite = '1' and unsigned(rdadr) /= 0 then
        registers(to_integer(unsigned(rdadr))) <= rd;
      end if;

      rs1 <= registers(to_integer(unsigned(rs1adr)));
      rs2 <= registers(to_integer(unsigned(rs2adr)));
    end if;
  end process;
end architecture;
