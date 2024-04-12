library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cpu is
  port(
    clk     : in std_logic;
    reset   : in std_logic;
    data_in : in std_logic_vector(31 downto 0);

    data_out : out std_logic_vector(31 downto 0);
    addr_out : out std_logic_vector(13 downto 0);
    write_en : out std_logic
    );
end entity;

architecture rtl of cpu is

  -- Instructioncounter
  signal s0 : std_logic;
  signal s1 : std_logic;

  -- Decode Outputs (decode --> register, alu, control)
  signal imm               : std_logic_vector(31 downto 0);
  signal control_flags_out : std_logic_vector(6 downto 0);

  -- Alu operands (register --> alu)
  signal rs1         : std_logic_vector(31 downto 0);
  signal rs2         : std_logic_vector(31 downto 0);
  signal reg_datain  : std_logic_vector(31 downto 0);
  signal reg_dataout : std_logic_vector(31 downto 0);
  signal reg_addr    : std_logic_vector(4 downto 0);

  -- Alu inputs
  signal a : std_logic_vector(31 downto 0);
  signal b : std_logic_vector(31 downto 0);

  -- Outputs of Alu and Memory
  -- MUX decides which one is the register input rd
  signal rdAlu : std_logic_vector(31 downto 0);

  -- Register Input
  signal rd : std_logic_vector(31 downto 0);

  -- Control Flags (control --> register, instructioncounter, memory, TODO: Komponente zum fetchen)
  signal wbflag    : std_logic := '0';
  signal memflag   : std_logic := '0';
  signal pcflag    : std_logic := '0';
  signal fetchflag : std_logic := '0';

  signal iword_reg   : std_logic_vector(31 downto 0);
  signal instruction : std_logic_vector(16 downto 0);

  signal pc_inc : std_logic_vector(15 downto 0);
  signal pc_out : std_logic_vector(15 downto 0);

  alias rs1adr : std_logic_vector(4 downto 0) is iword_reg(19 downto 15);
  alias rs2adr : std_logic_vector(4 downto 0) is iword_reg(24 downto 20);
  alias rdadr  : std_logic_vector(4 downto 0) is iword_reg(11 downto 7);

  alias mem_phase : std_logic is control_flags_out(0);
  alias mem_write : std_logic is control_flags_out(1);
  alias reg_write : std_logic is control_flags_out(2);
  alias imm_as_a  : std_logic is control_flags_out(3);
  alias jump      : std_logic is control_flags_out(4);
  alias read_rs1  : std_logic is control_flags_out(5);
  alias read_rs2  : std_logic is control_flags_out(6);
  alias rState    : std_logic_vector(1 downto 0) is control_flags_out(6 downto 5);

begin
  instruction <= iword_reg(31 downto 25) & iword_reg(14 downto 12) & iword_reg(6 downto 0);

  reg_addr <= rs1adr when rState = "00"
              else rs2adr when rState = "01"
              else rdadr;


  -- rs1 <= reg_dataout when rState = "01";
  -- rs2 <= reg_dataout when rState = "10";

  process(clk, reset)
  begin
    if rising_edge(clk) then
      if rState = "01" then
        rs1 <= reg_dataout;
      end if;

      if rState = "10" then
        rs2 <= reg_dataout;
      end if;

      if fetchflag = '1' then
        iword_reg <= data_in;
      end if;
    end if;
  end process;

  regs_inst : entity work.regs(rtl)
    port map (
      clk      => clk,
      reset    => reset,
      addr     => reg_addr,
      datain   => rd,
      regwrite => wbflag,
      dataout  => reg_dataout
      );

  alu_inst : entity work.alu(rtl)
    port map (
      clk         => clk,
      reset       => reset,
      a           => rs1,
      b           => b,
      instruction => instruction,
      rd          => rdAlu
      );

  control_inst : entity work.control(rtl)
    port map (
      clk               => clk,
      reset             => reset,
      iword             => iword_reg,
      control_flags_out => control_flags_out,
      imm               => imm,
      wbflag            => wbflag,
      memflag           => memflag,
      pcflag            => pcflag,
      fetchflag         => fetchflag
      );

  write_en <= memflag;

  b <= imm when control_flags_out(3) = '1' else
       rs2;

  rd <= x"0000" & pc_inc when control_flags_out(4) = '1' else
        data_in when control_flags_out(0) = '1'
        else rdAlu;

  s0 <= rdAlu(16) when control_flags_out(4) = '1'
        else '0';
  s1 <= rdAlu(17) when control_flags_out(4) = '1'
        else '1';

  data_out <= rs2;

  instruction_inst : entity work.instructioncounter(rtl)
    port map (
      clk       => clk,
      reset     => reset,
      pcflag    => pcflag,
      s0        => s0,
      s1        => s1,
      pc_offset => imm(15 downto 0),
      pc_inc    => pc_inc,
      pc_new    => pc_out
      );

  addr_out <= pc_out(15 downto 2) when fetchflag = '1'
              else rdAlu(13 downto 0);

end architecture;
