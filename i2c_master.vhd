
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library unisim;
use UNISIM.VComponents.all;

entity I2C_Master is
 Port ( clk : in std_logic;
        reset : in std_logic;
        load : in std_logic; 
        sclk : out std_logic;
        sdata : inout std_logic;
        busy : out std_logic;
        pdata : out std_logic_vector(15 downto 0); 
        status : out std_logic_vector (3 downto 0) );
       
end I2C_Master;

architecture Behavioral of I2C_Master is
Type State_Type is ( idle, Start, Address_High, Address_Low,
                    Read_Write_High, Read_Write_Low, Ack_High, Ack_Low, Read_High, Read_Low, Read_High2, 
                    Read_Low2, Stop_High, Stop_Low, Send_Ack_High, Send_Ack_Low, Send_Ack2_High, Send_Ack2_Low );

signal statemachine_state : State_Type;
signal clk_count : integer;
signal rd : std_logic;
signal address : std_logic_vector(6 downto 0);
signal address_count : integer;
signal data_0 : std_logic_vector(7 downto 0);
signal data_1 : std_logic_vector(7 downto 0);
signal bit_count : integer;


constant address_signal : integer := 6;
constant address_value : std_logic_vector(6 downto 0) := "0101000";
constant read_signal : integer := 7;
constant half_sclk: integer := 500;


begin
PU : Pullup PORT MAP (O => sdata);
   
process(clk, reset)
begin
if reset = '1' then
    statemachine_state <= idle;
    sdata <= '1';
    sclk<= '1';
    rd <= '0';
    busy <= '0';
    address_count <= address_signal;
    clk_count <= half_sclk;
    

