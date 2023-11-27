library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.ArmTypes.all;

entity ArmMultiplier_tb is
end ArmMultiplier_tb;

architecture testbench of ArmMultiplier_tb is
    -- helping components and variables 
    component ArmMultiplier is
        Port (
            MUL_OP1 	: in  STD_LOGIC_VECTOR (31 downto 0);	-- Rm
            MUL_OP2 	: in  STD_LOGIC_VECTOR (31 downto 0);	-- Rs
            MUL_RES 	: out  STD_LOGIC_VECTOR (31 downto 0)	-- Rd bzw. RdLo         	
        );
    end component ArmMultiplier;
    signal MUL_OP1:  STD_LOGIC_VECTOR (31 downto 0) := (others =>'0');
    signal MUL_OP2:  STD_LOGIC_VECTOR (31 downto 0) := (others =>'0');
    signal MUL_RES:  STD_LOGIC_VECTOR (31 downto 0); -- output, keine Zuweisung nötig

    -- random testwerte
    type test_array is array (5 downto 0) of std_logic_vector(31 downto 0);
    signal test_op1 : test_array := (x"00000000", x"00000000", x"FFFFFFFF", x"00000009", x"11111111", x"11111111");
    signal test_op2 : test_array := (x"00000000", x"FFFFFFFF", x"FFFFFFFF", x"0000000E", x"11111111", x"00000001");
    signal test_res : test_array := (x"00000000", x"00000001", x"00000000", x"0000007E", x"87654321", x"11111111");
    
    -- begin actual tests 
    begin 
        TEST : ArmMultiplier
        port map(
            MUL_OP1 => MUL_OP1,
            MUL_OP2 => MUL_OP2,
            MUL_RES => MUL_RES
        );

    testing: process 
    	
    begin
        for i in 5 downto 0 loop
            MUL_OP1 <= test_op1(i);
            MUL_OP2 <= test_op2(i);
            wait for 100 ns;
            assert MUL_RES = test_res(i) report "Expected " & to_hstring(MUL_OP1) &" * "&to_hstring(MUL_OP2)&" = "&to_hstring(test_res(i))&". Got "&to_hstring(MUL_RES)&" :(";
            wait for 10 ns;
        end loop;
        report "End of Test :)" severity failure;
    end process testing;
    
end architecture testbench;
