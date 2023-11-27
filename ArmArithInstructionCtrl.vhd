--------------------------------------------------------------------------------
-- 	Teilsteuerung Arithmetisch-logischer Instruktionen im Kontrollpfad
--	des HWPR-Prozessors.
--------------------------------------------------------------------------------
--	Datum:		??.??.2014
--	Version:	?.?
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library work;
use work.ArmTypes.all;

entity ArmArithInstructionCtrl is
	port(
		AIC_DECODED_VECTOR	: in std_logic_vector(15 downto 0);
		AIC_INSTRUCTION		: in std_logic_vector(31 downto 0);
		AIC_IF_IAR_INC		: out std_logic;
		AIC_ID_R_PORT_A_ADDR	: out std_logic_vector(3 downto 0);
		AIC_ID_R_PORT_B_ADDR	: out std_logic_vector(3 downto 0);
		AIC_ID_R_PORT_C_ADDR	: out std_logic_vector(3 downto 0);
		AIC_ID_REGS_USED	: out std_logic_vector(2 downto 0);
		AIC_ID_IMMEDIATE	: out std_logic_vector(31 downto 0);	
		AIC_ID_OPB_MUX_CTRL	: out std_logic;
		AIC_EX_ALU_CTRL		: out std_logic_vector(3 downto 0);
		AIC_MEM_RES_REG_EN	: out std_logic;
		AIC_MEM_CC_REG_EN	: out std_logic;
		AIC_WB_RES_REG_EN	: out std_logic;
		AIC_WB_CC_REG_EN	: out std_logic;	
		AIC_WB_W_PORT_A_ADDR	: out std_logic_vector(3 downto 0);
		AIC_WB_W_PORT_A_EN	: out std_logic;	
		AIC_WB_IAR_MUX_CTRL	: out std_logic;
		AIC_WB_IAR_LOAD		: out std_logic;
		AIC_WB_PSR_EN		: out std_logic;
		AIC_WB_PSR_SET_CC	: out std_logic;
		AIC_WB_PSR_ER		: out std_logic;
		AIC_DELAY		: out std_logic_vector(1 downto 0);
--------------------------------------------------------------------------------
--	Verwendung eines Typs aus ArmTypes weil die Codierung der Zustaende 
--	nicht vorgegeben ist.
--------------------------------------------------------------------------------
		AIC_ARM_NEXT_STATE	: out ARM_STATE_TYPE
	    );
end entity ArmArithInstructionCtrl;

architecture behave of ArmArithInstructionCtrl is
	signal opcode: std_logic_vector(3 downto 0);
	signal t_c_opcode, is_pc: std_logic;

begin
	is_pc <= '1' when AIC_INSTRUCTION(15 downto 12) = R15 else '0';

	-- set opcode
	opcode <= AIC_INSTRUCTION (24 downto 21);
	AIC_EX_ALU_CTRL <= opcode;
	t_c_opcode <= '1' when (opcode = OP_TST or opcode = OP_TEQ or opcode = OP_CMP or opcode = OP_CMN) else '0';

	-- Ergebnisse schreibport A
	AIC_WB_W_PORT_A_ADDR <= AIC_INSTRUCTION (15 downto 12);

	-- Direktoperand erweitern
	AIC_ID_OPB_MUX_CTRL <= '1' when AIC_DECODED_VECTOR = CD_ARITH_IMMEDIATE else '0';

	-- set operands
	AIC_ID_R_PORT_A_ADDR <= AIC_INSTRUCTION (19 downto 16);
	AIC_ID_R_PORT_B_ADDR <= AIC_INSTRUCTION(3 downto 0);
	AIC_ID_R_PORT_C_ADDR <= AIC_INSTRUCTION(11 downto 8);

	-- welche operanden wurden benutzt
	AIC_ID_REGS_USED(0) <= '1';
	AIC_ID_REGS_USED(1) <= '1' when AIC_DECODED_VECTOR = CD_ARITH_REGISTER or AIC_DECODED_VECTOR = CD_ARITH_REGISTER_REGISTER else '0';
	AIC_ID_REGS_USED(2) <= '1' when AIC_DECODED_VECTOR = CD_ARITH_REGISTER_REGISTER else '0';

	--next state
	AIC_ARM_NEXT_STATE <= STATE_WAIT_TO_FETCH when is_pc = '1' and t_c_opcode = '0' else STATE_DECODE;

	-- delay
	AIC_DELAY <= "10" when is_pc = '1' and t_c_opcode = '0' else "00";

	--adresse inkrementieren
	AIC_IF_IAR_INC <= '0' when is_pc = '1' and t_c_opcode = '0' else '1';

	--immediate erweitern
	AIC_ID_IMMEDIATE <= (31 downto 8 => '0') & AIC_INSTRUCTION(7 downto 0);

	-- test oder compare befehl oder s bit gesetzt
	AIC_WB_PSR_EN <= '1' when t_c_opcode = '1' or (AIC_INSTRUCTION(20) = '1' and t_c_opcode = '0') else '0';
	AIC_WB_PSR_SET_CC <= '1' when t_c_opcode = '1' or (AIC_INSTRUCTION(20) = '1' and is_pc = '0' and t_c_opcode = '0') else '0';
	AIC_WB_PSR_ER <= '1' when t_c_opcode = '0' and AIC_INSTRUCTION(20) = '1' and is_pc = '1' else '0';
	AIC_MEM_CC_REG_EN <= '1' when t_c_opcode = '1' or (AIC_INSTRUCTION(20) = '1' and is_pc = '0') else '0';
	AIC_WB_CC_REG_EN <= '1' when t_c_opcode = '1' or (AIC_INSTRUCTION(20) = '1' and is_pc = '0') else '0';

	--kein test oder compare befehl
	AIC_MEM_RES_REG_EN <= '1' when t_c_opcode = '0' else '0';
	AIC_WB_RES_REG_EN <= '1' when t_c_opcode = '0' else '0';
	AIC_WB_W_PORT_A_EN <= '1' when t_c_opcode = '0' else '0';

	AIC_WB_IAR_LOAD <= '1' when t_c_opcode = '0' and is_pc = '1' else '0';
	AIC_WB_IAR_MUX_CTRL <= '0';


end architecture behave;
