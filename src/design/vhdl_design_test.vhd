library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity vhdl_design_test is
  port (
    clk     : in  std_logic;
    reset   : in  std_logic;
    ena     : in std_logic
   
  );
end entity vhdl_design_test;

architecture rtl of vhdl_design_test is

  signal sclk_zw : std_logic;
  signal mosi_zw : std_logic;
  signal miso_zw : std_logic;
  signal cs : std_logic;
  signal reg : std_logic_vector(12 downto 0);
  signal meta : std_logic_vector(7 downto 0);
  signal meta1 : std_logic_vector(7 downto 0);
  signal uo_out_zw : std_logic_vector(7 downto 0);
  signal uio_out_zw : std_logic_vector(7 downto 0);
  signal ui_in_zw : std_logic_vector(7 downto 0);
  signal uio_in_zw : std_logic_vector(7 downto 0);
  signal reset_zw : std_logic;

  begin

 
    ui_in_zw(7 downto 1) <="0000000"; 
    uio_in_zw <= "00000000";
    reset_zw <= not(reset);

    cs <= uo_out_zw(2);
    sclk_zw <= uo_out_zw(1);
    mosi_zw <= uo_out_zw(0);
    reg(4 downto 0) <= uo_out_zw(7 downto 3);
    reg(12 downto 5) <= uio_out_zw;

    tt_um_cejmu_riscv_inst: entity work.tt_um_cejmu_riscv
     port map(
        clk => clk,
        ena => ena,
        rst_n => reset_zw,
        ui_in =>  ui_in_zw,
        uo_out => uo_out_zw,
        uio_out => uio_out_zw,
        uio_in => "00000000"
    );



    spi_slave_tt06_with_memory_inst: entity work.spi_slave_tt06_with_memory
     port map(
        sclk => clk,
        reset => reset,
        mosi => uo_out_zw(0),
        miso => ui_in_zw(0),
        cs => uo_out_zw(2)
    );


end architecture rtl;