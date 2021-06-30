--< CACHE_SET_TB >-----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-----------------------------------------------------------------------------------------------
entity cache_set_tb is

end cache_set_tb;

architecture cache_set_tb_arch of cache_set_tb is
    constant period : time := 20 ns;

    constant tag_bit_width      : positive := 8;
    constant block_id_bit_width : positive := 4;

    signal clk : std_ulogic := '0';

    signal set_is_selected : std_ulogic;
    signal reset_valid     : std_ulogic;
    signal query_hit       : std_ulogic;
    signal tag_query       : unsigned(tag_bit_width - 1 downto 0);
    signal hit_block_id    : unsigned(block_id_bit_width - 1 downto 0);

    shared variable clk_enable : integer := 1;

begin
    UUT : entity work.cache_set
        generic map (
            tag_bit_width      => tag_bit_width,
            block_id_bit_width => block_id_bit_width
        )
        port map (
            clk => clk,

            set_is_selected => set_is_selected,
            reset_valid     => reset_valid,
            query_hit       => query_hit,
            tag_query       => tag_query,
            hit_block_id    => hit_block_id
        );

    clk <= not clk after period / 2 when clk_enable = 1;

    process
        use std.textio.all;

        type stimulus is record 
            set_is_selected : bit;
            tag_query       : integer;
            query_hit       : bit;
            hit_block_id    : integer;
        end record stimulus;

        variable instance : line;

        file stimulus_file : text 
            open read_mode is "test/stimulus/set.stim";

        variable i : integer := 1;
        variable temp_stimulus : stimulus;
    begin
        while not endfile(stimulus_file) loop
            readline(stimulus_file, instance);
            read(instance, temp_stimulus.set_is_selected);
            read(instance, temp_stimulus.tag_query);
            read(instance, temp_stimulus.query_hit);
            read(instance, temp_stimulus.hit_block_id);

            case temp_stimulus.set_is_selected is
                when '1'    => set_is_selected <= '1';
                when others => set_is_selected <= '0';
            end case;

            tag_query <= to_unsigned(temp_stimulus.tag_query, tag_bit_width);

            wait for period / 4;

            assert to_bit(query_hit) = temp_stimulus.query_hit
            report "FAILED: at stim " & integer'image(i) & " with query_hit = " 
                & std_ulogic'image(query_hit)
            severity error;

            -- hit_block_id is practically speaking undefined when query_hit = 0, and will
            -- behave as a high-impedance port to the cache. Although this value should
            -- not be treated as valid data in this state, it value defaults to become the
            -- encoded value of the block_to_replace signal.
            if query_hit = '1' then
                assert to_integer(hit_block_id) = temp_stimulus.hit_block_id
                report "FAILED: at stim " & integer'image(i) & " with hit_block_id = " 
                    & integer'image(to_integer(hit_block_id))
                severity error;
            end if;

            -- -- verbose report
            -- report integer'image(i)                     & "; " 
            -- & std_ulogic'image(set_is_selected)         & "; " 
            -- & integer'image(to_integer(tag_query))      & "; " 
            -- & std_ulogic'image(query_hit)               & "; " 
            -- & integer'image(to_integer(hit_block_id));
        
            wait until falling_edge(clk);

            i := i + 1;
        end loop;

        -- finish test
        clk_enable := 0;
        wait;
    end process;

end cache_set_tb_arch;