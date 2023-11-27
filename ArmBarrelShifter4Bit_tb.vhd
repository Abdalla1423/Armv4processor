library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ArmBarrelShifter4Bit_tb is
end ArmBarrelShifter4Bit_tb;


architecture testbench of ArmBarrelShifter4Bit_tb is
    constant test_width: integer := 4;
    constant test_depth: integer := 2;

    signal tb_operand  		: std_logic_vector(test_width-1 downto 0);
    signal tb_mux_ctrl 		: std_logic_vector(1 downto 0);
    signal tb_amount   		: std_logic_vector(1 downto 0);
    signal tb_c_in     		: std_logic;
    signal tb_arith_shift 	: std_logic;
    signal tb_data_out 		: std_logic_vector(test_width-1 downto 0);
    signal tb_c_out		: std_logic;

    
    component ArmBarrelShifter
	generic (OPERAND_WIDTH : integer := 4;	
		 SHIFTER_DEPTH : integer := 2
	);
	port ( 	OPERAND 	: in std_logic_vector(OPERAND_WIDTH-1 downto 0);	
    		MUX_CTRL 	: in std_logic_vector(1 downto 0);
    		AMOUNT 		: in std_logic_vector(SHIFTER_DEPTH-1 downto 0);	
    		ARITH_SHIFT 	: in std_logic; 
    		C_IN 		: in std_logic;
           	DATA_OUT 	: out std_logic_vector(OPERAND_WIDTH-1 downto 0);	
    		C_OUT 		: out std_logic
	);
    end component;
    
    
    begin
    

    uut : ArmBarrelShifter
    generic map (
    	OPERAND_WIDTH => test_width,
    	SHIFTER_DEPTH => test_depth)
    port map (
        OPERAND => tb_operand,
        MUX_CTRL => tb_mux_ctrl,
        AMOUNT => tb_amount,
        ARITH_SHIFT => tb_arith_shift,
        C_IN => tb_c_in,
        DATA_OUT => tb_data_out,
        C_OUT => tb_c_out
    );

    testbench: process 
    begin

	-- tb_mux_ctrl: 00
		for i in 0 to 3 loop
			tb_operand <= "1001";
			tb_mux_ctrl <= "00";
			tb_amount <= std_logic_vector(to_unsigned(i, tb_amount'length));
			tb_c_in <= '1' when (i=2) else '0';
			tb_arith_shift <= '0';
			wait for 10 ns;
		end loop;
	
	-- tb_mux_ctrl: 00 -> 01
		for i in 0 to 3 loop
			tb_operand <= "1001";
			tb_mux_ctrl <= "01";
			tb_amount <= std_logic_vector(to_unsigned(i, tb_amount'length));
			tb_c_in <= '1' when (i=0) else '0';
			tb_arith_shift <= '0';
			wait for 10 ns;
		end loop;

	-- tb_mux_ctrl: 01 -> 10
		for i in 0 to 3 loop
			tb_operand <= "1001";
			tb_mux_ctrl <= "10";
			tb_amount <= std_logic_vector(to_unsigned(i, tb_amount'length));
			tb_c_in <= '1' when (i=2) else '0';
			tb_arith_shift <= '0';
			wait for 10 ns;
		end loop;	

	-- tb_arith_shift: 0 -> 1
		for i in 0 to 3 loop
			tb_operand <= "1001";
			tb_mux_ctrl <= "10";
			tb_amount <= std_logic_vector(to_unsigned(i, tb_amount'length));
			tb_c_in <= '0';
			tb_arith_shift <= '1';
			wait for 10 ns;
		end loop;

	-- tb_mux_ctrl: 10 -> 11
	-- tb_arith_shift: 1 -> 0
		for i in 0 to 3 loop
			tb_operand <= "1001";
			tb_mux_ctrl <= "11";
			tb_amount <= std_logic_vector(to_unsigned(i, tb_amount'length));
			tb_c_in <= '1' when (i=0) else '0';
			tb_arith_shift <= '0';
			wait for 10 ns;
		end loop;


	-- tb_mux_ctrl: 11 -> 00
	-- tb_c_in: 0 -> 1
		for i in 0 to 2 loop
			tb_operand <= "1001" when (i=0) else "0111";
			tb_mux_ctrl <= "00";
			tb_amount <= "00" when (i=0) else "10";
			tb_c_in <= '1';
			tb_arith_shift <= '0';
			wait for 10 ns;
		end loop;

	-- tb_operand: 0111 -> 0000
	-- tb_c_in: 1 -> 0
		for i in 0 to 1 loop
			tb_operand <= "0000";
    		tb_mux_ctrl <= "00";
			tb_amount <= "11" when (i=0) else "00";
			tb_c_in <= '0';
    		tb_arith_shift <= '0';
			wait for 10 ns;
		end loop;

		report "HALLO" severity failure;
	
    end process;
    
end architecture testbench;




