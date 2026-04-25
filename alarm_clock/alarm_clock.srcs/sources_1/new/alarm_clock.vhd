----------------------------------------------------------------------------------
-- Component Name: alarm_clock
-- Description:
--   Core state machine and timekeeping logic for the 24-hour alarm clock.
--   Handles setup modes (Seconds/Minutes/Hours), manual increment/decrement
--   with unit wrap-around, real-time countdown, and alarm triggering.
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity alarm_clock is
    Port (
        clk            : in  STD_LOGIC;
        sig_reset      : in  STD_LOGIC; -- Resets clock to 00:00:00
        sig_inc        : in  STD_LOGIC; -- Increment currently selected unit
        sig_dec        : in  STD_LOGIC; -- Decrement currently selected unit
        sig_mode       : in  STD_LOGIC; -- Cycle edit mode (Sec -> Min -> Hr)
        sig_play_pause : in  STD_LOGIC; -- Toggle countdown or silence alarm
        ce_1hz         : in  STD_LOGIC; -- 1 Hz enable pulse for real-time counting

        disp_data      : out STD_LOGIC_VECTOR(23 downto 0); -- Packed BCD for displays
        alarm_active   : out STD_LOGIC                      -- High when timer hits 0
    );
end alarm_clock;

architecture Behavioral of alarm_clock is

    -- Timekeeping counters
    signal sec0 : integer range 0 to 9 := 0;
    signal sec1 : integer range 0 to 5 := 0;
    signal min0 : integer range 0 to 9 := 0;
    signal min1 : integer range 0 to 5 := 0;
    signal hr0  : integer range 0 to 9 := 0;
    signal hr1  : integer range 0 to 2 := 0;

    -- State machine control flags
    signal counting_down : std_logic := '0';
    signal is_zero       : std_logic := '0';
    signal edit_mode     : integer range 0 to 2 := 0; -- 0: Sec, 1: Min, 2: Hr

begin

    p_timer : process(clk)
    begin
        if rising_edge(clk) then
            if sig_reset = '1' then 
                -- 1. Synchronous Reset First
                sec0 <= 0; sec1 <= 0; min0 <= 0; min1 <= 0; hr0 <= 0; hr1 <= 0;
                is_zero <= '0'; edit_mode <= 0; counting_down <= '0';
            else
            -- Play / Pause / Silence Logic
            if sig_play_pause = '1' then
                if is_zero = '1' then
                    is_zero <= '0'; -- Silence the alarm
                else
                    counting_down <= not counting_down; -- Toggle play/pause
                end if;
            end if;

            --------------------------------------------
            -- SETUP MODE (Paused)
            --------------------------------------------
            if counting_down = '0' then

                -- Mode Selector
                if sig_mode = '1' then
                    if edit_mode < 2 then edit_mode <= edit_mode + 1; else edit_mode <= 0; end if;
                end if;

                -- Reset Clock
                if sig_reset = '1' then
                    sec0 <= 0; sec1 <= 0; min0 <= 0; min1 <= 0; hr0 <= 0; hr1 <= 0;
                    is_zero <= '0'; edit_mode <= 0;

                -- Increment Unit
                elsif sig_inc = '1' then
                    if edit_mode = 0 then
                        if sec0 < 9 then sec0 <= sec0 + 1; else sec0 <= 0;
                            if sec1 < 5 then sec1 <= sec1 + 1; else sec1 <= 0; end if; end if;
                    elsif edit_mode = 1 then
                        if min0 < 9 then min0 <= min0 + 1; else min0 <= 0;
                            if min1 < 5 then min1 <= min1 + 1; else min1 <= 0; end if; end if;
                    elsif edit_mode = 2 then
                        if hr0 < 9 then
                            if hr1 = 2 and hr0 = 3 then hr0 <= 0; hr1 <= 0; else hr0 <= hr0 + 1; end if;
                        else hr0 <= 0; hr1 <= hr1 + 1; end if;
                    end if;

                -- Decrement Unit
                elsif sig_dec = '1' then
                    if edit_mode = 0 then
                        if sec0 > 0 then sec0 <= sec0 - 1; else sec0 <= 9;
                            if sec1 > 0 then sec1 <= sec1 - 1; else sec1 <= 5; end if; end if;
                    elsif edit_mode = 1 then
                        if min0 > 0 then min0 <= min0 - 1; else min0 <= 9;
                            if min1 > 0 then min1 <= min1 - 1; else min1 <= 5; end if; end if;
                    elsif edit_mode = 2 then
                        if hr0 > 0 then hr0 <= hr0 - 1; else
                            if hr1 > 0 then hr0 <= 9; hr1 <= hr1 - 1; else hr0 <= 3; hr1 <= 2; end if; end if;
                    end if;
                end if;

            --------------------------------------------
            -- COUNTDOWN MODE (Running)
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
                                        if hr0 > 0 then hr0 <= hr0 - 1; else hr0 <= 9; hr1 <= hr1 - 1; end if;
                                    end if; end if; end if; end if;
                    end if;
                end if;
            end if;
        end if;
    end process;

    -- Output mappings
    alarm_active <= is_zero;

    -- Pack discrete BCD digits into a single 24-bit bus for the display driver
    disp_data <= std_logic_vector(to_unsigned(hr1, 4)) & std_logic_vector(to_unsigned(hr0, 4)) &
                 std_logic_vector(to_unsigned(min1, 4)) & std_logic_vector(to_unsigned(min0, 4)) &
                 std_logic_vector(to_unsigned(sec1, 4)) & std_logic_vector(to_unsigned(sec0, 4));

end Behavioral;
