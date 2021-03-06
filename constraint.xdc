# Clock signal
set_property PACKAGE_PIN W5 [get_ports clk]       
 set_property IOSTANDARD LVCMOS33 [get_ports clk]
set_property PACKAGE_PIN V17 [get_ports reset]     
  set_property IOSTANDARD LVCMOS33 [get_ports reset]

#ADC2
set_property PACKAGE_PIN N17 [get_ports i2c_clk]       
 set_property IOSTANDARD LVCMOS33 [get_ports i2c_clk]
set_property PACKAGE_PIN P18 [get_ports i2c_sda]       
 set_property IOSTANDARD LVCMOS33 [get_ports i2c_sda]
 
#LEDS
set_property PACKAGE_PIN L1 [get_ports {LED[5]}]       
 set_property IOSTANDARD LVCMOS33 [get_ports {LED[5]}]
set_property PACKAGE_PIN P1 [get_ports {LED[4]}]       
 set_property IOSTANDARD LVCMOS33 [get_ports {LED[4]}]
set_property PACKAGE_PIN N3 [get_ports {LED[3]}]      
 set_property IOSTANDARD LVCMOS33 [get_ports {LED[3]}]
set_property PACKAGE_PIN P3 [get_ports {LED[2]}]       
 set_property IOSTANDARD LVCMOS33 [get_ports {LED[2]}]
set_property PACKAGE_PIN U3 [get_ports {LED[1]}]       
 set_property IOSTANDARD LVCMOS33 [get_ports {LED[1]}]
set_property PACKAGE_PIN W3 [get_ports {LED[0]}]       
 set_property IOSTANDARD LVCMOS33 [get_ports {LED[0]}]
 
 
 #Switches
set_property PACKAGE_PIN R2 [get_ports {SWITCH[5]}]                    
    set_property IOSTANDARD LVCMOS33 [get_ports {SWITCH[5]}]
set_property PACKAGE_PIN T1 [get_ports {SWITCH[4]}]                    
    set_property IOSTANDARD LVCMOS33 [get_ports {SWITCH[4]}]
set_property PACKAGE_PIN U1 [get_ports {SWITCH[3]}]                    
    set_property IOSTANDARD LVCMOS33 [get_ports {SWITCH[3]}]
set_property PACKAGE_PIN W2 [get_ports {SWITCH[2]}]                    
    set_property IOSTANDARD LVCMOS33 [get_ports {SWITCH[2]}]
set_property PACKAGE_PIN R3 [get_ports {SWITCH[1]}]                    
    set_property IOSTANDARD LVCMOS33 [get_ports {SWITCH[1]}]
set_property PACKAGE_PIN T2 [get_ports {SWITCH[0]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {SWITCH[0]}]
    
#DAC                   
set_property PACKAGE_PIN A14 [get_ports {CS}]                    
    set_property IOSTANDARD LVCMOS33 [get_ports {CS}]
set_property PACKAGE_PIN A16 [get_ports {spi_sda1}]                    
    set_property IOSTANDARD LVCMOS33 [get_ports {spi_sda1}]
set_property PACKAGE_PIN B15 [get_ports {spi_sda2}]                    
    set_property IOSTANDARD LVCMOS33 [get_ports {spi_sda2}]
set_property PACKAGE_PIN B16 [get_ports {spi_clk}]                    
    set_property IOSTANDARD LVCMOS33 [get_ports {spi_clk}]
# RX -----------------------------------------------------------------------------------
    set_property PACKAGE_PIN B18 [get_ports uart_in]						
	   set_property IOSTANDARD LVCMOS33 [get_ports uart_in]
# TX -----------------------------------------------------------------------------------
    set_property PACKAGE_PIN A18 [get_ports uart_out]						
	   set_property IOSTANDARD LVCMOS33 [get_ports uart_out]