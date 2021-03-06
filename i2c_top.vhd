
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity I2C_Top is
    Port ( clk : in std_logic;
           reset : in std_logic;
           LED : out std_logic_vector (5 downto 0);
           sclk : out std_logic;
           sdata : inout std_logic;
           busy : out std_logic;
           En : in std_logic;
           pdata_out : out std_logic_vector(11 downto 0) );
end I2C_Top;

architecture Behavioral of I2C_Top is

component I2C_Master is
 Port ( clk : in std_logic;
        reset : in std_logic;
        load : in std_logic; 
        sclk : out std_logic;
        sdata : inout std_logic;
        busy : out std_logic;
        pdata : out std_logic_vector (15 downto 0); 
        status : out std_logic_vector(3 downto 0) );
       
end component;

signal load : std_logic;
signal pdata : std_logic_vector(15 downto 0);
signal status : std_logic_vector(3 downto 0);
constant update_timer : integer := 1000;
signal update_load : integer := 1000;


begin
uut : I2C_Master PORT MAP (
clk => clk,
reset => reset,
load => load,
sclk => sclk,
sdata => sdata,
busy => busy,
pdata => pdata,
status =>status);

pdata_out <= pdata(11 downto 0);
LED(5 downto 0) <= pdata(11 downto 6);

process(clk, reset)
begin
if En = '1' then
    if rising_edge(clk) then
        if reset = '1' then
           load <= '0';
           update_load <= 100000;
        elsif update_load = 0 then
           update_load <= 100000;
        elsif update_load < 5 then
           load <= '1';
           update_load <= update_load - 1;
        else
           update_load <= update_load - 1;
           load <= '0';
        end if;
    end if;
else
end if;
end process;

end Behavioral;