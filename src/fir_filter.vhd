------------------------------------------------------------------
--  File        : dpROM12.vhd
--  Description : Direct Digital Synthesis top level
------------------------------------------------------------------
------------------------------------------------------------------
-- Filter Specifications:
-- Sample Rate     : 50 MHz
-- Response        : Lowpass
-- Specification   : Fp,Fst,Ap,Ast
-- Passband Ripple : 1 dB
-- Stopband Atten. : 80 dB
-- Passband Edge   : 120 kHz
-- Stopband Edge   : 125 kHz
-- Order: 51
-- ---------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.ALL;

ENTITY fir_filter IS
   PORT( I_CLK                           :   IN    std_logic; 
         I_RST                           :   IN    std_logic; 
         I_FILTER                        :   IN    std_logic_vector(31 DOWNTO 0); -- sfix32_En32
         O_FILTER                        :   OUT   std_logic_vector(47 DOWNTO 0)  -- sfix48_En48
         );

END fir_filter;

----------------------------------------------------------------
--Module Architecture: fir_filter
----------------------------------------------------------------
ARCHITECTURE rtl OF fir_filter IS
  -- Local Functions
  -- Type Definitions
  TYPE delay_pipeline_type IS ARRAY (NATURAL range <>) OF signed(31 DOWNTO 0); -- sfix32_En32
  -- Constants
  CONSTANT coeff1                         : signed(15 DOWNTO 0) := to_signed(-60, 16); -- sfix16_En16
  CONSTANT coeff2                         : signed(15 DOWNTO 0) := to_signed(-178, 16); -- sfix16_En16
  CONSTANT coeff3                         : signed(15 DOWNTO 0) := to_signed(-163, 16); -- sfix16_En16
  CONSTANT coeff4                         : signed(15 DOWNTO 0) := to_signed(240, 16); -- sfix16_En16
  CONSTANT coeff5                         : signed(15 DOWNTO 0) := to_signed(895, 16); -- sfix16_En16
  CONSTANT coeff6                         : signed(15 DOWNTO 0) := to_signed(1137, 16); -- sfix16_En16
  CONSTANT coeff7                         : signed(15 DOWNTO 0) := to_signed(502, 16); -- sfix16_En16
  CONSTANT coeff8                         : signed(15 DOWNTO 0) := to_signed(-430, 16); -- sfix16_En16
  CONSTANT coeff9                         : signed(15 DOWNTO 0) := to_signed(-504, 16); -- sfix16_En16
  CONSTANT coeff10                        : signed(15 DOWNTO 0) := to_signed(400, 16); -- sfix16_En16
  CONSTANT coeff11                        : signed(15 DOWNTO 0) := to_signed(909, 16); -- sfix16_En16
  CONSTANT coeff12                        : signed(15 DOWNTO 0) := to_signed(23, 16); -- sfix16_En16
  CONSTANT coeff13                        : signed(15 DOWNTO 0) := to_signed(-1108, 16); -- sfix16_En16
  CONSTANT coeff14                        : signed(15 DOWNTO 0) := to_signed(-584, 16); -- sfix16_En16
  CONSTANT coeff15                        : signed(15 DOWNTO 0) := to_signed(1143, 16); -- sfix16_En16
  CONSTANT coeff16                        : signed(15 DOWNTO 0) := to_signed(1360, 16); -- sfix16_En16
  CONSTANT coeff17                        : signed(15 DOWNTO 0) := to_signed(-806, 16); -- sfix16_En16
  CONSTANT coeff18                        : signed(15 DOWNTO 0) := to_signed(-2244, 16); -- sfix16_En16
  CONSTANT coeff19                        : signed(15 DOWNTO 0) := to_signed(-68, 16); -- sfix16_En16
  CONSTANT coeff20                        : signed(15 DOWNTO 0) := to_signed(3132, 16); -- sfix16_En16
  CONSTANT coeff21                        : signed(15 DOWNTO 0) := to_signed(1793, 16); -- sfix16_En16
  CONSTANT coeff22                        : signed(15 DOWNTO 0) := to_signed(-3891, 16); -- sfix16_En16
  CONSTANT coeff23                        : signed(15 DOWNTO 0) := to_signed(-5394, 16); -- sfix16_En16
  CONSTANT coeff24                        : signed(15 DOWNTO 0) := to_signed(4403, 16); -- sfix16_En16
  CONSTANT coeff25                        : signed(15 DOWNTO 0) := to_signed(20317, 16); -- sfix16_En16
  CONSTANT coeff26                        : signed(15 DOWNTO 0) := to_signed(28184, 16); -- sfix16_En16
  CONSTANT coeff27                        : signed(15 DOWNTO 0) := to_signed(20317, 16); -- sfix16_En16
  CONSTANT coeff28                        : signed(15 DOWNTO 0) := to_signed(4403, 16); -- sfix16_En16
  CONSTANT coeff29                        : signed(15 DOWNTO 0) := to_signed(-5394, 16); -- sfix16_En16
  CONSTANT coeff30                        : signed(15 DOWNTO 0) := to_signed(-3891, 16); -- sfix16_En16
  CONSTANT coeff31                        : signed(15 DOWNTO 0) := to_signed(1793, 16); -- sfix16_En16
  CONSTANT coeff32                        : signed(15 DOWNTO 0) := to_signed(3132, 16); -- sfix16_En16
  CONSTANT coeff33                        : signed(15 DOWNTO 0) := to_signed(-68, 16); -- sfix16_En16
  CONSTANT coeff34                        : signed(15 DOWNTO 0) := to_signed(-2244, 16); -- sfix16_En16
  CONSTANT coeff35                        : signed(15 DOWNTO 0) := to_signed(-806, 16); -- sfix16_En16
  CONSTANT coeff36                        : signed(15 DOWNTO 0) := to_signed(1360, 16); -- sfix16_En16
  CONSTANT coeff37                        : signed(15 DOWNTO 0) := to_signed(1143, 16); -- sfix16_En16
  CONSTANT coeff38                        : signed(15 DOWNTO 0) := to_signed(-584, 16); -- sfix16_En16
  CONSTANT coeff39                        : signed(15 DOWNTO 0) := to_signed(-1108, 16); -- sfix16_En16
  CONSTANT coeff40                        : signed(15 DOWNTO 0) := to_signed(23, 16); -- sfix16_En16
  CONSTANT coeff41                        : signed(15 DOWNTO 0) := to_signed(909, 16); -- sfix16_En16
  CONSTANT coeff42                        : signed(15 DOWNTO 0) := to_signed(400, 16); -- sfix16_En16
  CONSTANT coeff43                        : signed(15 DOWNTO 0) := to_signed(-504, 16); -- sfix16_En16
  CONSTANT coeff44                        : signed(15 DOWNTO 0) := to_signed(-430, 16); -- sfix16_En16
  CONSTANT coeff45                        : signed(15 DOWNTO 0) := to_signed(502, 16); -- sfix16_En16
  CONSTANT coeff46                        : signed(15 DOWNTO 0) := to_signed(1137, 16); -- sfix16_En16
  CONSTANT coeff47                        : signed(15 DOWNTO 0) := to_signed(895, 16); -- sfix16_En16
  CONSTANT coeff48                        : signed(15 DOWNTO 0) := to_signed(240, 16); -- sfix16_En16
  CONSTANT coeff49                        : signed(15 DOWNTO 0) := to_signed(-163, 16); -- sfix16_En16
  CONSTANT coeff50                        : signed(15 DOWNTO 0) := to_signed(-178, 16); -- sfix16_En16
  CONSTANT coeff51                        : signed(15 DOWNTO 0) := to_signed(-60, 16); -- sfix16_En16

  -- Signals
  SIGNAL cur_count                        : unsigned(5 DOWNTO 0); -- ufix6
  SIGNAL phase_0                          : std_logic; -- boolean
  SIGNAL delay_pipeline                   : delay_pipeline_type(0 TO 50); -- sfix32_En32
  SIGNAL I_FILTER_regtype                 : signed(31 DOWNTO 0); -- sfix32_En32
  SIGNAL inputmux_1                       : signed(31 DOWNTO 0); -- sfix32_En32
  SIGNAL acc_final                        : signed(47 DOWNTO 0); -- sfix48_En48
  SIGNAL acc_out_1                        : signed(47 DOWNTO 0); -- sfix48_En48
  SIGNAL product_1                        : signed(47 DOWNTO 0); -- sfix48_En48
  SIGNAL product_1_mux                    : signed(15 DOWNTO 0); -- sfix16_En16
  SIGNAL acc_sum_1                        : signed(47 DOWNTO 0); -- sfix48_En48
  SIGNAL acc_in_1                         : signed(47 DOWNTO 0); -- sfix48_En48
  SIGNAL add_temp                         : signed(48 DOWNTO 0); -- sfix49_En48
  SIGNAL output_typeconvert               : signed(47 DOWNTO 0); -- sfix48_En48
  SIGNAL output_register                  : signed(47 DOWNTO 0); -- sfix48_En48


