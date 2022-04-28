------------------------------------------------------------------
--  File        : sqrt.vhd
--  Description : Synthesizable Design for Finding Square root of
--  given number
------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sqrt96bit is
  port (
    I_CLK     : in std_logic;
    I_RST     : in std_logic;
    I_DATA    : in std_logic_vector(95 downto 0);
    O_SQ_ROOT : out std_logic_vector(47 downto 0)
  );
end sqrt96bit;

----------------------------------------------------------------
-- Module Architecture: sqrt
----------------------------------------------------------------
architecture rtl of sqrt96bit is
begin

  SQROOT_PROC : process(I_CLK, I_RST)
    variable v_input : unsigned(95 downto 0);  -- original input
    variable v_right : unsigned(49 downto 0) := (others => '0');
    variable v_left, v_reg : unsigned(50 downto 0) := (others => '0');
    variable v_result : unsigned(47 downto 0) := (others => '0'); -- 
    variable i : integer := 0; -- index of the loop
  begin
    if (I_RST = '1') then  -- Reset the variables
      O_SQ_ROOT <= (others => '0');
      i := 0;
      v_input := (others => '0');
      v_left := (others => '0');
      v_right := (others => '0');
      v_reg := (others => '0');
      v_result := (others => '0');
    elsif (rising_edge(I_CLK)) then
      if (i = 0) then  -- Propogate a data from port to variable
        v_input := unsigned(I_DATA);
        i := i + 1;
      elsif (i < 48) then -- Keep incrementing the loop index
        i := i + 1;
      end if;
      -- Derived from the block diagram
      v_right := v_result & v_reg(49) & '1';
      v_left := v_reg(48 downto 0) & v_input(95 downto 94);
      v_input := v_input(93 downto 0) & "00"; -- shifting left by 2 bit
      if (v_reg(49) = '1') then -- add or subtract as per this bit
        v_reg := v_left + v_right;
      else
        v_reg := v_left - v_right;
      end if;
      v_result := v_result(46 downto 0) & (not v_reg(49));
      if (i = 48) then -- @Goal: the max value of loop index has reached
        i := 0; -- reset loop index for beginning the next cycle
        O_SQ_ROOT <= std_logic_vector(v_result); -- assign 'v_result' to the output port
        -- reset other signals
        v_left := (others => '0');
        v_right := (others => '0');
        v_reg := (others => '0');
        v_result := (others => '0');
      end if;
    end if;
  end process;
end architecture rtl;
------------------------------------------------------------------
--  End of File: sqrt.vhd
------------------------------------------------------------------
