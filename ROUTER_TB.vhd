library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;
use work.pkg.all;

entity ROUTER_TB is
end ROUTER_TB;

architecture behav of ROUTER_TB is
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
  signal INDIN: DataArray;
  signal OUTDOUT: DataArray;
  signal INPUSH, OUTPOP: ControlArray;
begin
  uut: ROUTER port map(CLK => CLK, RESET => RESET, INDIN => INDIN, OUTDOUT => OUTDOUT, INPUSH => INPUSH, OUTPOP => OUTPOP);
  
  clk_process: process
    begin
      clk <= '0';
      wait for clk_period/2;
      clk <= '1';
      wait for clk_period/2;
  end process;
  
  DataIn: process(Clk)
    variable dataInState, dataInNState: state := state0;
    variable rand_temp : std_logic_vector(M-1 downto 0):=(M-1 downto M-17 => '1', others => '0');
    variable temp : std_logic := '0';
    variable count: integer := 0;
    begin
      if (RESET = '1') then
        INPUSH <= (others => '0');
      else
        dataInState := dataInNState;
      end if;
      
      if(Clk = '1' and Clk'event) then
        dataInState := DataInNState;
        case dataInState is
        when state0 =>
          temp := rand_temp(M-1) xor rand_temp(M-2);
          rand_temp(M-1 downto 1) := rand_temp(M-2 downto 0);
          rand_temp(0) := temp;
          dataInNState := state1;
        when state1 =>
          INDIN(count) <= rand_temp;
          INPUSH(count) <= '1';
          dataInNState := state2;
        when state2 =>
          INPUSH <= (others => '0');
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
      wait for 1 ns;
      reset <= '0';
      wait;
  end process;
end behav;