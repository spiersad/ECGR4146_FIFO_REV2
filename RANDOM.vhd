LIBRARY ieee;
use IEEE.std_logic_1164.all;
USE ieee.math_real.ALL;   -- for UNIFORM, TRUNC functions
USE ieee.numeric_std.ALL; -- for TO_UNSIGNED function

entity random is
  port(
    clk: in std_logic;
    random_number: out std_logic_vector(63 downto 0));
end entity random;

architecture behave of random is
  begin
PROCESS(clk)
  VARIABLE seed1, seed2: positive;               -- Seed values for random generator
  VARIABLE rand: real;                           -- Random real-number value in range 0 to 1.0
  VARIABLE int_rand: integer;                    -- Random integer value in range 0..4095
  VARIABLE stim: std_logic_vector(15 DOWNTO 0);  -- Random 12-bit stimulus
BEGIN

    UNIFORM(seed1, seed2, rand);                                   -- generate random number
    int_rand := INTEGER(TRUNC(rand*65536.0));                       -- rescale to 0..4096, find integer part
    stim := std_logic_vector(to_unsigned(int_rand, stim'LENGTH));  -- convert to std_logic_vector
    random_number <= stim & stim & stim & stim;
END PROCESS;
end behave;