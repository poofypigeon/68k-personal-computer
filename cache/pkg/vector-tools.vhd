library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package vector_reduce is
    function or_reduce  (vec : std_ulogic_vector) return std_ulogic;
    function and_reduce (vec : std_ulogic_vector) return std_ulogic;
    
end package vector_reduce;

package body vector_reduce is
    function or_reduce (vec : std_ulogic_vector) return std_ulogic is
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

    function and_reduce (vec : std_ulogic_vector) return std_ulogic is
        variable result: std_ulogic;
    begin
        for i in vec'range loop
            if i = vec'left then
                result := vec(i);
            else
                result := result and vec(i);
            end if;
            exit when result = '0';
        end loop;
        return result;
    end and_reduce;

end package body vector_reduce;


package vector_string is
    function to_string (vec : std_ulogic_vector) return string;
    
end package vector_string;

package body vector_string is
    function to_string (vec : std_ulogic_vector) return string is
        variable result : string (vec'length - 1 downto 0) := (others => NUL);
        begin
            for i in vec'range loop
                result(i) := std_ulogic'image(vec(i))(2);
            end loop;
        return result;
    end function;

end package body vector_string;