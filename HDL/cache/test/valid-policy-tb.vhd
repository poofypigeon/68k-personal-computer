--< VALID_POLICY_TB >---------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--+---------------------------------------------------------------------------------------------
--|
--+---------------------------------------------------------------------------------------------
entity valid_policy_tb is

end valid_policy_tb;

architecture valid_policy_tb_arch of valid_policy_tb is
    constant period : time := 20 ns;

    signal all_blocks_valid : std_logic;
    signal valid_block_bits : std_logic_vector(0 to 15);
    signal block_to_replace : std_logic_vector(0 to 15);

    -- This function was borrowed from Botond Sándor Kirei on Stack Overflow becuase I could not 
    -- be arsed to write it myself.
    -- >>> https://stackoverflow.com/a/38850022
    function to_string ( a: std_logic_vector) return string is
        variable b : string (1 to a'length) := (others => NUL);
        variable stri : integer := 1; 
        begin
            for i in a'range loop
                b(stri) := std_logic'image(a(i))(2);
            stri := stri+1;
            end loop;
        return b;
    end function;
begin
    UUT : entity work.valid_policy 
        port map (
            all_blocks_valid => all_blocks_valid, 
            valid_block_bits => valid_block_bits, 
            block_to_replace => block_to_replace
        );

    process
    begin
        valid_block_bits <= x"0000";
        wait for period;

        -- for all states of valid_block_bits
        for i in 0 to 15 loop
            -- for all bits in block_to_replace
            for j in 0 to 15 loop
                if j = i then
                    -- enabled block_to_replace bit for a given valid_block_bits input
                    assert block_to_replace(j) = '1'
                    report "FAILED: block_to_replace(" & integer'image(j)
                         & ") = '1' when valid_block_bits = " & to_string(valid_block_bits)
                    severity error;
                else
                    -- disabled block_to_replace bits for a given valid_block_bits input
                    assert block_to_replace(j) = '0'
                    report "FAILED: block_to_replace(" & integer'image(j)
                         & ") = '0' when valid_block_bits = " & to_string(valid_block_bits)
                    severity error;
                end if;
            end loop;
            -- update to next valid_block_bits state
            valid_block_bits(i) <= '1';
            wait for period;
        end loop;

        -- block_to_replace = x"0000" when valid_block_bits = x"FFFF"
        assert block_to_replace = x"0000"
        report "FAILED: block_to_replace = x""0000"" when valid_block_bits = x""FFFF""" 
        severity error;

        -- all_blocks_valid = '1' when block_to_replace = x"0000"
        assert all_blocks_valid = '1'
        report "FAILED: all_blocks_valid = '1' when block_to_replace = x""0000""" 
        severity error;

        -- finish test
        wait;
    end process;
end valid_policy_tb_arch;