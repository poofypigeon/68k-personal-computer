library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity t_flip_flop_tb is

end t_flip_flop_tb;

-- TODO add asserts now that states are predictable

architecture t_flip_flop_tb_arch of t_flip_flop_tb is
    constant period : time := 20 ns;

    component t_flip_flop 
        generic (
            initial : std_logic;
        );

        port (
            clk :  in std_logic;
            t   :  in std_logic;
            q   : out std_logic
        );
    end component;

    signal clk : std_logic;
    signal t   : std_logic;
    signal q   : std_logic;
    
begin
    UUT : t_flip_flop 
        port map (
            clk => clk, 
            t   => t, 
            q   => q
        );

        generic map (
            initial => '0'
        );

    process
        variable i : integer := 0; -- initial value is '0'
    begin
        loop
            t <= '1' when (i / 4) mod 2 = 0
            else '0'; 
                
            clk <= '1';
            wait for period / 2;
            clk <= '0';
            wait for period / 2;

            report "Output is " & std_logic'image(q);

            i := i + 1;
        end loop;
    end process;
end t_flip_flop_tb_arch;