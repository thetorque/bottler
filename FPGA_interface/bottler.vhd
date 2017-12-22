-- Implements a simple Nios II system for the DE-series board.
-- Inputs: SW7-0 are parallel port inputs to the Nios II system
-- CLOCK_50 is the system clock
-- KEY0 is the active-low system reset
-- Outputs: LEDR7-0 are parallel port outputs from the Nios II system
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
USE work.seven_segment_pkg.all;
USE work.all;

ENTITY bottler IS
PORT (
CLOCK_50 : IN STD_LOGIC;
KEY : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
SW : IN STD_LOGIC_VECTOR (9 DOWNTO 0);
LEDR : OUT STD_LOGIC_VECTOR (9 DOWNTO 0);
HEX0 : OUT STD_LOGIC_VECTOR (6 downto 0);
HEX1 : OUT STD_LOGIC_VECTOR (6 downto 0);
HEX2 : OUT STD_LOGIC_VECTOR (6 downto 0);
HEX3 : OUT STD_LOGIC_VECTOR (6 downto 0);
HEX4 : OUT STD_LOGIC_VECTOR (6 downto 0);
HEX5 : OUT STD_LOGIC_VECTOR (6 downto 0)
);
END bottler;


	 
ARCHITECTURE main OF bottler IS

component clk_pll is
	port (
		refclk   : in  std_logic := '0'; --  refclk.clk
		rst      : in  std_logic := '0'; --   reset.reset
		outclk_0 : out std_logic;        -- outclk0.clk
		outclk_1 : out std_logic         -- outclk1.clk
	);
end component;
	
	signal HEX_vector : std_logic_vector( 41 downto 0);
	signal HEX_integer: integer range 0 to 999999;
	signal counter_reset: std_logic := '0';
	signal clk_5: std_logic;
	signal clk_1: std_logic;

BEGIN
	LEDR <= SW;
	HEX_vector <= unsigned_to_seven_segment(value => to_unsigned(HEX_integer,17), number_of_digits => 6, value_is_bcd => false);
	HEX0 <= NOT HEX_vector (6 downto 0);
	HEX1 <= NOT HEX_vector (13 downto 7);
	HEX2 <= NOT HEX_vector (20 downto 14);
	HEX3 <= NOT HEX_vector (27 downto 21);
	HEX4 <= NOT HEX_vector (34 downto 28);
	HEX5 <= NOT HEX_vector (41 downto 35);
	counter_reset <= NOT KEY(0);
	pll: clk_pll port map (	refclk => CLOCK_50, rst => '0', outclk_0 => clk_5, outclk_1 => clk_1);
	
	process (clk_1)
		variable counter: integer range 0 to 1000000:=0;
		variable counter_slow: integer range 0 to 999999:=0;
	begin
		if (counter_reset = '1') then
			counter:=0;
			counter_slow := 0;
		elsif rising_edge(clk_1) then
			counter := counter + 1;
			if (counter = 1000000) then
				counter := 0;
				counter_slow := counter_slow + 1;
			end if;
		end if;
		HEX_integer <= counter_slow;
	end process;

--PORT MAP(
--clk_clk => CLOCK_50,
--reset_reset_n => KEY(0),
--switches_export => SW(7 DOWNTO 0),
--leds_export => LEDR(7 DOWNTO 0)
--);
END main;
