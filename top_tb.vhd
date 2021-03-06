----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/07/2020 11:37:55 AM
-- Design Name: 
-- Module Name: top_tb - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity top_tb is
--  Port ( );
end top_tb;

architecture Behavioral of top_tb is

component top is
    Port (clk, reset : in std_logic;
          SWITCH : in std_logic_vector(5 downto 0);         --input 1 for spi->dac
          uart_in : in std_logic;                           --communication with PC
          uart_out: out std_logic;                          --communication with PC
          LED : out std_logic_vector(5 downto 0);           --display data from receive through i2c
          spi_clk, spi_sda1, spi_sda2, CS: out std_logic;   --DAC communication
          i2c_clk: out std_logic;                           --ADC communication
          i2c_sda: inout std_logic
          );
end component;

signal clk : std_logic := '0';
signal reset : std_logic;
signal SWITCH : std_logic_vector(5 downto 0);
signal uart_in : std_logic;
signal uart_out : std_logic;
signal LED : std_logic_vector(5 downto 0);
signal spi_clk : std_logic;
signal spi_sda1 : std_logic;
signal spi_sda2 : std_logic;
signal CS : std_logic;
signal i2c_clk : std_logic;
signal i2c_sda : std_logic;
signal tx1: std_logic_vector(7 downto 0) := x"67"; --generate
signal tx2: std_logic_vector(7 downto 0) := x"72"; --record
signal tx3: std_logic_vector(7 downto 0) := X"6C"; --leds
signal tx4: std_logic_vector(7 downto 0) := x"31"; --mem 1
signal tx5: std_logic_vector(7 downto 0) := x"32"; --mem 2


constant bit_period : time := 8.68 us; --1/baudrate
begin
uut: Top Port Map(
clk => clk,
reset => reset,
SWITCH => SWITCH,
uart_in => uart_in,
uart_out => uart_out,
LED => LED,
spi_clk => spi_clk,
spi_sda1 => spi_sda1,
spi_sda2 => spi_sda2,
CS => CS,
i2c_clk => i2c_clk,
i2c_sda => i2c_sda);


clk <= not clk after 5 ns;
--process
--begin
--reset <= '1';
--wait for 10 ns;
--reset <= '0';
--switch <= "010101";
--wait for 10 ns;

----TEST SIGNAL GENERATION COMMAND ON
--uart_in <= '0';   --start bit
--wait for bit_period;
--for i in 0 to 7 loop
--    uart_in <= tx1(i);
--    wait for bit_period;
--end loop;
--uart_in <= '1'; --stop bit
--wait for bit_period*2;

----TEST LED ON COMMAND
--uart_in <= '0';   --start bit
--wait for bit_period;
--for i in 0 to 7 loop
--    uart_in <= tx3(i);
--    wait for bit_period;
--end loop;
--uart_in <= '1'; --stop bit
--wait for 2*bit_period;

----TEST SELECT LINE MEM 1(SINE WAVE)
--uart_in <= '0';   --start bit
--wait for bit_period;
--for i in 0 to 7 loop
--    uart_in <= tx4(i);
--    wait for bit_period;
--end loop;
--uart_in <= '1'; --stop bit
--wait for bit_period*2;
----TEST SELECT LINE MEM 2 (SQUARE WAVE)
--uart_in <= '0';   --start bit
--wait for bit_period;
--for i in 0 to 7 loop
--    uart_in <= tx5(i);
--    wait for bit_period;
--end loop;
--uart_in <= '1'; --stop bit
--wait for bit_period*2;

----TEST LED OFF COMMAND
--uart_in <= '0';   --start bit
--wait for bit_period;
--for i in 0 to 7 loop
--    uart_in <= tx2(i);
--    wait for bit_period;
--end loop;
--uart_in <= '1'; --stop bit
--wait for bit_period*2;

----test stop signal generation
--uart_in <= '0';   --start bit
--wait for bit_period;
--for i in 0 to 7 loop
--    uart_in <= tx1(i);
--    wait for bit_period;
--end loop;
--uart_in <= '1'; --stop bit
--wait;
--end process;
end Behavioral;

