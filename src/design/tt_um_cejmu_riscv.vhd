library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tt_um_cejmu_riscv is
  port (
    clk     : in  std_logic;
    ena     : in  std_logic;
    rst_n   : in  std_logic;
    ui_in   : in  std_logic_vector(7 downto 0);
    uo_out  : out std_logic_vector(7 downto 0);
    uio_in  : in  std_logic_vector(7 downto 0);
    uio_out : out std_logic_vector(7 downto 0);
    uio_oe  : out std_logic_vector(7 downto 0)
    );
end entity tt_um_cejmu_riscv;

architecture rtl of tt_um_cejmu_riscv is

  alias mosi         : std_logic is ui_in(0);
  alias program_mode : std_logic is ui_in(1);

  signal mem_write_en   : std_logic;
  signal cpu_addr_out   : std_logic_vector(13 downto 0);
  signal cpu_data_out   : std_logic_vector(31 downto 0);
  signal cpu_write_en   : std_logic;
  signal spi_addr_out   : std_logic_vector(13 downto 0);
  signal spi_data_out   : std_logic_vector(31 downto 0);
  signal spi_data_valid : std_logic;
  signal mem_addr_in    : std_logic_vector(13 downto 0);
  signal mem_data_in    : std_logic_vector(31 downto 0);
  signal reset          : std_logic;

begin

  uo_out  <= cpu_data_out(7 downto 0);
  uio_out <= cpu_data_out(15 downto 8);
  uio_oe  <= cpu_data_out(15 downto 8) and cpu_data_out(31 downto 24) and cpu_data_out(23 downto 16);

  mem_addr_in <= spi_addr_out when spi_data_valid = '1'
                 else cpu_addr_out;

  mem_data_in <= spi_data_out when spi_data_valid = '1'
                 else cpu_data_out;

  mem_write_en <= '1' when spi_data_valid = '1'
                  else cpu_write_en;

  reset <= not rst_n;

  cpu_inst : entity work.cpu (rtl)
    port map (
      clk      => clk,
      reset    => reset,
      data_in  => spi_data_out,
      addr_out => cpu_addr_out,
      data_out => cpu_data_out,
      write_en => cpu_write_en);

  spi_slave_inst : entity work.spi_slave (rtl)
    port map (
      sclk       => clk,
      mosi       => mosi,
      cs         => program_mode,
      addr       => spi_addr_out,
      dataout    => spi_data_out,
      data_valid => spi_data_valid);

end architecture rtl;
