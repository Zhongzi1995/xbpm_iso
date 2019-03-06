-------------------------------------------------------------------------------
-- Title         : AXI Data Generator
-------------------------------------------------------------------------------
-- File          : axi_data_gen.vhd
-- Author        : Joseph Mead  mead@bnl.gov
-- Created       : 01/11/2013
-------------------------------------------------------------------------------
-- Description:
-- Provides logic to send adc or test data to FIFO interface.
-- A testdata_en input permits test counters to be sent for verification 
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Modification history:
-- 01/11/2013: created.
-------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
  
entity data2ddr is
  
  port (
    sys_clk          	: in  std_logic;
    adc_clk             : in  std_logic;
    reset     			: in  std_logic;                       
    trig		 		: in  std_logic;
	burst_enb		    : in  std_logic;
	burst_len		    : in  std_logic_vector(31 downto 0);
	testdata_en  		: in  std_logic;	 
	 
	adc_ch0				: in  std_logic_vector(31 downto 0);
	adc_ch1				: in  std_logic_vector(31 downto 0);
	adc_ch2				: in  std_logic_vector(31 downto 0);
	adc_ch3				: in  std_logic_vector(31 downto 0);
	  
    hs_fifo_rdcnt       : out std_logic_vector ( 9 downto 0 );
    hs_fifo_rddata      : out std_logic_vector ( 63 downto 0 );
    hs_fifo_empty       : out std_logic;
    hs_fifo_rden        : in std_logic;
    hs_fifo_rst         : in  std_logic;
    hs_tx_enb           : out std_logic;
    hs_tx_active        : out std_logic      
     
  );    

end data2ddr;

architecture rtl of data2ddr is



component hsfifo
  port (
    rst             : in std_logic; 
    wr_clk          : in std_logic; 
    rd_clk          : in std_logic; 
    din             : in std_logic_vector(127 DOWNTO 0);
    wr_en           : in std_logic; 
    rd_en           : in std_logic; 
    dout            : out std_logic_vector(63 DOWNTO 0);
    full            : out std_logic;
    empty           : out std_logic;
    rd_data_count   : out std_logic_vector(9 DOWNTO 0);
    wr_data_count   : out std_logic_vector(8 DOWNTO 0)
  );
end component; 




  type     state_type is (IDLE, ACTIVE, HOLD);                    
  signal   state      : state_type;
  

  signal len			   : std_logic_vector(31 downto 0);
  signal testdata		   : std_logic_vector(63 downto 0); 
  
  signal data_wren_i	   : std_logic;   

  signal strobe_lat		   : std_logic;
  signal tx_active		   : std_logic;
  signal dlycnt            : INTEGER;
  
  signal adc_se_ch0        : std_logic_vector(31 downto 0);
  signal adc_se_ch1        : std_logic_vector(31 downto 0);
  signal adc_se_ch2        : std_logic_vector(31 downto 0);
  signal adc_se_ch3        : std_logic_vector(31 downto 0);
  
  signal fifo_din          : std_logic_vector(127 downto 0);
  signal fifo_full         : std_logic;
  signal fifo_wrcnt        : std_logic_vector(8 downto 0);

begin  

--sign extend to 32 bits
--adc_se_ch0(31 downto 18) <= (others => adc_ch0(17));
--adc_se_ch0(17 downto 0)  <= adc_ch0;

--adc_se_ch1(31 downto 18) <= (others => adc_ch1(17));
--adc_se_ch1(17 downto 0)  <= adc_ch1;

--adc_se_ch2(31 downto 18) <= (others => adc_ch2(17));
--adc_se_ch2(17 downto 0)  <= adc_ch2;

--adc_se_ch3(31 downto 18) <= (others => adc_ch3(17));
--adc_se_ch3(17 downto 0)  <= adc_ch3;


fifo_din <= adc_ch1 & adc_ch0 & adc_ch3 & adc_ch2;
--fifo_din <= adc_se_ch3 & adc_se_ch2 & adc_se_ch1 & adc_se_ch0;

hs_tx_active <= tx_active;

u0fifo: hsfifo
  port map (
    rst             => hs_fifo_rst,
    wr_clk          => adc_clk,
    rd_clk          => sys_clk,
    din             => fifo_din,
    wr_en           => tx_active, 
    rd_en           => hs_fifo_rden,
    dout            => hs_fifo_rddata,
    full            => fifo_full,
    empty           => hs_fifo_empty,
    rd_data_count   => hs_fifo_rdcnt, 
    wr_data_count   => fifo_wrcnt
  );




  --latch store_data trigger
  process (trig, tx_active, reset)
   begin
      if (reset = '1') OR (tx_active = '1') then
	     strobe_lat <= '0';
      elsif (trig'event and trig = '1') then
	      if (burst_enb = '1') then
		      strobe_lat <= '1';
			end if;
		end if;
   end process;



  --write burst_len adc samples to axi
  process (adc_clk, reset)
  begin  
    if (reset = '1') then 	
        hs_tx_enb          <= '0';         
        testdata <= (others => '0'); 
		state <= IDLE;
		len <= (others => '0');
		tx_active <= '0';
		dlycnt <= 300;
	  
    elsif (adc_clk'event and adc_clk = '1') then  
      case state is
        when IDLE =>       
            if (strobe_lat = '1') then 
				tx_active <= '1';
				hs_tx_enb <= '1';
				len <= burst_len;
                state <= active; 
            end if;

        when ACTIVE =>  
			if (len = x"00000000") then
				state <= hold;
				dlycnt <= 300;
				tx_active <= '0';
			else
			    len <= len - 1;
			    testdata <= testdata + 1;	
			end if;	
			
		when HOLD => 
		    if (dlycnt = 0) then
		       hs_tx_enb <= '0';
		       state <= idle;	
		    else
		       dlycnt <= dlycnt - 1;
		    end if;
		    
		    				
        when others =>
            state <= IDLE;
      end case;
    end if;
  end process;



  --synchronize hs_tx_enb to sys_clk domain
--  process (sys_clk, reset)
--   begin
--      if (reset = '1') OR (tx_active = '1') then
--	     strobe_lat <= '0';
--      elsif (trig'event and trig = '1') then
--	      if (burst_enb = '1') then
--		      strobe_lat <= '1';
--			end if;
--		end if;
--   end process;



  
end rtl;
