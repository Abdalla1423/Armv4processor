--------------------------------------------------------------------------------
--	Shifter des HWPR-Prozessors, instanziiert einen Barrelshifter.
--------------------------------------------------------------------------------
--	Datum:		??.??.2013
--	Version:	?.?
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.ArmTypes.all;

entity ArmShifter is
	port (
		SHIFT_OPERAND	: in	std_logic_vector(31 downto 0);
		SHIFT_AMOUNT	: in	std_logic_vector(7 downto 0);
		SHIFT_TYPE_IN	: in	std_logic_vector(1 downto 0);
		SHIFT_C_IN		: in	std_logic;
		SHIFT_RRX		: in	std_logic;
		SHIFT_RESULT	: out	std_logic_vector(31 downto 0);
		SHIFT_C_OUT		: out	std_logic    		
 	);
end entity ArmShifter;

architecture behave of ArmShifter is
	signal data_out: std_logic_vector(31 downto 0);
	signal shift_amount_int: integer;
	signal shift_amount_mod: integer;
	signal shamt: std_logic_vector(4 downto 0);
	signal mux_ctrl: std_logic_vector(1 downto 0);
	signal c_out: std_logic;
	signal arith_shift: std_logic;
begin
	shift_amount_mod <= to_integer(unsigned(SHIFT_AMOUNT)) mod 32;
	shift_amount_int <= to_integer(unsigned(SHIFT_AMOUNT));

BARREL_SHIFTER: entity work.ArmBarrelShifter(structure) 
generic map(OPERAND_WIDTH => 32,
				SHIFTER_DEPTH => 5)
port map(OPERAND => SHIFT_OPERAND,
			MUX_CTRL => mux_ctrl,
			AMOUNT => shamt,
			ARITH_SHIFT => arith_shift,
			C_IN => SHIFT_C_IN,
			DATA_OUT => data_out,
			C_OUT => c_out);

			--translate shamt
			shamt <= "00001" when SHIFT_RRX = '1'
			else std_logic_vector(to_unsigned(shift_amount_mod,5));
			
			--translate mux_ctrl
			mux_ctrl <= "10" when SHIFT_TYPE_IN = SH_LSR or SHIFT_TYPE_IN = SH_ASR or SHIFT_RRX = '1'
			else "01" when SHIFT_TYPE_IN = SH_LSL
			else "11" when SHIFT_TYPE_IN = SH_ROR;
			
			--translate arith
			arith_shift <= '1' when SHIFT_TYPE_IN = "10"
			else '0';

			--translate SHIFT_RESULT
			SHIFT_RESULT <=  (31 => SHIFT_C_IN, 30 downto 0 => data_out(30 downto 0)) when SHIFT_RRX = '1'
			else (others => '0') when (SHIFT_TYPE_IN = SH_LSL or SHIFT_TYPE_IN = SH_LSR) and shift_amount_int > 31
			else (others => SHIFT_OPERAND(31)) when SHIFT_TYPE_IN = SH_ASR  and shift_amount_int > 31 
			--else data_out when (SHIFT_TYPE_IN = SH_ROR  and shift_amount_int > 32) ;
			else data_out;
			

			--translate CARRY_OUT 
			SHIFT_C_OUT <= SHIFT_OPERAND(0) when SHIFT_RRX = '1'
			else '0' when (SHIFT_TYPE_IN = SH_LSL or SHIFT_TYPE_IN = SH_LSR) and shift_amount_int > 32
			else SHIFT_OPERAND(31) when (SHIFT_TYPE_IN = SH_ROR  and shift_amount_int > 32  and shift_amount_mod = 0) or (shift_amount_int = 32 and (SHIFT_TYPE_IN = SH_ASR or SHIFT_TYPE_IN = SH_LSR))  
			else SHIFT_OPERAND(0) when SHIFT_TYPE_IN = SH_LSL and shift_amount_int = 32
			else c_out;
			--else c_out when SHIFT_TYPE_IN = SH_ASR  and shift_amount_int > 32 and shift_amount_mod /= 0
			

end architecture behave;

