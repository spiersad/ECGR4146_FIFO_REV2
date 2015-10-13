library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;
use work.pkg.all;

entity ROUTER_TB is
  port (LATENCY, BANDWIDTH: out Time);
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
            OUTNOPOP: out ControlArray;
            INPUSH, OUTPOP: in ControlArray);
    end component;
  constant clk_period: time := 1 ns;
  constant M: integer := 64;
  signal CLK, RESET: std_logic;
  signal INDIN, OUTDOUT: DataArray;
  signal RN: std_logic_vector(63 downto 0);
  signal INPUSH, OUTPOP, OUTNOPOP: ControlArray;
  signal counter: integer := 0;
begin
  uut: ROUTER port map(CLK => CLK, RESET => RESET, INDIN => INDIN, OUTDOUT => OUTDOUT, OUTNOPOP => OUTNOPOP, INPUSH => INPUSH, OUTPOP => OUTPOP);
  rng: random port map(Clk => Clk, random_number => RN);
    
  clk_process: process
    begin
      clk <= '0';
      wait for clk_period/2;
      clk <= '1';
      counter <= counter + 1;
      wait for clk_period/2;
  end process;
  
  DataIn: process(Clk, Reset)
    variable count: integer := 0;
    variable CurrentState, NextState: State;
    begin
      if (RESET = '1') then
        INPUSH <= (others => '0');
        INDIN <= (others => x"0000000000000000");
        CurrentState := state0;
        NextState := state0;
      else
        CurrentState := NextState;
      end if;
      
      if(Clk = '1' and Clk'event and (counter mod 10 = 0)) then
        case CurrentState is
        when state0 =>
          INPUSH <= (others => '0');
          NextState := state1;
        when state1 =>
          INDIN(count) <= RN;
          NextState := state2;
        when state2 =>
          INPUSH(count) <= '1';
          if count = 3 then
            count := 0;
          else
            count := count + 1;
          end if;
          NextState := state0;
        when others =>
          NextState := state0;
        end case;
      end if;
  end process;
  
  BandwidthProc: process(reset, clk, OUTNOPOP)
    variable count: Integer;
    variable temp, totalTemp: Time;
    begin
      if reset = '1' then
        count := 0;
        temp := 0 ns;
        totalTemp := 0 ns;
        BANDWIDTH <= 0 ns;
      elsif (OUTNOPOP'event and (OUTNOPOP(0) < '1' or OUTNOPOP(1) < '1' or OUTNOPOP(2) < '1' or OUTNOPOP(3) < '1')) then
        count := count + 1;
        totalTemp := totalTemp + temp;
        BANDWIDTH <= totalTemp / count;
        temp := 0 ns;
      elsif (Clk = '1' and Clk'event) then
        temp := temp + clk_period;
      end if;  
  end process;
  
  LatencyProc: process(reset, clk, OUTDOUT, INPUSH)
    variable count: Integer;
    variable CurrentState, NextState: State;
    variable temp, totalTemp: Time;
    variable tmpSignal: std_logic_vector(M-1 downto 0);
    begin
      if (RESET = '1') then
        count := 0;
        LATENCY <= 0 ns;
        temp := 0 ns;
        totalTemp := 0 ns;
        CurrentState := state0;
        NextState := state0;
        tmpSignal := x"0000000000000000";
      elsif (clk'event and clk = '1') then
        CurrentState := NextState;
      end if;
      
      case CurrentState is
      when state0 =>
        if INPUSH(0)'event then
          tmpSignal := INDIN(0);
        elsif INPUSH(1)'event then
          tmpSignal := INDIN(1);
        elsif INPUSH(2)'event then
          tmpSignal := INDIN(2);
        elsif INPUSH(3)'event then
          tmpSignal := INDIN(3);
        end if;
        if INPUSH'event then
          NextState := state1;
          temp := 0 ns;
        end if;
      when state1 =>
        if (OUTDOUT'event and (OUTDOUT(0) = tmpSignal or OUTDOUT(1) = tmpSignal or OUTDOUT(2) = tmpSignal or OUTDOUT(3) = tmpSignal)) then
          count := count + 1;
          totalTemp := totalTemp + temp;
          LATENCY <= totalTemp / count;
          NextState := state0;
        elsif (Clk = '1' and Clk'event) then
          if temp > 100 ns then
            NextState := state0;
          end if;
          temp := temp + clk_period;
        end if;
      when others =>
        NextState := state0;
      end case;
  end process;
    
    
  DataOut: process(CLK, Reset)
  begin
    if reset = '1' then
      OUTPOP <= (others => '0');
    elsif (CLK = '1' and CLK'event and (counter mod 1 = 0)) then
      OUTPOP <= (others => '1');
    --else
    --  OUTPOP <= (others => '0');
    end if;
  end process;
  
  ResetProcess: process
    begin
      reset <= '1';
      wait for 2 ns;
      reset <= '0';
      wait;
  end process;
end behav;
