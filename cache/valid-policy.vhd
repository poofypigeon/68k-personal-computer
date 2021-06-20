--< VALID_POLICY >------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--+---------------------------------------------------------------------------------------------
--| Cascading logic to sequentially fill all blocks in a set with valid data before turning 
--| block replacement control over to the primary replacement policy.
--| ---
--| This is the first stage for assigning tags to cache blocks. It takes precedence when there
--| are blocks that do not have their valid-bit set, and it is responsible for the order in 
--| which blocks become valid. Becuase validity can only be reset for an entire set of blocks at
--| once, the behaviour of this component can be defined with the knowledge that the valid
--| blocks in a set can never be fragmented if tags are assigned to blocks in a fixed order.
--| This allows this component to have a simple cascading flow.
--+---------------------------------------------------------------------------------------------
entity valid_policy is
    generic ( block_id_bit_width : positive )
    port (
        all_blocks_valid : out std_logic;
        valid_blocks     : in  std_logic_vector(0 to block_id_bit_width - 1);
        block_to_replace : out std_logic_vector(0 to block_id_bit_width - 1)
    );
end valid_policy;

architecture valid_policy_arch of valid_policy is
    signal block_to_replace_s : std_logic_vector(0 to block_id_bit_width - 1);
begin
    update : process(valid_block_bits)
    begin
        for i in 0 to valid_block_bits'length - 1 loop
            -- first bit - no dependency on previous bits
            if i = 0 then
                if valid_block_bits(i) = '0' then
                    block_to_replace_s(i) <= '1';
                else 
                    block_to_replace_s(i) <= '0';
                end if;
            -- other bits - dependant on previous bits
            else
                if valid_block_bits(i - 1) = '1' and valid_block_bits(i) = '0' then
                    block_to_replace_s(i) <= '1';
                else 
                    block_to_replace_s(i) <= '0';
                end if;
            end if;
        end loop;
    end process update;

    -- signal to arbitrate replacement policy once all blocks are valid
    all_blocks_valid <= '1' when to_integer(unsigned(block_to_replace_s)) = 0
                   else '0';
    block_to_replace <= block_to_replace_s;

end valid_policy_arch;