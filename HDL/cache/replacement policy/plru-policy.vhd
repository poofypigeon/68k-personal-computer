--------------------------------------------------------------------------------
--  PSEUDO LEAST RECENTLY USED TREE
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--------------------------------------------------------------------------------
--  recursive tree structure for generating a PSLR replacement policy structure
--------------------------------------------------------------------------------
entity plru_tree is
    generic (h : natural);
    port (
        clk              : in  std_logic;
        
        toggle_path_out  : out std_logic_vector(0 to 1);
        toggle_path_in   : in  std_logic_vector(0 to (2 ** h) - 1);

        replace_path_in  : in  std_logic;
        replace_path_out : out std_logic_vector(0 to (2 ** h) - 1);
    );
end plru_tree;

architecture plru_tree_arch is
    generic (h : natural);

    signal toggle_path_in_s   : in  std_logic_vector(0 to 3);
    signal replace_path_out_s : out std_logic_vector(0 to 3);
begin
    degenerate_tree : if h = 0 then
        replace_path_out(0) <= replace_path_in;
        toggle_path_out     <= toggle_path_in;
    end if degenerate_tree;

    subtree : if h > 0 then
       subtree_array for i in 0 to 1 generate
            node : entity plru_node
                port map (
                    clk => clk,

                    toggle_path_in_a => toggle_path_in_s(i * 2),
                    toggle_path_in_b => toggle_path_in_s((i * 2) + 1),
                    toggle_path_out  => toggle_path_out(i),

                    replace_path_in    => replace_path_in,
                    replace_path_out_a => replace_path_out_s(i * 2),
                    replace_path_out_b => replace_path_out_s((i * 2) + 1)
                );

            branch : entity plru_tree
                generic map (h => h - 1)
                port map (
                    clk => clk,

                    toggle_path_out  => toggle_path_in_s(i * 2 to (i * 2) + 1),
                    toggle_path_in   => toggle_path_in
                        ( i * (2 ** (h – 1)) to (i + 1) * (2 ** (h – 1)) – 1),

                    replace_path_in  => (i * 2 to (i * 2) + 1),
                    replace_path_out => replace_path_out
                        ( i * (2 ** (h – 1)) to (i + 1) * (2 ** (h – 1)) – 1)
                );
        end generate subtree_array;
    end if subtree;
end plru_tree_arch


-- library ieee;
-- use ieee.std_logic_1164.all;
-- use ieee.numeric_std.all;

-- entity plru_root is
--     generics (
--         domain : natural;
--     );
--     port (
--         clk                 :  in std_logic;
--         toggle_path_in_a    :  in std_logic;
--         toggle_path_in_b    :  in std_logic;
--         replace_path_out_a  : out std_logic;
--         replace_path_out_b  : out std_logic;
--     );
-- end plru_tree;


-- library ieee;
-- use ieee.std_logic_1164.all;
-- use ieee.numeric_std.all;

-- entity plru_node is
--     port (
--         clk                 :  in std_logic;
--         toggle_path_in_a    :  in std_logic;
--         toggle_path_in_b    :  in std_logic;
--         toggle_path_out     : out std_logic;
--         replace_path_in     :  in std_logic;
--         replace_path_out_a  : out std_logic;
--         replace_path_out_b  : out std_logic;
--     );
-- end plru_tree;

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