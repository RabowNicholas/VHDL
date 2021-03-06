----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/02/2020 02:13:23 PM
-- Design Name: 
-- Module Name: controller - Behavioral
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

entity controller is
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
end controller;

architecture Behavioral of controller is
signal command: std_logic_vector(7 downto 0);
signal config: std_logic_vector(4 downto 0) := "00000"; --[0] = signal generation, [1] = record, [2-3] = switches/memory, [4] = LEDs
signal db1, db2: std_logic_vector(7 downto 0); --data transmission buffers
signal one_second_counter : integer;
signal trans_counter : integer;
signal firstbitflag : std_logic;
signal record_en : std_logic;

constant second_counter_reload : integer := 100000000; --1 second / 100 MHz
constant trans_counter_reload : integer := 17361;       -- time to transmit 2 data packets 100MHz/(baud rate/sizze of data packet)
constant trans_counter_onedatapack : integer := trans_counter_reload/2;
begin
command <= uart_com;
db1 <= "11" & i2c_data(11 downto 6) when firstbitflag = '1' else "01" & i2c_data(11 downto 6);
db2 <= "11" & i2c_data(5 downto 0) when firstbitflag = '1' else "01" & i2c_data(5 downto 0);
sel <= config(2 downto 1);
process(clk, reset)
begin
    if reset = '1' then
        config <= "00000";
        one_second_counter <= second_counter_reload;
    elsif rising_edge(clk) then
        if command = x"67" then      --signal generation (g)
            config(4) <= not config(4);
        elsif command = x"72" then   --record (r)
            config(3) <= not config(3);
        elsif command = x"73" then   --switch (s)
            config(2 downto 1) <= "00";
        elsif command = x"31" then   --signal from mem 1 (1)
            config(2 downto 1) <= "01";
        elsif command = x"32" then   --signal from mem 2 (2)
            config(2 downto 1) <= "10";
        elsif command = x"6C" then   --leds (l)
            config(0) <= not config(0);
        end if;
--        --SIGNAL GENERATION COMMAND
--        if config(4) = '1' then
--            i2c_en <= '1';
--            spi_en <= '1';
--        else
--            i2c_en <= '0';
--            spi_en <= '0';
--        end if;
        --RECORD COMMAND
        if record_en = '1' then
            if one_second_counter = 0 then
                    one_second_counter <= second_counter_reload;
                else
                    one_second_counter <= one_second_counter - 1;
                    if i2c_data(11 downto 6) = "111111" then firstbitflag <= '1'; else firstbitflag <= '0'; end if;
                    if i2c_data(5 downto 0) = "111111" then firstbitflag <= '1'; else firstbitflag <= '0'; end if;
                    if trans_counter = trans_counter_reload then
                        trans_data <= db1;
                        trans_load <= '1';
                    elsif trans_counter = trans_counter_onedatapack then
                        trans_data <= db2;
                        trans_load <= '1';
                    elsif trans_counter = 0 then
                        trans_counter <= trans_counter_reload;
                        trans_load <= '0';
                    else
                        trans_counter <= trans_counter - 1;
                        trans_load <= '0';
                    end if;
                    config(3) <= '0';
                end if;
        end if;
--        if config(0) = '1' then
--            led_en <= '1';
--        else led_en <= '0';
--        end if;
        case config is
            when "00000" => --stop everything
                spi_en <= '0';
                i2c_en <= '0';
                led_en <= '0';
                one_second_counter <= second_counter_reload;
            --SIGNAL FROM SWITCHES
            when "10000" => --signal generation on from switches without record or leds
                spi_en <= '1';
                i2c_en <= '1';
                led_en <= '0';
                record_en <= '0';
            when "10001" => --signal gen. on from switches with led only
                spi_en <= '1';
                i2c_en <= '1';
                led_en <= '1';
                record_en <= '0';
            when "11000" => --signal generation on from switches with record only
                spi_en <= '1';
                i2c_en <= '1';
                led_en <= '0';
                record_en <= '1';
            when "11001" => --signal generation on from switches with record & leds
                spi_en <= '1';
                i2c_en <= '1';
                led_en <= '1';
                record_en <= '1';
                
            --SIGNAL FROM MEM 1 (SINE WAVE)
            when "10010" => --signal gen. on from mem 1 wihtout record or leds
                spi_en <= '1';
                i2c_en <= '1';
                led_en <= '0';
                record_en <= '0';
            when "10011" => --signal gen. on from mem 1 with led only
                 spi_en <= '1';
                i2c_en <= '1';
                led_en <= '1';
                record_en <= '0';
            when "11010" => --signal gen. on from mem 1 with record only
                spi_en <= '1';
                i2c_en <= '1';
                led_en <= '0';
                record_en <= '1';
            when "11011" => --signal gen. on  from mem 1 with record& leds
                spi_en <= '1';
                i2c_en <= '1';
                led_en <= '1';
                record_en <= '1';
                
            --SIGNAL FROM MEM 2 (SQUARE WAVE)    
            when "10100" => --signal gen. on from mem 2 wihtout record or leds
                spi_en <= '1';
                i2c_en <= '1';
                led_en <= '0';
                record_en <= '0';
            when "10101" => --signal gen on from mem 2 with led only
                spi_en <= '1';
                i2c_en <= '1';
                led_en <= '1';
                record_en <= '0';
            when "11100" => --signal gen. of from mem 2 with record only
                spi_en <= '1';
                i2c_en <= '1';
                led_en <= '0';
                record_en <= '1';
            when "11101" => --signal gen. on  from mem 2 with record& leds
                spi_en <= '1';
                i2c_en <= '1';
                led_en <= '1';
                record_en <= '1';
            when others =>  --catch all
                config <= "00000";
            
            
        end case;
    end if;
end process;
end Behavioral;
