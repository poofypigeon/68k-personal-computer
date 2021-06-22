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