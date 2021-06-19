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
    signal valid_block_bits : std_logic_vector(0 to 15);
    signal block_to_replace : std_logic_vector(0 to 15);

    -- this function was borrowed from Botond Sándor Kirei on Stack Overflow
    -- becuase I could not be arsed to write it when I just want to make a
    -- testbench. https://stackoverflow.com/a/38850022
    function to_string ( a: std_logic_vector) return string is
        variable b : string (1 to a'length) := (others => NUL);
        variable stri : integer := 1; 
        begin
            for i in a'range loop
                b(stri) := std_logic'image(a((i)))(2);
            stri := stri+1;
            end loop;
        return b;
    end function;
begin
    UUT : entity work.prioritize_invalid_blocks 
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

    signal clk : std_logic := '0';

    signal toggle_in   : std_logic_vector(0 to 15);
    signal replace_out : std_logic_vector(0 to 15);

    function int_to_one_hot (num, size : natural) return std_logic_vector is
        variable result : std_logic_vector(0 to size - 1);
    begin
        for i in 0 to size - 1 loop
            if i = num then
                result(i) := '1';
            else 
                result(i) := '0';
            end if;
        end loop;
            return result;
    end function int_to_one_hot;

    function one_hot_to_int (one_hot : std_logic_vector) return integer is
    begin
        for i in 0 to one_hot'length - 1 loop
            if one_hot(i) = '1' then
                return i;
            end if;
        end loop;
                return -1;
    end function one_hot_to_int;

begin
    UUT : entity work.plru_tree
        generic map (h => 4)
        port map (
            clk => clk,

            toggle_in   => toggle_in,
            replace_out => replace_out
        );

    clk <= not clk after period / 2;

    process
        type stimulus is record 
            toggle_bit      : integer;
            resulting_state : integer;
        end record stimulus;

        type stimulus_file_type is file of integer;
        file stimulus_file : stimulus_file_type 
            open read_mode is "test/stimulus/plru-stimulus";

        variable i             : integer;
        variable temp_stimulus : stimulus;
    begin
        -- initialize to state of 0
        wait for 1 ns;
        assert one_hot_to_int(replace_out) = 0
        report "FAILED: initialize to state of 0, got: " & integer'image(one_hot_to_int(replace_out)) severity error;

        i := 0;
        while not endfile(stimulus_file) loop
            read(stimulus_file, temp_stimulus.toggle_bit);
            read(stimulus_file, temp_stimulus.resulting_state);

            toggle_in <= int_to_one_hot(temp_stimulus.toggle_bit, 16);
            wait until falling_edge(clk);

            assert one_hot_to_int(replace_out) = temp_stimulus.resulting_state
            report "FAILED: at stim " & integer'image(i) & " with replace_out = " 
                 & integer'image(one_hot_to_int(replace_out))
            severity error;

            -- verbose report
            report integer'image(i) & "; " 
            & integer'image(one_hot_to_int(toggle_in)) & "; " 
            & integer'image(one_hot_to_int(replace_out));

            i := i + 1;
        end loop;

        wait; -- finish test
    end process;
end plru_tree_tb_arch;