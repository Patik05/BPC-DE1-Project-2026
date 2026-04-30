library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity display_driver_tb is
end display_driver_tb;

architecture Behavioral of display_driver_tb is

    -- Component Declaration
    component display_driver
        Port ( clk   : in STD_LOGIC;
               rst   : in STD_LOGIC;
               data  : in STD_LOGIC_VECTOR (23 downto 0);
               seg   : out STD_LOGIC_VECTOR (6 downto 0);
               anode : out STD_LOGIC_VECTOR (5 downto 0);
               dp    : out STD_LOGIC);
    end component;

    -- Inputs
    signal clk  : std_logic := '0';
    signal rst  : std_logic := '0';
    signal data : std_logic_vector(23 downto 0) := (others => '0');

    -- Outputs
    signal seg   : std_logic_vector(6 downto 0);
    signal anode : std_logic_vector(5 downto 0);
    signal dp    : std_logic;

    -- Clock period definition
    constant clk_period : time := 10 ns;

begin

    -- Instantiate the Unit Under Test (UUT)
    uut: display_driver Port map (
          clk   => clk,
          rst   => rst,
          data  => data,
          seg   => seg,
          anode => anode,
          dp    => dp
        );


    -- Stimulus process
    stim_proc: process
    begin
        -- 1. Hold reset state for 50 ns.
        rst <= '1';
        wait for 50 ns;
        rst <= '0';
        wait for 50 ns;

        -- 2. Test Pattern 1: Time is "12:34:56"
        -- In Hex: 1=x"1", 2=x"2", 3=x"3", 4=x"4", 5=x"5", 6=x"6"
        data <= x"123456";
.
        wait for 200 ns;

        -- 3. Test Pattern 2: Time is "09:00:00"
        data <= x"090000";

        wait for 200 ns;
        
        data <= x"000000";

        wait for 200 ns;

        wait;
    end process;

end Behavioral;
