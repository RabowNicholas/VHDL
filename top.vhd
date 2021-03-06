----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/02/2020 12:42:37 PM
-- Design Name: 
-- Module Name: top - Behavioral
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

entity top is
    Port (clk, reset : in std_logic;
          SWITCH : in std_logic_vector(5 downto 0);         --input 1 for spi->dac
          uart_in : in std_logic;                           --communication with PC
          uart_out: out std_logic;                          --communication with PC
          LED : out std_logic_vector(5 downto 0);           --display data from receive through i2c
          spi_clk, spi_sda1, spi_sda2, CS: out std_logic;   --DAC communication
          i2c_clk: out std_logic;                           --ADC communication
          i2c_sda: inout std_logic
          );
end top;

architecture Behavioral of top is

component uart is
    Port ( clk : in STD_LOGIC;                      -- 100Mhz clock on Basys 3 FPGA board
           reset : in STD_LOGIC;                    -- reset
           data_in : in std_logic;
           load : in std_logic;
           serial_out : out std_logic;
           pdata_out : out std_logic_vector(7 downto 0);
           pdata_in : in std_logic_vector(7 downto 0));
end component;
component spi_master_top is
     port( clk : in std_logic;
          reset : in std_logic;
          en : in std_logic;
          switches : in std_logic_vector(5 downto 0);
          sel : in std_logic_vector(1 downto 0);
          busy : out std_logic;
          CS : out std_logic;
          Data1 : out std_logic;
          Data2 : out std_logic;
          spi_clk : out std_logic);
 end component;
component i2c_top is
    Port ( clk : in std_logic;
           reset : in std_logic;
           LED : out std_logic_vector (5 downto 0);
           sclk : out std_logic;
           sdata : inout std_logic;
           busy : out std_logic;
           En : in std_logic;
           pdata_out : out std_logic_vector(11 downto 0) );
end component;
component controller is
  Port (clk, reset: in std_logic;
        sel : out std_logic_vector(1 downto 0);              --select line for memory/switches
        uart_com : in std_logic_vector(7 downto 0);          --communication with uart
        i2c_busy : in std_logic;
        spi_busy : in std_logic;
        i2c_en : out std_logic;
        spi_en : out std_logic;
        led_en : out std_logic;
        i2c_data : in std_logic_vector(11 downto 0);
        trans_load : out std_logic;
        trans_data : out std_logic_vector(7 downto 0)
        );
 end component;
 
 signal uart_par: std_logic_vector(7 downto 0);
 signal i2c_busy : std_logic;
 signal spi_busy : std_logic;
 signal i2c_en : std_logic;
 signal spi_en : std_logic;
 signal sel : std_logic_vector(1 downto 0);
 signal LED_buff : std_logic_vector(5 downto 0);
 signal led_en : std_logic;
 signal i2c_data : std_logic_vector(11 downto 0);
 signal trans_load : std_logic;
 signal trans_data : std_logic_vector(7 downto 0);

begin
pc_com: uart Port Map(clk=>clk, reset=>reset, data_in=>uart_in,load=>trans_load, serial_out=>uart_out, pdata_out=>uart_par, pdata_in=>trans_data);
spi_com: spi_master_top Port Map(clk=>clk, reset=>reset,en =>spi_en, switches=>SWITCH, sel=>sel,busy=>spi_busy, CS=>CS, Data1=>spi_sda1, Data2=>spi_sda2, spi_clk=>spi_clk);
i2c_com: i2c_top Port Map(clk=>clk, reset=>reset,LED=>LED_buff,sclk=>i2c_clk, sdata=>i2c_sda, busy=>i2c_busy, en=>i2c_en, pdata_out=>i2c_data);
control: controller Port Map(clk=>clk,reset=>reset, sel=>sel, uart_com=>uart_par, i2c_busy=>i2c_busy, spi_busy=>spi_busy, i2c_en=>i2c_en, spi_en=>spi_en, led_en=>led_en,i2c_data=>i2c_data,trans_load=>trans_load,trans_data=>trans_data);

LED <= LED_buff when led_en = '1' else "000000";

end Behavioral;
