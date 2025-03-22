library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- this is to refund the input change if the user has not inputted money for roughly 20 seconds

entity refund_timer is
    
    port ( 
           clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           -- these inputs are all debounced
           twenty_fives: in STD_LOGIC; 
           tens : in STD_LOGIC; 
           fives : in STD_LOGIC;
           refund_flag : out STD_LOGIC
           );
end refund_timer;

architecture Behavioral of refund_timer is
    -- we'll set this at a frequency of 0.05 Hz
    signal slow_clk_count : integer range 0 to 100_000_000 * 20 := 0;
    signal slow_clk : STD_LOGIC := '0'; 
begin
    -- we create our clock divider process to dictate refund behavior
    refund_counter : process(clk) is
    begin
        if rising_edge(clk) then
            if rst = '1' or twenty_fives = '1' or tens = '1' or fives = '1' then -- either reset or user has inputted money
                slow_clk_count <= 0;
                slow_clk <= '0';
            else
                if slow_clk_count = 100_000_000 * 20 then
                    slow_clk <= not slow_clk;
                    slow_clk_count <= 0; -- we reset the clock counter back down to 0
                else
                    slow_clk_count <= slow_clk_count + 1;
                end if;
            end if;
        end if;
    end process refund_counter;
refund_flag <= slow_clk;
end Behavioral;
