library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity spi_slave_tt06_with_memory is

  port
  (
    sclk  : in std_logic;
    reset : in std_logic;
    mosi  : in std_logic;
    miso  : out std_logic;
    cs    : in std_logic

  );
end entity spi_slave_tt06_with_memory;

architecture rtl of spi_slave_tt06_with_memory is

  signal data_to_memory_zw     : std_logic_vector(31 downto 0);
  signal addr_to_memory_zw     : std_logic_vector(15 downto 0);
  signal data_from_memory_zw   : std_logic_vector(31 downto 0);
  signal mode_select_memory_zw : std_logic;

begin
  slave : entity work.spi_slave_tt06(rtl)
    port map
    (

      sclk               => sclk,
      mosi               => mosi,
      reset              => reset,
      miso               => miso,
      cs                 => cs,
      data_to_memory     => data_to_memory_zw,
      data_from_memory   => data_from_memory_zw,
      addr_to_memory     => addr_to_memory_zw,
      mode_select_memory => mode_select_memory_zw
    );
  memory : entity work.memory(simulation)
    port
    map (

    clk      => sclk,
    reset    => reset,
    addr     => addr_to_memory_zw,
    datain   => data_to_memory_zw,
    dataout  => data_from_memory_zw,
    write_en => mode_select_memory_zw
    );
end architecture;
