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

-------------------------------------------------------------------------------
-- This is the first method for assigning tags to cache blocks. It takes 
-- precedence when there exist blocks that do not have their valid-bit set,
-- and thus is responsible for the order in which blocks become valid.
-- Becuase of the paginated nature of the memory the cache refers to, validity
-- will only neet to be reset for an entire set of blocks at once. This is
-- crucial because it means we can define the behaviour of this component
-- with the knowledge that the valid blocks in a set can never be fragmented
-- if the validity of blocks is set in fixed order, allowing this component
-- to have a relatively simple cascading flow.
-------------------------------------------------------------------------------
entity prioritize_invalid_blocks is
    port(
        all_blocks_valid : out std_logic;
        block_valid_bits : in  std_logic_vector(0 to 15);
        block_to_replace : out std_logic_vector(0 to 15)
    );
end prioritize_invalid_blocks;

architecture prioritize_invalid_blocks_arch of prioritize_invalid_blocks is
    signal block_to_replace_s : std_logic_vector(0 to 15);
begin
    process(block_valid_bits)                               -- reevaluate if the valid blocks change
    begin
        block_to_replace_s <= x"0000";                      -- set all bits to '0'
        for i in 0 to (block_valid_bits'length - 1) loop    -- look at all of the blocks' valid-bits in order
            if i = 0  then                                  -- [first bit only]
                if (block_valid_bits(i) = '0') then           -- if the first bit isn't valid, then fill it
                    block_to_replace_s(i) <= '1';
                else
                    block_to_replace_s(i) <= '0';
                end if;
            
            else                                            -- [all other bits]
                if  (block_valid_bits(i - 1) = '1')           -- if the previous block is valid, but this one
                and (block_valid_bits(i) = '0') then        -- isn't, then this block is next to be filled.
                    block_to_replace_s(i) <= '1';
                else
                    block_to_replace_s(i) <= '0';
                end if;
            end if;
        end loop;
    end process;

    all_blocks_valid <= '1' when block_to_replace_s = x"0000" -- when all bits are '0'
                        else '0';
    block_to_replace <= block_to_replace_s;

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