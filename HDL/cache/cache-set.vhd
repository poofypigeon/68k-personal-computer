library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cache_set is
    port();
end cache_set;

architecture cache_set_arch of cache_set is
    component cache_block is
        port();
    end component;

    component replacement_policy is
        port();
    end component;

    component priority_encoder is
        port();
    end component;
begin
end cache_set_arch;