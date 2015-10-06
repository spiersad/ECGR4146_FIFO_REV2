library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;
use work.pkg.all;

entity ROUTER_TB is
end ROUTER_TB;

architecture behav of ROUTER_TB is
  component random
      port (clk:in std_logic;
            random_number: out std_logic_vector(63 downto 0));
    end component;
  component ROUTER
      generic (N: integer := 8; -- number of address bits for 2**N address locations
               M: integer := 64); -- number of data bits to/from FIFO
      port (CLK,RESET: in std_logic;
            INDIN: in DataArray;
            OUTDOUT: out DataArray;
            INPUSH, OUTPOP: in ControlArray);
    end component;
  constant clk_period: time := 1 ns;
  constant M: integer := 64;
  signal CLK,RESET: std_logic;
  signal INDIN, OUTDOUT: DataArray;
  signal RN: std_logic_vector(63 downto 0);
  signal INPUSH, OUTPOP: ControlArray;
begin
  uut: ROUTER port map(CLK => CLK, RESET => RESET, INDIN => INDIN, OUTDOUT => OUTDOUT, INPUSH => INPUSH, OUTPOP => OUTPOP);
  rng: random port map(Clk => Clk, random_number => RN);
    
  clk_process: process
    begin
      clk <= '0';
      wait for clk_period/2;
      clk <= '1';
      wait for clk_period/2;
  end process;
  
  DataIn: process(Clk)
    variable dataInState, dataInNState: state := state0;
    variable count: integer := 0;
    begin
      if (RESET = '1') then
        INPUSH <= (others => '0');
        INDIN <= (others => x"0000000000000000");
        OUTPOP <= (others => '0');
        dataInState := state0;
        dataInNState := state0;
      else
        dataInState := dataInNState;
      end if;
      
      if(Clk = '1' and Clk'event) then
        case dataInState is
        when state0 =>
          INPUSH <= (others => '0');
          dataInNState := state1;
        when state1 =>
          INDIN(count) <= RN;
          dataInNState := state2;
        when state2 =>
          INPUSH(count) <= '1';
          if count = 3 then
            count := 0;
          else
            count := count + 1;
          end if;
          dataInNState := state0;
        when others =>
          dataInNState := state0;
        end case;
      end if;
  end process;
  
  process
    begin
      reset <= '1';
      wait for 2 ns;
      reset <= '0';
      wait;
  end process;
end behav;
