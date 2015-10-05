library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity FIFO_LOGIC_MODIFIED is
  generic (N: integer := 8);
  port (CLK, PUSH, POP, INIT: in std_logic;
        ADD: out std_logic_vector(N-1 downto 0);
        BUFF: buffer std_logic_vector(3 downto 0);
        FULL, EMPTY, WE, NOPUSH, NOPOP: buffer std_logic);
end entity FIFO_LOGIC_MODIFIED;

architecture RTL of FIFO_LOGIC_MODIFIED is
  signal WPTR, RPTR: std_logic_vector(N-1 downto 0);
  signal LASTOP: std_logic;
  begin
    SYNC: process (CLK) begin
      if (CLK'event and CLK = '1') then
        if (INIT = '1') then -- initialization --
          WPTR <= (others => '0');
          RPTR <= (others => '0');
          LASTOP <= '0';
          BUFF <= "0000";
        elsif (POP = '1' and empty = '0') then -- pop --
          RPTR <= RPTR + 1;
          if (RPTR(5) = '1') then
            RPTR(5) <= '0';
          end if;
          LASTOP <= '0';
          BUFF <= BUFF - "0001";
        elsif (PUSH = '1' and FULL = '0') then -- push --
          WPTR <= WPTR + 1;
          if (WPTR(5) = '1') then
            WPTR(5) <= '0';
          end if;
          LASTOP <= '1';
          BUFF <= BUFF + "0001";
        end if; -- otherwise all Fs hold their value --
      end if;
end process SYNC;

COMB: process (PUSH, POP, WPTR, RPTR, LASTOP, FULL, EMPTY) 
  begin
    -- full and empty flags --
    if (RPTR = WPTR) then
      if (LASTOP = '1') then
        FULL <= '1';
        empty <= '0';
      else
        FULL <= '0';
        empty <= '1';
      end if;
    else
      FULL <= '0';
      empty <= '0';
    end if;
    -- address, write enable and nopush/nopop logic --
    if (POP = '0' and PUSH = '0') then -- no operation --
      ADD <= RPTR;
      WE <= '0';
      NOPUSH <= '0';
      NOPOP <= '0';
    elsif (POP = '0' and PUSH = '1') then -- push only --
      ADD <= WPTR;
      NOPOP <= '0';
      if (FULL = '0') then -- valid write condition --
        WE <= '1';
        NOPUSH <= '0';
      else -- no write condition --
        WE <= '0';
        NOPUSH <= '1';
      end if;
    elsif (POP = '1' and PUSH = '0') then -- pop only --
      ADD <= RPTR;
      NOPUSH <= '0';
      WE <= '0';
      if (empty = '0') then
        -- valid read condition --
        NOPOP <= '0';
      else
        NOPOP <= '1'; -- no red condition --
      end if;
    else -- push and pop at same time
      if (empty = '0') then -- valid pop --
        ADD <= RPTR;
        WE <= '0';
        NOPUSH <= '1';
        NOPOP <= '0';
      else
        ADD <= wptr;
        WE <= '1';
        NOPUSH <= '0';
        NOPOP <= '1';
      end if;
    end if;
  end process COMB;
end architecture RTL; 