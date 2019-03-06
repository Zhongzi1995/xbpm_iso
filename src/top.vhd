

--v66  - switched bias_flt_e pins [0] and [1]
--v67  - added BMR Offset Registers.  Changed default clk_src to external


library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.ALL;
--use ieee.std_logic_arith.all;
--use ieee.std_logic_unsigned.all;

library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
 

entity top is
generic(
    USE_ILA	        		: integer := 0;
    FPGA_VERSION			: integer := 31;
    SIM_MODE				: integer := 0
    );
  port (
    ddr_addr                : inout std_logic_vector ( 14 downto 0 );
    ddr_ba                  : inout std_logic_vector ( 2 downto 0 );
    ddr_cas_n               : inout std_logic;
    ddr_ck_n                : inout std_logic;
    ddr_ck_p                : inout std_logic;
    ddr_cke                 : inout std_logic;
    ddr_cs_n                : inout std_logic;
    ddr_dm                  : inout std_logic_vector ( 3 downto 0 );
    ddr_dq                  : inout std_logic_vector ( 31 downto 0 );
    ddr_dqs_n               : inout std_logic_vector ( 3 downto 0 );
    ddr_dqs_p               : inout std_logic_vector ( 3 downto 0 );
    ddr_odt                 : inout std_logic;
    ddr_ras_n               : inout std_logic;
    ddr_reset_n             : inout std_logic;
    ddr_we_n                : inout std_logic;
    fixed_io_ddr_vrn        : inout std_logic;
    fixed_io_ddr_vrp        : inout std_logic;
    fixed_io_mio            : inout std_logic_vector ( 53 downto 0 );
    fixed_io_ps_clk         : inout std_logic;
    fixed_io_ps_porb        : inout std_logic;
    fixed_io_ps_srstb       : inout std_logic;
    
     -- ADC channel 0
    adc0_sck                 : out std_logic;
    adc0_cnv                 : out std_logic;
    adc0_busy                : in std_logic;
    adc0_sdo                 : in std_logic;
   
    -- ADC channel 1
    adc1_sck                 : out std_logic;
    adc1_cnv                 : out std_logic;
    adc1_busy                : in std_logic;
    adc1_sdo                 : in std_logic;    
   
    -- ADC channel 2
    adc2_sck                 : out std_logic;
    adc2_cnv                 : out std_logic;
    adc2_busy                : in std_logic;
    adc2_sdo                 : in std_logic;
   
    -- ADC channel 3
    adc3_sck                 : out std_logic;
    adc3_cnv                 : out std_logic;
    adc3_busy                : in std_logic;
    adc3_sdo                 : in std_logic;       
     
    -- Gain Control
--    gain_sw_cha              : out std_logic_vector(4 downto 0); 
--    gain_sw_chb              : out std_logic_vector(4 downto 0); 
--    gain_sw_chc              : out std_logic_vector(4 downto 0); 
--    gain_sw_chd              : out std_logic_vector(4 downto 0);              

    -- Front end amplifiers
    Cha_latch               : out std_logic;
    Cha_cs                  : out std_logic;
    Cha_sdi                 : out std_logic;
    Cha_sck                 : out std_logic;
    
    Chb_latch               : out std_logic;
    Chb_cs                  : out std_logic;
    Chb_sdi                 : out std_logic;
    Chb_sck                 : out std_logic;

    Chc_latch               : out std_logic;
    Chc_cs                  : out std_logic;
    Chc_sdi                 : out std_logic;
    Chc_sck                 : out std_logic;
    
    Chd_latch               : out std_logic;
    Chd_cs                  : out std_logic;
    Chd_sdi                 : out std_logic;
    Chd_sck                 : out std_logic;
  
    -- Bias DAC
    ad5060_sclk             : out std_logic;
    ad5060_din              : out std_logic;
    ad5060_sync             : out std_logic;   
     
    --sfp I/O
    sfp_sck                 : inout std_logic_vector(1 downto 0);
    sfp_sda                 : inout std_logic_vector(1 downto 0);
    
    -- Embedded Event Receiver
    gtx_refclk_p            : in std_logic;
    gtx_refclk_n            : in std_logic;
    gtx_rx_p                : in std_logic;
    gtx_rx_n                : in std_logic;
    
    -- Motor Control DAC
    ad5754_sync             : out std_logic;
    ad5754_sclk             : out std_logic;  
    ad5754_din              : out std_logic;
    ad5754_sdo              : in std_logic; --disconnected for now since it was +5v on DAC DB. 
    ad5754_ldac             : out std_logic;
    ad5754_clrn             : out std_logic;  
    ad5754_bin2s            : out std_logic; 
      
    -- Debug header
    dbg                     : out std_logic_vector(9 downto 0);

    --  LED's
    fp_leds                 : out std_logic_vector(3 downto 0);
    sfp_leds                : out std_logic_vector(3 downto 0) 


  );
end top;


architecture behv of top is

