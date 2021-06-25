--< T_FLIP_FLOP_TB >----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- library user_library;
-- use user_library.one_hot.all;
--+---------------------------------------------------------------------------------------------
--|
--+---------------------------------------------------------------------------------------------
entity cache_block_tb is
    
end cache_block_tb;

architecture cache_block_tb_arch of cache_block_tb is
    constant period : time := 20 ns;

    signal  clk             : std_ulogic;

    signal  replace_en      : std_ulogic;
    signal  hit             : std_ulogic;
    signal  is_valid        : std_ulogic;
    signal  reset_valid     : std_ulogic;
    signal  tag_query       : unsigned(7 downto 0);

begin
    UUT: entity work.cache_block 
        generic map ( tag_bit_width => 8 )
        port map (
            clk             => clk, 
 
            replace_en      => replace_en, 
            tag_query       => tag_query, 
            hit             => hit, 
            is_valid        => is_valid, 
            reset_valid     => reset_valid
        );

    process
    begin
        -- load tag "00001111" into register
        reset_valid <= '0';
        tag_query   <= "00001111";
        replace_en  <= '1';
        -- clock pulse
        clk <= '0';
        wait for period/2;
        clk <= '1';
        wait for period/2;
        clk <= '0';

        -- assert that valid bit is set when new tag is loaded
        assert(is_valid = '1')
        report "Failed to set valid bit." severity error;

        -- assert that hit is not reported for incorrect tag
        tag_query <= "11110000";
        wait for period;
        assert(hit = '0')
        report "Failed to miss with incorrect tag." severity error;

        -- assert that valid bit resets correctly
        reset_valid <= '1';
        tag_query   <= "00001111";
        wait for period;
        assert(is_valid = '0')
        report "Failed to reset_validvalid bit." severity error;

        -- assert that hit is not reported with invalid data
        assert(hit = '0')
        report "Failed to miss with valid bit off." severity error;

        -- finish test
        wait;
    end process;
    
end cache_block_tb_arch;