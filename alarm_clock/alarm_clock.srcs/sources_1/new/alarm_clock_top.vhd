----------------------------------------------------------------------------------
-- Component Name: alarm_clock_top
-- Description:
--   Top-level structural wrapper for the Nexys A7-50T Alarm Clock.
--   Interconnects physical board interfaces (buttons, displays, buzzer)
--   with the internal 'alarm_clock' core logic.
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity alarm_clock_top is
    Port (
           clk      : in STD_LOGIC;
           btnu     : in STD_LOGIC; -- Increment time
           btnc     : in STD_LOGIC; -- Play / Pause / Silence Alarm
           btnl     : in STD_LOGIC; -- Reset clock
           btnr     : in STD_LOGIC; -- Change edit mode (Sec -> Min -> Hr)
           btnd     : in STD_LOGIC; -- Decrement time

           seg      : out STD_LOGIC_VECTOR( 6 downto 0);
           an       : out STD_LOGIC_VECTOR( 7 downto 0);
           dp       : out STD_LOGIC;
           led      : out STD_LOGIC_VECTOR (7 downto 0);

           led16_r  : out STD_LOGIC;
           buzzer   : out STD_LOGIC
    );
end alarm_clock_top;

architecture Behavioral of alarm_clock_top is

    ------------------------------------------------------------------------
    -- Component Declarations
    ------------------------------------------------------------------------
    component debounce is
        Port ( clk       : in  STD_LOGIC;
               rst       : in  STD_LOGIC := '0';
               btn_in    : in  STD_LOGIC;
               btn_state : out STD_LOGIC;
               btn_press : out STD_LOGIC);
    end component debounce;

    component clk_en is
        generic ( G_MAX : positive );
        port ( clk : in std_logic; rst : in std_logic; ce : out std_logic );
    end component clk_en;

    -- The extracted core logic
    component alarm_clock is
        Port (
            clk            : in  STD_LOGIC;
            sig_reset      : in  STD_LOGIC;
            sig_inc        : in  STD_LOGIC;
            sig_dec        : in  STD_LOGIC;
            sig_mode       : in  STD_LOGIC;
            sig_play_pause : in  STD_LOGIC;
            ce_1hz         : in  STD_LOGIC;
            disp_data      : out STD_LOGIC_VECTOR(23 downto 0);
            alarm_active   : out STD_LOGIC
        );
    end component alarm_clock;

    component display_driver is
        port( data : in std_logic_vector(23 downto 0); clk : in std_logic; rst : in std_logic; seg : out std_logic_vector(6 downto 0); anode : out std_logic_vector(5 downto 0) );
    end component display_driver;

    component buzzer_module is
        Port ( clk        : in  STD_LOGIC;
               en         : in  STD_LOGIC;
               buzzer_out : out STD_LOGIC);
    end component buzzer_module;

    ------------------------------------------------------------------------
    -- Internal Signals
    ------------------------------------------------------------------------
    signal sig_inc_pulse, sig_dec_pulse, sig_play_pause_pulse : std_logic;
    signal sig_reset_pulse, sig_mode_pulse, ce_1hz            : std_logic;

    signal is_zero   : std_logic;
    signal disp_data : std_logic_vector(23 downto 0);

begin

    ------------------------------------------------------------------------
    -- Instantiations
    ------------------------------------------------------------------------
    debounce_up     : debounce port map (clk => clk, btn_in => btnu, btn_press => sig_inc_pulse, btn_state => open);
    debounce_down   : debounce port map (clk => clk, btn_in => btnd, btn_press => sig_dec_pulse, btn_state => open);
    debounce_center : debounce port map (clk => clk, btn_in => btnc, btn_press => sig_play_pause_pulse, btn_state => open);
    debounce_left   : debounce port map (clk => clk, btn_in => btnl, btn_press => sig_reset_pulse, btn_state => open);
    debounce_right  : debounce port map (clk => clk, btn_in => btnr, btn_press => sig_mode_pulse, btn_state => open);

    clock_1hz : clk_en
        generic map ( G_MAX => 100_000_000 )
        port map (clk => clk, rst => '0', ce  => ce_1hz);

    -- The Brain
    core_logic : alarm_clock
        port map (
            clk            => clk,
            sig_reset      => sig_reset_pulse,
            sig_inc        => sig_inc_pulse,
            sig_dec        => sig_dec_pulse,
            sig_mode       => sig_mode_pulse,
            sig_play_pause => sig_play_pause_pulse,
            ce_1hz         => ce_1hz,
            disp_data      => disp_data,
            alarm_active   => is_zero
        );

    -- Display multiplexer
    display_0 : display_driver
        port map (
            data  => disp_data,
            clk   => clk,
            rst   => '0',
            seg   => seg,
            anode => an(5 downto 0)
        );

    -- Square wave generator for the HW-508
    alarm_speaker : buzzer_module
        port map (
            clk        => clk,
            en         => is_zero,
            buzzer_out => buzzer
        );

    ------------------------------------------------------------------------
    -- Hardware Output Routing
    ------------------------------------------------------------------------
    led16_r        <= is_zero;
    led            <= (others => '0');
    dp             <= '1';
    an(7 downto 6) <= "11"; -- Keep unused digits dark

end Behavioral;