component system is
  port (
    ddr_cas_n               : inout std_logic;
    ddr_cke                 : inout std_logic;
    ddr_ck_n                : inout std_logic;
    ddr_ck_p                : inout std_logic;
    ddr_cs_n                : inout std_logic;
    ddr_reset_n             : inout std_logic;
    ddr_odt                 : inout std_logic;
    ddr_ras_n               : inout std_logic;
    ddr_we_n                : inout std_logic;
    ddr_ba                  : inout std_logic_vector ( 2 downto 0 );
    ddr_addr                : inout std_logic_vector ( 14 downto 0 );
    ddr_dm                  : inout std_logic_vector ( 3 downto 0 );
    ddr_dq                  : inout std_logic_vector ( 31 downto 0 );
    ddr_dqs_n               : inout std_logic_vector ( 3 downto 0 );
    ddr_dqs_p               : inout std_logic_vector ( 3 downto 0 );
    fixed_io_mio            : inout std_logic_vector ( 53 downto 0 );
    fixed_io_ddr_vrn        : inout std_logic;
    fixed_io_ddr_vrp        : inout std_logic;
    fixed_io_ps_srstb       : inout std_logic;
    fixed_io_ps_clk         : inout std_logic;
    fixed_io_ps_porb        : inout std_logic;
    sys_clk                 : out std_logic; 
    sys_rst                 : out std_logic_vector(0 to 0);
    iobus_data_pl2ps        : in std_logic_vector ( 31 downto 0 );
    iobus_addr              : out std_logic_vector ( 15 downto 0 );
    iobus_cs                : out std_logic;
    iobus_rnw               : out std_logic;
    iobus_data_ps2pl        : out std_logic_vector( 31 downto 0 );
    hs_ddr_baseaddr         : in std_logic_vector( 31 downto 0 );
    hs_ddr_curaddr          : out std_logic_vector( 31 downto 0 );   
    hs_fifo_rdcnt           : in std_logic_vector ( 8 downto 0 );
    hs_fifo_rddata          : in std_logic_vector ( 63 downto 0 );
    hs_fifo_rden            : out std_logic;
    hs_tx_active            : out std_logic;
    hs_tx_enb               : in std_logic;
    tenhz_irq               : in std_logic;
    other_irq               : in std_logic
  );
end component;


component  evr_top
  port (
    Q0_CLK1_GTREFCLK_PAD_N_IN  : in std_logic;
    Q0_CLK1_GTREFCLK_PAD_P_IN  : in std_logic;  
    RXN_IN                     : in std_logic; 
    RXP_IN                     : in std_logic; 
    drp_clk_in                 : in std_logic; 
    --DRP_CLK_IN_P               : in std_logic;		
    --DRP_CLK_IN_N               : in std_logic;	 
    trignum                    : in std_logic_vector(7 downto 0);
    trigdly                    : in std_logic_vector(31 downto 0);
    tbtclk                     : out std_logic;
    fatrig                     : out std_logic;
    satrig                     : out std_logic;
    usrtrig                    : out std_logic;     
    gpstick                    : out std_logic;
    timestamp                  : out std_logic_vector(63 downto 0);    
	DBG_PIN                    : out std_logic_vector(19 downto 0)	
    );
end component;

component Front_end is
    Port (
    
        gain_switch : in STD_LOGIC_VECTOR(3 downto 0);
        sys_clk     : in std_logic;
        ch_latch    : out std_logic;
        ch_cs       : out std_logic;
        ch_sdi      : out std_logic;
        ch_sck      : out std_logic
        
        );
