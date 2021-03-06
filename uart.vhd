-- fpga4student.com: FPGA projects, Verilog projects, VHDL projects
-- VHDL code for seven-segment display on Basys 3 FPGA
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;
entity uart is
    Port ( clk : in STD_LOGIC;                      -- 100Mhz clock on Basys 3 FPGA board
           reset : in STD_LOGIC;                    -- reset
           data_in : in std_logic;
           load : in std_logic;
           serial_out : out std_logic;
           pdata_out : out std_logic_vector(7 downto 0);
           pdata_in : in std_logic_vector(7 downto 0));
end uart;

architecture Behavioral of uart is

signal data_ready : std_logic;
signal data_out : std_logic_vector(7 downto 0);

component receiver port ( clk : in std_logic;	-- clock input
		reset : in std_logic;	-- reset, active high
		sdata : in std_logic;	-- serial data in
		pdata : out std_logic_vector(7 downto 0);	-- parallel data out
		ready : out std_logic);	-- ready strobe, active high
end component;
component transmitter is
	port ( clk : in std_logic;	-- clock input
		reset : in std_logic;	-- reset, active high
		pdata : in std_logic_vector(7 downto 0); -- parallel data in
		load : in std_logic;	-- load signal, active high
		sdata : out std_logic);	-- serial data out
end component;

signal db1: std_logic_vector (7 downto 0);		
signal db2: std_logic_vector (7 downto 0);
begin
pdata_out <= data_out;
rx: receiver PORT MAP(
    clk => clk,
    reset => reset,
    sdata => data_in,
    pdata => data_out,
    ready => data_ready);
tx: transmitter PORT MAP(
    clk => clk,
    reset => reset,
    pdata => pdata_in,
    load => load,
    sdata => serial_out);


end Behavioral;