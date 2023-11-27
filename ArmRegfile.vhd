------------------------------------------------------------------------------
--	Registerspeichers des ARM-SoC
------------------------------------------------------------------------------
--	Datum:		16.05.2022
--	Version:	0.2
------------------------------------------------------------------------------

library work;
use work.ArmTypes.all;
use work.ArmRegAddressTranslation.all;
use work.ArmConfiguration.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity ArmRegfile is
	Port ( REF_CLK 		: in std_logic;
	       REF_RST 		: in  std_logic;

	       REF_W_PORT_A_ENABLE	: in std_logic;
	       REF_W_PORT_B_ENABLE	: in std_logic;
	       REF_W_PORT_PC_ENABLE	: in std_logic;

	       REF_W_PORT_A_ADDR 	: in std_logic_vector(4 downto 0);
	       REF_W_PORT_B_ADDR 	: in std_logic_vector(4 downto 0);

	       REF_R_PORT_A_ADDR 	: in std_logic_vector(4 downto 0);
	       REF_R_PORT_B_ADDR 	: in std_logic_vector(4 downto 0);
	       REF_R_PORT_C_ADDR 	: in std_logic_vector(4 downto 0);

	       REF_W_PORT_A_DATA 	: in std_logic_vector(31 downto 0);
	       REF_W_PORT_B_DATA 	: in std_logic_vector(31 downto 0);
	       REF_W_PORT_PC_DATA 	: in std_logic_vector(31 downto 0);

	       REF_R_PORT_A_DATA 	: out std_logic_vector(31 downto 0);
	       REF_R_PORT_B_DATA 	: out std_logic_vector(31 downto 0);
	       REF_R_PORT_C_DATA 	: out std_logic_vector(31 downto 0)
       );
end entity ArmRegfile;

architecture behavioral of ArmRegfile is
	-- MUX; 00 = RegFile A; 01 = RegFile B, 10 = RegPC, 11 = falsch;
	type which_mux is array (31 downto 0) of std_logic_vector (1 downto 0);
	signal REF_WHICH_REG_FILE : which_mux; -- default, read from Reg File A
	-- output Reg File A
	signal REG_FILE_A_PORT_A_DATA : std_logic_vector (31 downto 0);
	signal REG_FILE_A_PORT_B_DATA : std_logic_vector (31 downto 0);
	signal REG_FILE_A_PORT_C_DATA : std_logic_vector (31 downto 0);
	-- output Reg File B
	signal REG_FILE_B_PORT_A_DATA : std_logic_vector (31 downto 0);
	signal REG_FILE_B_PORT_B_DATA : std_logic_vector (31 downto 0);
	signal REG_FILE_B_PORT_C_DATA : std_logic_vector (31 downto 0);
	-- output Reg File PC
	signal REG_FILE_PC_PORT_A_DATA : std_logic_vector (31 downto 0);
	signal REG_FILE_PC_PORT_B_DATA : std_logic_vector (31 downto 0);
	signal REG_FILE_PC_PORT_C_DATA : std_logic_vector (31 downto 0);
	--write enable signals
	signal ENABLE_PORT_B : std_logic := '1';
	signal ENABLE_PORT_PC : std_logic:= '1';

	constant PC_ADDR : std_logic_vector := get_internal_address("1111", "00000", '1');
	component RAM32M
		port (
			WCLK : in std_logic;
			ADDRA : in std_logic_vector(4 downto 0);
			ADDRB : in std_logic_vector(4 downto 0);
			ADDRC : in std_logic_vector(4 downto 0);
			ADDRD : in std_logic_vector(4 downto 0);
			DID : in std_logic_vector(1 downto 0);
			DOA : out std_logic_vector(1 downto 0);
			DOB : out std_logic_vector(1 downto 0);
			DOC : out std_logic_vector(1 downto 0);
			DOD : out std_logic_vector(1 downto 0);
			WED : in std_logic
		);
	  end component RAM32M;
