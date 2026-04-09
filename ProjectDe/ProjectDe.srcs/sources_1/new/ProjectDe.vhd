library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ProjectDe is
    Port ( clk      : in STD_LOGIC;
           btnu     : in STD_LOGIC; -- increment
           btnc     : in STD_LOGIC; -- play / pause
           btnl     : in STD_LOGIC; -- reset
           btnr     : in STD_LOGIC; -- change alarm color
           btnd     : in STD_LOGIC; -- decrement

           seg      : out STD_LOGIC_VECTOR( 6 downto 0);
           an       : out STD_LOGIC_VECTOR( 7 downto 0);
           dp       : out STD_LOGIC;

           led      : out STD_LOGIC_VECTOR (7 downto 0); -- Standard LEDs (disabled)

           -- RGB LED 16 Ports
           led16_r  : out STD_LOGIC;
           led16_g  : out STD_LOGIC;
           led16_b  : out STD_LOGIC);
end ProjectDe;

architecture Behavioral of ProjectDe is

    component debounce is
        Port ( clk       : in  STD_LOGIC;
               rst       : in  STD_LOGIC;
               btn_in    : in  STD_LOGIC;
               btn_state : out STD_LOGIC;
               btn_press : out STD_LOGIC);
    end component debounce;

    component display_driver is
        port(
            data  : in std_logic_vector(23 downto 0);
            clk   : in std_logic;
            rst   : in std_logic;
            seg   : out std_logic_vector(6 downto 0);
            anode : out std_logic_vector(5 downto 0)
        );
    end component display_driver;

    component clk_en is
        generic ( G_MAX : positive );
        port ( clk : in std_logic; rst : in std_logic; ce : out std_logic );
    end component clk_en;

    -- Button pulses
    signal sig_inc_pulse        : std_logic;
    signal sig_dec_pulse        : std_logic;
    signal sig_play_pause_pulse : std_logic;
    signal sig_reset_pulse      : std_logic;
    signal sig_color_pulse      : std_logic;

    signal ce_1hz               : std_logic;

    -- Counters and States
    signal sec0 : integer range 0 to 9 := 0;
    signal sec1 : integer range 0 to 5 := 0;
    signal min0 : integer range 0 to 9 := 0;
    signal min1 : integer range 0 to 5 := 0;
    signal hr0  : integer range 0 to 9 := 0;
    signal hr1  : integer range 0 to 2 := 0;

    signal counting_down : std_logic := '0';
    signal is_zero       : std_logic := '0';
    signal color_state   : integer range 0 to 6 := 0; -- 7 colors
    signal disp_data     : std_logic_vector(23 downto 0);

