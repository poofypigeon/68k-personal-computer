library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package one_hot_type is
    subtype one_hot is std_ulogic_vector;

    function to_integer (signal_bus : one_hot) return integer;
end package;

package body one_hot_type is
    function to_integer (signal_bus : one_hot) return integer is
    begin
        for i in 0 to signal_bus'length - 1 loop
            if signal_bus(i) = '1' then
                return i;
            end if;
        end loop;
                return -1;
    end function to_integer;
end package body one_hot_type;