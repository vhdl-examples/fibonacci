library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
 
library vunit_lib;
context vunit_lib.vunit_context;
 
entity tb_fibonacci is
    generic (runner_cfg : string);
end tb_fibonacci;
 
architecture Behavioral of tb_fibonacci is
    component fibonacci is
        generic (MAX_IN_BITS : positive;
             MAX_OUT_BITS : positive);
 
    port (
        try : in unsigned (1 downto 0);
        clk, reset: in std_logic;
        start: in std_logic;
        num_in: in std_logic_vector (MAX_IN_BITS-1 downto 0) ;
        ready, done_tick: out std_logic;
        result: out std_logic_vector (MAX_OUT_BITS-1  downto 0 )
        );
    end component;
 
    constant MAX_IN_BITS: positive := 5;
    constant MAX_OUT_BITS: positive := 20;
 
    signal try: unsigned (1 downto 0);
    signal clk, reset, start: std_logic;
    signal num_in: std_logic_vector (MAX_IN_BITS-1 downto 0);
    signal ready, done_tick: std_logic;
    signal result: std_logic_vector (MAX_OUT_BITS-1  downto 0 );
 
    constant T : time := 20 ns;
begin
 
    clock_generation : process
    begin
        clk <= '0';
        wait for T/2;
        clk <= '1';
        wait for T/2;
    end process;
 
    uut: fibonacci
        generic map (
            MAX_IN_BITS => MAX_IN_BITS,
            MAX_OUT_BITS => MAX_OUT_BITS)
        port map (
            try => try,
            clk => clk,
            reset => reset,
            start => start,
            ready => ready,
            num_in => num_in,
            done_tick => done_tick,
            result => result);
 
    tb: process
    begin
        test_runner_setup(runner, runner_cfg);
       
        wait until falling_edge(clk);
        reset <= '1';
        start <= '0';
        try <= to_unsigned(1, try'length);
 
        wait until falling_edge(clk);
 
        reset <= '0';
        start <= '1';
        num_in <= "01000";
 
 
        wait until rising_edge(done_tick);
        wait until falling_edge(clk);
 
        assert result = "00000000000000010101" report "fibonacci is wrong";
 
        wait until falling_edge(clk);

        test_runner_cleanup(runner); -- Simulation ends here
    end process;
 
end Behavioral;
