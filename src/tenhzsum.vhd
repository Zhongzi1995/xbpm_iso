--library ieee;
--use ieee.std_logic_1164.all;
--use ieee.NUMERIC_STD.all;
--library unisim;
--use unisim.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


library UNISIM;
use UNISIM.VComponents.all;



entity tenhzave is
  port(
     clk				: in std_logic;
     adc_clk            : in std_logic;
     reset              : in std_logic;

	 tenhz_cnt	        : in std_logic_vector(31 downto 0);
	 adc_data_valid     : in std_logic;

	 adc_ch0			: in std_logic_vector(17 downto 0);
	 adc_ch1			: in std_logic_vector(17 downto 0);
	 adc_ch2			: in std_logic_vector(17 downto 0);
	 adc_ch3			: in std_logic_vector(17 downto 0);	 
	 
	 tenhz_trig         : out std_logic;
	 tenhz_cnt          : out std_logic_vector(31 downto 0);
	 adc_ch0_ave        : out std_logic_vector(31 downto 0);
	 adc_ch1_ave        : out std_logic_vector(31 downto 0); 
	 adc_ch2_ave        : out std_logic_vector(31 downto 0);
	 adc_ch3_ave        : out std_logic_vector(31 downto 0);	 
	 	    
    );

end tenhzave;


architecture behv of ltc2379 is


 

begin
  
 


end process;  



end behv;
