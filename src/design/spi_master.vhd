library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity SPI_Master is

    port
    (

        clk         : in std_logic;                    -- FPGA CLK
        sclk        : out std_logic;                   -- SPI_CLK                                   
        mode_select : in std_logic_vector(1 downto 0); -- Read := 0 or Write:= 1 

        reset : in std_logic;
        mosi  : out std_logic;
        miso  : in std_logic;
        cs    : in std_logic;                          -- needed for one clk cycle

        data_out : out std_logic_vector(31 downto 0);

        data_in : in std_logic_vector(31 downto 0);
        addr    : in std_logic_vector(15 downto 0);

        data_valid : out std_logic
    );
end entity SPI_Master;

architecture rtl of SPI_Master is

    --constant sclk_modify : integer := 8;                -- To modify sclk
    --variable counter : integer := 1;
    signal clock_polarity : std_logic := '1';

    signal data_reg : std_logic_vector(31 downto 0);
    signal valid    : std_logic;

    signal data_in_reg    : std_logic_vector(31 downto 0);
    signal adress_in_reg  : std_logic_vector(15 downto 0);
    signal cs_counter     : integer := 47;
    signal mode_select_zw : std_logic_vector(1 downto 0);

begin

    data_in_reg    <= data_in when cs = '1'; -- else data_in_reg <= data_in_reg;
    adress_in_reg  <= addr when cs = '1';
    data_valid     <= not(valid);
    sclk           <= clock_polarity;
    valid          <= '1' when cs = '1' and cs_counter >= 0 else '0';
    mode_select_zw <= "00" when reset = '1' else "01" when mode_select = "01" and cs = '1' and cs_counter = 47 else "10" when mode_select = "10" and cs = '1';
    -- SCLK Generator

    process (clk)
        constant sclk_modif   : integer := 3; -- To modify sclk : sclk = sclk_modify * clk_period/2 
        variable sclk_counter : integer := 0;
    begin

        if (reset = '1') then
            clock_polarity <= '0';

        elsif (rising_edge(clk) and valid = '1') then

            if (sclk_counter = sclk_modif - 1) then
                clock_polarity <= (clock_polarity xor '1');
                sclk_counter := 0;

                if (cs_counter >= 0) then
                    cs_counter      <= cs_counter - 1;
                else cs_counter <= 47;
                end if;
            else sclk_counter := sclk_counter + 1;
            end if;

        else if (falling_edge(clk) and valid = '1') then

            if (sclk_counter = sclk_modif - 1) then
                clock_polarity <= (clock_polarity xor '1');
                sclk_counter      := 0;
            else sclk_counter := sclK_counter + 1;
            end if;
        end if;
    end if;
end process;

-- Write Phase 

process (clock_polarity)

begin

    if (reset = '1') then
        mosi <= '0';
    elsif (rising_edge(clock_polarity) and mode_select_zw = "01" and valid = '1') then
        if (cs_counter > 31 and cs_counter < 47) then
            mosi            <= addr(cs_counter - 31);
        elsif (cs_counter <= 31 and cs_counter >= 0) then
            mosi              <= data_in(cs_counter);
        end if;
    end if;
end process;

-- Read Phase

process (clock_polarity)

begin
    -- send address
    if (rising_edge(clock_polarity) and mode_select = "10" and valid = '1') then
        if (cs_counter > 31 and cs_counter < 47) then
            mosi                 <= addr(cs_counter - 31);
        elsif (cs_counter    <= 31 and cs_counter >= 0) then
            data_reg(cs_counter) <= miso;
        elsif (cs_counter < 0) then
            data_out <= data_reg;
        end if;
    end if;
end process;

end architecture rtl;
