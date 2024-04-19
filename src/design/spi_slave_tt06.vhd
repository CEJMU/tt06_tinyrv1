library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity spi_slave_tt06 is

    port
    (

        sclk  : in std_logic;
        reset : in std_logic;
        mosi  : in std_logic;
        miso  : out std_logic;
        cs    : in std_logic;

        data_to_memory     : out std_logic_vector(31 downto 0);
        addr_to_memory     : out std_logic_vector(15 downto 0);
        data_from_memory   : in std_logic_vector(31 downto 0);
        mode_select_memory : out std_logic

    );
end entity spi_slave_tt06;

architecture rtl of spi_slave_tt06 is

    signal mode_select_zw : std_logic;
    type states is (rst, receive_adress, read_data, write_data, data);
    signal currstate            : states;
    signal data_to_memory_reg   : std_logic_vector(31 downto 0);
    signal addr_register        : std_logic_vector(15 downto 0);
    signal write_adress_counter : integer := 16;
    signal data_counter         : integer := 31;
    signal data_reg             : std_logic_vector(31 downto 0);
    signal data_to_master       : std_logic_vector(31 downto 0);

begin
    process (sclk)

    begin

        if (cs = '1' or reset = '1') then
            currstate <= rst;

        elsif (rising_edge(sclk)) then

            if (currstate = rst) then
                miso                 <= '0';
                data_to_memory       <= (others => '0');
                addr_register        <= (others => '0');
                mode_select_zw       <= '0';
                data_to_memory       <= (others => '0');
                write_adress_counter <= 17;
                data_counter         <= 33;
                addr_to_memory       <= (others => '0');
                data_to_master       <= (others => '0');
                data_to_memory_reg   <= (others => '0');

                if (cs = '0') then
                    currstate <= receive_adress;
                end if;
            end if;

            if (currstate = receive_adress) then
                if (write_adress_counter >= 17) then
                    write_adress_counter                                     <= write_adress_counter - 1;
                elsif(write_adress_counter = 16)then
                    mode_select_zw                                           <= mosi;
                    write_adress_counter                                     <= write_adress_counter - 1;
                elsif (write_adress_counter > 0 and write_adress_counter <= 15) then
                    addr_register (write_adress_counter)                     <= mosi;
                    write_adress_counter                                     <= write_adress_counter - 1;
                else addr_register(write_adress_counter)                 <= mosi;
                     addr_to_memory <= addr_register(15 downto 1) & mosi;
                     mode_select_memory <= mode_select_zw;      
                    if (mode_select_zw = '0') then
                        currstate <= read_data;
                        data_counter <= 33;
                    elsif (mode_select_zw = '1') then
                        currstate <= write_data;
                        data_counter <= 31;
                    end if;
                end if;
            end if;

            if (currstate = read_data) then
                if (data_counter >= 32) then
                    data_reg <= data_from_memory;
                    data_counter       <= data_counter - 1;
                    --addr_to_memory <= addr_register(15 downto 1) & mosi;         
                elsif (data_counter > 0 and data_counter <= 31) then
                    data_counter <= data_counter - 1;
                    miso         <= data_reg(data_counter);
                else currstate <= data;
                    miso           <= data_reg(data_counter);
                end if;
            end if;

            if (currstate = write_data) then
                if (data_counter > 32) then
                    data_counter       <= data_counter - 1;
                   -- addr_to_memory     <= addr_register;
                elsif (data_counter > 31) then
                    data_counter <= data_counter - 1;
                elsif (data_counter > 0) then
                    data_to_memory_reg(data_counter) <= mosi;
                    data_counter                     <= data_counter - 1;
                else currstate                   <= data;
                    data_to_memory_reg(data_counter) <= mosi;
                end if;
            end if;

            if (currstate = data) then
                data_to_memory <= data_to_memory_reg;
                currstate      <= rst;
                --mode_select_memory <= mode_select_zw;
            end if;
        end if;

    end process;
end architecture;
