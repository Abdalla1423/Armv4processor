--------------------------------------------------------------------------------
--	16-Bit-Register zur Steuerung der Auswahl des naechsten Registers
--	bei der Ausfuehrung von STM/LDM-Instruktionen. Das Register wird
--	mit der Bitmaske der Instruktion geladen. Ein Prioritaetsencoder
--	(Modul ArmPriorityVectorFilter) bestimmt das Bit mit der hochsten 
--	Prioritaet. Zu diesem Bit wird eine 4-Bit-Registeradresse erzeugt und
--	das Bit im Register geloescht. Bis zum Laden eines neuen Datums wird
--	mit jedem Takt ein Bit geloescht bis das Register leer ist.	
--------------------------------------------------------------------------------
--	Datum:		??.??.2013
--	Version:	?.??
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity ArmLdmStmNextAddress is
	port(
		SYS_RST			: in std_logic;
		SYS_CLK			: in std_logic;	
		LNA_LOAD_REGLIST 	: in std_logic;
		LNA_HOLD_VALUE 		: in std_logic;
		LNA_REGLIST 		: in std_logic_vector(15 downto 0);
		LNA_ADDRESS 		: out std_logic_vector(3 downto 0);
		LNA_CURRENT_REGLIST_REG : out std_logic_vector(15 downto 0)
	    );
end entity ArmLdmStmNextAddress;

architecture behave of ArmLdmStmNextAddress is	
	-- braucht man für output LNA_CURRENT_REGLIST_REG
	component ArmPriorityVectorFilter
		port(
			PVF_VECTOR_UNFILTERED	: in std_logic_vector(15 downto 0);
			PVF_VECTOR_FILTERED	: out std_logic_vector(15 downto 0)
		);
	end component ArmPriorityVectorFilter;

	signal INTERNAL_REGISTER : std_logic_vector(15 downto 0);
	signal VECTOR_FILTERED : std_logic_vector(15 downto 0);
	signal HOLD_LOAD : std_logic := '0';

begin
	CURRENT_REGLIST_FILTER : ArmPriorityVectorFilter
	port map(
		PVF_VECTOR_UNFILTERED	=> INTERNAL_REGISTER, -- kann das u2berhaupt stimmen...?
		PVF_VECTOR_FILTERED	=> VECTOR_FILTERED -- nur für LNA_ADDRESS?
	);

LNA_ADDRESS <=  "0001" when VECTOR_FILTERED = "0000000000000010" else
			"0010" when VECTOR_FILTERED = "0000000000000100" else                            
			"0011" when VECTOR_FILTERED = "0000000000001000" else
			"0100" when VECTOR_FILTERED = "0000000000010000" else
			"0101" when VECTOR_FILTERED = "0000000000100000" else
			"0110" when VECTOR_FILTERED = "0000000001000000" else
			"0111" when VECTOR_FILTERED = "0000000010000000" else
			"1000" when VECTOR_FILTERED = "0000000100000000" else
			"1001" when VECTOR_FILTERED = "0000001000000000" else
			"1010" when VECTOR_FILTERED = "0000010000000000" else
			"1011" when VECTOR_FILTERED = "0000100000000000" else
			"1100" when VECTOR_FILTERED = "0001000000000000" else
			"1101" when VECTOR_FILTERED = "0010000000000000" else
			"1110" when VECTOR_FILTERED = "0100000000000000" else                            
			"1111" when VECTOR_FILTERED = "1000000000000000" else
			"0000";
			
	-- wollen wir LNA_ADDRESS statisch...? 
	-- Also zB LNA_ADDRESS <= "0001" when VECTOR_FILTERED(1) = '1' (niedrig = high prio)
	LNA_CURRENT_REGLIST_REG <= INTERNAL_REGISTER;
	-- 
 	process (SYS_CLK) begin
   		if (rising_edge(SYS_CLK)) then 
			if (HOLD_LOAD = '0') then 
				if (LNA_LOAD_REGLIST = '1') then 
				-- neuen Wert laden
					INTERNAL_REGISTER <= LNA_REGLIST;
				elsif (LNA_LOAD_REGLIST = '0' and LNA_HOLD_VALUE = '1') then 
				-- bisherigen Wert verwenden
					HOLD_LOAD <= '1';
				else
				-- Prioritätscoder
					INTERNAL_REGISTER <= INTERNAL_REGISTER xor VECTOR_FILTERED; 
					-- 1 1 => 0, 1 0 => 1, 0 0 => 0;
				end if;
			else 
				HOLD_LOAD <= '0';
			end if;
			--reset signal
			if(SYS_RST = '1') then
				INTERNAL_REGISTER <= (others => '0');
			end if;
		end if;
	end process;
end architecture behave;
