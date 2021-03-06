
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity spi_master is
	port ( clk : in std_logic;	-- clock input
		   reset : in std_logic;	-- reset, active high
		   en : in std_logic;
		   load : in std_logic; 		-- notification to send data
		   data_in : in std_logic_vector(11 downto 0);	-- pdata in
		   busy : out std_logic;
		   sdata_0 : out std_logic;	-- serial data out 1
		   sdata_1 : out std_logic;	-- serial data out 2
		   spi_clk : out std_logic;		-- clk out to SPI devices
		   CS0_n : out std_logic);	-- chip select 1, active low
end spi_master;


architecture Behavioral of spi_master is
Type State_type is (IDLE, LOW, HIGH);
--signals
signal state : State_type;
signal clk_count : integer;
signal bit_count : integer;
signal data : std_logic_vector(15 downto 0);
--constants
constant spi_clk_count : integer := 434; --based on desired clk freq of spi_clk  master clock / baud rate

begin

process(clk, reset)
begin
    if reset = '1' then
        state <= IDLE;
        clk_count <= spi_clk_count;
        bit_count <= 15;
        busy <= '0';
    elsif rising_edge(clk) then
        if en = '1' then
            case state is
                when IDLE =>
                    busy <= '0';
                    --clk_count is based on freq of spi_clk
                    if load = '1' then
                        clk_count <= spi_clk_count;
                        bit_count <= 15;
                        data <= x"0" & data_in;
                        CS0_n <= '0';
                        state <= LOW;
                        busy <= '1';
                    else state <= IDLE;
                    end if;
                when LOW =>
                    spi_clk <= '0';
                        if clk_count = 0 then
                            bit_count <= bit_count - 1;
                            state <= HIGH;
                            clk_count <= spi_clk_count;
                            else clk_count <= clk_count - 1;
                        end if;
                when HIGH =>
                    spi_clk <= '1';
                    if clk_count = 0 then
                        clk_count <= spi_clk_count;
                        if bit_count /= -1 then
                            sdata_0 <= data(bit_count);
                            sdata_1 <= data(bit_count);
                            state <= LOW;
                        else
                            state <= IDLE;
                            CS0_n <= '1';
                        end if;
                    else clk_count <= clk_count - 1;
                    end if;
            end case;
        end if;
       end if;
end process;


end Behavioral;
