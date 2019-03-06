-- Stream10kdata.vhd
--
--  This module will average the frev adc data and then buffer in a fifo to be readout by the iobus
--
--


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


library UNISIM;
use UNISIM.VComponents.all;



entity stream10kdata is
  port(
     mach_clk           : in std_logic;
     sys_clk            : in std_logic;
     reset              : in std_logic;

     tenkhz_trig        : in std_logic;
     
     testmode           : in std_logic;
     tenkhzdata_enb     : in std_logic;
     tenkhzdata_fiforst : in std_logic;

	 adc_ch0			: in std_logic_vector(17 downto 0);
	 adc_ch1			: in std_logic_vector(17 downto 0);
	 adc_ch2			: in std_logic_vector(17 downto 0);
	 adc_ch3			: in std_logic_vector(17 downto 0);	 	 
	 
	 fifo_rdstr         : in  std_logic;
	 fifo_dout          : out std_logic_vector(31 downto 0);
	 fifo_rdcnt         : out std_logic_vector(31 downto 0)
	 	    
    );

end stream10kdata;


architecture behv of stream10kdata is


component fifo_generator_0
  PORT (
    rst                     : IN STD_LOGIC;
    wr_clk                  : IN STD_LOGIC;
    rd_clk                  : IN STD_LOGIC;
    din                     : IN STD_LOGIC_VECTOR(127 DOWNTO 0);
    wr_en                   : IN STD_LOGIC;
    rd_en                   : IN STD_LOGIC;
    dout                    : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    full                    : OUT STD_LOGIC;
    empty                   : OUT STD_LOGIC;
    rd_data_count           : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
  );
end component;




    signal tenkhz_cnt       : unsigned(31 downto 0);
    
    signal adc_ch0_se       : std_logic_vector(31 downto 0);
    signal adc_ch1_se       : std_logic_vector(31 downto 0);
    signal adc_ch2_se       : std_logic_vector(31 downto 0);
    signal adc_ch3_se       : std_logic_vector(31 downto 0); 
    
    signal adc_ch0_lat      : std_logic_vector(31 downto 0);
    signal adc_ch1_lat      : std_logic_vector(31 downto 0);
    signal adc_ch2_lat      : std_logic_vector(31 downto 0);
    signal adc_ch3_lat      : std_logic_vector(31 downto 0);    
    
    signal adc_ch0_sum      : signed(31 downto 0);  
    signal adc_ch1_sum      : signed(31 downto 0);     
    signal adc_ch2_sum      : signed(31 downto 0); 
    signal adc_ch3_sum      : signed(31 downto 0); 
    
    signal fifo_din         : std_logic_vector(127 downto 0);  
    
    signal fifo_full        : std_logic;
    signal fifo_empty       : std_logic;
    signal fifo_rd_data_cnt : std_logic_vector(15 downto 0);
    
    signal tst_data         : unsigned(31 downto 0);
    
    signal fifo_rdstr_prev  : std_logic;
    signal fifo_rdstr_fe    : std_logic;
    signal fifo_wrstr       : std_logic;
     

begin
  
  

fifo_rdcnt  <= x"0000" & fifo_rd_data_cnt;

-- sign extend the inputs
adc_ch0_se <= (31 downto 18 => adc_ch0(17)) & adc_ch0;
adc_ch1_se <= (31 downto 18 => adc_ch1(17)) & adc_ch1;
adc_ch2_se <= (31 downto 18 => adc_ch2(17)) & adc_ch2;
adc_ch3_se <= (31 downto 18 => adc_ch3(17)) & adc_ch3;  



--since fifo is fall-through mode, want the rdstr
--to happen after the current word is read.
process (reset,sys_clk)
   begin
       if (reset = '1') then
          fifo_rdstr_prev <= '0';
          fifo_rdstr_fe <= '0';
       elsif (sys_clk'event and sys_clk = '1') then
          fifo_rdstr_prev <= fifo_rdstr;
          if (fifo_rdstr = '0' and fifo_rdstr_prev = '1') then
              fifo_rdstr_fe <= '1'; --falling edge
          else
              fifo_rdstr_fe <= '0';
          end if;
       end if;
end process;
        



process(reset,mach_clk)
  begin
     if (reset = '1') then
        adc_ch0_sum <= (others => '0');
        adc_ch1_sum <= (others => '0');  
        adc_ch2_sum <= (others => '0');       
        adc_ch3_sum <= (others => '0');
        tst_data    <= (others => '0');
      

        
     elsif (mach_clk'event and mach_clk = '1') then
 
        adc_ch0_sum <= signed(adc_ch0_se) + adc_ch0_sum;
        adc_ch1_sum <= signed(adc_ch1_se) + adc_ch1_sum;
        adc_ch2_sum <= signed(adc_ch2_se) + adc_ch2_sum;
        adc_ch3_sum <= signed(adc_ch3_se) + adc_ch3_sum;                      
        if (tenkhz_trig = '1') then
           adc_ch0_lat <= std_logic_vector(adc_ch0_sum);
           adc_ch1_lat <= std_logic_vector(adc_ch1_sum);         
           adc_ch2_lat <= std_logic_vector(adc_ch2_sum);                   
           adc_ch3_lat <= std_logic_vector(adc_ch3_sum);                  
           adc_ch0_sum <= (others => '0');
           adc_ch1_sum <= (others => '0');  
           adc_ch2_sum <= (others => '0');       
           adc_ch3_sum <= (others => '0'); 
           tst_data    <= tst_data + 1;
        end if;
     end if;
end process;

fifo_din <= (x"0123456789ABCDEFDEADBEEF" & std_logic_vector(tst_data)) when testmode = '1' else
            (adc_ch0_lat & adc_ch1_lat & adc_ch2_lat & adc_ch3_lat);


fifo_wrstr <= tenkhz_trig AND tenkhzdata_enb;

tenkhzfifo : fifo_generator_0
  PORT MAP (
    rst             => tenkhzdata_fiforst,
    wr_clk          => mach_clk,
    wr_en           => fifo_wrstr,  
    din             => fifo_din,    
    rd_clk          => sys_clk,
    rd_en           => fifo_rdstr_fe,
    dout            => fifo_dout,
    full            => fifo_full,
    empty           => fifo_empty,
    rd_data_count   => fifo_rd_data_cnt
  );






end behv;
