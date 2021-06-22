--< PLRU_ROOT >--------------------------------------------------------------------------------
library ieee;
use ieee.std_ulogic_1164.all;
use ieee.numeric_std.all;
--+--------------------------------------------------------------------------------------------
--| Root node which sits at the root of the Pseudo Least Recently Used binary tree structure. 
--| ---
--| This node is not included in the recursion, but terminates the tree and acts as the source 
--| of the replace signal which traverses down the tree towards a leaf according to the 
--| internal state of each node within the tree.
--+--------------------------------------------------------------------------------------------
entity plru_root is
    port (
        clk : in std_ulogic;
        
        replace_out_left  : out std_ulogic;
        replace_out_right : out std_ulogic
    );
end plru_root;

architecture plru_root_arch of plru_root is
    signal state_s : std_ulogic;

begin
    state : entity work.t_flip_flop
        generic map ( initial => '0' )
        port map (
            clk => clk,
            -- Since the toggle is enabled by toggle_in_left or toggle_in_right, we can save some 
            -- gates by holding '1' on the toggle enable for root, becuase one of the toggle
            -- inputs will always be high.
            t => '1',
            q => state_s
        );

    replace_out_left  <= not state_s;
    replace_out_right <= state_s;

end plru_root_arch;


--< PLRU_NODE >--------------------------------------------------------------------------------
library ieee;
use ieee.std_ulogic_1164.all;
use ieee.numeric_std.all;
--+--------------------------------------------------------------------------------------------
--| Node which is structurally connected to each recursive iteration of the Pseudo Least
--| Recently Used binary tree. 
--| ---
--| This node is comprised of a T-flip-flop which selects the route of the replace signal
--| sourced from the root node of the tree. The toggle enable of this node is controlled by
--| the toggle signal which travels up the tree from one of its leaves--corresponding to the
--| cache block which was most recently accessed--to the root of the tree. The toggle signal
--| is passed to this node by either of this node's children, and is in turn forwarded onto
--| its parent node.
--+--------------------------------------------------------------------------------------------
entity plru_node is
    port (
        clk : in std_ulogic;

        toggle_in_left  : in  std_ulogic;
        toggle_in_right : in  std_ulogic;
        toggle_out      : out std_ulogic;

        replace_in        : in  std_ulogic;
        replace_out_left  : out std_ulogic;
        replace_out_right : out std_ulogic
    );
end plru_node;

architecture plru_node_arch of plru_node is
    signal toggle_s : std_ulogic;
    signal state_s  : std_ulogic;

begin
    state : entity work.t_flip_flop
        generic map ( initial => '0' )
        port map (
            clk => clk,

            t => toggle_s,
            q => state_s
        );

    toggle_s <= toggle_in_left or toggle_in_right;

    toggle_out <= toggle_s;

    replace_out_left  <= replace_in and not state_s;
    replace_out_right <= replace_in and state_s;

end plru_node_arch;


--< PLRU_RECURSIVE >---------------------------------------------------------------------------
library ieee;
use ieee.std_ulogic_1164.all;
use ieee.numeric_std.all;
--+--------------------------------------------------------------------------------------------
--| A recursive structure for dynamically generating a Pseudo Least Recently Used replacement
--| policy.
--| ---
--| A dynamically generated Pseudo Least Recently Used tree must create interfaces for each
--| iteration that carry the scope required to:
--| [1] Recieve signals from their parent node and pass their signals:
--|     > Each plru_recursive iteration holds two instances of plru_node which are fully mapped
--|     > to ports that were passed in its enclosing plru_recursive iteration, and to signals
--|     > which will be passed to the two new plru_recursive iterations that will be generated
--|     > from the current iteration. Because the two child nodes are generated in a loop, the
--|     > signals for these mappings must be able to be associated with an iterator. For this,
--|     > we create the .*_s signals of std_ulogic_vector(0 to 3) in which range(0 to 1)--
--|     > representing .*_left and .*_right of the (child = 0) node--are passed to the ports
--|     > of the plru_recursive generation of the first child, and range(2 to 3) are passed 
--|     > for the plru_recursive generation of the second child.
--| [2] Map the outputs of only the leaves of the tree to the outputs of the greater structure:
--|     > Each iteration of plru_recursive passes the first half of the replace_out vector
--|     > it recieved to its first child, and the second half to its second child. Nothing
--|     > is mapped to the replace_out vector until the terminating iteration, upon which,
--|     > each node will have two bits of the original replace_out vector. The final iteration
--|     > of plru_recursive maps its portion of replace_out to the replace_in from its parent.
--+--------------------------------------------------------------------------------------------
entity plru_recursive is
    generic ( height : positive );
    port (
        clk : in  std_ulogic;
        
        toggle_in   : in  std_ulogic_vector(0 to (2 ** height) - 1);
        toggle_out  : out std_ulogic_vector(0 to 1);
        
        replace_in  : in  std_ulogic_vector(0 to 1);
        replace_out : out std_ulogic_vector(0 to (2 ** height) - 1)
    );
