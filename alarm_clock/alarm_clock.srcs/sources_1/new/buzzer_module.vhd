library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity buzzer_module is
    Port ( clk        : in  STD_LOGIC;
           en         : in  STD_LOGIC;
           buzzer_out : out STD_LOGIC);
end buzzer_module;

architecture Behavioral of buzzer_module is

    -- Nexys A7 Clock is 100 MHz.
    -- Target audible frequency: 2,000 Hz (2 kHz)
    -- 100,000,000 / 2,000 = 50,000 clock cycles per full wave.
    -- To get a 50% duty cycle square wave, we toggle the output every 25,000 cycles.
    constant C_MAX : integer := 25000;
    --constant C_MAX : integer := 2; --for simulation

    signal cnt    : integer range 0 to C_MAX := 0;
    signal toggle : std_logic := '0';

begin

    p_buzzer : process(clk)
    begin
        if rising_edge(clk) then
            if en = '1' then
                -- Generate Square Wave
                if cnt = C_MAX - 1 then
                    cnt <= 0;
                    toggle <= not toggle; -- Flip the output (0 -> 1 -> 0)
                else
                    cnt <= cnt + 1;
                end if;
            else
                -- Keep buzzer silent when disabled
                cnt <= 0;
                toggle <= '0';
            end if;
        end if;
    end process;

    buzzer_out <= toggle;

end Behavioral;
