library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity binary_encoder is
    generic ( output_width : positive );
    port (
        input_bus : in  std_logic_vector(0 to (2 ** output_width) - 1);
        encoded   : out unsigned(output_width - 1 downto 0);
        valid     : out std_logic
    );
end binary_encoder;


architecture binary_encoder_arch of binary_encoder is
    constant k : positive := output_width;
    constant n : positive := 2 ** k;

    type vocab_t is array (0 to k - 1, 0 to (n / 2) - 1) of natural;
    type dim_t is array (0 to k - 1) of std_logic_vector(0 to (n / 2) - 1);
    
    function is_all(vec : std_logic_vector; val : std_logic) return boolean is
        constant all_bits : std_logic_vector(vec'range) := (others => val);
    begin
        return vec = all_bits;
    end function;

    function gen_vocab (k_fn, n_fn : positive) return vocab_t is
        type actual_reg_t is array (0 to (n_fn / 2) - 1) of natural;
        variable actual_reg : actual_reg_t;
        variable vocab      : vocab_t;

        constant test_one  : unsigned(k_fn - 1 downto 0) := (0 => '1', others => '0'); 
        constant test_zero : unsigned(k_fn - 1 downto 0) := (others => '0');

    begin
        for k_for in 0 to k_fn - 1 loop
            actual_reg(k_for) := 0;
        end loop;

        for n_for in 0 to n_fn - 1 loop
            for k_for in 0 to k_fn - 1 loop
                if ((test_one SLL k_for) and to_unsigned(n_for, k_fn)) /= test_zero then
                    vocab(k_for, actual_reg(k_for)) := n_for;
                    actual_reg(k_for) := actual_reg(k_for) + 1;
                end if;
            end loop;
        end loop;

        return vocab;

    end function gen_vocab;

    function or_reduce(vec : std_logic_vector) return std_logic is
        variable result: std_logic;
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

    constant vocab : vocab_t := gen_vocab(k, n);

    signal dim : dim_t;
    signal encoded_s : unsigned(k - 1 downto 0);
begin
    cross_conn: for k_for in 0 to k - 1 generate 
        out_conn: for q_for in 0 to (n / 2) - 1 generate
            dim(k_for)(q_for) <= input_bus(vocab(k_for, q_for)); 
        end generate out_conn;
    end generate cross_conn;
    
    process(dim)
    begin
        for k_for in 0 to k - 1 loop
            encoded_s(k_for) <= or_reduce(dim(k_for));
        end loop;
    end process;

    valid <= or_reduce(input_bus);

    encoded <= encoded_s;

end binary_encoder_arch;