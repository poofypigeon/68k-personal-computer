library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

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

------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity t_flip_flop is
    generic (
        initial : std_logic;
    );

    port (
        clk :  in std_logic;
        t   :  in std_logic;
        q   : out std_logic
    );
end t_flip_flop;

architecture t_flip_flop_arch of t_flip_flop is
    signal q_s : std_logic := initial;
begin
    toggle : process(clk)
    begin
        q_s <= not temp when rising_edge(clk) and t;
    end process toggle;
    q <= q_s;
end t_flip_flop_arch;

------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity register is
    generic (
        bit_count : positive;
    );

    port (
        clk : in  std_logic; -- clock
        en  : in  std_logic; -- data input enable
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
            en => en,
            d => d(i),
            q => q(i)
        );
    end generate build_array;
end register_8bit_arch;

