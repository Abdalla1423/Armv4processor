--------------------------------------------------------------------------------
--	Decoder zur Ermittlung der Instruktionsgruppe der aktuellen
--	Instruktion im der ID-Stufe im Kontrollpfad des HWPR-Prozessors.
--------------------------------------------------------------------------------
--	Datum:		??.??.2014
--	Version:	?.?
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

library work;
use work.ArmTypes.all;

--------------------------------------------------------------------------------
--	17 Instruktionsgruppen:
--	CD_UNDEFINED
--	CD_SWI
--	CD_COPROCESSOR
--	CD_BRANCH
--	CD_LOAD_STORE_MULTIPLE
--	CD_LOAD_STORE_UNSIGNED_IMMEDIATE
--	CD_LOAD_STORE_UNSIGNED_REGISTER
--	CD_LOAD_STORE_SIGNED_IMMEDIATE
--	CD_LOAD_STORE_UNSIGNED_REGISTER
--	CD_ARITH_IMMEDIATE
--	CD_ARITH_REGISTER
--	CD_ARITH_REGISTER_REGISTER
--	CD_MSR_IMMEDIATE
--	CD_MSR_REGISTER
--	CD_MRS
--	CD_MULTIPLY
--	CD_SWAP

-- 	UNDEFINED wird durch den Nullvektor angezeigt, die anderen
--	Befehlsgruppen durch einen 1-aus-16-Code.
--------------------------------------------------------------------------------

entity ArmCoarseInstructionDecoder is
	port(
		CID_INSTRUCTION		: in std_logic_vector(31 downto 0);
		CID_DECODED_VECTOR	: out std_logic_vector(15 downto 0)
	    );
end entity ArmCoarseInstructionDecoder;

architecture behave of ArmCoarseInstructionDecoder is
	signal DECV	: COARSE_DECODE_TYPE; -- std_logic_vector(15 downto 0);
--	...

begin
	CID_DECODED_VECTOR	<= DECV;
