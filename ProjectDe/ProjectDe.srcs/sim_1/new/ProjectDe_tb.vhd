library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ProjectDe_tb is
end ProjectDe_tb;

architecture Behavioral of ProjectDe_tb is

    component ProjectDe
        Port ( clk      : in STD_LOGIC;
               btnu     : in STD_LOGIC;
               btnc     : in STD_LOGIC;
               btnl     : in STD_LOGIC;
               btnr     : in STD_LOGIC;
               btnd     : in STD_LOGIC;
               seg      : out STD_LOGIC_VECTOR( 6 downto 0);
               an       : out STD_LOGIC_VECTOR( 7 downto 0);
               dp       : out STD_LOGIC;
               led      : out STD_LOGIC_VECTOR (7 downto 0);
               led16_r  : out STD_LOGIC;
               led16_g  : out STD_LOGIC;
               led16_b  : out STD_LOGIC);
    end component;

    signal clk, btnu, btnc, btnl, btnr, btnd : std_logic := '0';
    signal seg : std_logic_vector(6 downto 0);
    signal an : std_logic_vector(7 downto 0);
    signal dp, led16_r, led16_g, led16_b : std_logic;
    signal led : std_logic_vector(7 downto 0);

    constant clk_period : time := 10 ns;
    signal sim_ended : boolean := false;

begin

    uut: ProjectDe Port map (
          clk=>clk, btnu=>btnu, btnc=>btnc, btnl=>btnl, btnr=>btnr, btnd=>btnd,
          seg=>seg, an=>an, dp=>dp, led=>led,
          led16_r=>led16_r, led16_g=>led16_g, led16_b=>led16_b
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
        -- 1. TEST COLOR CHANGE
        report "Pressing Right (btnr) 4 times to change alarm color to Cyan";
        for i in 1 to 4 loop
            btnr <= '1'; wait for 40 ns; btnr <= '0'; wait for 40 ns;
        end loop;

        -- 2. TEST INCREMENT
        report "Pressing Up (btnu) 2 times -> 00:00:02";
        for i in 1 to 2 loop
            btnu <= '1'; wait for 40 ns; btnu <= '0'; wait for 40 ns;
        end loop;

        -- 3. START ALARM
        report "Pressing Center (btnc) to start clock";
        btnc <= '1'; wait for 40 ns; btnc <= '0';

        -- Wait for clock to hit 0 and turn on LED (with Cyan color)
        wait for 3000 ns;

        report "Simulation Finished.";
        sim_ended <= true;
        wait;
    end process;

end Behavioral;
