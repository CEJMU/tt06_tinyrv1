library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity memory is
  port (
    clk        : in  std_logic;
    reset      : in  std_logic;

    addr       : in  std_logic_vector(15 downto 0);
    datain     : in  std_logic_vector(31 downto 0);
    write_en   : in  std_logic;

    dataout    : out std_logic_vector(31 downto 0)
  );
end entity;

architecture simulation of memory is

  type mem_array is array(0 to (2**16) - 1 ) of std_logic_vector(31 downto 0);
  signal mem : mem_array := (others => (others => '0'));


begin
  process (clk, reset) begin

    if(reset = '1')then
      mem(0 to 12) <= ("10010011100000000101000000000000",
      "00010011000000010010000000000000",
      "10110011000000010001000100000000",
      "10110011010000100001000100000000",
      "00110011011100110001000100000000",
      "10100011001001110011000000000000",
      "00000011001000101111000000000000",
      "11101111000000111000000000000000",
      "10100011001001110000000000000000",
      "10010011000001000000000000000011",
      "01100111100000000000010000000000",
      "10100011001001110000000000000000",
      "01100011000000000001000000000000");
      end if;

    if rising_edge(clk) then

      
      if write_en = '1' then
        mem(to_integer(unsigned(addr))) <= datain;
      end if;

      dataout <= mem(to_integer(unsigned(addr)));
    end if;
  end process;



end architecture;