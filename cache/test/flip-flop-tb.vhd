--< T_FLIP_FLOP_TB >----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--+---------------------------------------------------------------------------------------------
--|
--+---------------------------------------------------------------------------------------------
entity t_flip_flop_tb is

end t_flip_flop_tb;

architecture t_flip_flop_tb_arch of t_flip_flop_tb is
    constant period : time := 20 ns;

    signal clk : std_ulogic := '0'; -- clock is initialized low
    signal t   : std_ulogic := '0'; -- t is initialized to low
    signal q   : std_ulogic;
    
begin
    UUT : entity t_flip_flop
        generic map ( initial => '0' )
        port map (
            clk => clk,
            t   => t,
            q   => q
        );
        
    -- clock generation
    clk <= not clk after period / 2;

    process
    begin
        -- initialization value test
        wait for 2 ns; -- prevents error by allowing q to initialize
        assert q = '0'
        report "FAILED: ""initialization value test""" severity error;

        -- retain state on clock when t = '0'
        wait until falling_edge(clk);
        assert q = '0'
        report "FAILED: ""retain state on clock when t = '0'""" severity error;

        -- set q <= '1' on clk when t = '1' and q = '0'
        t <= '1';
        wait until falling_edge(clk);
        assert q = '1'
        report "FAILED: ""set q <= '1' on clk when t = '1' and q = '0'""" severity error;

        -- set q <= '0' on clk when t = '1' and q = '1'
        wait until falling_edge(clk);
        assert q = '0'
        report "FAILED: ""set q <= '0' on clk when t = '1' and q = '1'""" severity error;

        -- finish test
        t <= '0';
        wait;
    end process;

end t_flip_flop_tb_arch;