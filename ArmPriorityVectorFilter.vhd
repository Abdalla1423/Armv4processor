--------------------------------------------------------------------------------
--	Prioritaetsencoder fuer das Finden des niederwertigsten
-- 	gesetzten Bits in einem 16-Bit-Vektor.
--------------------------------------------------------------------------------
--	Datum:		??.??.2013
--	Version:	?.??
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity ArmPriorityVectorFilter is
	port(
		PVF_VECTOR_UNFILTERED	: in std_logic_vector(15 downto 0);
		PVF_VECTOR_FILTERED	: out std_logic_vector(15 downto 0)
	    );
end entity ArmPriorityVectorFilter;

architecture structure of ArmPriorityVectorFilter is

begin
	PVF_VECTOR_FILTERED <= 
		"0000000000000001" when PVF_VECTOR_UNFILTERED(0) = '1' else 
		"0000000000000010" when PVF_VECTOR_UNFILTERED(1) = '1' else 
		"0000000000000100" when PVF_VECTOR_UNFILTERED(2) = '1' else 
		"0000000000001000" when PVF_VECTOR_UNFILTERED(3) = '1' else 
		"0000000000010000" when PVF_VECTOR_UNFILTERED(4) = '1' else 
		"0000000000100000" when PVF_VECTOR_UNFILTERED(5) = '1' else 
		"0000000001000000" when PVF_VECTOR_UNFILTERED(6) = '1' else 
		"0000000010000000" when PVF_VECTOR_UNFILTERED(7) = '1' else 
		"0000000100000000" when PVF_VECTOR_UNFILTERED(8) = '1' else 
		"0000001000000000" when PVF_VECTOR_UNFILTERED(9) = '1' else 
		"0000010000000000" when PVF_VECTOR_UNFILTERED(10) = '1' else 
		"0000100000000000" when PVF_VECTOR_UNFILTERED(11) = '1' else 
		"0001000000000000" when PVF_VECTOR_UNFILTERED(12) = '1' else 
		"0010000000000000" when PVF_VECTOR_UNFILTERED(13) = '1' else 
		"0100000000000000" when PVF_VECTOR_UNFILTERED(14) = '1' else 
		"1000000000000000" when PVF_VECTOR_UNFILTERED(15) = '1' else 
		"0000000000000000";
end architecture structure;

