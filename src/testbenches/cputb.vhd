library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cputb is
end entity;

architecture rtl of cputb is

    signal clk : std_logic := '0';
    signal reset : std_logic := '1';
    signal fetchnew : std_logic;

    signal finished : std_logic := '0';

    type reg_array is array (0 to 9) of std_logic_vector(31 downto 0);
    signal iwords : reg_array := (
    -- ADDI x1, x1, 5 | 0
    "000000000101" & "00001" & "000" & "00001" & "0010011",
    -- ADD x2, x0, x1 | 8
    "0000000" & "00001" & "00000" & "000" & "00010" & "0110011",
    -- MUL x3, x2, x1 | 16
    "0000001" & "00001" & "00010" & "000" & "00011" & "0110011",
    -- SW x3, 4(x0) | 24
    "0000000" & "00011" & "00000" & "010" & "00100" & "0100011",
    -- LW x4, 4(x0) | 32
    "000000000100" & "00000" & "010" & "00100" & "0000011",
    -- BNE x1, x0, -40 | 40
    "1111110" & "00001" & "00000" & "001" & "11000" & "1100011",
    "0000001" & "00001" & "00010" & "000" & "00101" & "0110011",
    "0000001" & "00001" & "00010" & "000" & "00011" & "0110011",
    "0000001" & "00001" & "00010" & "000" & "00011" & "0110011",
    "0000001" & "00001" & "00010" & "000" & "00011" & "0110011"
    );

    signal iword : std_logic_vector(31 downto 0) := iwords(0);
    signal rdTMP : std_logic_vector(31 downto 0);
    signal q0_q3 : std_logic_vector(15 downto 0);

begin

    -- process (q0_q3)
    --     variable counter : natural := 0;
    -- begin
    --     counter := counter + 1;
    --     if counter > 10 then
    --         finished <= '1';
    --     end if;

    --     if to_integer(unsigned(q0_q3))/8 < 10 then
    --         iword <= iwords(to_integer(unsigned(q0_q3)/8));
    --     else
    --         finished <= '1';
    --     end if;
    -- end process;

    process(clk)
        variable counter : natural := 0;

    begin
        if rising_edge(clk) then
            counter := counter + 1;

            if counter > 100 then
                finished <= '1';
            end if;
        end if;
    end process;

    dut: entity work.cpu(rtl)
    port map (
        clk => clk,
        reset => reset,
        -- iword => iword,
        rdTMP => rdTMP
        -- q0_q3 => q0_q3
    );


    reset <= '0' after 5 ns;

    clk <= not clk after 10 ns when finished = '0';


end architecture;
