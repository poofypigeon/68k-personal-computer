--< D_FLIP_FLOP >-------------------------------------------------------------------------------
library ieee;
use ieee.std_ulogic_1164.all;
use ieee.numeric_std.all;
--+---------------------------------------------------------------------------------------------
--| Single bit D-flip-flop.
--+---------------------------------------------------------------------------------------------
entity d_flip_flop is
    port (
        clk : in  std_ulogic;

        en  : in  std_ulogic; -- input enable
        d   : in  std_ulogic; -- data in
        q   : out std_ulogic  -- data out
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
use ieee.std_ulogic_1164.all;
use ieee.numeric_std.all;
--+---------------------------------------------------------------------------------------------
--| Simple T-flip-flop
--+---------------------------------------------------------------------------------------------
entity t_flip_flop is
    generic ( initial : std_ulogic := '0' );
    port (
        clk : in  std_ulogic;

        t   : in  std_ulogic; -- toggle enable
        q   : out std_ulogic  -- output
    );
end t_flip_flop;

architecture t_flip_flop_arch of t_flip_flop is
    signal q_s : std_ulogic := initial;
    
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
use ieee.std_ulogic_1164.all;
use ieee.numeric_std.all;
--+---------------------------------------------------------------------------------------------
--| Variable size register comprised of an array of single bit D-flip-flops
--+---------------------------------------------------------------------------------------------
entity d_type_register is
    generic (
        bit_width : positive
    );

    port (
        clk : in  std_ulogic;

        en  : in  std_ulogic; -- input enable
        d   : in  std_ulogic_vector(bit_width downto 0); -- data in
        q   : out std_ulogic_vector(bit_width downto 0)  -- data out
    );
end d_type_register;

architecture d_type_register_arch of d_type_register is
begin
    gen_flip_flop : for i in 0 to d'length - 1 generate
        flip_flop_instance : entity work.d_flip_flop port map (
            clk => clk,

            en  => en,
            d   => d(i),
            q   => q(i)
        );
    end generate gen_flip_flop;

end d_type_register_arch;