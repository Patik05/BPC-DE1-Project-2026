library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity display_driver is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           --data : in STD_LOGIC_VECTOR (7 downto 0);
           data : in STD_LOGIC_VECTOR (23 downto 0);
           seg : out STD_LOGIC_VECTOR (6 downto 0);
           anode : out STD_LOGIC_VECTOR (5 downto 0));
end display_driver;

architecture Behavioral of display_driver is

    -- Component declaration for clock enable
    component clk_en is
        generic ( G_MAX : positive );
        port (
            clk : in  std_logic;
            rst : in  std_logic;
            ce  : out std_logic
        );
    end component clk_en;

    -- Component declaration for binary counter
    component counter is
        generic ( G_BITS : positive );
        port (
            clk : in  std_logic;
            rst : in  std_logic;
            en  : in  std_logic;
            cnt : out std_logic_vector(G_BITS - 1 downto 0)
        );
    end component counter;

    component bin2seg is
        port(
            bin : in std_logic_vector (3 downto 0);
            seg : out std_logic_vector (6 downto 0)
        );
    end component bin2seg;

    -- Internal signals
    signal sig_en : std_logic;
    signal sig_digit : std_logic_vector(2 downto 0);
    signal sig_bin   : std_logic_vector(3 downto 0);
begin

    ------------------------------------------------------------------------
    -- Clock enable generator for refresh timing
    ------------------------------------------------------------------------
    clock_0 : clk_en
    -- The eye normally catches up above 16 ms. The more display, the more divided the period should be (at minumum)
        generic map ( G_MAX => 80_000 )  -- Adjusted for flicker-free multiplexing
        port map (                    
            clk => clk,              
            rst => rst,
            ce  => sig_en
        );

    ------------------------------------------------------------------------
    -- N-bit counter for digit selection
    ------------------------------------------------------------------------
    counter_0 : counter
        generic map ( G_BITS => 3 ) -- 3 bit binary
        port map (
            clk => clk,
            rst => rst,
            en  => sig_en,
            cnt => sig_digit
        );

    ------------------------------------------------------------------------
    -- Digit selection
    ------------------------------------------------------------------------
    p_mux : process(sig_digit, data)
        begin
            case sig_digit is
                when "000" => sig_bin <= data(3 downto 0);   -- sec0
                when "001" => sig_bin <= data(7 downto 4);   -- sec1
                when "010" => sig_bin <= data(11 downto 8);  -- min0
                when "011" => sig_bin <= data(15 downto 12); -- min1
                when "100" => sig_bin <= data(19 downto 16); -- hr0
                when "101" => sig_bin <= data(23 downto 20); -- hr1
                when others => sig_bin <= "0000";
            end case;
        end process;

    ------------------------------------------------------------------------
    -- 7-segment decoder
    ------------------------------------------------------------------------
    decoder_0 : bin2seg
        port map (
            bin => sig_bin,
            seg => seg
        );

    ------------------------------------------------------------------------
    -- Anode select process, one at the time (but so fast, the human eye does not register)
    ------------------------------------------------------------------------
    p_anode_select : process (sig_digit) is
    begin
        case sig_digit is
            when "000" => anode <= "111110"; -- Rightmost digit (sec0)
            when "001" => anode <= "111101";
            when "010" => anode <= "111011";
            when "011" => anode <= "110111";
            when "100" => anode <= "101111";
            when "101" => anode <= "011111"; -- Leftmost digit (hr1)
            when others => anode <= "111111"; -- All off
        end case;
    end process;

end Behavioral;
