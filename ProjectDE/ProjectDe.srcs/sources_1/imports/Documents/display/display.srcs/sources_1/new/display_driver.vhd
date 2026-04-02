library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity display_driver is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           data : in STD_LOGIC_VECTOR (7 downto 0);
           seg : out STD_LOGIC_VECTOR (6 downto 0);
           anode : out STD_LOGIC_VECTOR (1 downto 0));
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
    
    -- TODO: Add other needed signals
    --Vnitřní signály co vedou ven
    --Zakomentované pro více bitů
    --signal sig_digit : std_logic_vector(1 downto 0);
    signal sig_digit : std_logic_vector(0 downto 0);
    signal sig_bin   : std_logic_vector(3 downto 0);
begin

    ------------------------------------------------------------------------
    -- Clock enable generator for refresh timing
    ------------------------------------------------------------------------
    clock_0 : clk_en
    -- The eye normally catches up above 16 ms. The more display, the more devided
    -- the period should be
        generic map ( G_MAX => 800_000 )  -- Adjust for flicker-free multiplexing
        port map (                   -- For simulation: 32
            clk => clk,              -- For implementation: 3_200_000
            rst => rst,
            ce  => sig_en
        );

    ------------------------------------------------------------------------
    -- N-bit counter for digit selection
    ------------------------------------------------------------------------
    counter_0 : counter
        generic map ( G_BITS => 1 )
        port map (
            clk => clk,
            rst => rst,
            en  => sig_en,
            -- does not require to write down size, if the vectors are the same size/count
            cnt => sig_digit
        );

    ------------------------------------------------------------------------
    -- Digit select
    ------------------------------------------------------------------------
    sig_bin <= data(3 downto 0) when sig_digit = "0" else
               data(7 downto 4);

    ------------------------------------------------------------------------
    -- 7-segment decoder
    ------------------------------------------------------------------------
    decoder_0 : bin2seg
        port map (
            bin => sig_bin,
            seg => seg
        );

    ------------------------------------------------------------------------
    -- Anode select process
    -- Requires an update!
    ------------------------------------------------------------------------
    p_anode_select : process (sig_digit) is
    begin
        case sig_digit is
            when "0" =>
                anode <= "10";  -- Right digit active

            -- TODO: Add another anode selection(s)
            when "1" =>
                anode <= "01";

            when others =>
                anode <= "11";  -- All off
        end case;
    end process;

end Behavioral;
