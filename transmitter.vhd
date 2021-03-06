----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/16/2020 02:23:15 PM
-- Design Name: 
-- Module Name: transmitter - Behavioral
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

entity transmitter is
	port ( clk : in std_logic;	-- clock input
		reset : in std_logic;	-- reset, active high
		pdata : in std_logic_vector(7 downto 0); -- parallel data in
		load : in std_logic;	-- load signal, active high
		sdata : out std_logic);	-- serial data out
end transmitter;

architecture Behavioral of transmitter is

constant baud_rate : integer := 868; --(Master Clock / baud rate)

type state_type is (IDLE_tx, START_tx, DATA_tx, STOP_tx);
signal state_tx : state_type;
signal bit_count : integer := 0;
signal count_down : integer;

begin
process(clk, reset)
begin 
    if reset = '1' then
        sdata <= '1';
        count_down <= baud_rate;
        bit_count <= 0;
        state_tx <= IDLE_tx;
    elsif rising_edge(clk) then
        case state_tx is
        when IDLE_tx =>
            sdata <= '1';
            if load = '1' then
                state_tx <= START_tx;
                count_down <= baud_rate;
            else state_tx <= IDLE_tx;
            end if;
        when START_tx =>
            if count_down = 0 then
                state_tx <= DATA_tx;
                count_down <= baud_rate;
                sdata <= '0'; --send start bit
                bit_count <= 0;
            else count_down <= count_down - 1;
            end if;
        when DATA_tx =>
            if count_down = 0 then
                if bit_count < 8 then
                    state_tx <= DATA_tx;
                    sdata <= pdata(bit_count);
                    bit_count <= bit_count + 1;
                else
                    state_tx <= STOP_tx;
                    bit_count <= 0;
                    sdata <= '1'; --send stop bit
                end if;                    
                count_down <= baud_rate;
            else
                count_down <= count_down - 1;
            end if;
        when STOP_tx =>
        if count_down = 0 then
            state_tx <= IDLE_tx;
            count_down <= baud_rate;
        else count_down <= count_down - 1;
        end if;
        end case;
     end if;
end process;
end Behavioral;
