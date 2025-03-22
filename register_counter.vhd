library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- this module is used to store the state value of the vending machine
entity register_counter is
    port ( 
           clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           twenty_fives: in STD_LOGIC;
           tens : in STD_LOGIC;
           fives : in STD_LOGIC;
           refund : in STD_LOGIC;
           output : out STD_LOGIC_VECTOR (6 downto 0); -- max is 95
           change : out STD_LOGIC_VECTOR(6 downto 0); -- binary representation, not 7-seg
           dispense : out STD_LOGIC
           );
end register_counter;

architecture Behavioral of register_counter is

    component button_debounce is
        port ( 
           clk        : in  std_logic;
           rst        : in  std_logic;
           button_in  : in  std_logic;
           button_out : out std_logic
           );
    end component;

    signal total_value : integer range 0 to 100 := 0;
    signal db_twenty_fives_int : STD_LOGIC;
    signal db_fives_int : STD_LOGIC;
    signal db_tens_int : STD_LOGIC;
    signal dispense_int : STD_LOGIC := '0';
    signal change_int : STD_LOGIC_VECTOR(6 downto 0) := (others => '0');
begin

    debounced_fives : entity work.button_debounce 
    port map (
        clk => clk,
        rst => rst,
        button_in => fives,
        button_out => db_fives_int
    );
    
    debounced_tens : entity work.button_debounce 
    port map (
        clk => clk,
        rst => rst,
        button_in => tens,
        button_out => db_tens_int
    );
    
    debounced_twenty_fives : entity work.button_debounce 
    port map (
        clk => clk,
        rst => rst,
        button_in => twenty_fives,
        button_out => db_twenty_fives_int
    );

    total_coin_value : process(clk) is
        begin
        if rising_edge(clk) then
            if rst = '1' then
                dispense_int <= '0';
                change_int <= "0000000";
                total_value <= 0;
            elsif total_value >= 75 then
                dispense_int <= '1';
                change_int <= STD_LOGIC_VECTOR(to_unsigned(total_value - 75, change'length));
                total_value <= 0;
            elsif refund = '1' then
                dispense_int <= '0';
                change_int <= STD_LOGIC_VECTOR(to_unsigned(total_value, change'length));
                total_value <= 0;
            elsif db_tens_int = '1' then -- we check on debounced input, not unfiltered input
                dispense_int <= '0';
                change_int <= "0000000";
                total_value <= total_value + 10;
            elsif db_fives_int = '1' then -- same logic here, why we use debouncing
                dispense_int <= '0';
                change_int <= "0000000";
                total_value <= total_value + 5;
            elsif db_twenty_fives_int = '1' then
                dispense_int <= '0';
                change_int <= "0000000";
                total_value <= total_value + 25;
            end if;
        end if;
    end process total_coin_value;    
    output <= STD_LOGIC_VECTOR(to_unsigned(total_value, output'length));
    change <= change_int;
    dispense <= dispense_int;
end Behavioral;
