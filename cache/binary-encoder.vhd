library ieee;
use ieee.std_ulogic_1164.all;
use ieee.numeric_std.all;

entity binary_encoder is
    generic ( output_width : positive );
    port (
        input_bus : in  std_ulogic_vector(0 to (2 ** output_width) - 1);
        encoded   : out unsigned(output_width - 1 downto 0);
        valid     : out std_ulogic
    );
end binary_encoder;


architecture binary_encoder_arch of binary_encoder is
    constant input_width : positive := 2 ** output_width;

    type vocab_t is array (0 to output_width - 1, 0 to (input_width / 2) - 1) of natural;
    type dim_t is array (0 to output_width - 1) of std_ulogic_vector(0 to (input_width / 2) - 1);

    function gen_vocab (k, n : positive) return vocab_t is
        type actual_reg_t is array (0 to (input_width / 2) - 1) of natural;
        variable actual_reg : actual_reg_t;
        variable vocab      : vocab_t;

        constant test_one  : unsigned(k - 1 downto 0) := (0 => '1', others => '0'); 
        constant test_zero : unsigned(k - 1 downto 0) := (others => '0');

    begin
        for n_iter in 0 to input_width - 1 loop
            for k_iter in 0 to k - 1 loop
                if ((test_one SLL k_iter) and to_unsigned(n_iter, k)) /= test_zero then
                    vocab(k_iter, actual_reg(k_iter)) := n_iter;
                    actual_reg(k_iter) := actual_reg(k_iter) + 1;
                end if;
            end loop;
        end loop;

        return vocab;

    end function gen_vocab;

    function or_reduce(vec : std_ulogic_vector) return std_ulogic is
        variable result: std_ulogic;
    begin
        for i in vec'range loop
            if i = vec'left then
                result := vec(i);
            else
                result := result or vec(i);
            end if;
            exit when result = '1';
        end loop;
        return result;
    end or_reduce;

    constant vocab : vocab_t := gen_vocab(output_width, input_width);

    signal dim : dim_t;
    signal encoded_s : unsigned(output_width - 1 downto 0);
begin
    cross_conn : for k in 0 to output_width - 1 generate 
        out_conn : for q in 0 to (n / 2) - 1 generate
            dim(k)(q) <= input_bus(vocab(k, q)); 
        end generate out_conn;
    end generate cross_conn;
    
    encode : process(dim)
    begin
        for k in 0 to output_width - 1 loop
            encoded_s(k) <= or_reduce(dim(k));
        end loop;
    end process encode;

    valid <= or_reduce(input_bus);

    encoded <= encoded_s;

end binary_encoder_arch;