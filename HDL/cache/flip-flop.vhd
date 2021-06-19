--< D_FLIP_FLOP >-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--+---------------------------------------------------------------------------------------------
--|
--+---------------------------------------------------------------------------------------------
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
        if rising_edge(clk) and en = '1' then
            q <= d;
        end if;
    end process load;
end d_flip_flop_arch;


--< T_FLIP_FLOP >-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--+---------------------------------------------------------------------------------------------
--|
--+---------------------------------------------------------------------------------------------
entity t_flip_flop is
    generic (
        initial : std_logic := '0' -- initial state
    );

    port (
        clk : in  std_logic; -- clock
        t   : in  std_logic; -- toggle enable
        q   : out std_logic  -- output
    );
end t_flip_flop;

architecture t_flip_flop_arch of t_flip_flop is
    signal q_s : std_logic := initial; -- internal output signal ref
    
begin
    toggle : process(clk)
    begin
        if rising_edge(clk) and t = '1' then
            q_s <= not q_s;
        end if;
    end process toggle;
    q <= q_s;
end t_flip_flop_arch;


--< D_TYPE_REGISTER >---------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--+---------------------------------------------------------------------------------------------
--|
--+---------------------------------------------------------------------------------------------
entity d_type_register is
    generic (
        bit_count : positive
    );

    port (
        clk : in  std_logic; -- clock
        en  : in  std_logic; -- input enable
        d   : in  std_logic_vector(bit_count downto 0); -- data in
        q   : out std_logic_vector(bit_count downto 0)  -- data out
    );
end d_type_register;

architecture d_type_register_arch of d_type_register is
begin
    build_array : for i in 0 to bit_count - 1 generate
        array_bit : entity work.d_flip_flop port map (
            clk => clk,
            en  => en,
            d   => d(i), -- map flip-flop input to corresponding register input
            q   => q(i)  -- map flip-flop output to corresponding register output
        );
    end generate build_array;
end d_type_register_arch;