--	...
	-- 27:20) und (7:4) : 12 Bits eindeutige ID von Instruktion
	DECV
		<= CD_SWI 
			when CID_INSTRUCTION(27 downto 25) = "111" 
			and CID_INSTRUCTION(24) = '1'
		else CD_COPROCESSOR 
			when CID_INSTRUCTION(27 downto 25) = "111" and CID_INSTRUCTION(24) = '0'
		else CD_COPROCESSOR
			when CID_INSTRUCTION(27 downto 25) = "110"
		else CD_BRANCH 
			when CID_INSTRUCTION(27 downto 25) = "101"
		else CD_LOAD_STORE_MULTIPLE 
			when CID_INSTRUCTION(27 downto 25) = "100"
		else CD_LOAD_STORE_UNSIGNED_REGISTER 
			when CID_INSTRUCTION(27 downto 25) = "011" 
			and CID_INSTRUCTION(24) = '0'
		else CD_LOAD_STORE_UNSIGNED_IMMEDIATE
			when CID_INSTRUCTION(27 downto 25) = "010"
		else CD_MSR_IMMEDIATE 
			when CID_INSTRUCTION(27 downto 25) = "001" 
			and CID_INSTRUCTION(24 downto 23) = "10" 
			and CID_INSTRUCTION(21 downto 20) = "10"
		else CD_ARITH_IMMEDIATE 
			when CID_INSTRUCTION(27 downto 25) = "001" 
			and (
				CID_INSTRUCTION(24 downto 23) = "10" 
				and (CID_INSTRUCTION(21 downto 20) = "01" or CID_INSTRUCTION(21 downto 20) = "11") 
				and CID_INSTRUCTION(24 downto 23) /= "10"
			)
		else CD_MULTIPLY 
			when CID_INSTRUCTION(27 downto 25) = "000"
			and CID_INSTRUCTION(7) = '1' and CID_INSTRUCTION(4) = '1'
			and CID_INSTRUCTION(6 downto 5) = "00"
			and CID_INSTRUCTION(24) = '0'
		else CD_SWAP 
			when CID_INSTRUCTION(27 downto 25) = "000"
			and CID_INSTRUCTION(7) = '1' and CID_INSTRUCTION(4) = '1'
			and CID_INSTRUCTION(6 downto 5) = "00"
			and CID_INSTRUCTION(24) = '1'
			and CID_INSTRUCTION(23) = '0' and CID_INSTRUCTION(21 downto 20) = "00"
		else CD_LOAD_STORE_SIGNED_IMMEDIATE
			when CID_INSTRUCTION(27 downto 25) = "000"
			and CID_INSTRUCTION(7) = '1' and CID_INSTRUCTION(4) = '1'
			and CID_INSTRUCTION(6 downto 5) /= "00"
			and CID_INSTRUCTION(20) = '0' and CID_INSTRUCTION(6) = '1'
			and CID_INSTRUCTION(22) = '1'
		else CD_LOAD_STORE_SIGNED_REGISTER
			when CID_INSTRUCTION(27 downto 25) = "000"
			and CID_INSTRUCTION(7) = '1' and CID_INSTRUCTION(4) = '1'
			and CID_INSTRUCTION(6 downto 5) /= "00"
			and CID_INSTRUCTION(20) = '0' and CID_INSTRUCTION(6) = '1'
			and CID_INSTRUCTION(22) = '0'
		else CD_ARITH_REGISTER
			when CID_INSTRUCTION(27 downto 25) = "000"
			and CID_INSTRUCTION(7) = '1' and CID_INSTRUCTION(4) = '0'
			and (
				(CID_INSTRUCTION(24 downto 23) = "10"
					and CID_INSTRUCTION(20) = '1')
				or CID_INSTRUCTION(24 downto 23) /= "10"
			)
		else CD_ARITH_REGISTER_REGISTER 
			when CID_INSTRUCTION(27 downto 25) = "000"
			and CID_INSTRUCTION(7) = '0' and CID_INSTRUCTION(4) = '1'
			and (
				(CID_INSTRUCTION(24 downto 23) = "10" 
					and CID_INSTRUCTION(20) = '1')
				or CID_INSTRUCTION(24 downto 23) /= "10" 
			)
		else CD_ARITH_REGISTER 
			when CID_INSTRUCTION(27 downto 25) = "000"
			and CID_INSTRUCTION(7) = '0' and CID_INSTRUCTION(4) = '0'
			and (
				(CID_INSTRUCTION(24 downto 23) = "10" 
					and CID_INSTRUCTION(20) = '1')
				or CID_INSTRUCTION(24 downto 23) /= "10" 
			)
		else CD_MSR_REGISTER
			when CID_INSTRUCTION(27 downto 25) = "000"
			and CID_INSTRUCTION(7) = '0' and CID_INSTRUCTION(4) = '0'
			and CID_INSTRUCTION(24 downto 23) = "10" 
			and CID_INSTRUCTION(20) = '0'
			and CID_INSTRUCTION(21) = '1'
		else CD_MRS
			when CID_INSTRUCTION(27 downto 25) = "000"
			and CID_INSTRUCTION(7) = '0' and CID_INSTRUCTION(4) = '0'
			and CID_INSTRUCTION(24 downto 23) = "10" 
			and CID_INSTRUCTION(20) = '0'
			and CID_INSTRUCTION(21) = '0'
		else CD_UNDEFINED;

--------------------------------------------------------------------------------
--	Test fuer die Verhaltenssimulation.
--------------------------------------------------------------------------------
-- synthesis translate_off
 	CHECK_NR_OF_SIGNALS : process(CID_INSTRUCTION,DECV)IS
 		variable NR : integer range 0 to 16 := 0;
 	begin
 		NR := 0;
 		for i in DECV'range loop
 			if DECV(i) = '1' then
 				NR := NR + 1;
 			end if;
 		end loop;
  		assert NR <= 1 report "Fehler in ArmCoarseInstructionDecoder: Instruktion nicht eindeutig erkannt." severity error;
 	end process CHECK_NR_OF_SIGNALS;
-- synthesis translate_on
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
end architecture behave;