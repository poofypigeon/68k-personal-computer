-- library ieee;
-- use ieee.std_logic_1164.all;
-- use ieee.numeric_std.all;

-- entity policy_plru is
--     port(
--         clk               : in  std_logic;
--         most_recent_block : in  std_logic_vector(0 to 15);
--         block_to_replace  : out std_logic_vector(0 to 15)
--     );
-- end policy_plru;

-- architecture policy_plru is
-- begin
-- end policy_plru;

------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity prioritize_invalid_blocks is
    port(
        block_valid_bits  : in  std_logic_vector(0 to 15);
        block_to_replace  : out std_logic_vector(0 to 15)
    );
end prioritize_invalid_blocks;

architecture prioritize_invalid_blocks_arch of prioritize_invalid_blocks is
begin
    process(block_valid_bits)
    begin
        for i in 0 to (block_valid_bits'length - 1) loop
            if i = 0  then
                if (block_valid_bits(i) = '0') then
                    block_to_replace(i) <= '1';
                else
                    block_to_replace(i) <= '0';
                end if;
            else
                if (block_valid_bits(i - 1) = '1') and (block_valid_bits(i) = '0') then
                    block_to_replace(i) <= '1';
                else
                    block_to_replace(i) <= '0';
                end if;
            end if;
        end loop;
    end process;
end prioritize_invalid_blocks_arch;

------------------------------

-- library ieee;
-- use ieee.std_logic_1164.all;
-- use ieee.numeric_std.all;

-- entity replacement_handler is
--     port(
--         clk               : in  std_logic;
--         set_is_selected   : in  std_logic;
--         block_valid_bits  : in  std_logic_vector(0 to 15);
--         most_recent_block : in  std_logic_vector(0 to 15);
--         block_to_replace  : out std_logic_vector(0 to 15)
--     );
-- end replacement_handler;

-- architecture replacement_handler_arch is
-- begin
-- end replacement_handler_arch;