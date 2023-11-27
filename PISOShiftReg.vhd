--------------------------------------------------------------------------------
-- PISO-Schieberegister als mögliche Grundlage für die Implementierung der RS232-
-- Schnittstelle im Hardwarepraktikum
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity PISOShiftReg is
	generic(
		WIDTH	 : integer := 8
	);
	port(
		CLK	     : in std_logic;
		CLK_EN	 : in std_logic;
		LOAD	 : in std_logic;
		D_IN	 : in std_logic_vector(WIDTH-1 downto 0);
		D_OUT	 : out std_logic; -- (niederwertigste BIT!) Datenausgang des Schieberegister
		LAST_BIT : out std_logic
	);
end entity PISOShiftReg;

architecture behavioral of PISOShiftReg is
	signal shift_reg : std_logic_vector(WIDTH-1 downto 0);
	signal COUNT : integer := WIDTH-1;
begin
	D_OUT <= shift_reg(0);

	with COUNT select LAST_BIT <=
		'1' when 0,
		'0' when others;

	-- taktsynchron ein Eingangsdatum (D_IN) lesen und im internen Speicher (shift_reg) 
	process (CLK) 
	begin
		if (rising_edge(CLK) and CLK_EN = '1') then
			if (LOAD = '1') then 
				shift_reg <= D_IN;
				COUNT <= WIDTH-1;
			else 
				shift_reg <= '0' & shift_reg(WIDTH-1 downto 1); -- right shift
				if (COUNT > 0) then COUNT <= COUNT -1; end if;
			end if;
		end if;
	end process;
end architecture behavioral;