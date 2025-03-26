library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- this module is used to store the state value of the vending machine
entity coke_FSM is
    port ( 
           clk : in STD_LOGIC;
           enable : in STD_LOGIC; -- starts taking in coin input from user
           rst : in STD_LOGIC;
           coin_select : in STD_LOGIC_VECTOR(1 downto 0); -- 00 is no coin, 01 is nickel, 10 is dime, 11 is quarter
           refund : in STD_LOGIC; -- input refund flag if user has not inputted enough money, system automatically refunds
           output : out STD_LOGIC_VECTOR (6 downto 0); -- max is 95
           change : out STD_LOGIC_VECTOR(6 downto 0); -- binary representation, not 7-seg
           dispense : out STD_LOGIC -- binary flag for whether coke is dispensed
           );
end coke_FSM;

architecture Behavioral of coke_FSM is
    -- we reference our component for use here to clean the coin input
    component button_debounce is
        port ( 
           clk        : in  std_logic;
           rst        : in  std_logic;
           button_in  : in  std_logic;
           button_out : out std_logic
           );
    end component;

    -- here we declare our finite state machine implementation
    type coke_state is (zeroes, fives, tens, fifteens, twenties);
    signal curr_state : coke_state := zeroes; -- initial state has no money
    signal count : integer range 0 to 3 := 0; 
    -- if count is three then we are >= 75 cents
    -- we will just have to look at the current state to determine our change, no extra variables to consider
    
begin
    -- here we will handle the state machine based on the inputs
    
    coke_state_machine : process(clk) is
    begin
        if rising_edge(enable) then
            if rst = '1' then
                curr_state <= zeroes;
                count <= 0;
            end if;
            -- here is our explicit FSM implementation
            case curr_state is
                when zeroes => -- at 0, 25, 50, 75 cents
                    if count = 3 then
                        dispense <= '1';
                        change <= STD_LOGIC_VECTOR(to_unsigned(0, change'length));
                    else
                        case coin_select is
                            when "00" => -- no coin
                                curr_state <= curr_state; -- no change
                            when "01" =>
                                curr_state <= fives;
                            when "10" =>
                                curr_state <= tens;
                            when "11" =>
                                curr_state <= curr_state; -- not necessary but to be pedantic
                                count <= count + 1; 
                            when others =>
                                curr_state <= curr_state;
                        end case;
                    end if;
                when fives => -- at 5, 30, 55, 80 cents
                    if count = 3 then
                        dispense <= '1';
                        change <= STD_LOGIC_VECTOR(to_unsigned(5, change'length));
                    else
                        case coin_select is
                            when "00" => 
                                curr_state <= curr_state; 
                            when "01" =>
                                curr_state <= tens;
                            when "10" =>
                                curr_state <= fifteens;
                            when "11" =>
                                curr_state <= curr_state; 
                                count <= count + 1; 
                            when others =>
                                curr_state <= curr_state;
                        end case;
                    end if;
                when tens => -- at 10, 35, 60, 85 cents
                    if count = 3 then
                        dispense <= '1';
                        change <= STD_LOGIC_VECTOR(to_unsigned(10, change'length));
                    else
                        case coin_select is
                            when "00" => 
                                curr_state <= curr_state; 
                            when "01" =>
                                curr_state <= fifteens;
                            when "10" =>
                                curr_state <= twenties;
                            when "11" =>
                                curr_state <= curr_state; 
                                count <= count + 1; 
                            when others =>
                                curr_state <= curr_state;
                        end case;
                    end if;
                when fifteens => -- at 15, 40, 65, 90 cents
                    if count = 3 then
                        dispense <= '1';
                        change <= STD_LOGIC_VECTOR(to_unsigned(15, change'length));
                    else
                        case coin_select is
                            when "00" => 
                                curr_state <= curr_state; 
                            when "01" =>
                                curr_state <= twenties;
                            when "10" =>
                                curr_state <= zeroes;
                                count <= count + 1; -- since it overflows, we increment count
                            when "11" =>
                                curr_state <= curr_state; 
                                count <= count + 1; 
                            when others =>
                                curr_state <= curr_state;
                        end case;
                    end if;
                when twenties =>
                    if count = 3 then
                        dispense <= '1';
                        change <= STD_LOGIC_VECTOR(to_unsigned(20, change'length));
                    else
                        case coin_select is
                            when "00" => 
                                curr_state <= curr_state; 
                            when "01" =>
                                curr_state <= zeroes;
                                count <= count + 1;
                            when "10" =>
                                curr_state <= fives;
                                count <= count + 1;
                            when "11" =>
                                curr_state <= curr_state;
                                count <= count + 1; 
                            when others =>
                                curr_state <= curr_state;
                        end case;
                    end if;
            end case;
        end if;
    end process coke_state_machine;
    
    -- this next process converts the current state to the output (not the change, that's handled from the FSM)
    coin_insertion : process(enable) is
    begin
        if rising_edge(clk) then
            if rst = '1' then
                output <= (others => '0');
            else
                case curr_state is
                    when zeroes =>
                        output <= STD_LOGIC_VECTOR(to_unsigned(25 * count, output'length));
                    when fives =>
                        output <= STD_LOGIC_VECTOR(to_unsigned(5 + (25 * count), output'length));
                    when tens =>
                        output <= STD_LOGIC_VECTOR(to_unsigned(10 + (25 * count), output'length));
                    when fifteens =>
                        output <= STD_LOGIC_VECTOR(to_unsigned(15 + (25 * count), output'length));
                    when twenties =>
                        output <= STD_LOGIC_VECTOR(to_unsigned(20 + (25 * count), output'length));
                    when others =>
                        output <= (others => '0');
                end case;
            end if;
        end if;
    end process coin_insertion;

end Behavioral;
