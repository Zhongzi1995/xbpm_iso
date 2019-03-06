-------------------------------------------------------------------------------
-- Title         : IO bus Interface
-------------------------------------------------------------------------------
-- File          : iobus_interface.vhd
-- Author        : Joseph Mead  mead@bnl.gov
-- Created       : 03/01/2011
-------------------------------------------------------------------------------
-- Description:
-- Provides a read/write register interface with the ublz processor.  Decodes
-- transactions with a simple user_bus.
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Modification history:
-- 03/01/2011: created.
-------------------------------------------------------------------------------

 
library ieee;
use ieee.std_logic_1164.all; 
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;


entity iobus_interface is
    generic (
        FPGA_VERSION        : in integer := 01
        );
    port ( 
		clk       			: in  std_logic;
        rst          		: in  std_logic;	 
        addr      			: in  std_logic_vector(15 downto 0);
        cs           		: in  std_logic;
        rnw          		: in  std_logic;
        wrdata		        : in  std_logic_vector(31 downto 0);
        rddata		        : out std_logic_vector(31 downto 0);			  

			  
		soft_trig		    : out std_logic;
		trig_status         : in  std_logic_vector(1 downto 0);
		trig_clear          : out std_logic;
		  		
		testdata_en	        : out std_logic;			  
		adcburstlen	        : out std_logic_vector(31 downto 0);
		adcburstenb         : out std_logic;

        ddr_baseaddr        : out std_logic_vector(31 downto 0); 		

        machclk_divide      : out std_logic_vector(7 downto 0);

  	    tenhz_divide        : out std_logic_vector(31 downto 0);
  	    tenhz_irqenb        : out std_logic;	
  	    
  	    tenkhz_divide       : out std_logic_vector(31 downto 0);
  	    tenkhzdata_tmode    : out std_logic;
  	    tenkhzdata_enb      : out std_logic;
  	    tenkhzdata_fiforst  : out std_logic;
        tenkhzdata_rdstr    : out std_logic;
        tenkhzdata_dout     : in  std_logic_vector(31 downto 0);
        tenkhzdata_rdcnt    : in  std_logic_vector(31 downto 0);
		
		adc_testmode        : out std_logic_vector(7 downto 0);

		axi_hp_cntrl_reg    : out std_logic_vector(15 downto 0);
	
		dac8814_data        : out std_logic_vector(31 downto 0);
        dac8814_we          : out std_logic;
        dac8814_cntrl       : out std_logic_vector(1 downto 0);	
        
        ad5060_data         : out std_logic_vector(31 downto 0);
        ad5060_we           : out std_logic;
        cal_dac_sw          : out std_logic_vector(3 downto 0);    
        
        ad5754_data         : out std_logic_vector(31 downto 0);
        ad5754_we           : out std_logic;
        ad5754_ldac         : out std_logic;   
	
	    bias_gnd            : out std_logic_vector(1 downto 0);
	    bias_pol            : out std_logic_vector(1 downto 0);
	    bias_ext            : out std_logic_vector(1 downto 0);
	    
	    bias_pol_e          : out std_logic_vector(1 downto 0);
        bias_ext_e          : out std_logic_vector(1 downto 0);
        bias_gnd_e          : out std_logic_vector(1 downto 0);
        bias_flt_e          : out std_logic_vector(1 downto 0);  
        
        qreset              : out std_logic_vector(3 downto 0);
	 
	    adc_cha             :  in std_logic_vector(31 downto 0);
	    adc_chb             :  in std_logic_vector(31 downto 0);
	    adc_chc             :  in std_logic_vector(31 downto 0);
	    adc_chd             :  in std_logic_vector(31 downto 0);
	
	    adc_cha_ave         :  in std_logic_vector(31 downto 0);
        adc_chb_ave         :  in std_logic_vector(31 downto 0);
        adc_chc_ave         :  in std_logic_vector(31 downto 0);
        adc_chd_ave         :  in std_logic_vector(31 downto 0);
        	    
	    
	    	    	    
        tenhz_trignum         :  in std_logic_vector(31 downto 0);
	 
        dfe_temp0	  	    : in std_logic_vector(15 downto 0);
        dfe_temp1	  	    : in std_logic_vector(15 downto 0);
        dfe_temp2		    : in std_logic_vector(15 downto 0);
        dfe_temp3		    : in std_logic_vector(15 downto 0);			
        afe_temp0	  	    : in std_logic_vector(15 downto 0);
        afe_temp1	  	    : in std_logic_vector(15 downto 0);	 
	     
	    gain_sw             : out std_logic_vector(31 downto 0);
		leds				: out std_logic_vector(31 downto 0);
		
		mach_clk_sel        : out std_logic_vector(1 downto 0);
		
		evr_timestamp       : in  std_logic_vector(63 downto 0);
		evr_timestamplat    : in  std_logic_vector(63 downto 0);	
		evr_trignum         : out std_logic_vector(7 downto 0);
		evr_trigdly         : out std_logic_vector(31 downto 0);
		
		adc_bias            : in std_logic_vector(31 downto 0);	
		
		
		kx                  : out std_logic_vector(31 downto 0);
		ky                  : out std_logic_vector(31 downto 0)
	 	
		);
			  
end iobus_interface;


  

architecture Behavioral of iobus_interface is


