----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/02/2020 01:33:27 PM
-- Design Name: 
-- Module Name: receiver - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity receiver is
    port (clk : in std_logic;
        reset : in std_logic;
        sdata : in std_logic;
        pdata : out std_logic_vector(7 downto 0);
        ready : out std_logic);
end receiver;

architecture Behavioral of receiver is

constant baud_rate : integer := 868;    --(master clock / baud rate)
constant baud_rate_half : integer := 434;

type state_type is (IDLE_rx, START_rx, DATA_rx, STOP_rx);
signal state_rx : state_type;
signal bit_count : integer := 0;
signal count_down : integer;
signal data : std_logic_vector(7 downto 0);
begin
   
    process(clk,reset)
    begin
        if(reset = '1') then
            state_rx <= IDLE_rx;
            ready <= '0';
            bit_count <= 0;
            count_down <= baud_rate;
        elsif rising_edge(clk) then
            case state_rx is
            
            when IDLE_rx =>
                ready <= '0';
                pdata <= x"00";
                if sdata = '0' then
                    state_rx <= START_rx;
                    count_down <= baud_rate_half;
                else
                    state_rx <= IDLE_rx;
                end if;
            when START_rx =>
                if count_down = 0 then
                    bit_count <= 0;
                    state_rx <= DATA_rx;
                    count_down <= baud_rate;
                else
                    count_down <= count_down - 1;
                end if;
            when DATA_rx =>
                if count_down = 0 then
                    if bit_count < 8 then
                        bit_count <= bit_count + 1;
                        data(bit_count) <= sdata;
                        state_rx <= DATA_rx;
                        count_down <= baud_rate;
                    else
                        count_down <= baud_rate;
                        bit_count <= 0;
                        state_rx <= STOP_rx;
                        ready <= '1';
                end if;
                else
                    count_down <= count_down - 1;
                end if;
            when STOP_rx =>
                if count_down = 0 then
                        count_down <= 0;
                        bit_count <= 0;
                        state_rx <= IDLE_rx;
                        ready <= '0';
                        pdata <= data;
                else
                    count_down <= count_down - 1;
                end if;
            end case;
        end if;
    end process;
end Behavioral;
