library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- TODO test start up behaviour for valid bit

entity cache_block is
    port (
        clk             : in  std_logic; -- clock
        set_is_selected : in  std_logic; -- tag belongs to set containing blocks
        replace_en      : in  std_logic; -- block selected by replacement policy
        reset           : in  std_logic  -- mark set tags invalid
        hit             : out std_logic; -- block is reporting a cache hit
        valid           : out std_logic; -- block contains valid data
        tag             : in  std_logic_vector(7 downto 0); -- tag of requested address
    );
end cache_block;

architecture cache_block_arch of cache_block is
    signal stored   : std_logic_vector(7 downto 0);
    signal match    : std_logic;
    signal valid_s  : std_logic := 0;

begin
    tag_register : entity d_type_register
    generic  port map (
        bit_count <= 8;
    );
    port map (
        clk => clk,
        en  => replace_en,  -- data input enable is controlled by replacement policy
        d   => tag,   
        q   => stored
    );

    match <= '1' when tag = stored -- does the tag query match stored tag
        else '0';
    hit   <=   match and set_is_selected and valid_s; -- report a cache hit

    set_valid : process(clk, reset)
    begin
        if reset = '1'
            valid_s <= '0';
        elsif rising_edge(clk) and replace_en = '1'
            valid_s <= '1';
        end if
    end process set_valid;

    valid <= valid_s;

end cache_block_arch;