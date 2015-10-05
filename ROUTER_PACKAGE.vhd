library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

package pkg is
  type DataArray is array (3 downto 0) of std_logic_vector(63 downto 0);
  type ControlArray is array (3 downto 0) of std_logic;
  type AddressArray is array (3 downto 0) of std_logic_vector(7 downto 0);
  type BufferArray is array (3 downto 0) of std_logic_vector(3 downto 0);
  type state is (state0, state1, state2, state3,state4 ,state5 ,state6, state7);
end package;

package body pkg is
end package body;
