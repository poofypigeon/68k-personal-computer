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
        replace_out_b : out std_logic
    );
end plru_node;

architecture plru_node_arch of plru_node is
    signal toggle_s : std_logic;
    signal state_s  : std_logic;

begin
    state : entity work.t_flip_flop
        generic map (initial => '0')
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

architecture plru_branch_arch of plru_branch is
    signal toggle_in_s   : std_logic_vector(0 to 3);
    signal replace_out_s : std_logic_vector(0 to 3);

begin
    outer_structure : if h = 1 generate
        replace_out(0 to 1) <= replace_in;
        toggle_out          <= toggle_in;
    elsif h > 1 generate
       inner_structure : for i in 0 to 1 generate
            node : entity work.plru_node
                port map (
                    clk => clk,

                    toggle_in_a => toggle_in_s(i * 2),
                    toggle_in_b => toggle_in_s((i * 2) + 1),
                    toggle_out  => toggle_out(i),

                    replace_in    => replace_in(i),
                    replace_out_a => replace_out_s(i * 2),
                    replace_out_b => replace_out_s((i * 2) + 1)
                );

            branch : entity work.plru_branch
                generic map (h => h - 1)
                port map (
                    clk => clk,

                    toggle_out  => toggle_in_s(i * 2 to (i * 2) + 1),
                    toggle_in   => toggle_in
                        ( i * (2 ** (h - 1)) to (i + 1) * (2 ** (h - 1)) - 1),

                    replace_in  => replace_out_s(i * 2 to (i * 2) + 1),
                    replace_out => replace_out
                        ( i * (2 ** (h - 1)) to (i + 1) * (2 ** (h - 1)) - 1)
                );
        end generate inner_structure;
    end generate outer_structure;
end plru_branch_arch;






library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity plru_root is
    port (
        clk : in std_logic;
        toggle_in_a   :  in std_logic;
        toggle_in_b   :  in std_logic;
        replace_out_a : out std_logic;
        replace_out_b : out std_logic
    );
end plru_root;

architecture plru_root_arch of plru_root is
    signal toggle_s : std_logic;
    signal state_s  : std_logic;

begin
    state : entity work.t_flip_flop
        generic map (initial => '0')
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
        replace_out : out std_logic_vector(0 to (2 ** h) - 1)
    );
end plru_tree;

architecture plru_tree_arch of plru_tree is
    signal root_toggle_s   : std_logic_vector(0 to 1);
    signal root_replace_s  : std_logic_vector(0 to 1);
    
begin
        root : entity work.plru_root
            port map (
                clk => clk,

                toggle_in_a => root_toggle_s(0),
                toggle_in_b => root_toggle_s(1),

                replace_out_a => root_replace_s(0),
                replace_out_b => root_replace_s(1)
            );

        branches : entity work.plru_branch
            generic map (h => h)
            port map (
                clk => clk,

                toggle_out  => root_toggle_s,
                toggle_in   => toggle_in,

                replace_in  => root_replace_s,
                replace_out => replace_out
            );
end plru_tree_arch;