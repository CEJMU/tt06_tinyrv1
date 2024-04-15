library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.commons.all;


entity spi_mastertb is
end entity spi_mastertb;

architecture rtl of SPI_Mastertb is

-- To test set slck_modif to 3 
    signal CLK : std_logic := '0';
    signal reset : std_logic;
    signal sclk : STD_LOGIC := '0';             
    signal cs: std_logic;
    signal mosi : std_logic:= '0';
    signal miso : std_logic := '0';
    signal mode_select : std_logic_vector(1 downto 0);
    signal data_out : STD_LOGIC_VECTOR(31 downto 0);
    signal data_in : STD_LOGIC_VECTOR(31 downto 0);
    signal addr :  STD_LOGIC_VECTOR(15 downto 0);
  
    signal data_valid : STD_LOGIC := '0';

    signal finished: STD_LOGIC := '0';
    constant half_period: time := 10 ns;

    type spi_master_test_vector is record
    addr     : std_logic_vector(15 downto 0);
    data_in  : std_logic_vector(31 downto 0);
    data_out : std_logic_vector(31 downto 0);
    miso     : std_logic_vector(31 downto 0);
  end record;

  type spitest_vector_array is array (natural range <>) of spi_master_test_vector;
  constant test_vectors   : spitest_vector_array := (
    -- addr_in          data_in      data_out     miso
    (x"0000", x"A00000FF", x"FF0000A0", x"AAAAAAAA"),
    (x"AAAA", x"10BAC109", x"09C1BA10", x"AAAAAAAA")
    );

begin

    dut : entity work.spi_master(rtl)
    port map(
      clk         => clk,
      sclk        => sclk,
      cs   => cs,
      mosi => mosi,
      miso => miso,
      data_out => data_out,
      data_in => data_in,
      mode_select => mode_select,
      data_valid => data_valid,
      addr => addr,
      reset => reset
      );

      tb : process
      begin
        reset <= '1';
        wait for period;
        reset <= '0';


      for j in test_vectors'range loop

        wait for period;
        -- write mode

        cs <= '1';
        mode_select <= "01"; 
        addr <= test_vectors(j).addr;
        data_in <= test_vectors(j).data_in;

        write_addr : for i in 15 downto 0 loop
          wait for sclk_period;
          assert(addr(i) = mosi)
          report "Test failed during writing addr in write mode at bit" 
          severity error; 
        end loop ;

        write_data_2 : for i in 31 downto 0 loop
          wait for sclk_period;
          assert(data_in(i) = mosi)
          report "Test failed during writing data in write mode"
          severity failure; 
        end loop ;
        end loop;


        for j in test_vectors'range loop

          wait for period;
          -- read mode
  
          cs <= '1';
          mode_select <= "10"; 
          addr <= test_vectors(j).addr;
          data_in <= test_vectors(j).data_in;
  
          write_addr_1 : for i in 15 downto 0 loop
            wait for sclk_period;
            assert(addr(i) = mosi)
            report "Test failed during writing addr in write mode"
            severity failure; 
          end loop ;
  
          write_data : for i in 31 downto 0 loop
            wait for sclk_period;
            miso <= test_vectors(j).miso(i);
            report "Test failed during writing data in write mode"
            severity failure; 
          end loop ;
          wait for sclk_period;
          assert(data_valid = '1')
          report "Valid was not 1 after transmission"
          severity failure;
          
          assert (data_out = test_vectors(j).miso)
          report "Transimtted data is not equal to data_out" & "expected" & slv_to_hexstring(test_vectors(j).miso) & "but was" & slv_to_hexstring(data_out)
          severity failure;
          end loop;
  
      end process;
    
      clk <= not clk after half_period when finished = '0';
    
    
    

    


end architecture rtl;