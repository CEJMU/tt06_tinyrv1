library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity spi_master is

    port
    (

        clk         : in std_logic; 
        sclk        : out std_logic; 
        mode_select : in std_logic; 

        reset : in std_logic;
        mosi  : out std_logic;
        miso  : in std_logic;
        cs    : in std_logic; 

        data_out : out std_logic_vector(31 downto 0);
        data_in : in std_logic_vector(31 downto 0);
        addr    : in std_logic_vector(15 downto 0);

        data_valid : out std_logic
    );
end entity spi_master;

architecture rtl of spi_master is

    signal clock_polarity : std_logic := '0';

    signal data_reg : std_logic_vector(31 downto 0);
    signal data_in_reg : std_logic_vector(31 downto 0);
    signal mode_select_zw : std_logic;

    signal write_adress_counter : integer := 16;
    signal read_counter  : integer := 33;

    signal write_counter : integer := 31;

    type states is (rst, send_adress, write_data, read_data, data);
    signal currstate : states;

begin

process (clk)

begin

    if (reset = '1') then
        currstate <= rst;

    elsif (rising_edge(clk)) then

        if (currstate = rst) then
            mosi                 <= '0';
            mode_select_zw       <= '0';
            data_out             <= (others => '0');
            data_reg             <= (others => '0');
            write_adress_counter <= 16;    
            read_counter  <= 35;
            write_counter        <= 31;
            data_valid           <= '0';
            data_in_reg <= (others => '0');

            if (cs = '0') then
                currstate      <= send_adress;
                mode_select_zw <= mode_select;
                data_in_reg <= data_in(7 downto 0) & data_in(15 downto 8) & data_in(23 downto 16) & data_in(31 downto 24);
            end if;

        elsif (currstate = send_adress) then
            if (write_adress_counter = 16) then
                mosi <= mode_select_zw;
                write_adress_counter <= write_adress_counter - 1;
            elsif(write_adress_counter > 0 and write_adress_counter <= 15) then
                mosi                 <= addr(write_adress_counter);
                write_adress_counter <= write_adress_counter - 1;
            else
                mosi            <= addr(write_adress_counter);
                if (mode_select_zw = '0') then
                    currstate <= read_data;
                elsif (mode_select_zw = '1') then
                    currstate <= write_data;
                end if;

            end if;

        elsif (currstate = read_data) then
            if (read_counter >= 32) then
                read_counter <= read_counter - 1;

            elsif (read_counter > 0) then
                data_reg(read_counter) <= miso;
                read_counter           <= read_counter - 1;
            else
                currstate                <= data;
                data_reg(read_counter) <= miso;
            end if;

        elsif (currstate = write_data) then
            if(write_counter > 31)then
                write_counter <= write_counter -1;
            elsif (write_counter > 0) then
                mosi                <= data_in(write_counter);
                write_counter <= write_counter - 1;
            else
                currstate      <= data;
                mosi                <= data_in(write_counter);
            end if;

        elsif (currstate = data) then
            data_valid <= '1';
            data_out   <= data_reg(7 downto 0) & data_reg(15 downto 8) & data_reg(23 downto 16) & data_reg(31 downto 24);
            currstate  <= rst;
        end if;
    end if;
end process;

sclk <= clk;

end architecture rtl;
