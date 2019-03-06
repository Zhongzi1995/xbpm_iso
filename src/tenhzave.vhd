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
     mach_clk           : in std_logic;
     reset              : in std_logic;

	 adc_data_valid     : in std_logic;
	 tenhz_trig         : in std_logic;

	 adc_ch0			: in std_logic_vector(17 downto 0);
	 adc_ch1			: in std_logic_vector(17 downto 0);
	 adc_ch2			: in std_logic_vector(17 downto 0);
	 adc_ch3			: in std_logic_vector(17 downto 0);	 
	 
	 tenhz_trignum      : out std_logic_vector(31 downto 0);
	 
	 adc_cha            : out std_logic_vector(31 downto 0);
     adc_chb            : out std_logic_vector(31 downto 0); 
     adc_chc            : out std_logic_vector(31 downto 0);
     adc_chd            : out std_logic_vector(31 downto 0);     
             
	 adc_cha_ave        : out std_logic_vector(31 downto 0);
	 adc_chb_ave        : out std_logic_vector(31 downto 0); 
	 adc_chc_ave        : out std_logic_vector(31 downto 0);
	 adc_chd_ave        : out std_logic_vector(31 downto 0)	 
	 	    
    );

end tenhzave;


architecture behv of tenhzave is


    signal tenhz_trignum_i    : unsigned(31 downto 0);
    
    signal adc_ch0_se       : std_logic_vector(35 downto 0);
    signal adc_ch1_se       : std_logic_vector(35 downto 0);
    signal adc_ch2_se       : std_logic_vector(35 downto 0);
    signal adc_ch3_se       : std_logic_vector(35 downto 0); 
    
    signal adc_ch0_lat      : std_logic_vector(35 downto 0);
    signal adc_ch1_lat      : std_logic_vector(35 downto 0);
    signal adc_ch2_lat      : std_logic_vector(35 downto 0);
    signal adc_ch3_lat      : std_logic_vector(35 downto 0);    
    
    signal adc_ch0_sum      : signed(35 downto 0);  
    signal adc_ch1_sum      : signed(35 downto 0);     
    signal adc_ch2_sum      : signed(35 downto 0); 
    signal adc_ch3_sum      : signed(35 downto 0);   
    
     

begin
  
tenhz_trignum <= std_logic_vector(tenhz_trignum_i);  
  
--divide result by 4 to fit into 32 bit number 
-- 10Hz is /38000 from TbT data, do remaining divide by 9500 in ARM  
adc_cha_ave <= adc_ch0_lat(35 downto 4);
adc_chb_ave <= adc_ch1_lat(35 downto 4);  
adc_chc_ave <= adc_ch2_lat(35 downto 4);  
adc_chd_ave <= adc_ch3_lat(35 downto 4);   
 
-- sign extended version of 18 bit adc values 
adc_cha <= adc_ch0_se(31 downto 0);
adc_chb <= adc_ch1_se(31 downto 0);
adc_chc <= adc_ch2_se(31 downto 0);
adc_chd <= adc_ch3_se(31 downto 0);

process(reset,mach_clk)
  begin
     if (reset = '1') then
        tenhz_trignum_i <= (others => '0');
        adc_ch0_sum <= (others => '0');
        adc_ch1_sum <= (others => '0');  
        adc_ch2_sum <= (others => '0');       
        adc_ch3_sum <= (others => '0'); 
        
     elsif (mach_clk'event and mach_clk = '1') then
        if (tenhz_trig = '1') then
           adc_ch0_lat <= std_logic_vector(adc_ch0_sum);
           adc_ch1_lat <= std_logic_vector(adc_ch1_sum);         
           adc_ch2_lat <= std_logic_vector(adc_ch2_sum);                   
           adc_ch3_lat <= std_logic_vector(adc_ch3_sum);                  
           tenhz_trignum_i <= tenhz_trignum_i + 1;
           adc_ch0_sum <= (others => '0');
           adc_ch1_sum <= (others => '0');  
           adc_ch2_sum <= (others => '0');       
           adc_ch3_sum <= (others => '0');          
                
        else
           adc_ch0_se <= (35 downto 18 => adc_ch0(17)) & adc_ch0;
           adc_ch1_se <= (35 downto 18 => adc_ch1(17)) & adc_ch1;
           adc_ch2_se <= (35 downto 18 => adc_ch2(17)) & adc_ch2;
           adc_ch3_se <= (35 downto 18 => adc_ch3(17)) & adc_ch3;       
        
           adc_ch0_sum <= signed(adc_ch0_se) + adc_ch0_sum;
           adc_ch1_sum <= signed(adc_ch1_se) + adc_ch1_sum;
           adc_ch2_sum <= signed(adc_ch2_se) + adc_ch2_sum;
           adc_ch3_sum <= signed(adc_ch3_se) + adc_ch3_sum;                      

        end if;
     end if;
end process;




end behv;
