library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity top_module is
    port (
        clk : in STD_LOGIC;  -- internal 100 Mhz clock
        rst : in STD_LOGIC; -- rst pin
        twenty_fives : in STD_LOGIC;  -- coins worth 25 cents
        tens : in STD_LOGIC; -- coins worth 10 cents
        fives: in STD_LOGIC; -- coins worth 5 cents
        led : out STD_LOGIC_VECTOR(15 downto 0); -- external flag to show dispense
        segment : out STD_LOGIC_VECTOR(6 downto 0); -- represent the 7 segment display
        anodes : out STD_LOGIC_VECTOR(3 downto 0) -- multiplexer for anode displays
    );
end top_module;

architecture Behavioral of top_module is

    component refund_timer is
        port ( 
        clk : in STD_LOGIC;
        rst : in STD_LOGIC;
        -- these inputs are all debounced
        twenty_fives: in STD_LOGIC; 
        tens : in STD_LOGIC; 
        fives : in STD_LOGIC;
        refund_flag : out STD_LOGIC
        );
    end component;
    
    component register_counter is
        port ( 
        clk : in STD_LOGIC;
        rst : in STD_LOGIC;
        twenty_fives: in STD_LOGIC;
        tens : in STD_LOGIC;
        fives : in STD_LOGIC;
        refund : in STD_LOGIC;
        output : out STD_LOGIC_VECTOR (6 downto 0); -- max is 95
        change : out STD_LOGIC_VECTOR(6 downto 0); -- change
        dispense : out STD_LOGIC
        );
    end component;
    
    component seven_seg_mux is
        port (
        clk : in STD_LOGIC;
        rst : in STD_LOGIC;
        first_input : in STD_LOGIC_VECTOR(6 downto 0);
        second_input : in STD_LOGIC_VECTOR(6 downto 0);
        segment : out STD_LOGIC_VECTOR(6 downto 0);
        anodes : out STD_LOGIC_VECTOR(3 downto 0)
    );
    end component;
    
    signal output_vector : STD_LOGIC_VECTOR(6 downto 0);
    signal change_vector : STD_LOGIC_VECTOR(6 downto 0);
    signal int_refund_flag : STD_LOGIC;
    signal int_dispense : STD_LOGIC;

begin
    U1 : entity work.refund_timer 
    port map (
        clk => clk,
        rst => rst,
        twenty_fives => twenty_fives,
        tens => tens,
        fives => fives,
        refund_flag => int_refund_flag
    );

    U2 : entity work.register_counter 
    port map (
        clk => clk,
        rst => rst,
        twenty_fives => twenty_fives,
        tens => tens,
        fives => fives,
        refund => int_refund_flag,
        output => output_vector,
        change => change_vector,
        dispense => int_dispense
    );
    
    -- seven seg multiplexer declaration 
    U3 : entity work.seven_seg_mux 
    port map (
        clk => clk,
        rst => rst,
        first_input => output_vector,
        second_input => change_vector,
        segment => segment,
        anodes => anodes
    );
    led <= (others => int_dispense);
end Behavioral;
