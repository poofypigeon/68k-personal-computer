library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity binary_encoder_tb is

end binary_encoder_tb;

architecture binary_encoder_tb_arch of binary_encoder_tb is
    constant period : time := 20 ns;
    constant k : positive := 4;

    signal input_bus : std_logic_vector(0 to (2 ** k) - 1);
    signal encoded   : unsigned(k - 1 downto 0);
    signal valid     : std_logic;

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
    UUT : entity work.binary_encoder
        generic map ( output_width => k )
        port map (
            input_bus => input_bus,
            encoded   => encoded,
            valid     => valid
        );

    process
        variable data : std_logic_vector(0 to (2 ** k) - 1) := (0 => '1', others => '0');
    begin
        input_bus <= (others => '0');
        wait for period;
        report "input bus: " & integer'image(one_hot_to_int(input_bus)) & 
            "; encoded: " & to_string(std_logic_vector(encoded)) &
            "; valid: "   & std_logic'image(valid);

        for i in 0 to (2 ** k) - 1 loop 
            input_bus <= std_logic_vector((unsigned(data)) SRL i);
            wait for period;
            report "input bus: " & integer'image(one_hot_to_int(input_bus)) & 
                "; encoded: " & to_string(std_logic_vector(encoded)) &
                "; valid: "   & std_logic'image(valid);
        end loop;
        wait;
    end process;
end binary_encoder_tb_arch;