library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity prioritize_invalid_blocks_tb is
end prioritize_invalid_blocks_tb;

architecture prioritize_invalid_blocks_tb_arch of prioritize_invalid_blocks_tb is
    constant period : time := 20 ns;

    component prioritize_invalid_blocks
        port (
            block_valid_bits  : in  std_logic_vector(0 to 15);
            block_to_replace  : out std_logic_vector(0 to 15)
        ); 
    end component;

    signal block_valid_bits  : std_logic_vector(0 to 15);
    signal block_to_replace  : std_logic_vector(0 to 15);
begin
    UUT : prioritize_invalid_blocks port map (block_valid_bits, block_to_replace);

    process
    begin
        block_valid_bits <= "0000000000000000";
        wait for period;

        for i in 0 to 15 loop
            for j in 0 to 15 loop
                if j = i then
                    assert block_to_replace(j) = '1'
                    report "failed on bit" severity error;
                else
                    assert block_to_replace(j) = '0'
                    report "failed off bit" severity error;
                end if;
            end loop;
            block_valid_bits(i) <= '1';
            wait for period;
        end loop;
    end process;
end prioritize_invalid_blocks_tb_arch;