begin
--------------------------------------------------------------------------------
--	Auswahl und Einstellung der Registerspeicher-Implementierung
--	Version 2 des Registerspeichers nutzt Distributed RAM
--	Im HWPTI wird Version 2 implementiert, die ARM_SIM_LIB stellt
--	zu Debugging-Zwecken auch Version 1 zur Verfügung
--------------------------------------------------------------------------------
	
	REGFILE_VERSION : if USE_REGFILE_V2 generate

		-- Registerspeicher auf Basis von Distributed RAM

		-- REF Outputs (durch MUX)  REF_WHICH_REG_FILE(#num of Register)
		with REF_WHICH_REG_FILE(to_integer(unsigned(REF_R_PORT_A_ADDR))) select 
		REF_R_PORT_A_DATA <= REG_FILE_A_PORT_A_DATA when "00", 
							 REG_FILE_B_PORT_A_DATA when "01",
							 REG_FILE_PC_PORT_A_DATA when "10",
							 (others => '0') when others;
		with REF_WHICH_REG_FILE(to_integer(unsigned(REF_R_PORT_B_ADDR))) select 
		REF_R_PORT_B_DATA <= REG_FILE_A_PORT_B_DATA when "00", 
							 REG_FILE_B_PORT_B_DATA when "01",
							 REG_FILE_PC_PORT_B_DATA when "10",
							 (others => '0') when others;
		with REF_WHICH_REG_FILE(to_integer(unsigned(REF_R_PORT_C_ADDR))) select 
		REF_R_PORT_C_DATA <= REG_FILE_A_PORT_C_DATA when "00", 
							 REG_FILE_B_PORT_C_DATA when "01",
							 REG_FILE_PC_PORT_C_DATA when "10",
							 (others => '0') when others;

		-- Register File A, Schreibzugriff für Port A
		Generate_Reg_file_A: for i in 0 to 15 generate
			-- TODO indezies falsch
			Reg_file_A: RAM32M 
			port map (
				WCLK => REF_CLK,
				ADDRA => REF_R_PORT_A_ADDR,
				ADDRB => REF_R_PORT_B_ADDR,
				ADDRC => REF_R_PORT_C_ADDR,
				ADDRD => REF_W_PORT_A_ADDR,
				DID => REF_W_PORT_A_DATA((i*2)+1 downto i*2),
				DOA => REG_FILE_A_PORT_A_DATA((i*2)+1 downto i*2),
				DOB => REG_FILE_A_PORT_B_DATA((i*2)+1 downto i*2),
				DOC => REG_FILE_A_PORT_C_DATA((i*2)+1 downto i*2),
				DOD => open, 
				WED => REF_W_PORT_A_ENABLE
			); -- write on port a, DOD EGAL
		end generate;
	
		-- Register File B, Schreibzugriff für Port B
		Generate_Reg_file_B: for i in 0 to 15 generate
			-- TODO indezies falsch
			Reg_file_B: RAM32M 
			port map (
				WCLK => REF_CLK,
				ADDRA => REF_R_PORT_A_ADDR,
				ADDRB => REF_R_PORT_B_ADDR,
				ADDRC => REF_R_PORT_C_ADDR,
				ADDRD => REF_W_PORT_B_ADDR,
				DID => REF_W_PORT_B_DATA((i*2)+1 downto i*2),
				DOA => REG_FILE_B_PORT_A_DATA((i*2)+1 downto i*2),
				DOB => REG_FILE_B_PORT_B_DATA((i*2)+1 downto i*2),
				DOC => REG_FILE_B_PORT_C_DATA((i*2)+1 downto i*2),
				DOD => open, 
				WED => REF_W_PORT_B_ENABLE and ENABLE_PORT_B
			); -- write on port b, DOD EGAL
		end generate;

		-- Register File PC, Schreibzugriff für Port PC (R15 = "01111")
		Generate_Reg_file_PC: for i in 0 to 15 generate
			Reg_file_pC: RAM32M 
			port map (
				WCLK => REF_CLK,
				ADDRA => REF_R_PORT_A_ADDR,
				ADDRB => REF_R_PORT_B_ADDR,
				ADDRC => REF_R_PORT_C_ADDR,
				ADDRD => "01111", -- sollen wir PC_ADDR benutzen (sh. oben definiert)?
				DID => REF_W_PORT_PC_DATA((i*2)+1 downto i*2),
				DOA => REG_FILE_PC_PORT_A_DATA((i*2)+1 downto i*2),
				DOB => REG_FILE_PC_PORT_B_DATA((i*2)+1 downto i*2),
				DOC => REG_FILE_PC_PORT_C_DATA((i*2)+1 downto i*2),
				DOD => open, 
				WED => REF_W_PORT_PC_ENABLE and ENABLE_PORT_PC
			); --(read and write on R15 only)
		end generate;

		process(REF_CLK)
		begin
			-- Priorität einfach durch Reihenfolge.. oder?
			if(rising_edge(REF_CLK) and REF_W_PORT_PC_ENABLE = '1') then
				REF_WHICH_REG_FILE(to_integer(unsigned(PC_ADDR))) <= "10";
			end if;  -- last update on reg file PC
			if(rising_edge(REF_CLK) and REF_W_PORT_B_ENABLE = '1') then
				REF_WHICH_REG_FILE(to_integer(unsigned(REF_W_PORT_B_ADDR))) <= "01";
			end if;  -- last update on reg file B
			if(rising_edge(REF_CLK) and REF_W_PORT_A_ENABLE = '1') then
				REF_WHICH_REG_FILE(to_integer(unsigned(REF_W_PORT_A_ADDR))) <= "00";
			end if;  -- last update on reg file A	
		end process;		
	end generate;
end architecture;

