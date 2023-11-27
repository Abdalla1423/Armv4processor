--------------------------------------------------------------------------------
--	Testbench-Vorlage des HWPR-Bitaddierers.
--------------------------------------------------------------------------------
--	Datum:		??.??.2013
--	Version:	?.??
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--------------------------------------------------------------------------------
--	In TB_TOOLS kann, wenn gewuenscht die Funktion SLV_TO_STRING() zur
--	Ermittlung der Stringrepraesentation eines std_logic_vektor verwendet
--	werden und SEPARATOR_LINE fuer eine horizontale Trennlinie in Ausgaben.
--------------------------------------------------------------------------------
library work;
use work.TB_TOOLS.all;

entity ArmRegisterBitAdder_TB is
end ArmRegisterBitAdder_TB;

architecture testbench of ArmRegisterBitAdder_tb is 
	signal REGLIST : std_logic_vector (15 downto 0);
	signal NR_OF_REGS : std_logic_vector(4 downto 0);
	component ArmRegisterBitAdder
	port(
		RBA_REGLIST	: in std_logic_vector(15 downto 0);          
		RBA_NR_OF_REGS	: out std_logic_vector(4 downto 0)
		);
	end component ArmRegisterBitAdder;


begin
--	Unit Under Test
	UUT: ArmRegisterBitAdder port map(
		RBA_REGLIST	=> REGLIST,
		RBA_NR_OF_REGS	=> NR_OF_REGS
	);
	


--	Testprozess
	tb : process is
		type t_test_list is array (0 to 16) of std_logic_vector(15 downto 0);
		variable test_list : t_test_list := (x"0000", x"0001", x"0003", x"0007", x"000F", x"001F", x"003F",x"007F", x"00FF", x"01FF", x"03FF", x"07FF", x"0FFF", x"1FFF", x"3FFF", x"7FFF", x"FFFF");
		variable num_success : integer := 0;
		variable stable_signal : boolean := false;
	begin
		
--		...
		REGLIST <= (others => '0');
		wait for 100 ns;
		for i in 0 to 16 loop
			-- Intialising value
			REGLIST <= test_list(i);			
			wait for 11 ns; -- puffer zeit fu2r berechnung 
			--Validating output
			assert(to_integer(unsigned(NR_OF_REGS)) = i) report "Error: Expected " & integer'image(i) & ". Got: " & integer'image(to_integer(unsigned(NR_OF_REGS)));
			
			-- stability
			wait for 10 ns;
			stable_signal := NR_OF_REGS'stable(10 ns);
			assert(stable_signal) report "Error signal not stable";
			
			-- for correct testcase
			if (to_integer(unsigned(NR_OF_REGS)) = i) and stable_signal then 
				num_success := num_success + 1;
			end if;
		end loop;

		if num_success = 17 then
			report "Funktionstest bestanden";
		else
			report "Funktionstest NICHT bestanden";
		end if;

		report "Es waren " & integer'image(num_success) & " von 17 Testcases korrekt";	
  

		report SEPARATOR_LINE;	
		report " EOT (END OF TEST) - Diese Fehlermeldung stoppt den Simulator unabhaengig von tatsaechlich aufgetretenen Fehlern!" severity failure; 
--	Unbegrenztes Anhalten des Testbench Prozess
		wait;
	end process tb;
end architecture testbench;

