library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity buzzer_module_tb is
end buzzer_module_tb;

architecture Behavioral of buzzer_module_tb is

    component buzzer_module
        Port ( clk        : in  STD_LOGIC;
               en         : in  STD_LOGIC;
               buzzer_out : out STD_LOGIC);
    end component;

    signal clk        : std_logic := '0';
    signal en         : std_logic := '0';
    signal buzzer_out : std_logic;

    constant clk_period : time := 10 ns;
    signal sim_ended : boolean := false;

begin

    uut: buzzer_module Port map (
          clk        => clk,
          en         => en,
          buzzer_out => buzzer_out
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
        -- 1. Check disabled state (Should remain flat at 0)
        en <= '0';
        wait for 100 ns;

        -- 2. Trigger the alarm
        en <= '1';

        -- Wait 300ns to observe the generated square wave pattern
        -- If C_MAX is set to 2, it will toggle every 20ns.
        wait for 300 ns;

        -- 3. Silence the alarm
        en <= '0';

        -- Observe that the signal drops to 0 instantly and stays there
        wait for 100 ns;

        sim_ended <= true;
        wait;
    end process;

end Behavioral;