begin

    ------------------------------------------------------------------------
    -- Debouncers
    ------------------------------------------------------------------------
    debounce_up : debounce
        port map (clk => clk, rst => '0', btn_in => btnu, btn_press => sig_inc_pulse, btn_state => open);

    debounce_down : debounce
        port map (clk => clk, rst => '0', btn_in => btnd, btn_press => sig_dec_pulse, btn_state => open);

    debounce_center : debounce
        port map (clk => clk, rst => '0', btn_in => btnc, btn_press => sig_play_pause_pulse, btn_state => open);

    debounce_left : debounce
        port map (clk => clk, rst => '0', btn_in => btnl, btn_press => sig_reset_pulse, btn_state => open);

    debounce_right : debounce
        port map (clk => clk, rst => '0', btn_in => btnr, btn_press => sig_color_pulse, btn_state => open);

    ------------------------------------------------------------------------
    -- 1Hz Clock Enable
    ------------------------------------------------------------------------
    clock_1hz : clk_en
        --for actual use -> 1 second
        --generic map ( G_MAX => 100_000_000 )
        --for simulation -> 1 "second" takes 4 cycles
        generic map ( G_MAX => 100_000_000 )
        port map (clk => clk, rst => '0', ce  => ce_1hz);

    ------------------------------------------------------------------------
    -- Main Process
    ------------------------------------------------------------------------
    p_timer : process(clk)
    begin
        if rising_edge(clk) then

            -- COLOR SELECTOR (Cycles 0 to 6)
            -- color is only visible, when the alarm clock time rouns out.
            if sig_color_pulse = '1' then
                if color_state < 6 then color_state <= color_state + 1;
                else color_state <= 0; end if;
            end if;

            -- PLAY / PAUSE
            -- simple yes or no case, stops the alarm clock (or starts it)
            if sig_play_pause_pulse = '1' then
                if is_zero = '1' then is_zero <= '0';
                else counting_down <= not counting_down; end if;
            end if;

            --------------------------------------------
            -- PAUSED / SETUP MODE
            -- Logic for time up to 23:59:59
            --------------------------------------------
            if counting_down = '0' then
                if sig_reset_pulse = '1' then
                    sec0 <= 0; sec1 <= 0; min0 <= 0; min1 <= 0; hr0 <= 0; hr1 <= 0;
                    is_zero <= '0';

                elsif sig_inc_pulse = '1' then
                    if sec0 < 9 then sec0 <= sec0 + 1; else sec0 <= 0;
                        if sec1 < 5 then sec1 <= sec1 + 1; else sec1 <= 0;
                            if min0 < 9 then min0 <= min0 + 1; else min0 <= 0;
                                if min1 < 5 then min1 <= min1 + 1; else min1 <= 0;
                                    if hr0 < 9 then
                                        if hr1 = 2 and hr0 = 3 then hr0 <= 0; hr1 <= 0;
                                        else hr0 <= hr0 + 1; end if;
                                    else hr0 <= 0; hr1 <= hr1 + 1; end if;
                                end if;
                            end if;
                        end if;
                    end if;

                elsif sig_dec_pulse = '1' then
                    if sec0 > 0 then sec0 <= sec0 - 1; else sec0 <= 9;
                        if sec1 > 0 then sec1 <= sec1 - 1; else sec1 <= 5;
                            if min0 > 0 then min0 <= min0 - 1; else min0 <= 9;
                                if min1 > 0 then min1 <= min1 - 1; else min1 <= 5;
                                    if hr0 > 0 then hr0 <= hr0 - 1; else
                                        if hr1 > 0 then hr0 <= 9; hr1 <= hr1 - 1;
                                        else hr0 <= 3; hr1 <= 2; end if;
                                    end if;
                                end if;
                            end if;
                        end if;
                    end if;
                end if;

            --------------------------------------------
            -- COUNTDOWN MODE
            --------------------------------------------
            else
                if ce_1hz = '1' then
                    if (sec0 = 0 and sec1 = 0 and min0 = 0 and min1 = 0 and hr0 = 0 and hr1 = 0) then
                        is_zero <= '1';
                        counting_down <= '0';
                    else
                        if sec0 > 0 then sec0 <= sec0 - 1; else sec0 <= 9;
                            if sec1 > 0 then sec1 <= sec1 - 1; else sec1 <= 5;
                                if min0 > 0 then min0 <= min0 - 1; else min0 <= 9;
                                    if min1 > 0 then min1 <= min1 - 1; else min1 <= 5;
                                        if hr0 > 0 then hr0 <= hr0 - 1; else hr0 <= 9; hr1 <= hr1 - 1;
                                        end if;
                                    end if;
                                end if;
                            end if;
                        end if;
                    end if;
                end if;
            end if;
        end if;
    end process;

    ------------------------------------------------------------------------
    -- RGB Color Mixer (Combinational Logic)
    ------------------------------------------------------------------------
    process(is_zero, color_state)
    begin
        -- Default to OFF
        led16_r <= '0'; led16_g <= '0'; led16_b <= '0';

        if is_zero = '1' then
            case color_state is
                when 0 => led16_r <= '1';                                  -- Red
                when 1 => led16_g <= '1';                                  -- Green
                when 2 => led16_b <= '1';                                  -- Blue
                when 3 => led16_r <= '1'; led16_g <= '1';                  -- Yellow
                when 4 => led16_g <= '1'; led16_b <= '1';                  -- Cyan
                when 5 => led16_r <= '1'; led16_b <= '1';                  -- Magenta
                when 6 => led16_r <= '1'; led16_g <= '1'; led16_b <= '1';  -- White
                when others => led16_r <= '1';
            end case;
        end if;
    end process;

    ------------------------------------------------------------------------
    -- Other Outputs
    ------------------------------------------------------------------------
    led <= (others => '0'); -- Hardcodes standard LEDs to strictly OFF
    dp  <= '1';             -- Disable decimal points

    disp_data <= std_logic_vector(to_unsigned(hr1, 4)) & std_logic_vector(to_unsigned(hr0, 4)) &
                 std_logic_vector(to_unsigned(min1, 4)) & std_logic_vector(to_unsigned(min0, 4)) &
                 std_logic_vector(to_unsigned(sec1, 4)) & std_logic_vector(to_unsigned(sec0, 4));

    display_0 : display_driver
        port map (
            data  => disp_data, clk => clk, rst => '0',
            seg   => seg, anode => an(5 downto 0)
        );

    an(7 downto 6) <= "11"; -- Disable the two leftmost 7-segment displays (unecessary)

end Behavioral;
