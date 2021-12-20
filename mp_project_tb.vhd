library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
entity mp_project_tb is
end entity;
 
architecture sim of mp_project_tb is
 
 
    constant clock_rate     : integer := 100; -- the frequency of the clock, 100Hz
    constant cycle_duration : time    := 1000 ms / clock_rate; -- the duration of each clock cycle
     
    signal my_clock    : std_logic := '1'; -- this will determine the edge ( rising, falling)
    signal reset_flag  : std_logic := '0'; -- if it's zero, the data values in the module will be reset
    signal NS_stop    : std_logic       ;
    signal NS_ready : std_logic       ;
    signal NS_go  : std_logic       ;
    signal EW_stop     : std_logic       ;
    signal EW_ready  : std_logic       ;
    signal EW_go   : std_logic       ;
 
begin
 
    -- importing the our module
    i_TL_module : entity work.TL_module(RegTranLev)


    generic map(clock_rate => clock_rate)
    port map (clock => my_clock, reset_flag => reset_flag, NS_stop => NS_stop, NS_ready => NS_ready,
        NS_go  => NS_go, EW_stop => EW_stop, EW_ready  => EW_ready,EW_go   => EW_go);
 
 
    -- Process for generating clock
    my_clock <= not my_clock after cycle_duration / 2;
 
    -- Testbench sequence
    process is
    begin
        wait until rising_edge(my_clock);
        wait until rising_edge(my_clock);
     
        -- Take the DUT out of reset
        reset_flag <= '1';
     
        wait;
    end process;
     
end architecture;