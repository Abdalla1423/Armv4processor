--------------------------------------------------------------------------------
--	Schaltung fuer das Zaehlen von Einsen in einem 16-Bit-Vektor, realisiert
-- 	als Baum von Addierern.
--------------------------------------------------------------------------------
--	Datum:		??.??.2013
--	Version:	?.??
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ArmRegisterBitAdder is
	Port (
		RBA_REGLIST 	: in  std_logic_vector(15 downto 0);
		RBA_NR_OF_REGS 	: out  std_logic_vector(4 downto 0)
	);
end entity ArmRegisterBitAdder;

architecture structure of ArmRegisterBitAdder is
type t_ebene0 is array (7 downto 0) of unsigned(1 downto 0);
type t_ebene1 is array (3 downto 0) of unsigned(2 downto 0);
type t_ebene2 is array (1 downto 0) of unsigned(3 downto 0);

signal ebene0 : t_ebene0;
signal ebene1 : t_ebene1;
signal ebene2 : t_ebene2;
begin

	--ebene 0
	ebene0(7) <= ('0' &  RBA_REGLIST(15)) + ('0' & RBA_REGLIST(14));
	ebene0(6) <= ('0' &  RBA_REGLIST(13)) + ('0' & RBA_REGLIST(12));
	ebene0(5) <= ('0' &  RBA_REGLIST(11)) + ('0' & RBA_REGLIST(10));
	ebene0(4) <= ('0' &  RBA_REGLIST(9)) + ('0' & RBA_REGLIST(8));
	ebene0(3) <= ('0' &  RBA_REGLIST(7)) + ('0' & RBA_REGLIST(6));
	ebene0(2) <= ('0' &  RBA_REGLIST(5)) + ('0' & RBA_REGLIST(4));
	ebene0(1) <= ('0' &  RBA_REGLIST(3)) + ('0' & RBA_REGLIST(2));
	ebene0(0) <= ('0' &  RBA_REGLIST(1)) + ('0' & RBA_REGLIST(0));
	
	--ebene 1 
	ebene1(3) <= ('0' & ebene0(7)) + ('0' & ebene0(6));
	ebene1(2) <= ('0' & ebene0(5)) + ('0' & ebene0(4));
	ebene1(1) <= ('0' & ebene0(3)) + ('0' & ebene0(2));
	ebene1(0) <= ('0' & ebene0(1)) + ('0' & ebene0(0));
	
	--ebene 2
	ebene2(1) <= ('0' & ebene1(3)) + ('0' & ebene1(2));
	ebene2(0) <= ('0' & ebene1(1)) + ('0' & ebene1(0));
	
	--Ergebnis
	RBA_NR_OF_REGS <= std_logic_vector(('0' & ebene2(1)) + ('0' & ebene2(0)));
	
end architecture structure;
