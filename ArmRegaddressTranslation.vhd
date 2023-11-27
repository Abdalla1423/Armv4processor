------------------------------------------------------------------------------
--	Paket fuer die Funktionen zur die Abbildung von ARM-Registeradressen
-- 	auf Adressen des physischen Registerspeichers (5-Bit-Adressen)
------------------------------------------------------------------------------
--	Datum:		05.11.2013
--	Version:	0.1
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.ArmTypes.all;

package ArmRegaddressTranslation is
  
	function get_internal_address(
		EXT_ADDRESS: std_logic_vector(3 downto 0); 
		THIS_MODE: std_logic_vector(4 downto 0); 
		USER_BIT : std_logic) 
	return std_logic_vector;

end package ArmRegaddressTranslation;

package body ArmRegAddressTranslation is

function get_internal_address(
	EXT_ADDRESS: std_logic_vector(3 downto 0);
	THIS_MODE: std_logic_vector(4 downto 0); 
	USER_BIT : std_logic) 
	return std_logic_vector 
is

--------------------------------------------------------------------------------		
--	Raum fuer lokale Variablen innerhalb der Funktion
--------------------------------------------------------------------------------
	variable PHY_ADDR : std_logic_vector (4 downto 0) := (others =>'0');
	constant USER_MODE       : std_logic_vector := "10000";
	constant SYSTEM_MODE     : std_logic_vector := "11111";
	constant SUPERVISOR_MODE : std_logic_vector := "10011";
	constant FIQ_MODE        : std_logic_vector := "10001";
	constant IRQ_MODE        : std_logic_vector := "10010";
	constant ABORT_MODE      : std_logic_vector := "10111";
	constant UNDEFINED_MODE  : std_logic_vector := "11011";
	constant error_reg  : std_logic_vector := "11111";
	variable virt_addr_num:integer;
	constant skip_to_fiq : integer :=  8; -- ab R16
	constant skip_to_irq : integer := 10; -- ab R23
	constant skip_to_svc : integer := 12; -- ab R25
	constant skip_to_abt : integer := 14; -- ab R27
	constant skip_to_und : integer := 16; -- ab R29
	begin
--------------------------------------------------------------------------------		
--	Functionscode
--------------------------------------------------------------------------------	
		virt_addr_num := to_integer(unsigned(EXT_ADDRESS));
		-- if EXT_ADDRESS is nonsense
		if ((EXT_ADDRESS(3) /= '0' and EXT_ADDRESS(3) /= '1') or 
		    (EXT_ADDRESS(2) /= '0' and EXT_ADDRESS(2) /= '1') or
		    (EXT_ADDRESS(1) /= '0' and EXT_ADDRESS(1) /= '1') or
		    (EXT_ADDRESS(0) /= '0' and EXT_ADDRESS(0) /= '1')) then 
		    	return error_reg;
		end if;
		
		if (virt_addr_num = 15 or virt_addr_num < 8) then 
			PHY_ADDR := (3 downto 0 => EXT_ADDRESS, others => '0');
			return PHY_ADDR;
			-- R0 bis R7 und PC (R15) fest für alle
		end if;
		
		if (USER_BIT = '1' or THIS_MODE = USER_MODE or THIS_MODE = SYSTEM_MODE) then 
			PHY_ADDR := (3 downto 0 => EXT_ADDRESS, others => '0');
			-- R8 bis R14 for User oder Systemmode
		elsif (THIS_MODE = FIQ_MODE) then 
			return std_logic_vector(to_unsigned((virt_addr_num + skip_to_fiq), 5));
			-- R8_fiq bis R14_fiq (als R16 bis R22)
		elsif (THIS_MODE = IRQ_MODE) then
			if (virt_addr_num < 13) then 
				PHY_ADDR := (3 downto 0 => EXT_ADDRESS, others => '0');
				return PHY_ADDR;
			end if;
			return std_logic_vector(to_unsigned((virt_addr_num + skip_to_irq), 5));
			-- R13_irq und R14_irq (als R23 und R24)
		elsif (THIS_MODE = SUPERVISOR_MODE) then 
			if (virt_addr_num < 13) then 
				PHY_ADDR := (3 downto 0 => EXT_ADDRESS, others => '0');
				return PHY_ADDR;
			end if;
			return std_logic_vector(to_unsigned((virt_addr_num + skip_to_svc), 5));
			-- R13_svc und R14_svc (als R25 und R26)
		elsif (THIS_MODE = ABORT_MODE) then 
			if (virt_addr_num < 13) then 
				PHY_ADDR := (3 downto 0 => EXT_ADDRESS, others => '0');
				return PHY_ADDR;
			end if;
			return std_logic_vector(to_unsigned((virt_addr_num + skip_to_abt), 5));
			-- R13_abt und R14_abt (als R27 und R28)
		elsif (THIS_MODE = UNDEFINED_MODE) then 
			if (virt_addr_num < 13) then 
				PHY_ADDR := (3 downto 0 => EXT_ADDRESS, others => '0');
				return PHY_ADDR;
			end if;
			return std_logic_vector(to_unsigned((virt_addr_num + skip_to_und), 5));
			-- R13_und und R14_und (als R29 und R30)
		else
			PHY_ADDR := "11111"; -- (alles falsche als R31)
		end if;
	return PHY_ADDR;			

end function get_internal_address;	
	 
end package body ArmRegAddressTranslation;