BEGIN

  -- Block Statements
  Counter_process : PROCESS (I_CLK, I_RST)
  BEGIN
    IF I_RST = '1' THEN
      cur_count <= to_unsigned(0, 6);
    ELSIF (rising_edge(I_CLK)) THEN
      IF cur_count >= to_unsigned(50, 6) THEN
        cur_count <= to_unsigned(0, 6);
      ELSE
        cur_count <= cur_count + to_unsigned(1, 6);
      END IF;
    END IF; 
  END PROCESS Counter_process;

  phase_0 <= '1' WHEN cur_count = to_unsigned(0, 6) ELSE '0';

  Delay_Pipeline_process : PROCESS (I_CLK, I_RST)
  BEGIN
    IF I_RST = '1' THEN
      delay_pipeline(0 TO 50) <= (OTHERS => (OTHERS => '0'));
    ELSIF (rising_edge(I_CLK)) THEN
      IF phase_0 = '1' THEN
        delay_pipeline(0) <= signed(I_FILTER);
        delay_pipeline(1 TO 50) <= delay_pipeline(0 TO 49);
      END IF;
    END IF; 
  END PROCESS Delay_Pipeline_process;

  I_FILTER_regtype <= signed(I_FILTER);

  inputmux_1 <= I_FILTER_regtype WHEN ( cur_count = to_unsigned(0, 6) ) ELSE
                     delay_pipeline(1) WHEN ( cur_count = to_unsigned(1, 6) ) ELSE
                     delay_pipeline(2) WHEN ( cur_count = to_unsigned(2, 6) ) ELSE
                     delay_pipeline(3) WHEN ( cur_count = to_unsigned(3, 6) ) ELSE
                     delay_pipeline(4) WHEN ( cur_count = to_unsigned(4, 6) ) ELSE
                     delay_pipeline(5) WHEN ( cur_count = to_unsigned(5, 6) ) ELSE
                     delay_pipeline(6) WHEN ( cur_count = to_unsigned(6, 6) ) ELSE
                     delay_pipeline(7) WHEN ( cur_count = to_unsigned(7, 6) ) ELSE
                     delay_pipeline(8) WHEN ( cur_count = to_unsigned(8, 6) ) ELSE
                     delay_pipeline(9) WHEN ( cur_count = to_unsigned(9, 6) ) ELSE
                     delay_pipeline(10) WHEN ( cur_count = to_unsigned(10, 6) ) ELSE
                     delay_pipeline(11) WHEN ( cur_count = to_unsigned(11, 6) ) ELSE
                     delay_pipeline(12) WHEN ( cur_count = to_unsigned(12, 6) ) ELSE
                     delay_pipeline(13) WHEN ( cur_count = to_unsigned(13, 6) ) ELSE
                     delay_pipeline(14) WHEN ( cur_count = to_unsigned(14, 6) ) ELSE
                     delay_pipeline(15) WHEN ( cur_count = to_unsigned(15, 6) ) ELSE
                     delay_pipeline(16) WHEN ( cur_count = to_unsigned(16, 6) ) ELSE
                     delay_pipeline(17) WHEN ( cur_count = to_unsigned(17, 6) ) ELSE
                     delay_pipeline(18) WHEN ( cur_count = to_unsigned(18, 6) ) ELSE
                     delay_pipeline(19) WHEN ( cur_count = to_unsigned(19, 6) ) ELSE
                     delay_pipeline(20) WHEN ( cur_count = to_unsigned(20, 6) ) ELSE
                     delay_pipeline(21) WHEN ( cur_count = to_unsigned(21, 6) ) ELSE
                     delay_pipeline(22) WHEN ( cur_count = to_unsigned(22, 6) ) ELSE
                     delay_pipeline(23) WHEN ( cur_count = to_unsigned(23, 6) ) ELSE
                     delay_pipeline(24) WHEN ( cur_count = to_unsigned(24, 6) ) ELSE
                     delay_pipeline(25) WHEN ( cur_count = to_unsigned(25, 6) ) ELSE
                     delay_pipeline(26) WHEN ( cur_count = to_unsigned(26, 6) ) ELSE
                     delay_pipeline(27) WHEN ( cur_count = to_unsigned(27, 6) ) ELSE
                     delay_pipeline(28) WHEN ( cur_count = to_unsigned(28, 6) ) ELSE
                     delay_pipeline(29) WHEN ( cur_count = to_unsigned(29, 6) ) ELSE
                     delay_pipeline(30) WHEN ( cur_count = to_unsigned(30, 6) ) ELSE
                     delay_pipeline(31) WHEN ( cur_count = to_unsigned(31, 6) ) ELSE
                     delay_pipeline(32) WHEN ( cur_count = to_unsigned(32, 6) ) ELSE
                     delay_pipeline(33) WHEN ( cur_count = to_unsigned(33, 6) ) ELSE
                     delay_pipeline(34) WHEN ( cur_count = to_unsigned(34, 6) ) ELSE
                     delay_pipeline(35) WHEN ( cur_count = to_unsigned(35, 6) ) ELSE
                     delay_pipeline(36) WHEN ( cur_count = to_unsigned(36, 6) ) ELSE
                     delay_pipeline(37) WHEN ( cur_count = to_unsigned(37, 6) ) ELSE
                     delay_pipeline(38) WHEN ( cur_count = to_unsigned(38, 6) ) ELSE
                     delay_pipeline(39) WHEN ( cur_count = to_unsigned(39, 6) ) ELSE
                     delay_pipeline(40) WHEN ( cur_count = to_unsigned(40, 6) ) ELSE
                     delay_pipeline(41) WHEN ( cur_count = to_unsigned(41, 6) ) ELSE
                     delay_pipeline(42) WHEN ( cur_count = to_unsigned(42, 6) ) ELSE
                     delay_pipeline(43) WHEN ( cur_count = to_unsigned(43, 6) ) ELSE
                     delay_pipeline(44) WHEN ( cur_count = to_unsigned(44, 6) ) ELSE
                     delay_pipeline(45) WHEN ( cur_count = to_unsigned(45, 6) ) ELSE
                     delay_pipeline(46) WHEN ( cur_count = to_unsigned(46, 6) ) ELSE
                     delay_pipeline(47) WHEN ( cur_count = to_unsigned(47, 6) ) ELSE
                     delay_pipeline(48) WHEN ( cur_count = to_unsigned(48, 6) ) ELSE
                     delay_pipeline(49) WHEN ( cur_count = to_unsigned(49, 6) ) ELSE
                     delay_pipeline(50);

  --   ------------------ Serial partition # 1 ------------------

  product_1_mux <= coeff1 WHEN ( cur_count = to_unsigned(0, 6) ) ELSE
                        coeff2 WHEN ( cur_count = to_unsigned(1, 6) ) ELSE
                        coeff3 WHEN ( cur_count = to_unsigned(2, 6) ) ELSE
                        coeff4 WHEN ( cur_count = to_unsigned(3, 6) ) ELSE
                        coeff5 WHEN ( cur_count = to_unsigned(4, 6) ) ELSE
                        coeff6 WHEN ( cur_count = to_unsigned(5, 6) ) ELSE
                        coeff7 WHEN ( cur_count = to_unsigned(6, 6) ) ELSE
                        coeff8 WHEN ( cur_count = to_unsigned(7, 6) ) ELSE
                        coeff9 WHEN ( cur_count = to_unsigned(8, 6) ) ELSE
                        coeff10 WHEN ( cur_count = to_unsigned(9, 6) ) ELSE
                        coeff11 WHEN ( cur_count = to_unsigned(10, 6) ) ELSE
                        coeff12 WHEN ( cur_count = to_unsigned(11, 6) ) ELSE
                        coeff13 WHEN ( cur_count = to_unsigned(12, 6) ) ELSE
                        coeff14 WHEN ( cur_count = to_unsigned(13, 6) ) ELSE
                        coeff15 WHEN ( cur_count = to_unsigned(14, 6) ) ELSE
                        coeff16 WHEN ( cur_count = to_unsigned(15, 6) ) ELSE
                        coeff17 WHEN ( cur_count = to_unsigned(16, 6) ) ELSE
                        coeff18 WHEN ( cur_count = to_unsigned(17, 6) ) ELSE
                        coeff19 WHEN ( cur_count = to_unsigned(18, 6) ) ELSE
                        coeff20 WHEN ( cur_count = to_unsigned(19, 6) ) ELSE
                        coeff21 WHEN ( cur_count = to_unsigned(20, 6) ) ELSE
                        coeff22 WHEN ( cur_count = to_unsigned(21, 6) ) ELSE
                        coeff23 WHEN ( cur_count = to_unsigned(22, 6) ) ELSE
                        coeff24 WHEN ( cur_count = to_unsigned(23, 6) ) ELSE
                        coeff25 WHEN ( cur_count = to_unsigned(24, 6) ) ELSE
                        coeff26 WHEN ( cur_count = to_unsigned(25, 6) ) ELSE
                        coeff27 WHEN ( cur_count = to_unsigned(26, 6) ) ELSE
                        coeff28 WHEN ( cur_count = to_unsigned(27, 6) ) ELSE
                        coeff29 WHEN ( cur_count = to_unsigned(28, 6) ) ELSE
                        coeff30 WHEN ( cur_count = to_unsigned(29, 6) ) ELSE
                        coeff31 WHEN ( cur_count = to_unsigned(30, 6) ) ELSE
                        coeff32 WHEN ( cur_count = to_unsigned(31, 6) ) ELSE
                        coeff33 WHEN ( cur_count = to_unsigned(32, 6) ) ELSE
                        coeff34 WHEN ( cur_count = to_unsigned(33, 6) ) ELSE
                        coeff35 WHEN ( cur_count = to_unsigned(34, 6) ) ELSE
                        coeff36 WHEN ( cur_count = to_unsigned(35, 6) ) ELSE
                        coeff37 WHEN ( cur_count = to_unsigned(36, 6) ) ELSE
                        coeff38 WHEN ( cur_count = to_unsigned(37, 6) ) ELSE
                        coeff39 WHEN ( cur_count = to_unsigned(38, 6) ) ELSE
                        coeff40 WHEN ( cur_count = to_unsigned(39, 6) ) ELSE
                        coeff41 WHEN ( cur_count = to_unsigned(40, 6) ) ELSE
                        coeff42 WHEN ( cur_count = to_unsigned(41, 6) ) ELSE
                        coeff43 WHEN ( cur_count = to_unsigned(42, 6) ) ELSE
                        coeff44 WHEN ( cur_count = to_unsigned(43, 6) ) ELSE
                        coeff45 WHEN ( cur_count = to_unsigned(44, 6) ) ELSE
                        coeff46 WHEN ( cur_count = to_unsigned(45, 6) ) ELSE
                        coeff47 WHEN ( cur_count = to_unsigned(46, 6) ) ELSE
                        coeff48 WHEN ( cur_count = to_unsigned(47, 6) ) ELSE
                        coeff49 WHEN ( cur_count = to_unsigned(48, 6) ) ELSE
                        coeff50 WHEN ( cur_count = to_unsigned(49, 6) ) ELSE
                        coeff51;

  product_1 <= inputmux_1 * product_1_mux;

  add_temp <= resize(product_1, 49) + resize(acc_out_1, 49);
  acc_sum_1 <= add_temp(47 DOWNTO 0);

  acc_in_1 <= product_1 WHEN ( phase_0 = '1' ) ELSE
                   acc_sum_1;

  Acc_reg_1_process : PROCESS (I_CLK, I_RST)
  BEGIN
    IF I_RST = '1' THEN
      acc_out_1 <= (OTHERS => '0');
    ELSIF (rising_edge(I_CLK)) THEN
      acc_out_1 <= acc_in_1;
    END IF; 
  END PROCESS Acc_reg_1_process;

  Finalsum_reg_process : PROCESS (I_CLK, I_RST)
  BEGIN
    IF I_RST = '1' THEN
      acc_final <= (OTHERS => '0');
    ELSIF (rising_edge(I_CLK)) THEN
      IF phase_0 = '1' THEN
        acc_final <= acc_out_1;
      END IF;
    END IF; 
  END PROCESS Finalsum_reg_process;

  output_typeconvert <= acc_final;

  Output_Register_process : PROCESS (I_CLK, I_RST)
  BEGIN
    IF I_RST = '1' THEN
      output_register <= (OTHERS => '0');
    ELSIF (rising_edge(I_CLK)) THEN
      IF phase_0 = '1' THEN
        output_register <= output_typeconvert;
      END IF;
    END IF; 
  END PROCESS Output_Register_process;

  -- Assignment Statements
  O_FILTER <= std_logic_vector(output_register);
END rtl;
