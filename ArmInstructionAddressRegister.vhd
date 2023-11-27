--------------------------------------------------------------------------------
--	Instruktionsadressregister-Modul fuer den HWPR-Prozessor
--------------------------------------------------------------------------------
--	Datum:		29.10.2013
--	Version:	0.1
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.ArmTypes.INSTRUCTION_ID_WIDTH;
use work.ArmTypes.VCR_RESET;

entity ArmInstructionAddressRegister is
	port(
		IAR_CLK 	: in std_logic;
		IAR_RST 	: in std_logic;
		IAR_INC		: in std_logic;
		IAR_LOAD 	: in std_logic;
		IAR_REVOKE	: in std_logic;
		IAR_UPDATE_HB	: in std_logic;
--------------------------------------------------------------------------------
--	INSTRUCTION_ID_WIDTH  ist ein globaler Konfigurationsparameter
--	zur Einstellung der Breite der Instruktions-IDs und damit der Tiefe
--	der verteilten Puffer. Eine Breite von 3 Bit genuegt fuer die 
--	fuenfstufige Pipeline definitiv.
--------------------------------------------------------------------------------
		IAR_HISTORY_ID	: in std_logic_vector(INSTRUCTION_ID_WIDTH-1 downto 0);
		IAR_ADDR_IN 	: in std_logic_vector(31 downto 2);
		IAR_ADDR_OUT 	: out std_logic_vector(31 downto 2);
		IAR_NEXT_ADDR_OUT : out std_logic_vector(31 downto 2)
	    );
	
end entity ArmInstructionAddressRegister;

architecture behave of ArmInstructionAddressRegister is
	signal IAR_REG_IN : std_logic_vector(31 downto 2) := (others => '0');
	signal IAR_REG_OUT: std_logic_vector(31 downto 2) := (others => '0');
	signal IAR_REG_INC: std_logic_vector(31 downto 2) := (others => '0');
	signal IAR_REVOKE_ADDR : std_logic_vector(31 downto 2) := (others => '0');
	component ArmRamBuffer
	generic(
		ARB_ADDR_WIDTH : natural range 1 to 4 := 3;
		ARB_DATA_WIDTH : natural range 1 to 64 := 32
	       );
	port(
		ARB_CLK 	: in std_logic;
		ARB_WRITE_EN	: in std_logic;
		ARB_ADDR	: in std_logic_vector(ARB_ADDR_WIDTH-1 downto 0);
		ARB_DATA_IN	: in std_logic_vector(ARB_DATA_WIDTH-1 downto 0);          
		ARB_DATA_OUT	: out std_logic_vector(ARB_DATA_WIDTH-1 downto 0)
		);
	end component ArmRamBuffer;

begin
-- red 
	with IAR_INC select IAR_REG_INC <=
		std_logic_vector(unsigned(IAR_REG_OUT)+1) when '1',
		IAR_REG_OUT when others; 

-- orange 
	with IAR_LOAD select IAR_REG_IN <=
		IAR_ADDR_IN when '1',
		IAR_REG_INC when others; 

-- yellow
	IAR_HISTORY_BUFFER: ArmRamBuffer
	generic map(
			ARB_ADDR_WIDTH => INSTRUCTION_ID_WIDTH,
			ARB_DATA_WIDTH => 30
		)
	port map(
		ARB_CLK	=> IAR_CLK,
		ARB_WRITE_EN	=> IAR_UPDATE_HB,
		ARB_ADDR	=> IAR_HISTORY_ID,
		ARB_DATA_IN	=> IAR_REG_OUT,
		ARB_DATA_OUT	=> IAR_REVOKE_ADDR 
	);
	
--green 	
	with IAR_REVOKE select IAR_NEXT_ADDR_OUT <=
		IAR_REVOKE_ADDR when '1',
		std_logic_vector(unsigned(IAR_REG_OUT) + 1) when others;

-- blue
	IAR_ADDR_OUT <= IAR_REG_OUT; 

-- purple	
	set_IAR_REG: process (IAR_CLK)
	begin
		if (rising_edge(IAR_CLK)) then 
			--with IAR_RST select IAR_REG_OUT <= 
			--	(others => '0') when '1', 
			--	IAR_REG_IN when others;
			if(IAR_RST = '1') then
				IAR_REG_OUT <= (others => '0');
			else
				IAR_REG_OUT <= IAR_REG_IN;
			end if;
		end if;
	end process;
end architecture behave;
