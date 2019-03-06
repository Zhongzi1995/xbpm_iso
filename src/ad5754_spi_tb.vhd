library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library UNISIM;
use UNISIM.VComponents.all;

entity ad5754_spi_tb is
end ad5754_spi_tb;



architecture behv of ad5754_spi_tb is

   signal sys_clk           : std_logic;
   signal sys_rst           : std_logic;
   signal ad5754_data       : std_logic_vector(31 downto 0);
   signal ad5754_we         : std_logic;
   
   signal ad5754_sclk       : std_logic;                    
   signal ad5754_din        : std_logic;
   signal ad5754_sync       : std_logic;
   signal ad5754_clrn       : std_logic;
   signal ad5754_bin2s      : std_logic;


begin  


uut:  entity work.ad5754_spi
  
  port map (
   clk         => sys_clk,                     
   reset  	   => sys_rst,                      
   we		   => ad5754_we, 
   wrdata	   => ad5754_data, 

   sclk        => ad5754_sclk,                    
   din 	       => ad5754_din, 
   sync        => ad5754_sync,
   clrn        => ad5754_clrn,
   bin2s       => ad5754_bin2s                  
  );    


-- system clk process
process
  begin
     sys_clk <= '0';
     wait for 10 ns;
     sys_clk <= '1';
     wait for 10 ns;
end process;


-- main process
process
  begin
    sys_rst   <= '1';
    ad5754_we <= '0';
    ad5754_data <= x"00000000";
  
    wait for 100 ns;
    sys_rst   <= '0';
    wait for 100 ns;

    ad5754_we <= '1';
    ad5754_data <= x"89ABCDEF";
    wait for 20 ns;
    ad5754_we <= '0';
    wait for 10 us;
    
    ad5754_we <= '1';
    ad5754_data <= x"01234567";
    wait for 20 ns;
    ad5754_we <= '0';
    wait for 10 us;
    
end process;








  
end behv;