--component flag_crossdomain2 is
--	port
--	(
--	  rst		: in std_logic;
--      clka 		: in std_logic;
--	  flaga		: in std_logic;
--	  clkb 		: in std_logic;
--	  flagb		: out std_logic
--	);
--end component;




signal soft_trig_i 		        : std_logic;

signal testdata_en_i	        : std_logic;

signal adcburstlen_i	        : std_logic_vector(31 downto 0);
signal burst_enb_i              : std_logic_vector(2 downto 0);

signal gain_sw_i                : std_logic_vector(31 downto 0);
signal leds_i					: std_logic_vector(31 downto 0);

signal bias_gnd_i               : std_logic_vector(1 downto 0);
signal bias_pol_i				: std_logic_vector(1 downto 0);
signal bias_ext_i               : std_logic_vector(1 downto 0);

signal bias_gnd_e_i             : std_logic_vector(1 downto 0);
signal bias_pol_e_i				: std_logic_vector(1 downto 0);
signal bias_ext_e_i             : std_logic_vector(1 downto 0);
signal bias_flt_e_i             : std_logic_vector(1 downto 0);  

signal axi_hp_cntrl_reg_i       : std_logic_vector(15 downto 0);

signal dac8814_data_i           : std_logic_vector(31 downto 0);
signal dac8814_cntrl_i          : std_logic_vector(1 downto 0);

signal ad5060_data_i            : std_logic_vector(31 downto 0);
signal cal_dac_sw_i             : std_logic_vector(3 downto 0);

signal adc_testmode_i           : std_logic_vector(7 downto 0);

signal qreset_i                 : std_logic_vector(3 downto 0);

signal tenhz_divide_i           : std_logic_vector(31 downto 0);
signal tenhz_irqenb_i           : std_logic;
signal ddr_baseaddr_i           : std_logic_vector(31 downto 0);

signal kx_i                     : std_logic_vector(31 downto 0);
signal ky_i                     : std_logic_vector(31 downto 0);

signal cha_gain_i               : std_logic_vector(31 downto 0);
signal chb_gain_i               : std_logic_vector(31 downto 0);
signal chc_gain_i               : std_logic_vector(31 downto 0);
signal chd_gain_i               : std_logic_vector(31 downto 0);
signal cha_offset_i             : std_logic_vector(31 downto 0);
signal chb_offset_i             : std_logic_vector(31 downto 0);
signal chc_offset_i             : std_logic_vector(31 downto 0);
signal chd_offset_i             : std_logic_vector(31 downto 0);

signal cha_bmroffset_i          : std_logic_vector(31 downto 0);
signal chb_bmroffset_i          : std_logic_vector(31 downto 0);
signal chc_bmroffset_i          : std_logic_vector(31 downto 0);
signal chd_bmroffset_i          : std_logic_vector(31 downto 0);

signal mach_clk_sel_i           : std_logic_vector(1 downto 0);

signal trig_clear_i             : std_logic;
signal tenkhz_divide_i          : std_logic_vector(31 downto 0);
signal tenkhzdata_tmode_i       : std_logic;
signal tenkhzdata_enb_i         : std_logic;
signal tenkhzdata_fiforst_i     : std_logic;
signal tenkhzdata_triglen_i     : std_logic_vector(31 downto 0);
signal tenkhzdata_percdone_i    : std_logic_vector(31 downto 0);

signal machclk_divide_i         : std_logic_vector(7 downto 0);

signal ad5754_data_i            : std_logic_vector(31 downto 0);
signal ad5754_ldac_i            : std_logic;

signal evr_trignum_i            : std_logic_vector(7 downto 0);
signal evr_trigdly_i            : std_logic_vector(31 downto 0);

signal fdbk_a_kp               : std_logic_vector(31 downto 0);
signal fdbk_b_kp               : std_logic_vector(31 downto 0);
signal fdbk_c_kp               : std_logic_vector(31 downto 0);
signal fdbk_d_kp               : std_logic_vector(31 downto 0);
signal fdbk_a_ki               : std_logic_vector(31 downto 0);
signal fdbk_b_ki               : std_logic_vector(31 downto 0);
signal fdbk_c_ki               : std_logic_vector(31 downto 0);
signal fdbk_d_ki               : std_logic_vector(31 downto 0);
signal fdbk_a_kd               : std_logic_vector(31 downto 0);
signal fdbk_b_kd               : std_logic_vector(31 downto 0);
signal fdbk_c_kd               : std_logic_vector(31 downto 0);
signal fdbk_d_kd               : std_logic_vector(31 downto 0);
signal fdbk_a_en               : std_logic_vector(31 downto 0);
signal fdbk_b_en               : std_logic_vector(31 downto 0);
signal fdbk_c_en               : std_logic_vector(31 downto 0);
signal fdbk_d_en               : std_logic_vector(31 downto 0);
signal fdbk_a_sp               : std_logic_vector(31 downto 0);
signal fdbk_b_sp               : std_logic_vector(31 downto 0);
signal fdbk_c_sp               : std_logic_vector(31 downto 0);
signal fdbk_d_sp               : std_logic_vector(31 downto 0);
signal fdbk_delt               : std_logic_vector(31 downto 0);
signal fdbk_a_ctrl_max         : std_logic_vector(31 downto 0);
signal fdbk_b_ctrl_max         : std_logic_vector(31 downto 0);
signal fdbk_c_ctrl_max         : std_logic_vector(31 downto 0);
signal fdbk_d_ctrl_max         : std_logic_vector(31 downto 0);
signal fdbk_a_ctrl_min         : std_logic_vector(31 downto 0);
signal fdbk_b_ctrl_min         : std_logic_vector(31 downto 0);
signal fdbk_c_ctrl_min         : std_logic_vector(31 downto 0);
signal fdbk_d_ctrl_min         : std_logic_vector(31 downto 0);
signal fdbk_a_int_max          : std_logic_vector(31 downto 0);
signal fdbk_b_int_max          : std_logic_vector(31 downto 0);
signal fdbk_c_int_max          : std_logic_vector(31 downto 0);
signal fdbk_d_int_max          : std_logic_vector(31 downto 0);
signal fdbk_a_ctrl_scalefactor : std_logic_vector(31 downto 0);
signal fdbk_b_ctrl_scalefactor : std_logic_vector(31 downto 0);
signal fdbk_c_ctrl_scalefactor : std_logic_vector(31 downto 0);
signal fdbk_d_ctrl_scalefactor : std_logic_vector(31 downto 0);
signal ampl_flux_calfactor     : std_logic_vector(31 downto 0);
signal fdbk_a_ctrl             : std_logic_vector(31 downto 0);
signal fdbk_b_ctrl             : std_logic_vector(31 downto 0);
signal fdbk_c_ctrl             : std_logic_vector(31 downto 0);
signal fdbk_d_ctrl             : std_logic_vector(31 downto 0);