end plru_recursive;

architecture plru_recursive_arch of plru_recursive is
    -- These signals are the interface between a parent node's iteration and its children being
    -- generated within its iteration.
    --
    -- signals .*_s(0) and .*_s(1) are for .*_left and .*_right, respectively, of the (child = 0)
    -- node, and the same is true of .*_s(2) and .*_s(3) for the (child = 1) node.
    signal toggle_in_s   : std_ulogic_vector(0 to 3);
    signal replace_out_s : std_ulogic_vector(0 to 3);

begin
    gen_main : 
    -- terminate recursion on last iteration (height = 1) by binding in/out to final ports
    if height = 1 generate
        replace_out <= replace_in;
        toggle_out  <= toggle_in;
    -- continue recursion
    elsif height > 1 generate
       gen_recursive : for child in 0 to 1 generate
            -- component being recursively generated
            node_instance : entity work.plru_node
                port map (
                    clk => clk,

                    toggle_in_left  => toggle_in_s(child * 2),
                    toggle_in_right => toggle_in_s((child * 2) + 1),
                    toggle_out      => toggle_out(child),

                    replace_in        => replace_in (child),
                    replace_out_left  => replace_out_s(child * 2),
                    replace_out_right => replace_out_s((child * 2) + 1)
                );

            -- wrapper to allow for recursive generation
            recursive_instance : entity work.plru_recursive
                -- recursive call to generate self with height decremented
                generic map ( height => height - 1 )
                port map (
                    clk => clk,

                    toggle_out => toggle_in_s(child * 2 to (child * 2) + 1),
                    toggle_in  => toggle_in
                        (child * (2 ** (height - 1)) to (child + 1) * (2 ** (height - 1)) - 1),

                    replace_in  => replace_out_s(child * 2 to (child * 2) + 1),
                    replace_out => replace_out
                        (child * (2 ** (height - 1)) to (child + 1) * (2 ** (height - 1)) - 1)
                );
        end generate gen_recursive;
    end generate gen_main;

end plru_recursive_arch;


--< PLRU_POLICY >------------------------------------------------------------------------------
library ieee;
use ieee.std_ulogic_1164.all;
use ieee.numeric_std.all;
--+--------------------------------------------------------------------------------------------
--| Assembles the discrete elements which comprise the Pseudo Least Recently Used policy into
--| a usable component.
--+--------------------------------------------------------------------------------------------
entity plru_policy is
    generic ( height : positive );
    port (
        clk : in std_ulogic;
        
        toggle_in   : in  std_ulogic_vector(0 to (2 ** height) - 1);
        replace_out : out std_ulogic_vector(0 to (2 ** height) - 1)
    );
end plru_policy;

architecture plru_policy_arch of plru_policy is
    signal root_replace_s : std_ulogic_vector(0 to 1);
    
begin
    root : entity work.plru_root
        port map (
            clk => clk,

            replace_out_left  => root_replace_s(0),
            replace_out_right => root_replace_s(1)
        );

    branches : entity work.plru_recursive
        generic map ( height => height )
        port map (
            clk => clk,

            toggle_out => open, -- *see plru_root t_flip_flop port mapping
            toggle_in  => toggle_in,

            replace_in  => root_replace_s,
            replace_out => replace_out
        );

end plru_policy_arch;