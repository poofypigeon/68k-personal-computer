--------------------------------------------------------------------------------
--  PRIORITIZE INVALID BLOCKS REPLACEMENT POLICY TESTBENCH
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--------------------------------------------------------------------------------
entity prioritize_invalid_blocks_tb is

end prioritize_invalid_blocks_tb;

architecture prioritize_invalid_blocks_tb_arch of prioritize_invalid_blocks_tb is
    constant period : time := 20 ns;

    signal all_blocks_valid : std_logic;
    signal block_valid_bits : std_logic_vector(0 to 15);
    signal block_to_replace : std_logic_vector(0 to 15);
begin
    UUT : entity prioritize_invalid_blocks 
        port map (
            all_blocks_valid => all_blocks_valid, 
            block_valid_bits => block_valid_bits, 
            block_to_replace => block_to_replace
        );

    tb : process
    begin
        block_valid_bits <= x"0000";
        wait for period;

        -- for all states of block_valid_bits
        for i in 0 to 15 loop
            -- for all bits in block_to_replace
            for j in 0 to 15 loop
                if j = i then
                    -- enabled block_to_replace bit for a given block_valid_bits input
                    assert block_to_replace(j) = '1'
                    report "FAILED: block_to_replace(" & integer'image(j)
                         & ") = '1' when block_valid_bits = " & std_logic_vector'image(block_valid_bits)
                    severity error;
                else
                    -- disabled block_to_replace bits for a given block_valid_bits input
                    assert block_to_replace(j) = '0'
                    report "FAILED: block_to_replace(" & integer'image(j)
                         & ") = '0' when block_valid_bits = " & std_logic_vector'image(block_valid_bits)
                    severity error;
                end if;
            end loop;
            -- update to next block_valid_bits state
            block_valid_bits(i) <= '1';
            wait for period;
        end loop;

        -- block_to_replace = x"0000" when block_valid_bits = x"FFFF"
        assert block_to_replace = x"0000"
        report "FAILED: block_to_replace = x""0000"" when block_valid_bits = x""FFFF""" 
        severity error;

        -- all_blocks_valid = '1' when block_to_replace = x"0000"
        assert all_blocks_valid = '1'
        report "FAILED: all_blocks_valid = '1' when block_to_replace = x""0000""" 
        severity error;

        -- finish test
        wait;
    end process tb;
end prioritize_invalid_blocks_tb_arch;


--------------------------------------------------------------------------------
--  PSEUDO LEAST RECENTLY USED TREE STRUCTURE TESTBENCH
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--------------------------------------------------------------------------------
entity plru_tree_tb is

end plru_tree_tb;

architecture plru_tree_tb_arch of plru_tree_tb is
    constant period : time := 20 ns;

    signal clk : in std_logic := '0';

    signal toggle_in   : std_logic_vector(0 to 15);
    signal replace_out : std_logic_vector(0 to 15);
begin
    UUT : entity plru_tree
        generic map (h => 4)
        port map (
            clk => clk,

            toggle_in   => toggle_in,
            replace_out => replace_out;
        );

    clk <= not clk after period / 2;

    process
        type stimulus is record 
            toggle_bit      : integer range 0 to 15;
            resulting_state : integer range 0 to 15;
        end record stimulus;

        type stimulus_file_type is file of stimulus;
        file stimulus_file : stimulus_file_type
            open is "stimulus/plru-stimulus.txt"

        variable i    : natural;
        variable temp : stimulus;
    begin
        -- initialize to state of 0
        wait for 0 ns;
        assert one_hot_to_int(replace_out, 16) = 0
        report "FAILED: initiale to state of 0" severity error;

        i := 0
        while not endfile(stimulus_file) loop
            read(stimulus_file, temp);
            toggle_in <= int_to_one_hot(temp.toggle_bit, 16)
            wait until falling_edge(clk);

            assert one_hot_to_int(replace_out, 16) = temp.resulting_state
            report "FAILED: at stim " & i & " with replace_out = " 
                 & integer'image(one_hot_to_int(replace_out, 16))
            severity error;

            i := i + 1;
        end loop
    end process
end plru_tree_tb_arch