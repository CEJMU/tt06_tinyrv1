library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cputb is
end entity;

architecture rtl of cputb is

    signal clk      : std_logic := '0';
    signal reset    : std_logic := '1';
    signal fetchnew : std_logic;

    signal finished : std_logic := '0';

    type reg_array is array (0 to 9) of std_logic_vector(31 downto 0);
    signal iwords : reg_array := (
        -- ADDI x1, x0, 5 | 0
        "000000000101" & "00000" & "000" & "00001" & "0010011",
        -- ADDI x2, x0, 2 | 0
        "000000000010" & "00000" & "000" & "00010" & "0010011",
        -- ADD x3, x2, x1 | 8
        "0000000" & "00001" & "00010" & "000" & "00011" & "0110011",
        "0000000" & "00001" & "00000" & "000" & "00000" & "0110011",
        "0000000" & "00001" & "00000" & "000" & "00000" & "0110011",
        "0000000" & "00001" & "00000" & "000" & "00000" & "0110011",
        "0000000" & "00001" & "00000" & "000" & "00000" & "0110011",
        "0000000" & "00001" & "00000" & "000" & "00000" & "0110011",
        "0000000" & "00001" & "00000" & "000" & "00000" & "0110011",
        "0000000" & "00001" & "00000" & "000" & "00000" & "0110011"
        );

    signal iword : std_logic_vector(31 downto 0) := iwords(0);
    signal rdTMP : std_logic_vector(31 downto 0);
    signal addr  : std_logic_vector(13 downto 0);

begin

    dut : entity work.cpu(rtl)
        port map (
            clk      => clk,
            reset    => reset,
            data_in  => iword,
            addr_out => addr
            );

    process (addr)
    begin
        if to_integer(unsigned(addr)) < 10 then
            iword <= iwords(to_integer(unsigned(addr)));
        end if;
    end process;

    process(clk)
        variable counter : natural := 0;

    begin
        if rising_edge(clk) then
            counter := counter + 1;

            if counter > 300 then
                finished <= '1';
            end if;
        end if;
    end process;

    reset <= '0' after 5 ns;

    clk <= not clk after 10 ns when finished = '0';


end architecture;
