--------------------------------------------------------------------------------
-- 	Barrelshifter fuer LSL, LSR, ASR, ROR mit Shiftweiten von 0 bis 3 (oder 
--	generisch n-1) Bit. 
--------------------------------------------------------------------------------
--	Datum:		??.??.2013
--	Version:	?.?
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity ArmBarrelShifter is
--------------------------------------------------------------------------------
--	Breite der Operanden (n) und die Zahl der notwendigen
--	Multiplexerstufen (m) um Shifts von 0 bis n-1 Stellen realisieren zu
--	koennen. Es muss gelten: ???
--------------------------------------------------------------------------------
	generic (OPERAND_WIDTH : integer := 32;	
			 SHIFTER_DEPTH : integer := 5
	 );
	port ( 	OPERAND 	: in std_logic_vector(OPERAND_WIDTH-1 downto 0);	
    		MUX_CTRL 	: in std_logic_vector(1 downto 0);
    		AMOUNT 		: in std_logic_vector(SHIFTER_DEPTH-1 downto 0);	
    		ARITH_SHIFT : in std_logic; 
    		C_IN 		: in std_logic;
           	DATA_OUT 	: out std_logic_vector(OPERAND_WIDTH-1 downto 0);	
    		C_OUT 		: out std_logic
	);
end entity ArmBarrelShifter;

architecture structure of ArmBarrelShifter is
begin	
	process(OPERAND,MUX_CTRL,AMOUNT,ARITH_SHIFT, C_IN)
	variable shift_amount : integer;
	begin
		shift_amount := to_integer(unsigned(AMOUNT));
		C_OUT <= C_IN;
 		DATA_OUT <= OPERAND;
 		if(shift_amount > 0 and MUX_CTRL /= "00") then
			for i in 0 to OPERAND_WIDTH-1 loop 
			
				--logischer left shift
				if MUX_CTRL = "01" then 
					C_OUT <= OPERAND(OPERAND_WIDTH -shift_amount);
					if i < shift_amount then
						DATA_OUT(i) <= '0';
					else
						DATA_OUT(i) <= OPERAND(i - shift_amount);		
					end if;

				--logischer right shift
				elsif MUX_CTRL = "10" and ARITH_SHIFT = '0' then 
					C_OUT <= OPERAND(shift_amount - 1);
					if i > OPERAND_WIDTH - 1 - shift_amount then
						DATA_OUT(i) <= '0';
					else
						DATA_OUT(i) <= OPERAND(i + shift_amount);		
					end if;

				--arithmetischer right shift
				elsif MUX_CTRL = "10" and ARITH_SHIFT = '1' then 
					C_OUT <= OPERAND(shift_amount - 1);
					if i > OPERAND_WIDTH - 1 - shift_amount then
						DATA_OUT(i) <= OPERAND(OPERAND_WIDTH-1); 
					else
						DATA_OUT(i) <= OPERAND(i + shift_amount);		
					end if;

				--Rechtsrotation
				else
					C_OUT <= OPERAND(shift_amount - 1);
					if i > OPERAND_WIDTH - 1 - shift_amount then
						DATA_OUT(i) <= OPERAND(i + shift_amount - OPERAND_WIDTH);
					else
						DATA_OUT(i) <= OPERAND(i + shift_amount);
					end if;
			
				end if;
			end loop;
		end if;
	end process;
end architecture structure;

