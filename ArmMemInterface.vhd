--------------------------------------------------------------------------------
--	Schnittstelle zur Anbindung des RAM an die Busse des HWPR-Prozessors
--------------------------------------------------------------------------------
--	Datum:		??.??.2013
--	Version:	?.?
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.ArmConfiguration.all;
use work.ArmTypes.all;

entity ArmMemInterface is
	generic(
--------------------------------------------------------------------------------
--	Beide Generics sind fuer das HWPR nicht relevant und koennen von
--	Ihnen ignoriert werden.
--------------------------------------------------------------------------------
		SELECT_LINES				: natural range 0 to 2 := 1;
		EXTERNAL_ADDRESS_DECODING_INSTRUCTION : boolean := false);
	port (  RAM_CLK	:  in  std_logic;
		--	Instruction-Interface	
       		IDE		:  in std_logic;	
			IA		:  in std_logic_vector(31 downto 2);
			ID		: out std_logic_vector(31 downto 0);	
			IABORT	: out std_logic;
		--	Data-Interface
			DDE		:  in std_logic;
			DnRW	:  in std_logic;
			DMAS	:  in std_logic_vector(1 downto 0);
			DA 		:  in std_logic_vector(31 downto 0);
			DDIN	:  in std_logic_vector(31 downto 0);
			DDOUT	: out std_logic_vector(31 downto 0);
			DABORT	: out std_logic);
end entity ArmMemInterface;

architecture behave of ArmMemInterface is	
	component ArmRAMB_4kx32 port(
		RAM_CLK	: in  std_logic;
		ENA		: in  std_logic;
		ADDRA	: in  std_logic_vector(11 downto 0);
		WEB		: in  std_logic_vector(3 downto 0);
		ENB		: in  std_logic;
		ADDRB	: in  std_logic_vector(11 downto 0);
		DIB		: in  std_logic_vector(31 downto 0);
		DOA		: out  std_logic_vector(31 downto 0);
		DOB		: out  std_logic_vector(31 downto 0)); 
	end component;

	-- WEB
	signal WEB : std_logic_vector(3 downto 0);
	signal WEB_BYTE: std_logic_vector(3 downto 0);
	signal WEB_DMAS: std_logic_vector(3 downto 0);

	-- RAM Ports 
	signal portB_out: std_logic_vector(31 downto 0);
	signal portA_out: std_logic_vector(31 downto 0);
	
	--IABORT
	signal NOT_IN_INSTR: std_logic;

	-- DABORT 
	signal WEB_WRONG: std_logic;
begin	

	-- RAM signale 
	ARM_RAMB: ArmRAMB_4kx32
	port map(
		RAM_CLK	=> RAM_CLK,
		ENA		=> IDE,
		ADDRA	=> IA(13 downto 2),
		WEB		=> WEB,
		ENB		=> DDE,
		ADDRB	=> DA(13 downto 2),
		DIB		=> DDIN,
		DOA		=> portA_out,
		DOB		=> portB_out
	);
	
	-- INSTRUKTIONSBUS
	-- TODO statt vorhergehendem Prozess 
	NOT_IN_INSTR <= '1' when (unsigned(IA) &"00" > unsigned(INST_HIGH_ADDR ) or unsigned(IA) &"00" < unsigned(INST_LOW_ADDR)) else '0';
	with IDE select 
	IABORT <= (NOT_IN_INSTR) when '1',
			  'Z' when '0',
			  '0' when others;

	with IDE select ID <= 
		portA_out when '1',
		(others => 'Z') when others;
	-- TODO ENDE

	-- DATENBUS
	with (not DnRW and DDE) select  -- test or dde
	DDOUT <= portB_out when '1',
			 (others => 'Z') when others; 
	
	
	-- Write or Read access
	with DA (1 downto 0) select WEB_BYTE <= 
		"0001" when "00",
		"0010" when "01",
		"0100" when "10",
		"1000" when "11",
		"1111" when others;
	
	with DMAS select WEB_DMAS <= 
		WEB_BYTE when DMAS_BYTE,
		(DA(1) & DA(1) & not DA(1) & not DA(1)) when DMAS_HWORD,
		"1111" when others;
	
	WEB <= "0000" when (DnRW = '0'or WEB_WRONG = '1') --read mode
			else WEB_DMAS; --write mode dependend on mask
	
	WEB_WRONG <= '1' when 
		DMAS = DMAS_RESERVED 
		or (DMAS = DMAS_BYTE and WEB_BYTE = "1111")
		or (DMAS = DMAS_HWORD and (DA(0) /= '0'))
		or (DMAS = DMAS_WORD and (DA(1 downto 0) /= "00"))
		else '0';

	with DDE select 
	DABORT <= WEB_WRONG when '1',
			  'Z' when '0',
			  '0' when others;

end architecture behave;