end component;





   signal sys_clk           : std_logic;
   signal fpga_clk          : std_logic;
   signal mach_clk          : std_logic;   
   signal sys_rst           : std_logic;
   signal sys_rstb          : std_logic_vector(0 downto 0);

   signal iobus_addr        : std_logic_vector(15 downto 0);
   signal iobus_cs          : std_logic;
   signal iobus_rnw         : std_logic;
   signal iobus_rddata      : std_logic_vector(31 downto 0);
   signal iobus_wrdata      : std_logic_vector(31 downto 0);
   
   signal iobus_leds        : std_logic_vector(31 downto 0);
        
   signal soft_trig        : std_logic;
   signal burst_enb        : std_logic;
   signal burst_len        : std_logic_vector(31 downto 0);
   signal testdata_enb     : std_logic;
  
   signal adc_testmode      : std_logic_vector(7 downto 0);
   signal adc_testmode_enb  : std_logic;
   signal adc_testmode_rst  : std_logic;
   signal adc_data_valid    : std_logic;
  
   signal adc0_cnv_i        : std_logic;
   signal adc0_sck_i        : std_logic;
     
   signal adc1_sck_i        : std_logic; -- fOR BOARD MISTAKE AJK 
   signal adc2_sck_i        : std_logic; -- fOR BOARD MISTAKE AJK 
   signal adc3_sck_i        : std_logic; -- fOR BOARD MISTAKE AJK 
  
  
   signal adc_ch0		   : std_logic_vector(17 downto 0);
   signal adc_ch1		   : std_logic_vector(17 downto 0); 
   signal adc_ch2		   : std_logic_vector(17 downto 0);
   signal adc_ch3          : std_logic_vector(17 downto 0); 
  
   
   signal adc_cha		    : std_logic_vector(31 downto 0);
   signal adc_chb           : std_logic_vector(31 downto 0); 
   signal adc_chc           : std_logic_vector(31 downto 0);
   signal adc_chd           : std_logic_vector(31 downto 0); 
   signal adc_cha_ave	    : std_logic_vector(31 downto 0);
   signal adc_chb_ave       : std_logic_vector(31 downto 0); 
   signal adc_chc_ave       : std_logic_vector(31 downto 0);
   signal adc_chd_ave       : std_logic_vector(31 downto 0);    
   
   signal tenhz_trignum       : std_logic_vector(31 downto 0);     
   

   signal hs_ddr_baseaddr   : std_logic_vector( 31 downto 0 );
   signal hs_ddr_curaddr    : std_logic_vector( 31 downto 0 );   
   signal hs_fifo_rdcnt     : std_logic_vector ( 9 downto 0 );
   signal hs_fifo_rddata    : std_logic_vector ( 63 downto 0 );
   signal hs_fifo_empty     : std_logic;
   signal hs_fifo_rden      : std_logic;
   signal hs_fifo_rst       : std_logic;
   signal hs_tx_enb         : std_logic;
   signal hs_tx_active      : std_logic;
   signal hs_axi_tx_active  : std_logic;
   signal axi_hp_cntrl_reg  : std_logic_vector(15 downto 0);   
   
   signal tenhz_cnt        : std_logic_vector(31 downto 0);
   signal tenhz_divide     : std_logic_vector(31 downto 0);
   signal tenhz_irqenb     : std_logic;
   signal tenhz_irq        : std_logic;  
   signal other_irq        : std_logic;
   signal iobus_dbg        : std_logic_vector(31 downto 0);
   
   signal dac8814_sclk_i    : std_logic;
   signal dac8814_sdi_i     : std_logic;
   signal dac8814_csn_i     : std_logic;
   signal dac8814_ldacn_i   : std_logic;

   signal dac8814_data      : std_logic_vector(31 downto 0);
   signal dac8814_we        : std_logic;
   signal dac8814_cntrl     : std_logic_vector(1 downto 0);

   signal ad5060_data       : std_logic_vector(31 downto 0);
   signal ad5060_we         : std_logic;
   signal ad5060_sclk_i     : std_logic;                    
   signal ad5060_din_i      : std_logic;
   signal ad5060_sync_i     : std_logic;

   signal ad5754_data       : std_logic_vector(31 downto 0);
   signal ad5754_we         : std_logic;
--   signal ad5754_sclk       : std_logic;                    
--   signal ad5754_din        : std_logic;
--   signal ad5754_sync       : std_logic;
--   signal ad5754_ldac       : std_logic;
--   signal ad5754_clrn       : std_logic;
--   signal ad5754_bin2s      : std_logic;


   signal dfe_temp0              : std_logic_vector(15 downto 0);
   signal dfe_temp1              : std_logic_vector(15 downto 0);
   signal dfe_temp2               : std_logic_vector(15 downto 0);
   signal dfe_temp3              : std_logic_vector(15 downto 0);    
   signal dfe_temp_debug     : std_logic_vector(7 downto 0);    

   signal afe_temp0              : std_logic_vector(15 downto 0);
   signal afe_temp1              : std_logic_vector(15 downto 0);
   signal afe_temp_debug     : std_logic_vector(7 downto 0); 
   
   signal kx,ky             : std_logic_vector(31 downto 0);
   
   signal sa_trig_stretch    : std_logic;
   signal evr_gpstick_stretch : std_logic;
   signal evr_usrtrig_stretch : std_logic;
   
   signal ext_tbtclk        : std_logic;
   signal mach_clk_sel      : std_logic_vector(1 downto 0);
   signal clk_cnt           : unsigned(7 downto 0);
   
   signal machclk_divide        : std_logic_vector(7 downto 0);
 
   signal trig_clear            : std_logic;
   signal trig_status           : std_logic_vector(1 downto 0);
   signal trig_active           : std_logic;
   
   signal tenkhzdata_tmode     : std_logic;
   --signal tenkhzdata_enb       : std_logic;
   signal tenkhzdata_rdstr     : std_logic;
   signal tenkhzdata_dout      : std_logic_vector(31 downto 0);
   signal tenkhzdata_rdcnt     : std_logic_vector(31 downto 0);
   signal tenkhzdata_fiforst   : std_logic;
   signal tenkhz_divide        : std_logic_vector(31 downto 0);
   
   signal evr_dbg               : std_logic_vector(19 downto 0);
   signal evr_tbtclk            : std_logic;
   signal evr_fatrig            : std_logic;
   signal evr_satrig            : std_logic;
   signal evr_usrtrig           : std_logic;
   signal evr_gpstick           : std_logic;
   signal evr_timestamp         : std_logic_vector(63 downto 0);
   signal evr_timestamplat      : std_logic_vector(63 downto 0);
   signal evr_trignum           : std_logic_vector(7 downto 0);
   signal evr_trigdly           : std_logic_vector(31 downto 0);
   
   signal fa_trig                : std_logic;
   signal sa_trig                : std_logic;
   
   signal adcbias_sdi           : std_logic;   
   signal adc_bias              : std_logic_vector(17 downto 0);
   signal adc_bias_se           : std_logic_vector(31 downto 0);    
  
   signal gain_sw               : std_logic_vector(31 downto 0);
   signal gain_switch           : std_logic_vector(4 downto 0);  
   signal gain_sw_cha           : std_logic_vector(4 downto 0);
   signal gain_sw_chb           : std_logic_vector(4 downto 0);
   signal gain_sw_chc           : std_logic_vector(4 downto 0);
   signal gain_sw_chd           : std_logic_vector(4 downto 0);
   
   signal Cha_latch_i           : std_logic;
   signal Cha_cs_i              : std_logic;
   signal Cha_sck_i             : std_logic;
   signal Cha_sdi_i             : std_logic;
   
   signal Chb_latch_i           : std_logic;
   signal Chb_cs_i              : std_logic;
   signal Chb_sck_i             : std_logic;
   signal Chb_sdi_i             : std_logic;
   
   signal Chc_latch_i           : std_logic;
   signal Chc_cs_i              : std_logic;
   signal Chc_sck_i             : std_logic;
   signal Chc_sdi_i             : std_logic;
   
   signal Chd_latch_i           : std_logic;
   signal Chd_cs_i              : std_logic;
   signal Chd_sck_i             : std_logic;
   signal Chd_sdi_i             : std_logic;

             
