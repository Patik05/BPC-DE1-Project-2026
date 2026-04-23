library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity alarm_clock_tb is
end alarm_clock_tb;

architecture Behavioral of alarm_clock_tb is

    component alarm_clock
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
    end component;

    signal clk            : std_logic := '0';
    signal sig_reset      : std_logic := '0';
    signal sig_inc        : std_logic := '0';
    signal sig_dec        : std_logic := '0';
    signal sig_mode       : std_logic := '0';
    signal sig_play_pause : std_logic := '0';
    signal ce_1hz         : std_logic := '0';

    signal disp_data      : std_logic_vector(23 downto 0);
    signal alarm_active   : std_logic;

    constant clk_period : time := 10 ns;
    signal sim_ended : boolean := false;

begin

    uut: alarm_clock Port map (
          clk            => clk,
          sig_reset      => sig_reset,
          sig_inc        => sig_inc,
          sig_dec        => sig_dec,
          sig_mode       => sig_mode,
          sig_play_pause => sig_play_pause,
          ce_1hz         => ce_1hz,
          disp_data      => disp_data,
          alarm_active   => alarm_active
        );

    clk_process :process
    begin
        if not sim_ended then
            clk <= '0'; wait for clk_period/2;
            clk <= '1'; wait for clk_period/2;
        else wait; end if;
    end process;

    stim_proc: process
    begin
        wait for 50 ns;

        -- 1. Initial Reset
        sig_reset <= '1'; wait for clk_period; sig_reset <= '0'; wait for 50 ns;

        -- 2. Add 3 seconds (No need to wait long, the core accepts 1-cycle pulses)
        for i in 1 to 3 loop
            sig_inc <= '1'; wait for clk_period; sig_inc <= '0'; wait for clk_period;
        end loop;

        -- 3. Switch to Minutes mode
        sig_mode <= '1'; wait for clk_period; sig_mode <= '0'; wait for clk_period;

        -- 4. Add 1 minute (Time is now 00:01:03)
        sig_inc <= '1'; wait for clk_period; sig_inc <= '0'; wait for 50 ns;

        -- 5. Start the countdown
        sig_play_pause <= '1'; wait for clk_period; sig_play_pause <= '0'; wait for 50 ns;

        -- 6. Artificially accelerate time!
        -- Instead of waiting 100,000,000 clock cycles, we just pulse ce_1hz 64 times.
        -- This will run a 64 "second" countdown in just over 1,000 nanoseconds.
        for i in 1 to 64 loop
            ce_1hz <= '1'; wait for clk_period;
            ce_1hz <= '0'; wait for 20 ns;
        end loop;

        -- 7. Silence the alarm
        sig_play_pause <= '1'; wait for clk_period; sig_play_pause <= '0'; wait for 50 ns;

        sim_ended <= true;
        wait;
    end process;

end Behavioral;
