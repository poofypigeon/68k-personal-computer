--< CACHE_SET >--------------------------------------------------------------------------------
library ieee;
use ieee.std_ulogic_1164.all;
use ieee.numeric_std.all;

use work.vector_reduce.or_reduce;
--+---------------------------------------------------------------------------------------------
--|
--+---------------------------------------------------------------------------------------------
entity cache_set is
    generic (
        tag_bit_width      : positive;
        block_id_bit_width : positive
    );
    port(
        clk : in std_ulogic;

        set_is_selected : in  std_ulogic;
        reset_valid     : in  std_ulogic;
        query_hit       : out std_ulogic;
        tag_query       : in  unsigned(tag_bit_width - 1 downto 0)
        hit_block_id    : out unsigned(block_id_bit_width - 1 downto 0)
    );
end cache_set;

architecture cache_set_arch of cache_set is
    constant block_count : positive := 2 ** block_id_bit_width;

    signal pulse_s                : std_ulogic;
    signal all_blocks_valid_s     : std_ulogic;
    signal query_hit_s            : std_ulogic;
    signal valid_blocks_s         : std_ulogic_vector(0 to block_count - 1);
    signal valid_policy_replace_s : std_ulogic_vector(0 to block_count - 1);
    signal plru_policy_replace_s  : std_ulogic_vector(0 to block_count - 1);
    signal block_to_replace_s     : std_ulogic_vector(0 to block_count - 1);
    signal replace_en_s           : std_ulogic_vector(0 to block_count - 1);
    signal hit_block_s            : std_ulogic_vector(0 to block_count - 1);
    signal block_to_access_s      : std_ulogic_vector(0 to block_count - 1);

begin
    gen_blocks : for i in 0 to block_count - 1 generate
        block_instance : entity work.cache_block
            generic map ( tag_bit_width => tag_bit_width )
            port map ( 
                clk => pulse_s;

                tag_query   => tag_query,
                replace_en  => replace_en_s,
                reset_valid => reset_valid,
                hit         => hit_block_s(i),
                is_valid    => valid_blocks_s(i)
            );
    end generate gen_blocks;
    
    init_policy : entity work.valid_policy
        generic map ( block_id_bit_width => block_id_bit_width )
        port map (
            all_blocks_valid => all_blocks_valid_s,
            valid_blocks     => valid_blocks_s,
            block_to_replace => valid_policy_replace_s
        );

    main_policy : entity work.plru_policy
        generic map ( height => block_id_bit_width )
        port map (
            clk => pulse_s,
        
            toggle_in   => block_to_access_s,
            replace_out => plru_policy_replace_s
        );

    encoder : entity work.binary_encoder
        generic map ( output_width => block_id_bit_width )
        port map (
            input_bus => block_to_access_s,
            encoded   => hit_block_id,
            valid     => open
        );

    pulse_s <= clk and set_is_selected;

    query_hit_s <= '1' when or_reduce(hit_block_s) = '1'
              else '0';
    query_hit   <= query_hit_s and set_is_selected;

    block_to_replace_s <= valid_policy_replace_s when all_blocks_valid_s = '0'
                     else plru_policy_replace_s;
    block_to_access_s  <= hit_block_s when query_hit_s = '1'
                     else block_to_replace_s;
    replace_en_s       <= block_to_replace_s when query_hit_s = '0'
                     else (others => '0');
        
end cache_set_arch;