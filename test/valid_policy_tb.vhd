--< VALID_POLICY_TB >---------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library userlib;
use userlib.vector_tools.to_string;
use userlib.one_hot.all;
--+---------------------------------------------------------------------------------------------
--|
--+---------------------------------------------------------------------------------------------
entity valid_policy_tb is

end valid_policy_tb;

architecture valid_policy_tb_arch of valid_policy_tb is
    constant period : time := 20 ns;

    signal all_blocks_valid : std_ulogic;
    signal valid_blocks     : std_ulogic_vector(0 to 15);
    signal block_to_replace : one_hot(0 to 15);

begin
    UUT : entity work.valid_policy 
        generic map ( output_bundle_width => 16 )
        port map (
            all_blocks_valid => all_blocks_valid, 
            valid_blocks     => valid_blocks,
            block_to_replace => block_to_replace
        );

    process
    begin
        valid_blocks <= x"0000";
        wait for period;

        -- for all states of valid_blocks
        for i in 0 to 15 loop
            -- for all bits in block_to_replace
            for j in 0 to 15 loop
                if j = i then
                    -- enabled block_to_replace bit for a given valid_blocks input
                    assert block_to_replace(j) = '1'
                    report "FAILED: block_to_replace(" & integer'image(j)
                         & ") = '1' when valid_blocks = " & to_string(valid_blocks)
                    severity error;
                else
                    -- disabled block_to_replace bits for a given valid_blocks input
                    assert block_to_replace(j) = '0'
                    report "FAILED: block_to_replace(" & integer'image(j)
                         & ") = '0' when valid_blocks = " & to_string(valid_blocks)
                    severity error;
                end if;
            end loop;
            -- update to next valid_blocks state
            valid_blocks(i) <= '1';
            wait for period;
        end loop;

        -- block_to_replace = x"0000" when valid_blocks = x"FFFF"
        assert block_to_replace = x"0000"
        report "FAILED: block_to_replace = x""0000"" when valid_blocks = x""FFFF""" 
        severity error;

        -- all_blocks_valid = '1' when block_to_replace = x"0000"
        assert all_blocks_valid = '1'
        report "FAILED: all_blocks_valid = '1' when block_to_replace = x""0000""" 
        severity error;

        -- finish test
        wait;
    end process;
    
end valid_policy_tb_arch;