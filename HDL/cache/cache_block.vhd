library library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity register_8bit is
    port (
        clk : in  std_logic; -- clock
        en  : in  std_logic; -- data input enable
        d   : in  std_logic_vector (7 downto 0); -- data in
        q   : out std_logic_vector (7 downto 0)  -- data out
    );
end register_8bit;

architecture register_8bit_arch is
begin
    try_latch : process(rising_edge(clk))
    begin
        if en = '1' then
            q <= d;
        end if;
    end process try_latch;
end register_8bit_arch;


entity cache_block is
    port (
        clk         : in  std_logic; -- clock
        set_select  : in  std_logic; -- tag belongs to set containing blocks
        replace_en  : in  std_logic; -- block selected by replacement policy
        tag_query   : in  std_logic vector (7 downto 0); -- tag of requested address
        tag_assert  : out std_logic_vector (7 downto 0); -- buffered tag output on cache hit
        hit   : out std_logic; -- block is reporting a cache hit
        valid       : out std_logic; -- block contains valid data
        reset       : in  std_logic  -- mark set tags invalid
    );
end cache_block;

architecture cache_block_arch of cache_block is
    component register_8bit
        port (
            clk : in  std_logic;
            en  : in  std_logic;
            d   : in  std_logic_vector (7 downto 0);
            q   : out std_logic_vector (7 downto 0)
        );
    end component;

    signal stored   : std_logic_vector (7 downto 0);
    signal match    : std_logic;
    signal hit_s    : std_logic;
    signal valid_s  : std_logic;

begin
    tag_register : register_8bit port map (
        clk => clk,
        en  => replace_en,  -- data in enable is controlled by replacement policy
        d   => tag_query,   
        q   => stored
    );

    valid   <=  valid_s;
    hit     <=  hit_s;

    match       <=  '1' when tag_query = stored  -- does the tag query match stored tag
                    else '0';
    hit_s       <=  match and set_select and valid_s;     -- report a cache hit
    tag_assert  <=  stored when hit_s = '1' -- block will output to tag bus only when reporting a hit
                    else 'Z';

    set_valid : process(clk, reset)
    begin
        if reset = '1' then 
            valid_s <= '0'; -- clear valid bit
        elsif rising_edge(clk) and replace_en = '1' then 
            valid_s <= '1'; -- set valid bit when tag assigned
    end process set_valid;

end cache_block_arch;