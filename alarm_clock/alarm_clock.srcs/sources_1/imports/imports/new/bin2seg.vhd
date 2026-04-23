library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
----------------------------------------------------
entity bin2seg is
    Port ( bin : in STD_LOGIC_VECTOR (3 downto 0);
           seg : out STD_LOGIC_VECTOR (6 downto 0));
end bin2seg;
----------------------------------------------------
architecture Behavioral of bin2seg is

begin

-- This combinational process decodes binary input
-- `bin` into 7-segment display output `seg` for a
-- Common Anode configuration (active-low outputs).
-- The process is triggered whenever `bin` changes.

p_7seg_decoder : process (bin) is
begin
    case bin is
        when x"0" =>
            seg <= "0000001";
        when x"1" =>
            seg <= "1001111";
        when x"2" =>
            seg <= "0010010";
        when x"3" =>
            seg <= "0000110";
        when x"4" =>
            seg <= "1001100";
        when x"5" =>
            seg <= "0100100";
        when x"6" =>
            seg <= "0100000";
        when x"7" =>
            seg <= "0001111";
        when x"8" =>
            seg <= "0000000";
        when x"9" =>
            seg <= "0000100";
        -- Default case (e.g., for values that would go above number 9)
        when others =>
            seg <= "0000001";
    end case;
end process p_7seg_decoder;

end Behavioral;
