--< VALID_POLICY >------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library userlib;
use userlib.one_hot.all;
use userlib.vector_tools.and_reduce;
--+---------------------------------------------------------------------------------------------
--| Cascading logic to sequentially fill all blocks in a set with valid data before turning 
--| block replacement control over to the primary replacement policy.
--| ---
--| This is the first stage for assigning tags to cache blocks. It takes precedence when there
--| are blocks that do not have their valid-bit set, and it is responsible for the order in 
--| which blocks become valid. Becuase validity can only be reset for an entire set of blocks at
--| once, the behaviour of this component can be defined with the knowledge that the valid
--| blocks in a set can never be fragmented if tags are assigned to blocks in a fixed order.
--| This allows this component to have a simple cascading flow. Were fragmentation a factor,
--| this difficulty could be overcome by using a traditional priority resolving circuit.
--|
--| ~NOTE : this component should be considered in the case that propogation delay proves to be
--|         an issue when synthesizing. A parallel solution could be implemented at the cost
--|         of more gates.
--+---------------------------------------------------------------------------------------------
entity valid_policy is
    generic ( output_bundle_width : positive );
    port (
        all_blocks_valid : out std_ulogic;
        valid_blocks     : in  std_ulogic_vector(0 to output_bundle_width - 1);
        block_to_replace : out one_hot(0 to output_bundle_width - 1)
    );
end valid_policy;

architecture valid_policy_arch of valid_policy is
begin
    priority : for i in 0 to output_bundle_width - 1 generate
        first_bit : if i = 0 generate
            block_to_replace(i) <= not valid_blocks(i);
        end generate first_bit;

        other_bits : if i > 0 generate
             block_to_replace(i) <= valid_blocks(i - 1) and not valid_blocks(i);
        end generate other_bits;
            
    end generate priority;

    -- signal to arbitrate replacement policy once all blocks are valid
    all_blocks_valid <= and_reduce(valid_blocks);

end valid_policy_arch;