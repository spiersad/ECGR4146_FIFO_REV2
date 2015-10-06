library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;
use work.pkg.all;

entity ROUTER is
  generic (N: integer := 8; -- number of address bits for 2**N address locations
           M: integer := 64); -- number of data bits to/from FIFO
  port (CLK,RESET: in std_logic;
        INDIN: in DataArray;
        OUTDOUT: out DataArray;
        INPUSH, OUTPOP: in ControlArray);
end entity ROUTER;

architecture behav of router is
  
  signal current_state, next_state : state := state0;
  signal RTABLE: DataArray := (x"aaaa000000000000", x"5555000100000000", x"5555001000000000", x"0000001100000000");
  signal OUTDIN, INDOUT: DataArray;
  signal INPOP, OUTPUSH, INNOPOP, INNOPUSH, OUTNOPUSH, OUTNOPOP, INWE, OUTWE: ControlArray;
  signal INADDR, OUTADDR: AddressArray;
  signal OUTBUFF: BufferArray;
  signal TMP: std_logic_vector(63 downto 0);
  signal INIT: std_logic;
  
  component FIFO_LOGIC_MODIFIED is
    generic (N: integer); -- number of address bits
    port (CLK, PUSH, POP, INIT: in std_logic;
          BUFF: out std_logic_vector(3 downto 0);
          we: out std_logic;
          ADD: out std_logic_vector(N-1 downto 0);
          FULL, EMPTY, NOPUSH, NOPOP: buffer std_logic);
  end component FIFO_LOGIC_MODIFIED;
  component RAM is
    generic (K, W: integer); -- number of address and data bits
    port (WR: in std_logic; -- active high write enable
          ADDR: in std_logic_vector (W-1 downto 0); -- RAM address
          DIN: in std_logic_vector (K-1 downto 0); -- write data
          DOUT: out std_logic_vector (K-1 downto 0)); -- read data
  end component RAM;
  
begin
  
  PORT_MAP_GEN:
  for I in 3 downto 0 generate
    OUTRAM: RAM generic map (W => N, K => M)
      port map (DIN => OUTDIN(I), ADDR => OUTADDR(I), DOUT => OUTDOUT(I), WR => OUTWE(I));
    INRAM: RAM generic map (W => N, K => M)
      port map (DIN => INDIN(I), ADDR => INADDR(I), DOUT => INDOUT(I), WR => INWE(I));
    OUTFIFO: FIFO_LOGIC_MODIFIED generic map (N => N)
      port map(CLK => CLK, PUSH => OUTPUSH(I), POP => OUTPOP(I), INIT => INIT, NOPOP => OUTNOPOP(I),
               NOPUSH => OUTNOPUSH(I), ADD => OUTADDR(I) , BUFF => OUTBUFF(I), WE => OUTWE(I));
    INFIFO: FIFO_LOGIC_MODIFIED generic map (N => N)
      port map(CLK => CLK, PUSH => INPUSH(I), POP => INPOP(I), INIT => INIT,
               NOPUSH => INNOPUSH(I), NOPOP => INNOPOP(I), ADD => INADDR(I), WE => INWE(I));
  end generate;
  
  RTABLE(0)(19 downto 16) <= OUTBUFF(0);
  RTABLE(1)(19 downto 16) <= OUTBUFF(1);
  RTABLE(2)(19 downto 16) <= OUTBUFF(2);
  RTABLE(3)(19 downto 16) <= OUTBUFF(3);
  
  main: process(Clk, RESET)
    variable i : std_logic_vector(1 downto 0);
    variable j : integer;
      begin
        
        if (RESET = '1') then
          current_state <= state0;
          next_state <= state0;
          i := "00";
          INIT <= '1';
          TMP <= x"0000000000000000";
          OUTDIN <= (others => x"0000000000000000");
          OUTPUSH <= (others => '0');
          INPOP <= (others => '0');
        else
          INIT <= '0';
          current_state <= next_state;
        end if;
        
        if (Clk'event and Clk='1') then
          case current_state is
          when state0 =>
            TMP <= INDOUT(to_integer(unsigned(i)));
            next_state <= state1;
          when state1 =>
            INPOP(to_integer(unsigned(i))) <= '1';
            if (INNOPOP(to_integer(unsigned(i))) = '1') then
              next_state <= state3;
            else
              next_state <= state2;
            end if;
          when state2 =>
            INPOP <= (others => '0');
            if (TMP(63 downto 48) >= RTABLE(3)(63 downto 48)) then
              j := 3;
            elsif (TMP(63 downto 48) >= RTABLE(2)(63 downto 48)) then
              j := 2;
            elsif (TMP(63 downto 48) >= RTABLE(2)(63 downto 48)) then
              j := 1;
            else
              j := 0;
            end if;
            next_state <= state4;
          when state3 =>
            INPOP <= (others => '0');
            OUTPUSH <= (others => '0');
            i := i + "01";
            next_state <= state0;
          when state4 =>
            if j >= 1 then
              if (RTABLE(j-1)(63 downto 48) = RTABLE(j)(63 downto 48)) and
                  RTABLE(j-1)(31 downto 16) < RTABLE(j)(31 downto 16) then
                OUTDIN(j-1) <= TMP;
                j := j-1;
              else
                OUTDIN(j) <= TMP;
              end if;
            else
              OUTDIN(j) <= TMP;
            end if;
            next_state <= state5;
          when state5 =>
            OUTPUSH(J) <= '1';
            next_state <= state3;
          when others =>
            next_state <= state3;
          end case;
        end if;
    end process;
end behav;