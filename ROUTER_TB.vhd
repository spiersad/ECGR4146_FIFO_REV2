library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;
use work.pkg.all;

entity ROUTER_TB is
  port (LATENCY: out Integer);
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
  signal RN, t, TEMP: std_logic_vector(63 downto 0);
  signal INPUSH, OUTPOP: ControlArray;
  signal latencyCount: std_logic;
  signal combLatency: integer;
  signal dataInState, dataInNState, dataOutState, dataOutNState: state := state0;
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
  
  DataIn: process(Clk, Reset)
    variable count: integer := 0;
    begin
      if (RESET = '1') then
        INPUSH <= (others => '0');
        INDIN <= (others => x"0000000000000000");
        dataInState <= state0;
        dataInNState <= state0;
        LatencyCount <= '0';
      else
        dataInState <= dataInNState;
      end if;
      
      if(Clk = '1' and Clk'event) then
        case dataInState is
        when state0 =>
          INPUSH <= (others => '0');
          dataInNState <= state1;
        when state1 =>
          LatencyCount <= '1';
          TEMP <= RN;
          INDIN(count) <= RN;
          dataInNState <= state2;
        when state2 =>
          latencyCount <= '0';
          INPUSH(count) <= '1';
          if count = 3 then
            count := 0;
          else
            count := count + 1;
          end if;
          dataInNState <= state0;
        when others =>
          dataInNState <= state0;
        end case;
      end if;
  end process;
  
  DataOut: process(CLK, Reset)
  variable i, j: integer;
  begin
    if reset = '1' then
      OUTPOP <= (others => '0');
      dataOutState <= state0;
      dataOutNState <= state0;
      t <= x"0000000000000000";
      i := 0;
      j := 0;
      LATENCY <= 0;
      combLatency <= 0;
    else
      dataOutState <= dataOutNState;
    end if;
    
    if(Clk = '1' and Clk'event) then
      case dataOutState is
      when state0 =>
        if j > 0 then
          LATENCY <= combLatency / j;
        end if;
        if LatencyCount = '1' then
          t <= TEMP;
          dataOutNState <= state1;
          i := 0;
        end if;
      when state1 =>
        OUTPOP <= (others => '0');
        if (OUTDOUT(0) = t or OUTDOUT(1) = t or OUTDOUT(2) = t or OUTDOUT(3) = t) then
          j := j + 1;
          dataOutNState <= state2;
        else
          i := i + 1;
          dataOutNState <= state3;
        end if;
      when state2 =>
        combLatency <= combLatency + i;
        dataOutNState <= state0;
      when state3 =>
        OUTPOP <= (others => '1');
        dataOutNState <= state1;
      when others =>
        dataOutNState <= state0;
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
