library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package one_hot is
    subtype one_hot is std_ulogic_vector;

    function to_integer (signal_bus : one_hot) return integer;

    function to_one_hot (value, size : natural) return one_hot;

end package one_hot;

package body one_hot is
    function to_integer (signal_bus : one_hot) return integer is
    begin
        for i in 0 to signal_bus'length - 1 loop
            if signal_bus(i) = '1' then
                return i;
            end if;
        end loop;
                return -1;
    end function to_integer;

    function to_one_hot (value, size : natural) return one_hot is
        variable result : one_hot(0 to size - 1);
    begin
        for i in 0 to result'length - 1 loop 
            if i = value then
                result(i) := '1';
            else
                result(i) := '0';
            end if;
        end loop;
        return result;
    end function to_one_hot;
end package body one_hot;