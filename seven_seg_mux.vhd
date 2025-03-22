library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity seven_seg_mux is
    port (
        clk : in STD_LOGIC;
        rst : in STD_LOGIC;
        first_input : in STD_LOGIC_VECTOR(6 downto 0); -- binary representation, not 7 seg
        second_input : in STD_LOGIC_VECTOR(6 downto 0);
        segment : out STD_LOGIC_VECTOR(6 downto 0);
        anodes : out STD_LOGIC_VECTOR(3 downto 0)
    );
end seven_seg_mux;

architecture Behavioral of seven_seg_mux is
    signal kHz_clock : STD_LOGIC := '0';
    signal segment_display: STD_LOGIC_VECTOR(6 downto 0) := "0000001"; -- shows a 0
    signal anode_selector : STD_LOGIC_VECTOR(3 downto 0); -- assignment will be handled in a processs 

begin
    -- here we construct our three different processes 
    -- first is a clock divider to generate a 1 kHz clock
    kHz_clock_generator : process(clk) is
    variable clock_count : integer range 0 to (100000000 / 1000) := 0; -- internal basys clock is 100 MHz
    begin
        if rising_edge(clk) then
            if rst = '1' then
                clock_count := 0; -- variable assignment
                kHz_clock <= '0';
            elsif clock_count = (100000000 / 1000) then
                clock_count := 0;
                kHz_clock <= not kHz_clock; -- now we can use this 1 kHz clock for display
            else 
                clock_count := clock_count + 1;
            end if;
        end if;
    end process kHz_clock_generator;
    
    -- the second is a multiplexer that runs on the 1 kHz clock
    anode_mux : process(kHz_clock) is
    variable anode_select : integer range 0 to 3 := 0;
    begin
        if rising_edge(kHz_clock) then
            if rst = '1' then
                anode_select := 0;
                anode_selector <= "1111";
            elsif anode_select = 3 then
                anode_select := 0;
            else 
                anode_select := anode_select + 1;
            end if;
            
            case anode_select is
                when 0 =>
                    anode_selector <= "1110";
                when 1 =>
                    anode_selector <= "1101";
                when 2 =>
                    anode_selector <= "1011";
                when 3 =>
                    anode_selector <= "0111";
                when others =>
                    anode_selector <= "1111";
                end case;
        end if;
    end process anode_mux;
    
    -- the third is a binary to bcd decoder to display the correct digit
    -- reason why we need anode_selector to be a global signal instead of a variable
    -- is so that we have access to it in this process
    binary_decoder : process(kHz_clock) is
    variable integer_temp : integer range 0 to 9 := 0;
    variable bcd_segment : STD_LOGIC_VECTOR(6 downto 0) := "0000001";
    -- this will be used to determine the individual 7 segments
    begin
        if rising_edge(kHz_clock) then
            if rst = '1' then
                bcd_segment := "0000001";
            end if;
            case anode_selector is
                when "1110" =>
                    integer_temp := TO_INTEGER(unsigned(first_input)) mod 10;
                when "1101" =>
                    integer_temp := (TO_INTEGER(unsigned(first_input)) / 10) mod 10;
                when "1011" =>
                    integer_temp := TO_INTEGER(unsigned(second_input)) mod 10;
                when "0111" =>
                    integer_temp := (TO_INTEGER(unsigned(second_input)) / 10) mod 10;
                when others =>
                    integer_temp := 0;
                end case;
            case integer_temp is
                when 0 =>
                    bcd_segment := "0000001";
                when 1 =>
                    bcd_segment := "1001111";
                when 2 =>
                    bcd_segment := "0010010";
                when 3 => 
                    bcd_segment := "0000110";
                when 4 =>
                    bcd_segment := "1001100";
                when 5 =>
                    bcd_segment := "0100100";
                when 6 =>
                    bcd_segment := "0100000";
                when 7 =>
                    bcd_segment := "0001111";
                when 8 =>
                    bcd_segment := "0000000";
                when 9 =>
                    bcd_segment := "0000100";
                when others =>
                    bcd_segment := "1111111";
                end case;
        end if; 
    segment <= bcd_segment;
    end process binary_decoder;
    
   anodes <= anode_selector;
end Behavioral;
