--N x K RAM is 2-dimensional array of N K-bit words
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.NUMERIC_STD.all;

entity RAM is 
  generic (K: integer:=64;  --number of bits per word
           W: integer:=8); --number of address bits; N = 2^W
  port(
    WR: in std_logic;               --active high write enable
    ADDR: in std_logic_vector(W-1 downto 0);   --RAM address
    DIN : in std_logic_vector(K-1 downto 0);   --write data
    DOUT: out std_logic_vector(K-1 downto 0)); --read data
end entity RAM;
architecture RAMBEHAVIOR of RAM is
  subtype WORD  is std_logic_vector( K-1 downto 0) ;    --define  size  of WORD
  type MEMORY is array (0 to 2**W-1)  of WORD;--define size of MEMORY 
  signal RAM256: MEMORY := ((others=> (others=>'0')));--define RAM256 as signal of type MEMORY
  begin
    process (WR,  DIN, ADDR)
      variable RAM_ADDR_IN: natural range 0 to 2**W-1;--translate address to integer
      begin
        RAM_ADDR_IN := TO_INTEGER(UNSIGNED(ADDR));--convert address to integer
        if (WR='1') then--write operation to RAM
          RAM256 (RAM_ADDR_IN) <= DIN ;
        end if;
        DOUT <= RAM256 (RAM_ADDR_IN);--always does read operation
    end process;
end architecture RAMBEHAVIOR;