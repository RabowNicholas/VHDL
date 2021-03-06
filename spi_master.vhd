
--potential bugs:
--initialize of the refresh counter

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;


entity spi_master_top is
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
end spi_master_top;

architecture Behavioral of spi_master_top is

component spi_master is
	port ( clk : in std_logic;	-- clock input
		   reset : in std_logic;	-- reset, active high
		   load : in std_logic; 		-- notification to send data
		   en : in std_logic;
		   data_in : in std_logic_vector(11 downto 0);	-- pdata in
		   busy : out std_logic;
		   sdata_0 : out std_logic;	-- serial data out 1
		   sdata_1 : out std_logic;	-- serial data out 2
		   spi_clk : out std_logic;		-- clk out to SPI devices
		   CS0_n : out std_logic);	-- chip select 1, active low
end component;
COMPONENT blk_mem_gen_0 IS
  PORT (
    clka : IN STD_LOGIC;
    addra : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(11 DOWNTO 0)
  );
  end component;
 component  blk_mem_gen_1 IS
  PORT (
    clka : IN STD_LOGIC;
    addra : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(11 DOWNTO 0)
  );
end component;
signal data_in : std_logic_vector(11 downto 0);
signal load : std_logic;
signal update : integer := 17360;
constant refresh_rate : integer := 17360; --master clock /refresh rate   refresh rate of 5.76 kHz
signal addr : std_logic_vector(15 downto 0);
signal address : integer := 50000;
signal address_counter : integer;
constant address_max: integer := 1000; --master clock / #of samples
signal block_out_0 : std_logic_vector(11 downto 0);
signal block_out_1 : std_logic_vector(11 downto 0);
signal block_out : std_logic_vector(11 downto 0);
begin
blk_mem0: blk_mem_gen_0 port map(clka=>clk,addra=>addr,douta=>block_out_0);
blk_mem1: blk_mem_gen_1 port map(clka=>clk,addra=>addr,douta=>block_out_1);
uut: spi_master port map(clk => clk, reset => reset,en=>en, load => load, data_in => data_in,busy=>busy, sdata_0 => Data1, sdata_1 => Data2, spi_clk => spi_clk, CS0_n => CS);
--update <= refresh_rate;
addr <= std_logic_vector(TO_UNSIGNED(address, 16));
block_out <= block_out_0 when sel = "01" else block_out_1;
process (clk,reset)
begin
    if en = '1' then
        if reset = '1' then
            update <= refresh_rate;
            address_counter <= address_max;
            load <= '0';
            address <= 0;
            data_in <= x"000";
        elsif rising_edge(clk) then
            if sel = "00" then   --get input from switches
                load <= '0';
                if update = 0 then
                    data_in <= switches & "000000";
                    load <= '1';
                    update <= refresh_rate;
                else update <= update - 1;
                end if;
            else   -- get input from memory 1
               if address_counter = 0 then
                    address_counter <= address_max;
                    load <= '0';
                    if address = 50000-1 then
                        address <= 0;
                    else
                    address <= address + 1;
                    end if;
               else address_counter <= address_counter - 1;
               load <= '1';
               data_in <= block_out;
               end if;
            end if;
       end if;
   end if;
end process;
end Behavioral;
