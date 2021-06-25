library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.one_hot.all;
use work.vector_tools.to_string;

entity binary_encoder_tb is

end binary_encoder_tb;

architecture binary_encoder_tb_arch of binary_encoder_tb is
    constant period : time := 20 ns;
    constant k      : positive := 4;

    signal input_bus : one_hot(0 to (2 ** k) - 1);
    signal encoded   : unsigned( k - 1 downto 0 );
    signal valid     : std_ulogic;

begin
    UUT : entity work.binary_encoder
        generic map ( output_width => k )
        port map (
            input_bus => input_bus,
            encoded   => encoded,
            valid     => valid
        );

    process
        variable data : std_ulogic_vector(0 to (2 ** k) - 1) := (0 => '1', others => '0');
    begin
        input_bus <= (others => '0');
        wait for period;
        report "input bus: " & integer'image(to_integer(input_bus)) & 
            "; encoded: " & to_string(std_ulogic_vector(encoded)) &
            "; valid: "   & std_ulogic'image(valid);

        for i in 0 to (2 ** k) - 1 loop 
            input_bus <= std_ulogic_vector((unsigned(data)) SRL i);
            wait for period;
            report "input bus: " & integer'image(to_integer(input_bus)) & 
                "; encoded: " & to_string(std_ulogic_vector(encoded)) &
                "; valid: "   & std_ulogic'image(valid);
        end loop;
        wait;
    end process;
end binary_encoder_tb_arch;