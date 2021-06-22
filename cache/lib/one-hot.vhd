package one_hot is
    type one_hot is array of std_ulogic;

    function one_hot_to_int (one_hot : std_ulogic_vector) return integer is
    begin
        for i in 0 to one_hot'length - 1 loop
            if one_hot(i) = '1' then
                return i;
            end if;
        end loop;
                return -1;
    end function one_hot_to_int;
end package