elsif rising_edge(clk) then
    case statemachine_state is
    when idle =>
    status <= "0001";
    sdata <= '1';
    sclk <= '1';
    rd <= '0';
    bit_count <= 10;
    busy <= '0';
    if load = '1' then
        statemachine_state <= start;
        busy <= '1';
        sdata <= '0';
        address_count <= address_count;
        clk_count <= half_sclk;
        address <= address_value;
    else
        statemachine_state <= idle;
    end if;
    
    when start => 
    status <= "0010";
    if clk_count = 0 then
        sdata <= address(address_count);
        statemachine_state <= Address_High;
        clk_count <= half_sclk;
        sclk <= '0';
    else 
        clk_count <= clk_count - 1;
    end if;
     
    when Address_High =>
     status <= "0011";
    if clk_count = 0 then
        status <= "0011";
         statemachine_state <= Address_Low;
         address_count <= address_count - 1;
         clk_count <= half_sclk;
         sclk <= '1';
    else 
        clk_count <= clk_count - 1;
    end if; 
        
    when Address_Low =>
    status <= "0100";
    if clk_count = 0 then
        if address_count = -1 then
            statemachine_state <= Read_Write_High;
            clk_count <= half_sclk;
            sdata <= '1';
            sclk <= '0';
        else
            sdata <= address(address_count);    
            statemachine_state <= Address_High;
            clk_count <= half_sclk;
            sclk <= '0';
        end if;
    else
        clk_count <= clk_count - 1;
    end if;
                     
    when Read_Write_High =>
    status <= "0101";
    if clk_count = 0 then
        statemachine_state <= Read_Write_Low;
        sclk <= '1';
        rd <= '0';
        clk_count <= half_sclk;
    else
        clk_count <= clk_count - 1;
    end if;          
    
    when Read_Write_Low =>
    status <= "0110";
    if clk_count = 0 then
        statemachine_state <= Ack_High;
        sclk <= '0';
        rd <= '0';
        clk_count <= half_sclk;
    else   
       clk_count <= clk_count - 1;
    end if;
    
           
    when Ack_High =>
    status <= "0111";
    sdata <= 'Z';
    rd <= '1';
    if clk_count = 0 then
        --if sdata = '0' then
           sclk <= '1';
           bit_count <= read_signal;
           statemachine_state <= Ack_Low;
           clk_count <= half_sclk; 
        --else
          --  statemachine_state <= Ack_High;
        --end if;
   else clk_count <= clk_count - 1;
   end if;
   
    when Ack_Low =>
    status <= "1000";
    sdata <= 'Z';
    rd <= '1';
    if clk_count = 0 then
        --if sdata = '0' then
            sclk <= '0';
            statemachine_state <= Read_Low;
            data_0(bit_count) <= sdata;
            clk_count <= half_sclk;
        --else
            --statemachine_state <= Ack_Low;
        --end if;
    else clk_count <= clk_count - 1;
    end if;
   
    when Read_High =>
    status <= "1010";
    if clk_count = 0 then
       statemachine_state <= Read_Low;
       if bit_count = 0 then
           statemachine_state <= Send_Ack_Low;
           rd <= '0';
           bit_count <= read_signal;
           clk_count <= half_sclk;
           sclk <= '0';
           sdata <= '0';
       else
        bit_count <= bit_count - 1;
        sclk <= '0';
        clk_count <= half_sclk;
       end if;
    else 
        clk_count <= clk_count - 1;
    end if;
            
    when Read_Low =>
    status <= "1001";
    if clk_count = 0 then
       data_0(bit_count) <= sdata;
       statemachine_state <= Read_High;
       clk_count <= half_sclk;
       sclk <= '1';     
    else
        clk_count <= clk_count - 1;
    end if;
              
    when Send_Ack_High =>
    status <= "1100";
        if clk_count = 0 then
            statemachine_state <= Read_Low2;
            rd <= '1';
            sdata <= 'Z';
            clk_count <= half_sclk;
            sclk <= '0';
        else
            clk_count <= clk_count - 1;
        end if;
    
    when Send_Ack_Low =>
    status <= "1011";
        if clk_count = 0 then
            statemachine_state <= Send_Ack_High;
            rd <= '1';
            --data_1(bit_count) <= sdata;
            clk_count <= half_sclk;
            sclk <= '1';
        else
            clk_count <= clk_count - 1;
        end if;
    
    when Read_High2 =>
    status <= "1110";
    if clk_count = 0 then
        if bit_count = 0 then
            statemachine_state <= Send_Ack2_Low;
            sdata <= '1';
            rd <= '0';
            bit_count <= read_signal;
            clk_count <= half_sclk;
            sclk <= '0';
        else
            statemachine_state <= Read_Low2;
            bit_count <= bit_count - 1;
            sclk <= '0';
            clk_count <= half_sclk;
        end if;
    else
        clk_count <= clk_count - 1;
    end if;
        
    when Read_Low2 =>
    status <= "1101";
    if clk_count = 0 then
        data_1(bit_count) <= sdata;
        statemachine_state <= Read_High2;
        clk_count <= half_sclk;
        sclk <= '1';
    else 
        clk_count <= clk_count - 1;
    end if;
    
    when Send_Ack2_High =>
    if clk_count = 0 then
        statemachine_state <= Stop_Low;
        sclk <= '0';
        clk_count <= half_sclk;
        sdata <= '0';
    else
        clk_count <= clk_count - 1;
    end if;
    
    when Send_Ack2_Low =>
    status <= "1111";
    sdata <= '1';
    if clk_count = 0 then
        statemachine_state <= Send_Ack2_High;
        sclk <= '1';
        clk_count <= half_sclk;
    else
        clk_count <= clk_count - 1;
    end if;
    
    when Stop_High =>
    if clk_count = half_sclk/2 then
        sdata<= '1';
        clk_count <= clk_count - 1;
    elsif clk_count = 0 then
        sdata <= '1';
        statemachine_state <= idle;
        clk_count <= half_sclk;
        address_count <= 6;
        sclk <= '1';
    else
        clk_count <= clk_count - 1;
    end if;
    
    when Stop_Low =>
    if clk_count = 0 then
        sclk <= '1';
        statemachine_state <= Stop_High;
        pdata <= data_0 & data_1;
        clk_count <= half_sclk;
    else
        clk_count <= clk_count - 1;
    end if;
    
    when others => 
        statemachine_state<= idle;
    end case;
  end if;
end process;
end Behavioral;