begin
 

testdata_en	        <= testdata_en_i;
adcburstlen	        <= adcburstlen_i;
adcburstenb         <= burst_enb_i(0);

gain_sw             <= gain_sw_i;
leds				<= leds_i;



--inner shield relays
bias_pol <= "01" when (bias_pol_i = "00") else "10";
bias_ext <= "10" when (bias_ext_i = "01") else "01";
bias_gnd  <= "01" when (bias_gnd_i = "01") else "10";


--electrode relays
--force bias_pol_e to be the same as bias_pol
bias_pol_e <= "10" when (bias_pol_i = "00") else "01";
bias_gnd_e   <= "10" when (bias_gnd_e_i = "00") else "01";
bias_ext_e   <= "10" when (bias_ext_e_i = "00") else "01";
bias_flt_e   <= "10" when (bias_flt_e_i = "00") else "01";

--bias_gnd            <= bias_gnd_i;
--bias_pol <= bias_pol_i;
--bias_pol_e  <= bias_pol_e_i;
--bias_ext <= bias_ext_i;

--bias_gnd_e          <= bias_gnd_e_i;
--bias_pol_e          <= bias_pol_e_i;
--bias_ext_e          <= bias_ext_e_i;
--bias_flt_e          <= bias_flt_e_i;

axi_hp_cntrl_reg    <= axi_hp_cntrl_reg_i;

dac8814_data        <= dac8814_data_i; 
dac8814_cntrl       <= dac8814_cntrl_i;

ad5060_data         <= ad5060_data_i;
cal_dac_sw          <= cal_dac_sw_i;

soft_trig            <= soft_trig_i;

adc_testmode        <= adc_testmode_i;

qreset              <= qreset_i;

tenhz_divide        <= tenhz_divide_i;
tenhz_irqenb        <= tenhz_irqenb_i;
ddr_baseaddr        <= ddr_baseaddr_i;

kx                  <= kx_i;
ky                  <= ky_i;

mach_clk_sel        <= mach_clk_sel_i;

tenkhz_divide       <= tenkhz_divide_i;
tenkhzdata_tmode    <= tenkhzdata_tmode_i;
tenkhzdata_enb      <= tenkhzdata_enb_i;
tenkhzdata_fiforst  <= tenkhzdata_fiforst_i;

ad5754_data         <= ad5754_data_i;
ad5754_ldac         <= ad5754_ldac_i;

evr_trignum         <= evr_trignum_i;
evr_trigdly         <= evr_trigdly_i;

trig_clear          <= trig_clear_i;

machclk_divide      <= machclk_divide_i;


