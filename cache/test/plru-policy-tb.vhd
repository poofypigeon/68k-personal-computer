--< PLRU_POLICY_TB >----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--+---------------------------------------------------------------------------------------------
--|
--+---------------------------------------------------------------------------------------------
entity plru_policy_tb is

end plru_policy_tb;

architecture plru_policy_tb_arch of plru_policy_tb is
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
    UUT : entity work.plru_policy
        generic map (height => 4)
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
    
end plru_policy_tb_arch;