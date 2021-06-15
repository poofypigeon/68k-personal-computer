library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity plru_tree is
    generics (
        h : positive;
    );
    port (
        clk                 :  in std_logic;
        toggle_path_in_a    :  in std_logic;
        toggle_path_in_b    :  in std_logic;
        toggle_path_out     : out std_logic;
        replace_path_in     :  in std_logic;
        replace_path_out_a  : out std_logic;
        replace_path_out_b  : out std_logic;
    );
end plru_tree;

architecture plru_tree_arch is
    generics (
        h : positive;
    );
    
    component plru_root (
        port (
            clk                 :  in std_logic;
            toggle_path_in_a    :  in std_logic;
            toggle_path_in_b    :  in std_logic;
            replace_path_out_a  : out std_logic;
            replace_path_out_b  : out std_logic;
        );
    )

    component plru_node (
        port (
            clk                 :  in std_logic;
            toggle_path_in_a    :  in std_logic;
            toggle_path_in_b    :  in std_logic;
            toggle_path_out     : out std_logic;
            replace_path_in     :  in std_logic;
            replace_path_out_a  : out std_logic;
            replace_path_out_b  : out std_logic;
        );
    )

    component plru_tree (
        port (
            clk                 :  in std_logic;
            toggle_path_in_a    :  in std_logic;
            toggle_path_in_b    :  in std_logic;
            toggle_path_out     : out std_logic;
            replace_path_in     :  in std_logic;
            replace_path_out_a  : out std_logic;
            replace_path_out_b  : out std_logic;
        );
    )

    signal
begin

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