library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cache_block_tb is
end cache_block_tb;

architecture tb of cache_block_tb is
    constant period : time := 20 ns;

    component cache_block
        port (
            clk             : in  std_logic;
            set_is_selected : in  std_logic;
            replace_en      : in  std_logic;
            reset           : in  std_logic
            hit             : out std_logic;
            valid           : out std_logic;
            tag             : in  std_logic_vector(7 downto 0);
        );
    end component;

    signal  clk             : std_logic;
    signal  set_is_selected : std_logic;
    signal  replace_en      : std_logic;
    signal  hit             : std_logic;
    signal  valid           : std_logic;
    signal  reset           : std_logic;
    signal  tag             : std_logic_vector(7 downto 0);

begin
    UUT: cache_block port map(
        clk, 
        set_is_selected, 
        replace_en, 
        tag, 
        hit, 
        valid, 
        reset
    );

    process
    begin
        -- reset valid bit as would be done on boot up
        reset <= '1';
        wait for period;
        assert(valid = '0')
        report "Failed at initial reset." severity error;


        -- load tag "00001111" into register
        reset <= '0';
        tag <= "00001111";
        replace_en <= '1';
        -- clock pulse
        clk <= '0';
        wait for period/2;
        clk <= '1';
        wait for period/2;
        clk <= '0';

        -- assert that valid bit is set when new tag is loaded
        assert(valid = '1')
        report "Failed to set valid bit." severity error;

        -- assert that hit is not reported if set is not selected
        set_is_selected <= '0';
        wait for period;
        assert(hit = '0')
        report "Failed to miss with set not selected." severity error;

        -- assert that hit is reported when all conditions are met
        set_is_selected <= '1';
        wait for period;
        assert(hit = '1')
        report "Failed to register hit." severity error;

        -- assert that hit is not reported for incorrect tag
        tag <= "11110000";
        wait for period;
        assert(hit = '0')
        report "Failed to miss with incorrect tag." severity error;

        -- assert that valid bit resets correctly
        reset <= '1';
        tag <= "00001111";
        wait for period;
        assert(valid = '0')
        report "Failed to reset valid bit." severity error;

        -- assert that hit is not reported with invalid data
        assert(hit = '0')
        report "Failed to miss with valid bit off." severity error;
    end process;
end tb;