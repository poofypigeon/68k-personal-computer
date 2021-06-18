--------------------------------------------------------------------------------
--  PSEUDO LEAST RECENTLY USED TREE
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--------------------------------------------------------------------------------
--  recursive tree structure for generating a PSLR replacement policy structure
--------------------------------------------------------------------------------
entity plru_branch is
    generic (h : natural);
    port (
        clk : in  std_logic;
        
        toggle_out  : out std_logic_vector(0 to 1);
        toggle_in   : in  std_logic_vector(0 to (2 ** h) - 1);

        replace_in  : in  std_logic_vector(0 to 1);
        replace_out : out std_logic_vector(0 to (2 ** h) - 1)
    );
end plru_branch;

architecture plru_branch_arch is
    generic (h : natural);

    signal toggle_in_s   : in  std_logic_vector(0 to 3);
    signal replace_out_s : out std_logic_vector(0 to 3);
begin
    degenerate_tree : if h = 0 then
        replace_out(0) <= replace_in;
        toggle_out     <= toggle_in;
    end if degenerate_tree;

    subtree : if h > 0 then
       subtree_array for i in 0 to 1 generate
            node : entity plru_node
                port map (
                    clk => clk,

                    toggle_in_a => toggle_in_s(i * 2),
                    toggle_in_b => toggle_in_s((i * 2) + 1),
                    toggle_out  => toggle_out(i),

                    replace_in    => replace_in(i),
                    replace_out_a => replace_out_s(i * 2),
                    replace_out_b => replace_out_s((i * 2) + 1)
                );

            branch : entity plru_branch
                generic map (h => h - 1)
                port map (
                    clk => clk,

                    toggle_out  => toggle_in_s(i * 2 to (i * 2) + 1),
                    toggle_in   => toggle_in
                        ( i * (2 ** (h – 1)) to (i + 1) * (2 ** (h – 1)) – 1),

                    replace_in  => replace_out_s(i * 2 to (i * 2) + 1),
                    replace_out => replace_out
                        ( i * (2 ** (h – 1)) to (i + 1) * (2 ** (h – 1)) – 1)
                );
        end generate subtree_array;
    end if subtree;
end plru_branch_arch


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity plru_node is
    port (
        clk : in std_logic;

        toggle_in_a   :  in std_logic;
        toggle_in_b   :  in std_logic;
        toggle_out    : out std_logic;

        replace_in    :  in std_logic;
        replace_out_a : out std_logic;
        replace_out_b : out std_logic;
    );
end plru_branch;

architecture plru_node_arch of plru_node is
    signal toggle_s : std_logic;
    signal state_s  : std_logic;
begin
    state : entity t_flip_flop
        generic map (inital => '0')
        port map (
            clk => clk,
            t   => toggle_s,
            q   => state_s
        );

    toggle_s <= toggle_in_a or toggle_in_b;

    toggle_out <= toggle_s;

    replace_out_a <= replace_in and not state_s;
    replace_out_b <= replace_in and state_s;
end plru_node_arch;


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity plru_root is
    generics (
        domain : natural;
    );
    port (
        clk : in std_logic;
        toggle_in_a   :  in std_logic;
        toggle_in_b   :  in std_logic;
        replace_out_a : out std_logic;
        replace_out_b : out std_logic;
    );
end plru_branch;

architecture plru_root_arch of plru_root is
    signal toggle_s : std_logic;
    signal state_s  : std_logic;
begin
    state : entity t_flip_flop
        generic map (inital => '0')
        port map (
            clk => clk,
            t   => toggle_s,
            q   => state_s
        );

    toggle_s <= toggle_in_a or toggle_in_b;

    replace_out_a <= not state_s;
    replace_out_b <= state_s;
end plru_root_arch;


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity plru_tree is
    generic (h : positive);
    port (
        clk : in std_logic;
        
        toggle_in   : in  std_logic_vector(0 to (2 ** h) - 1);
        replace_out : out std_logic_vector(0 to (2 ** h) - 1);
    );
end plru_tree;

architecture plru_tree_arch of plru_tree is
    root_toggle_s   : std_logic_vector(0 to 1);
    root_replace_s  : std_logic_vector(0 to 1);
begin
        root : entity plru_root
            port map (
                clk => clk,

                toggle_in_a => root_toggle_s(0),
                toggle_in_b => root_toggle_s(1),

                replace_out_a => root_replace_s(0).
                replace_out_b => root_replace_s(1)
            );

        branches : entity plru_branch
            generic map (h => h - 1)
            port map (
                clk => clk,

                toggle_out  => root_toggle_s,
                toggle_in   => toggle_in,

                replace_in  => root_replace_s,
                replace_out => replace_out
            );
end plru_tree_arch;


-- library ieee;
-- use ieee.std_logic_1164.all;
-- use ieee.numeric_std.all;

-- entity plru_policy is
--     port(
--         clk               : in  std_logic;
--         most_recent_block : in  std_logic_vector(0 to 15);
--         block_to_replace  : out std_logic_vector(0 to 15)
--     );
-- end plru_policy;

-- architecture plru_policy_arch of plru_policy is
    
-- begin
--     process
--     begin
--         for i in 1 to 8 loop
--             if i = 1 then
--                 -- root node
--             else
--                 for j in 0 to i generate
--                     -- others
--                 end generate;
--             end if;
--         end loop;
--     end process;
-- end plru_policy_arch;