--   --debug signals (connect to ila)
    attribute mark_debug                 : string;
    attribute mark_debug of adc0_cnv_i      : signal is "true";
    attribute mark_debug of adc0_sck_i      : signal is "true";
    attribute mark_debug of adc0_busy      : signal is "true";
    attribute mark_debug of adc0_sdo      : signal is "true";    
    
    attribute mark_debug of adc_ch0         : signal is "true";
    attribute mark_debug of adc_ch1         : signal is "true";
    attribute mark_debug of adc_ch2         : signal is "true";
    attribute mark_debug of adc_ch3         : signal is "true";    
    attribute mark_debug of adc_data_valid  : signal is "true";
    
    
    --attribute mark_debug of evr_tbtclk    : signal is "true";
    --attribute mark_debug of evr_fatrig    : signal is "true";
    --attribute mark_debug of evr_satrig    : signal is "true";
    --attribute mark_debug of evr_usrtrig   : signal is "true";  
    --attribute mark_debug of evr_timestamp : signal is "true";  
        
    --attribute mark_debug of soft_trig     : signal is "true";  
    --attribute mark_debug of trig_clear    : signal is "true";          
    --attribute mark_debug of trig_active   : signal is "true";  
    --attribute mark_debug of trig_status   : signal is "true";   
    

    --attribute mark_debug of fa_trig        : signal is "true";
    --attribute mark_debug of sa_trig        : signal is "true";
    --attribute mark_debug of tenhz_trignum  : signal is "true";



    
    
  --dbg(14) <= adcbias_busy; --input 
    --dbg(15) <= adcbias_cnv;  --output
    --dbg(16) <= adcbias_sdo;  --input
    --dbg(17) <= adcbias_sck;  --output    
        
--    attribute mark_debug of tenhz_cnt    : signal is "true";       
--    attribute mark_debug of tenhz_divide : signal is "true";   
--    attribute mark_debug of tenhz_irqenb : signal is "true";  
--    attribute mark_debug of tenhz_trig   : signal is "true";
--    attribute mark_debug of tenhz_irq    : signal is "true";    
--    attribute mark_debug of other_irq    : signal is "true";     
   
----   attribute mark_debug     : string;
   attribute mark_debug of iobus_addr: signal is "true";
   attribute mark_debug of iobus_cs: signal is "true";  
   attribute mark_debug of iobus_rnw: signal is "true";
   attribute mark_debug of iobus_wrdata: signal is "true";
   attribute mark_debug of iobus_rddata: signal is "true";
--   attribute mark_debug of sys_rst: signal is "true";
--   attribute mark_debug of trig: signal is "true";

--   attribute mark_debug of burst_len : signal is "true";
 
--   attribute mark_debug of hs_fifo_rdcnt : signal is "true";
--   attribute mark_debug of hs_fifo_rddata : signal is "true";  
--   attribute mark_debug of hs_fifo_rden : signal is "true";
--   attribute mark_debug of hs_tx_active : signal is "true";
--   attribute mark_debug of hs_axi_tx_active : signal is "true";  
--   attribute mark_debug of hs_tx_enb : signal is "true";
--   attribute mark_debug of hs_ddr_baseaddr : signal is "true";
--   attribute mark_debug of hs_ddr_curaddr : signal is "true";  
--   attribute mark_debug of iobus_dbg : signal is "true";   
----   attribute mark_debug of adc_ch1 : signal is "true";
----   attribute mark_debug of ext_clk : signal is "true";
   attribute mark_debug of Cha_latch_i: signal is "true";
   attribute mark_debug of Cha_cs_i: signal is "true";
   attribute mark_debug of Cha_sck_i: signal is "true";
   attribute mark_debug of Cha_sdi_i: signal is "true";
   

