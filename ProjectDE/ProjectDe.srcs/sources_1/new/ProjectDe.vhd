library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ProjectDe is
    Port ( clk      : in STD_LOGIC;
           btnu     : in STD_LOGIC; --up
           btnc     : in STD_LOGIC; --center
           btnl     : in STD_LOGIC; --left
           btnr     : in STD_LOGIC; --right
           btnd     : in STD_LOGIC; --down
           
           seg      : out STD_LOGIC_VECTOR( 6 downto 0);
           an       : out STD_LOGIC_VECTOR( 7 downto 0);
           dp       : out STD_LOGIC;
           

           led      : out STD_LOGIC_VECTOR (7 downto 0);
           led16_r  : out STD_LOGIC);
end ProjectDe;

architecture Behavioral of ProjectDe is

    component debounce is
        Port ( clk       : in  STD_LOGIC;
               rst       : in  STD_LOGIC;
               btn_in    : in  STD_LOGIC;
               btn_state : out STD_LOGIC;
               btn_press : out STD_LOGIC);
    end component debounce;

    component counter is
        generic(G_BITS : positive);
        port(
            clk : in std_logic;
            rst : in std_logic;
            en : in std_logic;
            cnt : out std_logic_vector(G_BITS - 1 downto 0)
        );

    end component counter;
    
    component display_driver is
        port(
            data : in std_logic_vector(7 downto 0);
            clk : in std_logic;
            rst : in std_logic;
            seg : out std_logic_vector(6 downto 0);
            anode : out std_logic_vector(1 downto 0)
            );

    end component display_driver;

    -- Internal signal(s)
    signal sig_cnt_en : std_logic;
    signal sig_cnt_val : std_logic_vector(7 downto 0);

begin

    ------------------------------------------------------------------------
    -- Button debouncer
    ------------------------------------------------------------------------
    debounce_0 : debounce
        port map (
            clk       => clk,
            rst       => btnu,
            btn_in    => btnd,
            btn_press => sig_cnt_en,
            btn_state => led16_b
        );

    ------------------------------------------------------------------------
    -- Counter
    ------------------------------------------------------------------------
    counter_0 : counter
        generic map ( G_BITS => 8 )
        port map (
            clk => clk,
            rst => btnu,
            en => sig_cnt_en,
            cnt => sig_cnt_val

        );
        
        
     led <= sig_cnt_val;
        
     display_0 : display_driver
        port map (
            data => sig_cnt_val,
            clk => clk,
            rst => btnu,
            seg => seg,
            anode => an(1 downto 0)

        );

    -- Disable other digits and decimal points
    an(7 downto 2) <= b"11_1111";
    dp             <= '1';


end Behavioral;
