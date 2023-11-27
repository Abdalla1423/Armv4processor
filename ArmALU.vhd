--------------------------------------------------------------------------------
--	ALU des ARM-Datenpfades
--------------------------------------------------------------------------------
--	Datum:		??.??.14
--	Version:	?.?
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.ArmTypes.all;

entity ArmALU is
    Port ( ALU_OP1 		: in	std_logic_vector(31 downto 0);
           ALU_OP2 		: in 	std_logic_vector(31 downto 0);           
    	   ALU_CTRL 	: in	std_logic_vector(3 downto 0);
    	   ALU_CC_IN 	: in	std_logic_vector(1 downto 0); --(1) = carry in; (0) = overflow
		   ALU_RES 		: out	std_logic_vector(31 downto 0);
		   ALU_CC_OUT	: out	std_logic_vector(3 downto 0)
   	);
end entity ArmALU;

architecture behave of ArmALU is
	signal op1, op2, add_op1, add_op2 : signed (32 downto 0);
	
	signal add_carry : unsigned(0 downto 0) := (others => '0'); -- vector fuer addition
	signal alu_result, add_result : std_logic_vector(32 downto 0) := (others => '0');
	
	-- für overflow
	signal is_logical,addOperation, subOperation, rsubOperation, a_n, b_n, z_n : std_logic;

begin
		-- Invertiert schon nach 2k Regeln (weil signed), also nixda +/- 1
		op1 <= signed('0' & ALU_OP1); 
		op2 <= signed('0' & ALU_OP2);

		-- ja, SBC und RCS sind richtig gesetzt, sh. unten
		add_op1 <= not op1 when (ALU_CTRL = OP_SBC or ALU_CTRL = OP_RSB) else op1;
		add_op2 <= not op2 when (ALU_CTRL = OP_SUB or ALU_CTRL = OP_RSC or ALU_CTRL = OP_CMP) else op2;
		
		add_carry(0) <= ALU_CC_IN(1) when ALU_CTRL = OP_ADC else -- addition mit carry
			not ALU_CC_IN(1) when ALU_CTRL = OP_SBC or ALU_CTRL = OP_RSC else  -- Substraktion mit carry (sh. unten)
			'1' when ALU_CTRL = OP_SUB or ALU_CTRL = OP_RSB else -- Substraktion
			'0'; -- (0) bc add_carry is vector 

		add_result <= std_logic_vector(unsigned(add_op1) + unsigned(add_op2) + add_carry); -- goal 
	
	-- weil SBC & RSC pain waren, reminder: 
	-- Bsp(SBC): adder = op1[5] - op2[-10] + C[0] - 1 = 14
	-- inverted: adder = op2[-10] + (inv)op1[5] + (inv)C[0] = -14 => result = inv(adder)
	
	-- Endergebnis 
		ALU_RES <= alu_result(31 downto 0); -- in zwischensignal, weil MSB noch gebraucht wird
		with ALU_CTRL select alu_result <= 
			add_result when OP_SUB,
			add_result when OP_RSB,
			add_result when OP_ADD,
			add_result when OP_ADC,
			not add_result when OP_SBC,
			not add_result when OP_RSC,
			add_result when OP_CMP,
			add_result when OP_CMN,
			'0'&ALU_OP1 and '0'&ALU_OP2 when OP_AND,
			'0'&ALU_OP1 and '0'&ALU_OP2 when OP_TST,
			'0'&ALU_OP1 xor '0'&ALU_OP2 when OP_EOR,
			'0'&ALU_OP1 xor '0'&ALU_OP2 when OP_TEQ,
			'0'&ALU_OP1 or '0'&ALU_OP2 when OP_ORR,
			'0'&ALU_OP2 when OP_MOV,
			'0'&ALU_OP1 and not ('0'&ALU_OP2) when OP_BIC,
			not ('0'&ALU_OP2) when others;
			
-- "Berechnung" Status Bits ALU_CC_OUT
	-- Hilfssignale
		is_logical <= '1' when ALU_CTRL = OP_AND or ALU_CTRL = OP_EOR 
			or ALU_CTRL = OP_TST or ALU_CTRL = OP_TEQ or ALU_CTRL = OP_ORR 
			or ALU_CTRL = OP_MOV or ALU_CTRL = OP_BIC or ALU_CTRL =  OP_MVN else
		'0';

		-- für overflow
		a_n <= ALU_OP1(31);
		b_n <= ALU_OP2(31);
		z_n <= alu_result(31);
		addOperation <= '1' when (ALU_CTRL = OP_ADD) or (ALU_CTRL = OP_ADC) or (ALU_CTRL = OP_CMN) else '0';  --Additionen                                        
		subOperation <= '1' when (ALU_CTRL = OP_SUB) or (ALU_CTRL = OP_RSC) or (ALU_CTRL = OP_CMP) else '0'; --Subtraktionen
		rsubOperation <= '1' when (ALU_CTRL = OP_RSB) or (ALU_CTRL = OP_SBC) else '0'; --reversed Subtraktionen
	
	-- Endergebnis 
		-- N (is negative)
		ALU_CC_OUT(3) <= alu_result(31); -- wegen 2k binary gilt negative when '1', positive when '0'

		-- Z (zero)
		ALU_CC_OUT(2) <= '1' when to_integer(unsigned(alu_result)) = 0 else '0';
	
		-- C (carry out)
		ALU_CC_OUT(1) <= 
			ALU_CC_IN(1) when (is_logical = '1') else 
			(not alu_result(32)) when (ALU_CTRL = OP_SUB) or (ALU_CTRL = OP_RSB) or (ALU_CTRL = OP_CMP) or (ALU_CTRL = OP_SBC) or (ALU_CTRL = OP_RSC) -- Für Subtraktion: Carry =1 when kein Übertrag
			else alu_result(32); -- Für Additionen, SBC, RSE:  C=1 bei Übertrag

		-- V (overflow)
		ALU_CC_OUT(0) <= 
			(not a_n and not b_n and z_n) or (a_n and b_n and not z_n) when addOperation = '1' else -- ( [-]+[-] != [+] und [+]+[+] != [-] )
			(a_n and not b_n and not z_n) or (not a_n and b_n and z_n) when  subOperation = '1' else -- ( [+]-[-] != [-] und [-]-[+] != [+] )
			(a_n and not b_n and z_n) or (not a_n and b_n and not z_n)  when rsubOperation = '1' else -- basically genauso wie oben
			ALU_CC_IN(0); 
end architecture behave;
