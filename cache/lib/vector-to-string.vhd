package vector_to_string is
    function to_string (vec : std_ulogic_vector) return string;
end package vector_to_string;


package body vector_string is
    function to_string (vec : std_ulogic_vector) return string is
        variable result : string (vec'length - 1 downto 0) := (others => NUL);
        begin
            for i in vec'range loop
                result(i) := std_ulogic'image(vec(i))(2);
            end loop;
        return result;
    end function;
end package body vector_to_string;