--------------------------------------------------------------------------------
-- PRIORITIZE INVALID BLOCKS
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--------------------------------------------------------------------------------
-- This is the first stage for assigning tags to cache blocks. It takes 
-- precedence when there are blocks that do not have their valid-bit set,
-- and it is responsible for the order in which blocks become valid. Becuase
-- validity can only be reset for an entire set of blocks at once, the behaviour
-- of this component can be defined with the knowledge that the valid blocks
-- in a set can never be fragmented if tags are assigned to blocks in a fixed
-- order. This allows this component to have a simple cascading flow.
--------------------------------------------------------------------------------
entity prioritize_invalid is
    port(
        all_blocks_valid : out std_logic; -- signals block replacement arbitration to main policy
        valid_block_bits : in  std_logic_vector(0 to 15); -- valid bits from the blocks in the set
        block_to_replace : out std_logic_vector(0 to 15)  -- signals the next block to be replaced
    );
end prioritize_invalid;

architecture prioritize_invalid_blocks_arch of prioritize_invalid_blocks is
    signal block_to_replace_s : std_logic_vector(0 to 15);
begin
    process(valid_block_bits)
    begin
        for i in 0 to (valid_block_bits'length - 1) loop
            -- first bit
            if i = 0 then
                block_to_replace_s(i) <= '1' when not valid_block_bits(i)
                                    else '0';
            -- other bits
            else            
                block_to_replace_s(i) <= '1' when valid_block_bits(i - 1) 
                                             and not valid_block_bits(i) 
                                    else '0';
            end if;
        end loop;
    end process;

    all_blocks_valid <= '1' when block_to_replace_s = x"0000"
                   else '0';
    block_to_replace <= block_to_replace_s;

end prioritize_invalid_arch;