library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
entity TL_module is
generic(clock_rate : integer);

port(
    -- input values from the test bench
     clock : in std_logic; reset_flag : in std_logic; -- resets if 0
     -- output values to the test bench
    NS_stop    : out std_logic; NS_ready : out std_logic;
    NS_go  : out std_logic; EW_stop     : out std_logic;
    EW_ready  : out std_logic; EW_go   : out std_logic);

end entity;
 
architecture RegTranLev of TL_module is -- RegTranLev -> register transfer level
 
    type tl_state is (NorthNext, StartNorth, North, StopNorth, -- defining a new
                        EastNext, StartEast, East, StopEast); -- data type
    signal State : tl_state;
  	
    signal wait_time : integer range 0 to clock_rate * 60; -- used to keep
                                                           -- track of the waiting time
 	
begin
 
    process(clock) is
 
        -- Procedure for changing state after a given time
        procedure ChangeState(new_state : tl_state;
                              minutes : integer := 0; -- default val: 0
                              seconds : integer := 0) is
            variable Totalseconds : integer;
            variable clock_count  : integer; -- number of clocks passed
        begin
            Totalseconds := seconds + minutes * 60;
            clock_count  := Totalseconds * clock_rate -1;
            if wait_time = clock_count then
                wait_time <= 0;
                State   <= new_state;
            end if;
        end procedure;
 
    begin
        if rising_edge(clock) then
            if reset_flag = '0' then
                -- initial values
                State   <= NorthNext;
                wait_time <= 0;
                NS_stop    <= '1';
                NS_ready <= '0';
                NS_go  <= '0';
                EW_stop     <= '1';
                EW_ready  <= '0';
                EW_go   <= '0';
 
            else
                -- Default values
                NS_stop    <= '0';
                NS_ready <= '0';
                NS_go  <= '0';
                EW_stop     <= '0';
                EW_ready  <= '0';
                EW_go   <= '0';
 
                wait_time <= wait_time + 1;
 
                case State is
 
                    -- both lights are red
                    when NorthNext =>
                        NS_stop <= '1';
                        EW_stop  <= '1';
                        ChangeState(StartNorth, seconds => 5); 
                        -- change current state to make north light turn red and yellow
 
                    -- Red and yellow in north and red in east direction
                    when StartNorth =>
                        NS_stop    <= '1';
                        NS_ready <= '1';
                        EW_stop     <= '1';
                        ChangeState(North, seconds => 5);
 
                    -- Green in North direction
                    when North =>
                        NS_go <= '1';
                        EW_stop    <= '1';
                        ChangeState(StopNorth, minutes => 1);
 
                    -- Yellow in North direction
                    when StopNorth =>
                        NS_ready <= '1';
                        EW_stop     <= '1';
                        ChangeState(EastNext, seconds => 5);
 
                    -- Red in East and North directions
                    when EastNext =>
                        NS_stop <= '1';
                        EW_stop  <= '1';
                        ChangeState(StartEast, seconds => 5);
 
                    -- Red and yellow in East direction
                    when StartEast =>
                        NS_stop   <= '1';
                        EW_stop    <= '1';
                        EW_ready <= '1';
                        ChangeState(East, seconds => 5);
 
                    -- Green in East direction
                    when East =>
                        NS_stop  <= '1'; 
                        EW_go <= '1';
                        ChangeState(StopEast, minutes => 1);
 
                    -- Yellow in East
                    when StopEast =>
                        NS_stop   <= '1';
                        EW_ready <= '1';
                        ChangeState(NorthNext, seconds => 5);
 
                end case;
 
            end if;
        end if;
    end process;
 
end architecture;