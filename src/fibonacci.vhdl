library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
 
entity fibonacci is
    generic (MAX_IN_BITS : positive := 5;
             MAX_OUT_BITS : positive := 20);
 
    port (
        try : in unsigned(1 downto 0);
        clk, reset: in std_logic;
        start: in std_logic;
        num_in: in std_logic_vector (MAX_IN_BITS-1 downto 0) ;
        ready, done_tick: out std_logic;
        result: out std_logic_vector (MAX_OUT_BITS-1  downto 0 )
        );
end fibonacci;
 
architecture arch of fibonacci is
    type state_type is (idle, op, done);
    signal state, next_state: state_type;
    signal prev_1, prev_2: unsigned(MAX_OUT_BITS-1  downto 0 );
    signal next_prev_1, next_prev_2: unsigned(MAX_OUT_BITS-1  downto 0 );
    signal next_result: std_logic_vector (MAX_OUT_BITS-1  downto 0 );
    signal counter:  unsigned  (MAX_IN_BITS-1  downto 0 );
    signal next_counter: unsigned (MAX_IN_BITS-1  downto 0 );
    signal next_ready, next_done_tick: std_logic;
    signal result_reg: std_logic_vector (MAX_OUT_BITS-1  downto 0 );
begin
 
    sync: process(reset, clk) is
    begin
        if (reset = '1') then
            state <= idle;
            prev_1 <= (others => '0');        
            prev_2 <= to_unsigned(1, prev_2'length);
            result_reg <= (others => '0'); 
        elsif rising_edge(clk) then
            state <= next_state;
            counter <= next_counter;
            prev_1 <=  next_prev_1;
            prev_2 <=  next_prev_2;
            result_reg <= next_result;

        end if;
    end process sync;
 
    comb: process (state, counter, start) is
    begin
        report "prev_1 = " & integer'IMAGE(to_integer(prev_1));
        report "prev_2 = " & integer'IMAGE(to_integer(prev_2));
        next_counter <= unsigned(num_in)-1;
        next_state <= state;
        done_tick <= '0';
        next_prev_1 <= prev_1;
        next_prev_2 <= prev_2;
        ready <= '0';
        next_result <= result_reg;
        case state is
            when idle =>
                report "state: idle";
                ready <= '1';
                next_result <= (others => '0');
                if start = '1' then
                    next_state <= op;
                end if;
            when op =>
                report "state: op";
                if counter = 0 then
                    next_state <= done;
                    done_tick <= '1';
                else 
                    next_counter <= counter -1;
                    next_result <= std_logic_vector(prev_1+prev_2);
                    next_prev_1 <= prev_2;
                    next_prev_2 <= unsigned(prev_1+prev_2);
                end if;
            when done =>
                report "state: done";
                next_state <= idle;
        end case;
    end process comb;
 
    result <= result_reg;
 
 
 
end arch;
