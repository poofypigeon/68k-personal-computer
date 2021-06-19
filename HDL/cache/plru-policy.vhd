--< PLRU_ROOT >----------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--+----------------------------------------------------------------------------
--| Root node which sits at the root of the Pseudo Least Recently Used
--| binary tree structure. 
--| ---
--| This node is not included in the recursion, but terminates the tree and
--| acts as the source of the replace signal which traverses down the tree
--| according to the internal state of each node within the tree.
--+----------------------------------------------------------------------------
entity plru_root is
    port (
        clk : in std_logic;

        replace_out_a : out std_logic; -- replace signal to left child node ('1' when q = '0')
        replace_out_b : out std_logic  -- replace signal to right child node ('1' when q = '1')
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
            t   => '1',
            q   => state_s
        );

    -- enable flip flop toggle when 
    toggle_s <= toggle_in_a or toggle_in_b;

    replace_out_a <= not state_s;
    replace_out_b <= state_s;
end plru_root_arch;


--< PLRU_NODE >----------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--+----------------------------------------------------------------------------
--| Node which is structurally connected to each recursive 
--| iteration of the Pseudo Least Recently Used binary tree. 
--| ---
--| This node is comprised of a
--| T-flip-flop which selects the route of the replace signal sourced from
--| the root node of the tree. The toggle enable of this node is controlled
--| by the toggle signal which travels up the tree from one of its leaves--
--| corresponding to the cache block which was most recently accessed--to the
--| root of the tree. The toggle signal is passed to this node by either of
--| this node's children, and is in turn forwarded onto its parent node.
--+----------------------------------------------------------------------------
entity plru_node is
    port (
        clk : in std_logic;

        toggle_in_a   : in  std_logic;
        toggle_in_b   : in  std_logic;
        toggle_out    : out std_logic;

        replace_in    : in  std_logic;
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


--< PLRU_RECURSIVE >-----------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--+----------------------------------------------------------------------------
--| A recursive tree structure for dynamically generating a Pseudo Least 
--| Recently Used replacement policy structure.
--| ---
--| 
--+----------------------------------------------------------------------------
entity plru_recursive is
    generic (height : natural);
    port (
        clk : in  std_logic;
        
        toggle_in   : in  std_logic_vector(0 to (2 ** h) - 1);
        toggle_out  : out std_logic_vector(0 to 1);
        
        replace_in  : in  std_logic_vector(0 to 1);
        replace_out : out std_logic_vector(0 to (2 ** h) - 1)
    );
end plru_recursive;

architecture plru_recursive_arch of plru_recursive is
    -- These signals are the interface between a parent node's iteration and
    -- its children being generated within its iteration.
    --
    -- signals .*_s(0) and .*_s(1) are for .*_a and .*_b, respectively, of the
    -- left child node, and the same is true of .*_s(2) and .*_s(3) for the
    -- right child node.
    signal toggle_in_s   : std_logic_vector(0 to 3);
    signal replace_out_s : std_logic_vector(0 to 3);

    -- Ugly math to pass half of the final in/out ports from a parent node to
    -- its respective child node.
    function half_of_vector (
        vector : std_logic_vector;
        half   : natural
        height : natural
    ) return std_logic_vector is
        return vector (
            half * (2 ** (height - 1)) to
            (half + 1) * (2 ** (height - 1)) - 1
        );
    end function half_of_vector;

begin
    outer_structure : 
    -- terminate recursion on last iteration by binding in/out to final ports
    if height = 1 generate
        replace_out(0 to 1) <= replace_in;
        toggle_out          <= toggle_in;
    -- continue recursion
    elsif height > 1 generate
       inner_structure : for i in 0 to 1 generate
            -- Functional component being recursively generated.
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

            -- Wrapper to allow for recursive generation
            branch : entity work.plru_recursive
                generic map (height => height - 1)
                port map (
                    clk => clk,

                    toggle_out  => toggle_in_s(i * 2 to (i * 2) + 1),
                    toggle_in   => half_of_vector(toggle_in, i, height),

                    replace_in  => replace_out_s(i * 2 to (i * 2) + 1),
                    replace_out => half_of_vector(replace_out, i, height)
                );
        end generate inner_structure;
    end generate outer_structure;
end plru_recursive_arch;


--< PLRU_POLICY >----------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--+----------------------------------------------------------------------------
--| 
--+----------------------------------------------------------------------------
entity plru_policy is
    generic (height : positive);
    port (
        clk : in std_logic;
        
        toggle_in   : in  std_logic_vector(0 to (2 ** height) - 1);
        replace_out : out std_logic_vector(0 to (2 ** height) - 1)
    );
end plru_policy;

architecture plru_policy_arch of plru_policy is
    signal root_toggle_s   : std_logic_vector(0 to 1);
    signal root_replace_s  : std_logic_vector(0 to 1);
    
begin
        root : entity work.plru_root
            port map (
                clk => clk,

                replace_out_a => root_replace_s(0),
                replace_out_b => root_replace_s(1)
            );

        branches : entity work.plru_recursive
            generic map (height => height)
            port map (
                clk => clk,

                toggle_out  => open,
                toggle_in   => toggle_in,

                replace_in  => root_replace_s,
                replace_out => replace_out
            );
end plru_policy_arch;