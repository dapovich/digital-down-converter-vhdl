------------------------------------------------------------------
--  File        : dds_tb.vhd
--  Description : Testbench of DDS sine generation
------------------------------------------------------------------
library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

entity testbench is
end entity testbench;

architecture rtl of testbench is
  -- DDS generator component
  component dds is
    port (
      I_CLK      : in std_logic;
      I_RST      : in std_logic;
      I_PHASEINC : in std_logic_vector(31 downto 0);
      O_SINE     : out std_logic_vector(15 downto 0);
      O_COS      : out std_logic_vector(15 downto 0)
    );
  end component;

  -- FIR filter component
  component fir_filter is
    port (
      I_CLK    : in std_logic;
      I_RST    : in std_logic;
      I_FILTER : in std_logic_vector(31 downto 0);
      O_FILTER : out std_logic_vector(49 downto 0)
    );
  end component;

  -- High-frequency generator of sin
  component hf_generator is
    port (
      I_CLK : in std_logic;
      I_RST : in std_logic;
      I_PHASEINC : in std_logic_vector(31 downto 0);
      O_SINE : out std_logic_vector(15 downto 0)
    );
  end component;

  -- Testbench signals
  signal tbClk : std_logic := '0';
  signal tbRst : std_logic := '1';

  -- HF generator signal
  -- Phs_inc = (Fout * 2^32)/Fclk
  -- For Fout = 725 kHz and Fo = 5 MHz
  -- tbPhsInc_hf = x"03B645A1"
  -- tbPhsInc = x"1999_9999"
  -- FIR filter should has more less Amplitude Characteristic

  signal tbPhsInc_hf : std_logic_vector(31 downto 0) := x"03B645A1";
  signal tbOutHfSignal : std_logic_vector(15 downto 0);

  -- Phase accumulator signals of DDS
  signal tbPhsInc : std_logic_vector(31 downto 0) := x"03B645A1";
  signal tbStep   : std_logic_vector(31 downto 0) := (others => '0');

  -- Input signals
  signal tbSin    : std_logic_vector(15 downto 0);
  signal tbCos    : std_logic_vector(15 downto 0);

  -- Input signals of I and Q filter
  signal tbInFilterQ : std_logic_vector(31 downto 0);
  signal tbInFilterI : std_logic_vector(31 downto 0);

  -- Output signals of I and Q filter
  signal tbOutFilterQ : std_logic_vector(49 downto 0);
  signal tbOutFilterI : std_logic_vector(49 downto 0);

  -- Internal testbench clock with 50 MHz frequency
  constant CLK_PERIOD : time := 20 ns;

begin

  ----------------------------------------------------------------
  -- Instantiate Unit Under Test (UUT) of HF generator
  ----------------------------------------------------------------
  uut_hf_generator : hf_generator
    port map (
      I_CLK => tbClk,
      I_RST => tbRst,
      I_PHASEINC => tbPhsInc_hf,
      O_SINE => tbOutHfSignal
    );

  ----------------------------------------------------------------
  -- Instantiate Unit Under Test (UUT) of DDS generator
  ----------------------------------------------------------------
  uut_dds : dds
    port map (
      I_CLK => tbClk,
      I_RST => tbRst,
      I_PHASEINC => tbPhsInc,
      O_SINE => tbSin,
      O_COS => tbCos
    );

  --------------------------------------------------------------------------
  -- Instantiate Unit Under Test of FIR filter for I (cos) quadrature
  --------------------------------------------------------------------------
  uut_fir_filter_I : fir_filter
    port map (
      I_CLK => tbClk,
      I_RST => tbRst,
      I_FILTER => tbInFilterI,
      O_FILTER => tbOutFilterI
    );

  --------------------------------------------------------------------------
  -- Instantiate Unti Under Test (UUT) of FIR filter for Q (sin) quadrature
  --------------------------------------------------------------------------
  uut_fir_filter_Q : fir_filter
    port map (
      I_CLK => tbClk,
      I_RST => tbRst,
      I_FILTER => tbInFilterQ,
      O_FILTER => tbOutFilterQ
    );

  -- Format I quadrature component
  tbInFilterI <= std_logic_vector(signed(tbOutHfSignal) * signed(tbCos));

  -- Format Q quadrature component
  tbInFilterQ <= std_logic_vector(signed(tbOutHfSignal) * signed(tbSin));

  --tbRealI <= real(to_integer(signed(tbOutFilterI)));
  --tbRealQ <= real(to_integer(signed(tbOutFilterQ)));
  --tbOutQuadratureReal <= sqrt(tbRealI**2 + tbRealQ**2);
  --tbOutQuadratureSignal <= std_logic_vector(to_unsigned(integer(tbOutQuadratureReal), tbOutQuadratureSignal'length));

  -- @Goal: generate the clock & reset
  tbClk <= not(tbClk) after (CLK_PERIOD/2);
  tbRst <= '0' after 200 ns;

  ----------------------------------------------------------------
  -- Main testing process
  ----------------------------------------------------------------
  --process (tbClk, tbRst) is
  --begin
    --if (rising_edge(tbClk)) then
      --tbPhsInc <= std_logic_vector(unsigned(tbPhsInc) + unsigned(tbStep));
      --tbStep <= std_logic_vector(unsigned(tbStep) + to_unsigned(1, 32));
    --end if;
  --end process;

end architecture rtl;

------------------------------------------------------------------
--  End of File: dds_tb.vhd
------------------------------------------------------------------
