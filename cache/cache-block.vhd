--< CACHE_BLOCK >------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--+--------------------------------------------------------------------------------------------
--| A paramentric cache block responsible for keeping track of tags which currently are 
--| represented in a larger cache set.
--| ---
--| A block will report a hit when two conditions are met:
--| [1] The valid bit is enabled to signify that its tag is associated with valid data in the
--|     cache's SRAM.
--| [2] The tag stored in the block matches the tag segment of the address being queried.
--+--------------------------------------------------------------------------------------------
entity cache_block is
    generic ( tag_bit_width : positive );
    port (
        clk : in  std_ulogic;

        tag_query   : in  unsigned(tag_bit_width - 1 downto 0);
        replace_en  : in  std_ulogic;
        reset_valid : in  std_ulogic;
        hit         : out std_ulogic;
        is_valid    : out std_ulogic
    );
end cache_block;

--+-< Cache Address Mapping >------------------+
--|   [a] tag (8)       xxxxxxxx xxxxx xxxxx   |
--|   [b] set (5)       [a]      [b]   [c]     |
--|   [c] offset (5)                           |
--+--------------------------------------------+

architecture cache_block_arch of cache_block is
    signal stored  : unsigned(tag_bit_width - 1 downto 0);
    signal match   : std_ulogic;
    signal valid_s : std_ulogic := 0;

begin
    tag_register : entity d_type_register
    generic map ( bit_width => tag_bit_width )
    port map (
        clk => clk,
        en  => replace_en,
        d   => tag_query,
        q   => stored
    );

    match <= '1' when tag_query = stored
        else '0';
    hit   <=   match and valid_s;

    set_valid : process(clk, reset)
    begin
        if reset_valid = '1'
            valid_s <= '0';
        elsif rising_edge(clk) and replace_en = '1'
            valid_s <= '1';
        end if
    end process set_valid;

    is_valid <= valid_s;

end cache_block_arch;