--------------------------------------------------------------------------------
--  D-FLIP-FLOP
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--------------------------------------------------------------------------------
--  single bit D-type flip-flop
--------------------------------------------------------------------------------
entity d_flip_flop is
    port (
        clk : in  std_logic; -- clock
        en  : in  std_logic; -- input enable
        d   : in  std_logic; -- data in
        q   : out std_logic  -- data out
    );
end d_flip_flop;

architecture d_flip_flop_arch of d_flip_flop is
begin
    load : process(clk)
    begin
        q <= d when rising_edge(clk) and en;
    end process load;
end d_flip_flop_arch;


--------------------------------------------------------------------------------
--  T-FLIP-FLOP
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--------------------------------------------------------------------------------
--  single T-flip-flop latch
--------------------------------------------------------------------------------
entity t_flip_flop is
    generic (
        initial : std_logic; -- initial state
    );

    port (
        clk :  in std_logic; -- clock
        t   :  in std_logic; -- toggle enable
        q   : out std_logic  -- output
    );
end t_flip_flop;

architecture t_flip_flop_arch of t_flip_flop is
    signal q_s : std_logic := initial; -- internal output signal ref
begin
    toggle : process(clk)
    begin
        q_s <= not q_s when rising_edge(clk) and t;
    end process toggle;
    q <= q_s;
end t_flip_flop_arch;


--------------------------------------------------------------------------------
-- REGISTER
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--------------------------------------------------------------------------------
-- variably sized register comprised of an array of D-flip-flops
--------------------------------------------------------------------------------
entity register is
    generic (
        bit_count : positive;
    );

    port (
        clk : in  std_logic; -- clock
        en  : in  std_logic; -- input enable
        d   : in  std_logic_vector(bits downto 0); -- data in
        q   : out std_logic_vector(bits downto 0)  -- data out
    );
end register;

architecture register_arch of register is
    component d_flip_flop
        port (
            clk : in  std_logic; -- clock
            en  : in  std_logic; -- input enable
            d   : in  std_logic; -- data in
            q   : out std_logic  -- data out
        );
    end component;
begin
    build_array : for i in 0 to bit_count - 1 generate
        register_bit : d_flip_flop port map (
            clk => clk,
            en  => en,
            d   => d(i), -- map flip-flop input to corresponding register input
            q   => q(i)  -- map flip-flop output to corresponding register output
        );
    end generate build_array;
end register_arch;