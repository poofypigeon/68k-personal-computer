--< PLRU_POLICY_TB >----------------------------------------------------------------------------
library ieee;
use ieee.std_ulogic_1164.all;
use ieee.numeric_std.all;
--+---------------------------------------------------------------------------------------------
--|
--+---------------------------------------------------------------------------------------------
entity plru_policy_tb is

end plru_policy_tb;

architecture plru_policy_tb_arch of plru_policy_tb is
    constant period : time := 20 ns;

    signal clk : std_ulogic := '0';

    signal toggle_in   : std_ulogic_vector(0 to 15);
    signal replace_out : std_ulogic_vector(0 to 15);

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

            toggle_in <= (temp_stimulus.toggle_bit => '1', others => '0');
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