readwrite_gen: process(clk, rst)  
	begin
		if (rst = '1') then
			 rddata			        <= (others => '0');
			 soft_trig_i 	        <= '0';
			 
			 testdata_en_i          <= '0';
			 adcburstlen_i 	        <= (others => '0');
			 burst_enb_i            <= "000";
			 
			 gain_sw_i              <= x"08080808"; --"01000";  --default to 1mA scale
			 leds_i					<= CONV_STD_LOGIC_VECTOR(FPGA_VERSION,32);

			 bias_gnd_i             <= "00";
			 bias_pol_i             <= "00"; 
             bias_ext_i             <= "00";
 
             bias_pol_e_i           <= "00";
             bias_ext_e_i           <= "00"; 
             bias_gnd_e_i           <= "00";
             bias_flt_e_i           <= "00";            
             	  
			 dac8814_data_i         <= (others => '0');
             dac8814_cntrl_i        <= "00"; 			  
			  
			 ad5060_data_i          <= (others => '0');
			 cal_dac_sw_i           <= "0000";
			  
			 axi_hp_cntrl_reg_i     <= x"0000";
			 
			 adc_testmode_i         <= x"00";
			 
			 qreset_i               <= "0000";
	
			 tenhz_divide_i         <= x"00009470";  --(1/38000) ~10Hz @378.545KHz
             tenhz_irqenb_i         <= '0';
             ddr_baseaddr_i         <= x"10000000";
             
             kx_i                   <= (others => '0');
             ky_i                   <= (others => '0');
			
			 cha_offset_i           <= (others => '0');
			 chb_offset_i           <= (others => '0');
			 chc_offset_i           <= (others => '0');
			 chd_offset_i           <= (others => '0');
			 
			 cha_bmroffset_i        <= (others => '0');
             chb_bmroffset_i        <= (others => '0');
             chc_bmroffset_i        <= (others => '0');
             chd_bmroffset_i        <= (others => '0');	
			 
			 
			 cha_gain_i             <= (others => '0');
			 chb_gain_i             <= (others => '0');
			 chc_gain_i             <= (others => '0');
			 chd_gain_i             <= (others => '0');
			 mach_clk_sel_i         <= "01";  --default to Internal
 			 machclk_divide_i       <= x"84";  -- NSLSII 100Mhz/378.545KHz
			 
			 tenkhz_divide_i        <= x"00000026";  --(1/38) ~10Khz @378.545KHz
			 tenkhzdata_tmode_i     <= '0';
			 tenkhzdata_enb_i       <= '0';
			 tenkhzdata_triglen_i   <= x"00002000";
			 tenkhzdata_percdone_i  <= (others => '0');
			 
			 ad5754_data_i          <= (others => '0');
			 ad5754_we              <= '0';
			 ad5754_ldac_i          <= '0';
			 
			 evr_trigdly_i          <= x"00000010";
			 evr_trignum_i          <= x"23";   --default to pinger
			 
			 trig_clear_i           <= '0';
			 
		else
			if (clk = '1' and clk'event) then
				if  cs = '1' then
					case addr(11 downto 0) is

					    --Reserved
						when x"000" =>	  rddata <= (others => '0');
										

                        --Enable Test Data
						when x"004" =>	if (rnw = '0') then 	testdata_en_i <= wrdata(0);   
										else				    rddata <= x"0000000" & "000" & testdata_en_i; 
										end if;
  
                        --ADC Test Mode
						when x"008" =>	if (rnw = '0') then 	adc_testmode_i <= wrdata(7 downto 0);   
										else				    rddata <= x"000000" & adc_testmode_i;
										end if;
						
						--AXI HP control                                                                                                             
                        when x"00C" =>   if (rnw = '0') then 	axi_hp_cntrl_reg_i <= wrdata(15 downto 0);                        
                                        else                    rddata <= x"0000" & axi_hp_cntrl_reg_i;
                                        end if;                                              
                                                                                                                    
                                                                                                                    										
                        --enables AXI bursts to DDR3 on trigger
                        when x"010" =>	if (rnw = '0') then	    burst_enb_i <= wrdata(2 downto 0);
					                    else					rddata <= x"0000000" & "0" & burst_enb_i;			  			
					                    end if; 

                        -- controls LED's
                        when x"014" =>  if (rnw = '0') then	    leds_i <= wrdata(31 downto 0);
									   else			            rddata <= leds_i;			  			
									   end if;  

						--ADC Burst length to DDR3
						when x"018" =>	if (rnw = '0') then     adcburstlen_i <= wrdata;
										else				    rddata <= adcburstlen_i;			  			
										end if;
	
						--FPGA_version				
						when x"01C" =>   rddata <= CONV_STD_LOGIC_VECTOR(FPGA_VERSION,32);	


                       -- 10 Hz Divide value
                        when x"020" =>  if (rnw = '0') then	    tenhz_divide_i <= wrdata;
									   else			            rddata <= tenhz_divide_i;			  			
									   end if;  

                        -- 10 Hz irq enable
                        when x"024" =>  if (rnw = '0') then	    tenhz_irqenb_i <= wrdata(0);
									   else			            rddata <= x"0000000" & "000" & tenhz_irqenb_i;			  			
									   end if;  

                        -- High Speed DDR BaseAddr
                        when x"028" =>  if (rnw = '0') then	    ddr_baseaddr_i <= wrdata;
									   else			            rddata <= ddr_baseaddr_i;			  			
									   end if;  


                        -- Machine Clock Selection
                        when x"02C" =>  if (rnw = '0') then	    mach_clk_sel_i <= wrdata(1 downto 0);
									   else			            rddata <= x"0000000" & "00" & mach_clk_sel_i;			  			
									   end if;  


                        -- 10Hz ADC Raw Data (read only)                     
                        when x"030" =>     rddata <= adc_cha; 
                        when x"034" =>     rddata <= adc_chb; 
                        when x"038" =>     rddata <= adc_chc; 
                        when x"03C" =>     rddata <= adc_chd; 
                        when x"040" =>     rddata <= tenhz_trignum; 
 

                        -- Kx
                        --Ethernet Address : 7
                        when x"044" =>  if (rnw = '0') then	    kx_i <= wrdata;
									   else			            rddata <= kx_i;			  			
									   end if;  
									   
	                    -- Ky
                        when x"048" =>  if (rnw = '0') then	    ky_i <= wrdata;
                                       else                     rddata <= ky_i;                          
                                       end if;  
 
	                    -- machine clock divide (generate mach. clk from 50Mhz osc.
                        when x"04C" =>  if (rnw = '0') then      machclk_divide_i <= wrdata(7 downto 0);
                                        else                     rddata <= x"000000" & machclk_divide_i;                          
                                        end if;                                         
                                                                       									   

	                    -- ChA Offset
                        when x"050" =>  if (rnw = '0') then	    cha_offset_i <= wrdata;
                                       else                     rddata <= cha_offset_i;                          
                                       end if; 

	                    -- ChB Offset
                        when x"054" =>  if (rnw = '0') then	    chb_offset_i <= wrdata;
                                       else                     rddata <= chb_offset_i;                          
                                       end if; 
                                       
	                    -- ChC Offset
                        when x"058" =>  if (rnw = '0') then     chc_offset_i <= wrdata;
                                        else                    rddata <= chc_offset_i;                          
                                        end if;                                        

	                    -- ChD Offset
                        when x"05C" =>  if (rnw = '0') then     chd_offset_i <= wrdata;
                                        else                    rddata <= chd_offset_i;                          
                                        end if;                                        

	                    -- ChA Gain
                        when x"060" =>  if (rnw = '0') then	    cha_gain_i <= wrdata;
                                       else                     rddata <= cha_gain_i;                          
                                       end if; 

	                    -- ChB Gain
                        when x"064" =>  if (rnw = '0') then	    chb_gain_i <= wrdata;
                                       else                     rddata <= chb_gain_i;                          
                                       end if; 
                                       
	                    -- ChC Gain
                        when x"068" =>  if (rnw = '0') then     chc_gain_i <= wrdata;
                                        else                    rddata <= chc_gain_i;                          
                                        end if;                                        

	                    -- ChD Gain
                        when x"06C" =>  if (rnw = '0') then     chd_gain_i <= wrdata;
                                        else                    rddata <= chd_gain_i;                          
                                        end if;                                        



						--Gain Switch
                        when x"070" =>	if (rnw = '0') then	    gain_sw_i <= wrdata(31 downto 0);
                                        else					rddata <= gain_sw_i;			  			
                                        end if; 

                        --Bias GND
                        when x"074" =>	if (rnw = '0') then	    bias_gnd_i <= wrdata(1 downto 0);
                                        else					rddata <= x"0000000" & "00" & bias_gnd_i;			  			
                                        end if; 

                        --Bias Polarity
                        when x"078" =>	if (rnw = '0') then	    bias_pol_i <= wrdata(1 downto 0);
                                        else					rddata <= x"0000000" & "00" & bias_pol_i;			  			
                                        end if; 			
			
			
                        --DAC 8814 SPI
                        when x"080" =>	if (rnw = '0') then	    dac8814_data_i <= wrdata(31 downto 0);
                                                                dac8814_we <= '1';
                                        else					rddata <= dac8814_data_i;			  			
                                        end if; 			
			
			
                        --DAC 8814 Control (bit0=msb, bit1=rsn)
                        when x"084" =>	if (rnw = '0') then	    dac8814_cntrl_i <= wrdata(1 downto 0);
                                        else					rddata <= x"0000000" & "00" & dac8814_cntrl_i;			  			
                                        end if; 					
			
			            --DAC AD5060 Bias DAC (controls HV offset)
			            when x"090" =>  if (rnw = '0') then      ad5060_data_i <= wrdata(31 downto 0);
			                                                    ad5060_we <= '1';
			                           else                     rddata <= ad5060_data_i;
			                           end if;
			              
			            --CAL DAC Switches
                        when x"094" =>	if (rnw = '0') then	    cal_dac_sw_i <= wrdata(3 downto 0);
                                        else					rddata <= x"0000000" & cal_dac_sw_i;			  			
                                        end if; 			                           
	
                        --Bias External
                        when x"098" =>	if (rnw = '0') then	    bias_ext_i <= wrdata(1 downto 0);
                                        else					rddata <= x"0000000" & "00" & bias_ext_i;			  			
                                        end if; 				
			                    
		                --Q Reset
                        when x"09C" =>	if (rnw = '0') then	    qreset_i <= wrdata(3 downto 0);
                                        else					rddata <= x"0000000" & qreset_i;			  			
                                        end if; 	                     
			                     
			                     		                          
                        --Electrode Bias Polarity
                        when x"0A0" =>	if (rnw = '0') then	    bias_pol_e_i <= wrdata(1 downto 0);
                                        else					rddata <= x"0000000" & "00" & bias_pol_e_i;			  			
                                        end if; 	
			             
                       --Electrode Bias External
                       when x"0A4" =>	if (rnw = '0') then	    bias_ext_e_i <= wrdata(1 downto 0);
                                        else					rddata <= x"0000000" & "00" & bias_ext_e_i;			  			
                                        end if; 	
	
                      --Electrode Bias GND
                      when x"0A8" =>	    if (rnw = '0') then	    bias_gnd_e_i <= wrdata(1 downto 0);
                                        else					rddata <= x"0000000" & "00" & bias_gnd_e_i;			  			
                                        end if; 	
	
                      --Electrode Bias Float
                      when x"0AC" =>	    if (rnw = '0') then	    bias_flt_e_i <= wrdata(1 downto 0);
                                        else					rddata <= x"0000000" & "00" & bias_flt_e_i;			  			
                                        end if; 	
	


                      -- 10Hz ADC Averaged Data (read only)                     
                        when x"0B0" =>     rddata <= adc_cha_ave; 
                        when x"0B4" =>     rddata <= adc_chb_ave; 
                        when x"0B8" =>     rddata <= adc_chc_ave; 
                        when x"0BC" =>     rddata <= adc_chd_ave; 



	                    -- ChA BMR Offset
                        when x"0C0" =>  if (rnw = '0') then	    cha_bmroffset_i <= wrdata;
                                       else                     rddata <= cha_bmroffset_i;                          
                                       end if; 

	                    -- ChB BMR Offset
                        when x"0C4" =>  if (rnw = '0') then	    chb_bmroffset_i <= wrdata;
                                       else                     rddata <= chb_bmroffset_i;                          
                                       end if; 
                                       
	                    -- ChC BMR Offset
                        when x"0C8" =>  if (rnw = '0') then     chc_bmroffset_i <= wrdata;
                                        else                    rddata <= chc_bmroffset_i;                          
                                        end if;                                        

	                    -- ChD BMROffset
                        when x"0CC" =>  if (rnw = '0') then     chd_bmroffset_i <= wrdata;
                                        else                    rddata <= chd_bmroffset_i;                          
                                        end if;                                       



                        --evr timestamp free running                     
                        when x"0D0" =>      rddata <= evr_timestamp(63 downto 32);  --seconds portion 
                        when x"0D4" =>      rddata <= evr_timestamp(31 downto 0);   --offset portion (fast counter) 
 
                         --evr timestamp (latched on usr_trig event)                     
                        when x"0D8" =>      rddata <= evr_timestamplat(63 downto 32);  --seconds portion 
                        when x"0DC" =>      rddata <= evr_timestamplat(31 downto 0);   --offset portion (fast counter) 
                                               
     
	                    -- evr_trig delay
                        when x"0E0" =>  if (rnw = '0') then     evr_trigdly_i <= wrdata;
                                        else                    rddata <= evr_trigdly_i;                          
                                        end if;    
                                        
	                    -- evr_trig number
                        when x"0E4" =>  if (rnw = '0') then     evr_trignum_i <= wrdata(7 downto 0);
                                        else                    rddata <= x"000000" & evr_trignum_i;                          
                                        end if;       
                                        
                        -- ADC Bias (read only)                     
                        when x"0F0" =>     rddata <= adc_bias;                                   


                        --temperature sensors (read only)                     
                        when x"100" =>     rddata <= x"0000" &  dfe_temp0; 
                        when x"104" =>     rddata <= x"0000" &  dfe_temp1; 
                        when x"108" =>     rddata <= x"0000" &  dfe_temp2; 
                        when x"10C" =>     rddata <= x"0000" &  dfe_temp3; 
                        when x"110" =>     rddata <= x"0000" &  afe_temp0; 
                        when x"114" =>     rddata <= x"0000" &  afe_temp1; 
                        

 		
			            --DAC AD5060 Bias DAC (controls feedback loop )
			            when x"120" =>  if (rnw = '0') then     ad5754_data_i <= wrdata(31 downto 0);
			                                                    ad5754_we <= '1';
			                           else                     rddata <= ad5754_data_i;
			                           end if;


                       --DAC 5754 LDAC (latch the DAC settings to the output)
                        when x"124" =>	if (rnw = '0') then	    ad5754_ldac_i <= wrdata(0);
                                        else					rddata <= x"0000000" & "000" & ad5754_ldac_i; 			  			
                                        end if; 					
	
                                                   
			            -- 10KHz fifo data read
			            when x"200" =>  if (rnw = '1') then     rddata <= tenkhzdata_dout;
			                                                    tenkhzdata_rdstr <= '1';
			                             end if;

                        --10KHz FIFO rd counter
                        when x"204" =>     rddata <= tenkhzdata_rdcnt;

	                    --10KHz soft trigger (read back is trigger status)
                        when x"208" =>  if (rnw = '0') then     soft_trig_i <= wrdata(0);         
                                        else                    rddata <= x"0000000" & "00" & trig_status;                    
                                        end if;   

	                    --10KHz trigger length
                        when x"20C" =>  if (rnw = '0') then     tenkhzdata_triglen_i <= wrdata;
                                        else                    rddata <= tenkhzdata_triglen_i;                    
                                        end if;   

	                    --10KHz trigger percent complete
                        when x"210" =>  if (rnw = '0') then     tenkhzdata_percdone_i <= wrdata;
                                        else                    rddata <= tenkhzdata_percdone_i;                    
                                        end if; 

	                    --10KHz Dvide
                        when x"214" =>  if (rnw = '0') then     tenkhz_divide_i <= wrdata;
                                        else                    rddata <= tenkhz_divide_i;                    
                                        end if; 

	                    --10KHz control
                        when x"218" =>  if (rnw = '0') then     tenkhzdata_fiforst_i <= wrdata(0);
                                                                tenkhzdata_tmode_i   <= wrdata(1);
                                        else                    rddata <= x"0000000" & "00" & tenkhzdata_tmode_i & tenkhzdata_fiforst_i;                    
                                        end if;   

	                    --10KHz trig clear
                        when x"21C" =>  if (rnw = '0') then     trig_clear_i <= wrdata(0);
                                        else                    rddata <= x"0000000" & "000" & trig_clear_i;                    
                                        end if; 




	                    --Feedback PID Kp ChannelA
                        when x"220" =>  if (rnw = '0') then     fdbk_a_kp <= wrdata;
                                        else                    rddata <= fdbk_a_kp;                    
                                        end if; 

	                    --Feedback PID Kp ChannelB
                        when x"224" =>  if (rnw = '0') then     fdbk_b_kp <= wrdata;
                                        else                    rddata <= fdbk_b_kp;                    
                                        end if; 

	                    --Feedback PID Kp ChannelC
                        when x"228" =>  if (rnw = '0') then     fdbk_c_kp <= wrdata;
                                        else                    rddata <= fdbk_c_kp;                    
                                        end if; 

	                    --Feedback PID Kp ChannelD
                        when x"22C" =>  if (rnw = '0') then     fdbk_d_kp <= wrdata;
                                        else                    rddata <= fdbk_d_kp;                    
                                        end if; 

	                    --Feedback PID Ki ChannelA
                        when x"230" =>  if (rnw = '0') then     fdbk_a_ki <= wrdata;
                                        else                    rddata <= fdbk_a_ki;                    
                                        end if; 

	                    --Feedback PID Ki ChannelB
                        when x"234" =>  if (rnw = '0') then     fdbk_b_ki <= wrdata;
                                        else                    rddata <= fdbk_b_ki;                    
                                        end if; 

	                    --Feedback PID Ki ChannelC
                        when x"238" =>  if (rnw = '0') then     fdbk_c_ki <= wrdata;
                                        else                    rddata <= fdbk_c_ki;                    
                                        end if; 

	                    --Feedback PID Ki ChannelD
                        when x"23C" =>  if (rnw = '0') then     fdbk_d_ki <= wrdata;
                                        else                    rddata <= fdbk_d_ki;                    
                                        end if; 

	                    --Feedback PID Kd ChannelA
                        when x"240" =>  if (rnw = '0') then     fdbk_a_kd <= wrdata;
                                        else                    rddata <= fdbk_a_kd;                    
                                        end if; 

	                    --Feedback PID Kd ChannelB
                        when x"244" =>  if (rnw = '0') then     fdbk_b_kd <= wrdata;
                                        else                    rddata <= fdbk_b_kd;                    
                                        end if; 

	                    --Feedback PID Kd ChannelC
                        when x"248" =>  if (rnw = '0') then     fdbk_c_kd <= wrdata;
                                        else                    rddata <= fdbk_c_kd;                    
                                        end if; 

	                    --Feedback PID Kd ChannelD
                        when x"24C" =>  if (rnw = '0') then     fdbk_d_kd <= wrdata;
                                        else                    rddata <= fdbk_d_kd;                    
                                        end if; 

	                    --Feedback Enable ChannelA
                        when x"250" =>  if (rnw = '0') then     fdbk_a_en <= wrdata;
                                        else                    rddata <= fdbk_a_en;                    
                                        end if; 

	                    --Feedback Enable ChannelB
                        when x"254" =>  if (rnw = '0') then     fdbk_b_en <= wrdata;
                                        else                    rddata <= fdbk_b_en;                    
                                        end if; 

	                    --Feedback Enable ChannelC
                        when x"258" =>  if (rnw = '0') then     fdbk_c_en <= wrdata;
                                        else                    rddata <= fdbk_c_en;                    
                                        end if; 

	                    --Feedback Enable ChannelD
                        when x"25C" =>  if (rnw = '0') then     fdbk_d_en <= wrdata;
                                        else                    rddata <= fdbk_d_en;                    
                                        end if; 

	                    --Feedback Setpoint ChannelA
                        when x"260" =>  if (rnw = '0') then     fdbk_a_sp <= wrdata;
                                        else                    rddata <= fdbk_a_sp;                    
                                        end if; 

	                    --Feedback Setpoint ChannelB
                        when x"264" =>  if (rnw = '0') then     fdbk_b_sp <= wrdata;
                                        else                    rddata <= fdbk_b_sp;                    
                                        end if; 

	                    --Feedback Setpoint ChannelC
                        when x"268" =>  if (rnw = '0') then     fdbk_c_sp <= wrdata;
                                        else                    rddata <= fdbk_c_sp;                    
                                        end if; 

	                    --Feedback Setpoint ChannelD
                        when x"26C" =>  if (rnw = '0') then     fdbk_d_sp <= wrdata;
                                        else                    rddata <= fdbk_d_sp;                    
                                        end if; 

	                    --Feedback Loop Period 
                        when x"270" =>  if (rnw = '0') then     fdbk_delt <= wrdata;
                                        else                    rddata <= fdbk_delt;                    
                                        end if; 

	                    --Feedback Control max ChannelA
                        when x"274" =>  if (rnw = '0') then     fdbk_a_ctrl_max <= wrdata;
                                        else                    rddata <= fdbk_a_ctrl_max;                    
                                        end if; 

	                    --Feedback Control max ChannelB
                        when x"278" =>  if (rnw = '0') then     fdbk_b_ctrl_max <= wrdata;
                                        else                    rddata <= fdbk_b_ctrl_max;                    
                                        end if; 
                                        
	                    --Feedback Control max ChannelC
                        when x"27C" =>  if (rnw = '0') then     fdbk_c_ctrl_max <= wrdata;
                                        else                    rddata <= fdbk_c_ctrl_max;                    
                                        end if;                                         
                                        
	                    --Feedback Control max ChannelD
                        when x"280" =>  if (rnw = '0') then     fdbk_d_ctrl_max <= wrdata;
                                        else                    rddata <= fdbk_d_ctrl_max;                    
                                        end if;                                         

	                    --Feedback Control min ChannelA
                        when x"284" =>  if (rnw = '0') then     fdbk_a_ctrl_min <= wrdata;
                                        else                    rddata <= fdbk_a_ctrl_min;                    
                                        end if; 

	                    --Feedback Control min ChannelB
                        when x"288" =>  if (rnw = '0') then     fdbk_b_ctrl_min <= wrdata;
                                        else                    rddata <= fdbk_b_ctrl_min;                    
                                        end if; 
                                        
	                    --Feedback Control min ChannelC
                        when x"28C" =>  if (rnw = '0') then     fdbk_c_ctrl_min <= wrdata;
                                        else                    rddata <= fdbk_c_ctrl_min;                    
                                        end if;                                         
                                        
	                    --Feedback Control min ChannelD
                        when x"290" =>  if (rnw = '0') then     fdbk_d_ctrl_min <= wrdata;
                                        else                    rddata <= fdbk_d_ctrl_min;                    
                                        end if;                                         

	                    --Feedback Integral max ChannelA
                        when x"294" =>  if (rnw = '0') then     fdbk_a_int_max <= wrdata;
                                        else                    rddata <= fdbk_a_int_max;                    
                                        end if; 

	                    --Feedback Integral max ChannelB
                        when x"298" =>  if (rnw = '0') then     fdbk_b_int_max <= wrdata;
                                        else                    rddata <= fdbk_b_int_max;                    
                                        end if; 
                                        
	                    --Feedback Integral max ChannelC
                        when x"29C" =>  if (rnw = '0') then     fdbk_c_int_max <= wrdata;
                                        else                    rddata <= fdbk_c_int_max;                    
                                        end if;                                         
                                        
	                    --Feedback Integral max ChannelD
                        when x"2A0" =>  if (rnw = '0') then     fdbk_d_int_max <= wrdata;
                                        else                    rddata <= fdbk_d_int_max;                    
                                        end if;                                         

	                    --Feedback scale factor ChannelA
                        when x"2A4" =>  if (rnw = '0') then     fdbk_a_ctrl_scalefactor <= wrdata;
                                        else                    rddata <= fdbk_a_ctrl_scalefactor;                    
                                        end if; 

	                    --Feedback scale factor ChannelB
                        when x"2A8" =>  if (rnw = '0') then     fdbk_b_ctrl_scalefactor <= wrdata;
                                        else                    rddata <= fdbk_b_ctrl_scalefactor;                    
                                        end if; 
                                        
	                    --Feedback scale factor ChannelC
                        when x"2AC" =>  if (rnw = '0') then     fdbk_c_ctrl_scalefactor <= wrdata;
                                        else                    rddata <= fdbk_c_ctrl_scalefactor;                    
                                        end if;                                         
                                        
	                    --Feedback scale factor ChannelD
                        when x"2B0" =>  if (rnw = '0') then     fdbk_d_ctrl_scalefactor <= wrdata;
                                        else                    rddata <= fdbk_d_ctrl_scalefactor;                    
                                        end if;                                         

	                    --Amplifier Flux Calibration Factor
                        when x"2BC" =>  if (rnw = '0') then     ampl_flux_calfactor <= wrdata;
                                        else                    rddata <= ampl_flux_calfactor;                    
                                        end if;        

	                    --Feedback Integral ChannelA
                        when x"2C0" =>  if (rnw = '0') then     fdbk_a_ctrl <= wrdata;
                                        else                    rddata <= fdbk_a_ctrl;                    
                                        end if; 

	                    --Feedback Integral ChannelB
                        when x"2C4" =>  if (rnw = '0') then     fdbk_b_ctrl <= wrdata;
                                        else                    rddata <= fdbk_b_ctrl;                    
                                        end if; 
                                        
	                    --Feedback Integral ChannelC
                        when x"2C8" =>  if (rnw = '0') then     fdbk_c_ctrl <= wrdata;
                                        else                    rddata <= fdbk_c_ctrl;                    
                                        end if;                                         
                                        
	                    --Feedback Integral ChannelD
                        when x"2CC" =>  if (rnw = '0') then     fdbk_d_ctrl <= wrdata;
                                        else                    rddata <= fdbk_d_ctrl;                    
                                        end if;                          





			
					 when others =>
										null;
																
				   end case;
						
				else
				   dac8814_we       <= '0';
				   ad5754_we       <= '0';
                   ad5060_we        <= '0';
				   soft_trig_i 	    <= '0';
				   tenkhzdata_rdstr <= '0';
				end if;
			end if;
		end if;
	end process;
						

-- ****************************************************************************************	
 

-- npi_softtrig must cross over to adc_clk domain	
--npi_softtrig_pulse :	flag_crossdomain 
--	port map
--	(
--	  rst			=> rst, 
--     clka 		=> clk, 
--	  flaga		=> npi_softtrig_i,
--	  clkb 		=> adc_clk,
--	  flagb		=> npi_softtrig
--	);
	
	
-- errcnt_injerr must cross over to adc_clk domain	
--injerr_pulse :	flag_crossdomain2 
--	port map
--	(
--	  rst		=> rst, 
--     clka 		=> clk, 
--	  flaga		=> errcnt_injerr_i,
--	  clkb 		=> adc_clk,
--	  flagb		=> errcnt_injerr
--	);	
	
	

end Behavioral;