begin

----debug header (debug pins 0-6 are now used for motor controller DAC on AFE Daughterboard
--dbg(0) <= ad5754_sync;
--dbg(1) <= ad5754_sclk;  
--dbg(2) <= ad5754_din;
--dbg(3) <= '0';  --connects to ad5754_sdo, but disconnected for now since it was +5v on DAC DB. 
--dbg(4) <= ad5754_ldac;
--dbg(5) <= ad5754_clrn;  
--dbg(6) <= ad5754_bin2s;

----debug header (debug pins 14-17 are now used for BIAS adc on AFE) 
--dbg(14) <= adcbias_busy; --input 
--dbg(15) <= adcbias_cnv;  --output
--dbg(16) <= adcbias_sdo;  --input
--dbg(17) <= adcbias_sck;  --output 

Cha_latch <=  Cha_latch_i;
Cha_cs <=  Cha_cs_i;
Cha_sck <=  Cha_sck_i;
Cha_sdi <=  Cha_sdi_i;

Chb_latch <=  Chb_latch_i;
Chb_cs <=  Chb_cs_i;
Chb_sck <=  Chb_sck_i;
Chb_sdi <=  Chb_sdi_i;

Chc_latch <=  Chc_latch_i;
Chc_cs <=  Chc_cs_i;
Chc_sck <=  Chc_sck_i;
Chc_sdi <=  Chc_sdi_i;

Chd_latch <=  Chd_latch_i;
Chd_cs <=  Chd_cs_i;
Chd_sck <=  Chd_sck_i;
Chd_sdi <=  Chd_sdi_i;


--************** Debug assignments *******************

dbg(0) <= Cha_latch_i; --fa_trig;      --dbg(7)
dbg(1) <= Cha_cs_i; --evr_tbtclk;   --dbg(8)
dbg(2) <= Cha_sck_i; --mach_clk; --sys_clk;      --dbg(9) 
dbg(3) <= Cha_sdi_i; --'0'; --mach_clk;    --dbg(10)
dbg(4) <= sys_clk; --'0'; --ext_tbtclk;  --dbg(11)
dbg(5) <= adc0_cnv_i;  --evr_gpstick; --dbg(12)
dbg(6) <= adc0_sck_i; --sa_trig;     --dbg(13)
dbg(7) <= adc0_busy; --evr_fatrig;  --dbg(18)  
dbg(8) <= adc0_sdo;   --evr_satrig;  --dbg(19) 


--fp_leds <= iobus_leds(3 downto 0);

fp_leds(0) <= trig_active;      --upper right LED
fp_leds(1) <= adc1_sck_i; --iobus_leds(1);    --bottom right LED
fp_leds(2) <= adc2_sck_i; --sa_trig_stretch;  --upper left LED
fp_leds(3) <= adc3_sck_i; --iobus_leds(0);    --bottom left LED

gain_sw_cha <= gain_sw(4 downto 0);
gain_sw_chb <= gain_sw(12 downto 8);
gain_sw_chc <= gain_sw(20 downto 16);
gain_sw_chd <= gain_sw(28 downto 24);



sys_rst <= sys_rstb(0);

sfp_leds <= iobus_leds(7 downto 4);
--sfp_leds(0) <= evr_gpstick_stretch when (mach_clk_sel = "10") else '0';
--sfp_leds(1) <= evr_usrtrig_stretch when (mach_clk_sel = "10") else '0';
--sfp_leds(11 downto 2) <= (others => '0'); 


adc0_cnv <= adc0_cnv_i;
adc0_sck <= adc0_sck_i;


ad5060_sclk    <= ad5060_sclk_i; 
ad5060_din     <= ad5060_din_i; 
ad5060_sync    <= ad5060_sync_i;   



-- generate interrupt
tenhz_irq <= sa_trig when (tenhz_irqenb = '1') else '0';
other_irq <= tenhz_irq;







---- Embedded event receiver
evr: evr_top
  port map (
    Q0_CLK1_GTREFCLK_PAD_N_IN    => gtx_refclk_n,	-- 312.5 MHz
    Q0_CLK1_GTREFCLK_PAD_P_IN    => gtx_refclk_p,  
    RXN_IN                       => gtx_rx_n, 
    RXP_IN                       => gtx_rx_p,  
    drp_clk_in                   => sys_clk, 
    --DRP_CLK_IN_P                 => fpga_clk_p,		
    --DRP_CLK_IN_N                 => fpga_clk_n,
    trignum                      => evr_trignum,
    trigdly                      => evr_trigdly,
    tbtclk                       => evr_tbtclk,
    fatrig                       => evr_fatrig,
    satrig                       => evr_satrig,
    usrtrig                      => evr_usrtrig,
    gpstick                      => evr_gpstick,
    timestamp                    => evr_timestamp, 
	DBG_PIN                      => evr_dbg	
    );


clk_logic:  entity work.clk_cntrl
   port map(
     clk                    => sys_clk,
     reset                  => sys_rst,
     
     mach_clk_sel           => mach_clk_sel,
     machclk_divide         => machclk_divide,
     tenkhz_divide          => tenkhz_divide,
     tenhz_divide           => tenhz_divide,
     
     ext_tbtclk             => ext_tbtclk,     
     evr_tbtclk             => evr_tbtclk,
     evr_fatrig             => evr_fatrig,
     evr_satrig             => evr_satrig,

     mach_clk               => mach_clk,
     fa_trig                => fa_trig,
     sa_trig                => sa_trig
);


trig_logic : entity work.trig_cntrl
  port map(
     clk                    => sys_clk,
     reset                  => sys_rst,
     
     mach_clk_sel           => mach_clk_sel,     
     trig_clear             => trig_clear,    
     soft_trig              => soft_trig,
     evr_trig               => evr_usrtrig,
     evr_timestamp          => evr_timestamp,
     
     evr_timestamplat       => evr_timestamplat,
     trig_status            => trig_status,
     trig_active            => trig_active
     );




tenkhz : entity work.stream10kdata
  port map(
     mach_clk               => mach_clk, 
     sys_clk                => sys_clk, 
     reset                  => sys_rst,  
     
     tenkhz_trig            => fa_trig,
     
     testmode               => tenkhzdata_tmode, 
     tenkhzdata_enb         => trig_active, 
     tenkhzdata_fiforst     => tenkhzdata_fiforst,

	 adc_ch0			    => adc_ch0, 
	 adc_ch1			    => adc_ch1, 
	 adc_ch2			    => adc_ch2, 
	 adc_ch3			    => adc_ch3, 	 
	 
	 fifo_rdstr             => tenkhzdata_rdstr, 
	 fifo_dout              => tenkhzdata_dout, 
	 fifo_rdcnt             => tenkhzdata_rdcnt	 	    
    );






ave10hz : entity work.tenhzave 
  port map(
     clk				    => sys_clk, 
     mach_clk               => mach_clk, 
     reset                  => sys_rst, 
     
	 tenhz_trig             => sa_trig, 
	 
	 adc_data_valid         => adc_data_valid, 
	 adc_ch0			    => adc_ch0, 
	 adc_ch1			    => adc_ch1, 
	 adc_ch2			    => adc_ch2, 
	 adc_ch3			    => adc_ch3,	 
	 
	 tenhz_trignum          => tenhz_trignum,
	 
	 adc_cha                => adc_cha, 
     adc_chb                => adc_chb,  
     adc_chc                => adc_chc, 
     adc_chd                => adc_chd, 	
	  
	 adc_cha_ave            => adc_cha_ave, 
	 adc_chb_ave            => adc_chb_ave,  
	 adc_chc_ave            => adc_chc_ave, 
	 adc_chd_ave            => adc_chd_ave	 
	 	    
    );




adc_testmode_enb <= adc_testmode(0); 
adc_testmode_rst <= adc_testmode(1); 






readadc_ch0 : entity work.ltc2379 
    port map(
        clk				    => sys_clk, 
        adc_clk             => mach_clk, 
        reset               => sys_rst, 

	    testmode_enb	    => adc_testmode_enb,
	    testmode_rst        => adc_testmode_rst,
	    
	    adc_sdo	  	        => adc0_sdo, 
	    adc_busy            => adc0_busy, 
	    adc_cnv			    => adc0_cnv_i, 
	    adc_sck			    => adc0_sck_i, 
	    adc_sdi             => open,
	   
	    adc_data		    => adc_ch0, 
        adc_data_valid      => adc_data_valid 
        );


readadc_ch1 : entity work.ltc2379 
    port map(
        clk				    => sys_clk, 
        adc_clk             => mach_clk, 
        reset               => sys_rst, 

	    testmode_enb	    => adc_testmode_enb,
	    testmode_rst        => adc_testmode_rst,
	    
	    adc_sdo	  	        => adc1_sdo, 
	    adc_busy            => adc1_busy, 
	    adc_cnv			    => adc1_cnv, 
	    adc_sck			    => adc1_sck_i, -- for board mistake AJK
	    adc_sdi             => open,
	   
	    adc_data		    => adc_ch1, 
        adc_data_valid      => open
        );
 
readadc_ch2 : entity work.ltc2379 
    port map(
        clk				    => sys_clk, 
        adc_clk             => mach_clk, 
        reset               => sys_rst, 

        testmode_enb	    => adc_testmode_enb,
        testmode_rst        => adc_testmode_rst,
    
        adc_sdo	  	        => adc2_sdo, 
        adc_busy            => adc2_busy, 
        adc_cnv			    => adc2_cnv, 
        adc_sck			    => adc2_sck_i,  -- for board mistake AJK
        adc_sdi             => open,
   
        adc_data		    => adc_ch2, 
        adc_data_valid      => open
       );

readadc_ch3 : entity work.ltc2379 
    port map(
        clk				    => sys_clk, 
        adc_clk             => mach_clk, 
        reset               => sys_rst, 

        testmode_enb	    => adc_testmode_enb,
        testmode_rst        => adc_testmode_rst,
   
        adc_sdo	  	        => adc3_sdo, 
        adc_busy            => adc3_busy, 
        adc_cnv			    => adc3_cnv, 
        adc_sck			    => adc3_sck_i,  -- for board mistake AJK
        adc_sdi             => open,
  
        adc_data		    => adc_ch3, 
        adc_data_valid      => open
      );






bias_cntrl : entity work.ad5060_spi  
    port map(
        clk                 => sys_clk,                     
        reset  	            => sys_rst,                     
        we		            => ad5060_we,
        wrdata	            => ad5060_data,

        sclk                => ad5060_sclk_i,                    
        din 	            => ad5060_din_i,
        sync                => ad5060_sync_i                 
        );   


motor_cntrl :  entity work.ad5754_spi
    port map (
        clk                 => sys_clk,                     
        reset  	            => sys_rst,                      
        we		            => ad5754_we, 
        wrdata	            => ad5754_data, 

        sclk                => ad5754_sclk,                    
        din 	            => ad5754_din, 
        sync                => ad5754_sync,
        clrn                => ad5754_clrn,
        bin2s               => ad5754_bin2s                  
        );    



iobus_io : entity work.iobus_interface 
    generic map (
      FPGA_VERSION          => FPGA_VERSION
        )
    port map ( 
		clk       			=> sys_clk,
        rst         		=> sys_rst, 	 
        addr      			=> iobus_addr,
        cs          		=> iobus_cs, 
        rnw         		=> iobus_rnw, 
        wrdata      		=> iobus_wrdata, 
        rddata      		=> iobus_rddata, 			  

		soft_trig		    => soft_trig,
		trig_status         => trig_status,
		trig_clear          => trig_clear,
        	 
		testdata_en         => testdata_enb,
		adcburstlen         => burst_len,
		adcburstenb         => burst_enb, 

        ddr_baseaddr        => hs_ddr_baseaddr, 
        
        machclk_divide      => machclk_divide,        
        		
  	    tenhz_divide        => tenhz_divide, 
  	    tenhz_irqenb        => tenhz_irqenb, 	
  	    
  	    tenkhz_divide       => tenkhz_divide,
        tenkhzdata_tmode    => tenkhzdata_tmode,   
   	    tenkhzdata_fiforst  => tenkhzdata_fiforst,     
        tenkhzdata_rdstr    => tenkhzdata_rdstr, 
        tenkhzdata_dout     => tenkhzdata_dout, 
        tenkhzdata_rdcnt    => tenkhzdata_rdcnt, 
  	    
		adc_testmode        => adc_testmode, 
				
		axi_hp_cntrl_reg    => axi_hp_cntrl_reg,
		
		dac8814_data        => dac8814_data, 
        dac8814_we          => dac8814_we, 
		dac8814_cntrl       => dac8814_cntrl,
		
		ad5060_data         => ad5060_data, 
        ad5060_we           => ad5060_we, 		
  
 		ad5754_data         => ad5754_data, 
        ad5754_we           => ad5754_we,                
        ad5754_ldac         => ad5754_ldac, 
                
 	    adc_cha             => adc_cha,
        adc_chb             => adc_chb, 
        adc_chc             => adc_chc, 
        adc_chd             => adc_chd,  
        
        adc_cha_ave         => adc_cha_ave,
        adc_chb_ave         => adc_chb_ave,
        adc_chc_ave         => adc_chc_ave,
        adc_chd_ave         => adc_chd_ave,
                       
        tenhz_trignum       => tenhz_trignum,        
	
        dfe_temp0           => dfe_temp0,
        dfe_temp1           => dfe_temp1,
        dfe_temp2           => dfe_temp2,
        dfe_temp3           => dfe_temp3,
        afe_temp0           => afe_temp0,
        afe_temp1           => afe_temp1,	
	
	         		
		gain_sw             => gain_sw,
		leds				=> iobus_leds,
		
		mach_clk_sel        => mach_clk_sel,
		
		evr_timestamp       => evr_timestamp,
		evr_timestamplat    => evr_timestamplat,
		evr_trignum         => evr_trignum,
		evr_trigdly         => evr_trigdly,
		
		adc_bias            => adc_bias_se,
		
		kx                  => kx,
		ky                  => ky
		);







hs_fifo_rst <= '1';

hsdata: entity work.data2ddr 
    port map (
      sys_clk          	            => sys_clk,
      adc_clk                       => mach_clk,
      reset      			        => sys_rst,                     
      trig		 		            => '0',  --softtrig,
	  burst_enb		                => burst_enb,
	  burst_len		                => burst_len,
	  testdata_en  		            => testdata_enb,	 
	 
	  adc_ch0				        => (x"000" & "00" & adc_ch0), 
	  adc_ch1				        => (x"000" & "00" & adc_ch1),
	  adc_ch2				        => (x"000" & "00" & adc_ch2), 
	  adc_ch3				        => (x"000" & "00" & adc_ch3), 
	  
      hs_fifo_rdcnt                 => hs_fifo_rdcnt,
      hs_fifo_rddata                => hs_fifo_rddata, 
      hs_fifo_empty                 => hs_fifo_empty,
      hs_fifo_rden                  => hs_fifo_rden, 
      hs_fifo_rst                   => hs_fifo_rst,
      hs_tx_enb                     => hs_tx_enb,   
      hs_tx_active                  => hs_tx_active   
   
  );    





system_i: component system
    port map (
      ddr_addr(14 downto 0)         => ddr_addr(14 downto 0),
      ddr_ba(2 downto 0)            => ddr_ba(2 downto 0),
      ddr_cas_n                     => ddr_cas_n,
      ddr_ck_n                      => ddr_ck_n,
      ddr_ck_p                      => ddr_ck_p,
      ddr_cke                       => ddr_cke,
      ddr_cs_n                      => ddr_cs_n,
      ddr_dm(3 downto 0)            => ddr_dm(3 downto 0),
      ddr_dq(31 downto 0)           => ddr_dq(31 downto 0),
      ddr_dqs_n(3 downto 0)         => ddr_dqs_n(3 downto 0),
      ddr_dqs_p(3 downto 0)         => ddr_dqs_p(3 downto 0),
      ddr_odt                       => ddr_odt,
      ddr_ras_n                     => ddr_ras_n,
      ddr_reset_n                   => ddr_reset_n,
      ddr_we_n                      => ddr_we_n,
      fixed_io_ddr_vrn              => fixed_io_ddr_vrn,
      fixed_io_ddr_vrp              => fixed_io_ddr_vrp,
      fixed_io_mio(53 downto 0)     => fixed_io_mio(53 downto 0),
      fixed_io_ps_clk               => fixed_io_ps_clk,
      fixed_io_ps_porb              => fixed_io_ps_porb,
      fixed_io_ps_srstb             => fixed_io_ps_srstb,
      sys_clk                       => sys_clk,
      sys_rst                       => sys_rstb,
      iobus_addr(15 downto 0)       => iobus_addr(15 downto 0),      
      iobus_cs                      => iobus_cs,
      iobus_data_pl2ps(31 downto 0) => iobus_rddata(31 downto 0),
      iobus_data_ps2pl(31 downto 0) => iobus_wrdata(31 downto 0),
      iobus_rnw                     => iobus_rnw,
      hs_ddr_baseaddr               => hs_ddr_baseaddr, 
      hs_ddr_curaddr                => hs_ddr_curaddr,
      hs_fifo_rdcnt                 => hs_fifo_rdcnt(8 downto 0), 
      hs_fifo_rddata                => hs_fifo_rddata,
      hs_fifo_rden                  => hs_fifo_rden, 
      hs_tx_active                  => hs_axi_tx_active, 
      hs_tx_enb                     => hs_tx_enb,
      tenhz_irq                     => tenhz_irq,
      other_irq                     => other_irq 
      
    );
    
Front_end_cha : entity work.Front_end
        port map (               
            gain_switch  => gain_sw_cha,
            sys_clk      => mach_clk, --sys_clk, slow down clock!
            ch_latch     => Cha_latch_i,
            ch_cs        => Cha_cs_i,
            ch_sdi       => Cha_sdi_i,
            ch_sck       => Cha_sck_i       
            );

Front_end_chb : entity work.Front_end
                    port map (               
                        gain_switch  => gain_sw_chb,
                        sys_clk      => mach_clk, --sys_clk, slow down clock!
                        ch_latch     => Chb_latch_i,
                        ch_cs        => Chb_cs_i,
                        ch_sdi       => Chb_sdi_i,
                        ch_sck       => Chb_sck_i       
                        );

Front_end_chc : entity work.Front_end
        port map (               
            gain_switch  => gain_sw_chc,
            sys_clk      => mach_clk, --sys_clk, slow down clock!
            ch_latch     => Chc_latch_i,
            ch_cs        => Chc_cs_i,
            ch_sdi       => Chc_sdi_i,
            ch_sck       => Chc_sck_i       
            );

Front_end_chd : entity work.Front_end
                    port map (               
                        gain_switch  => gain_sw_chd,
                        sys_clk      => mach_clk, --sys_clk, slow down clock!
                        ch_latch     => Chd_latch_i,
                        ch_cs        => Chd_cs_i,
                        ch_sdi       => Chd_sdi_i,
                        ch_sck       => Chd_sck_i       
                        );
    




stretch_1 : entity work.stretch
	port map (
	    clk                 => sys_clk,
	  	reset               => sys_rst, 
	  	sig_in              => sa_trig, 
	  	len                 => 1000000, -- ~25ms;
	  	sig_out             => sa_trig_stretch
	  	);	  	


stretch_2 : entity work.stretch
	port map (
	    clk                 => sys_clk,
	  	reset               => sys_rst, 
	  	sig_in              => evr_gpstick, 
	  	len                 => 1000000, -- ~25ms;
	  	sig_out             => evr_gpstick_stretch
	  	);	  	 
 
stretch_3 : entity work.stretch
    port map (
        clk                 => sys_clk,
        reset               => sys_rst, 
        sig_in              => evr_usrtrig, 
        len                 => 1000000, -- ~25ms;
        sig_out             => evr_usrtrig_stretch
        );           
 
    
    
end behv;
