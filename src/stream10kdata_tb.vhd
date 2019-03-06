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


entity stream10kdata_tb is
end stream10kdata_tb;



architecture behv of stream10kdata_tb is

component stream10kdata is
  port(
     mach_clk           : in std_logic;
     sys_clk            : in std_logic;
     reset              : in std_logic;
     
     testmode           : in std_logic;
     tenkhzdata_enb     : in std_logic;
     tenkhzdata_fiforst : in std_logic;

	 adc_ch0			: in std_logic_vector(17 downto 0);
	 adc_ch1			: in std_logic_vector(17 downto 0);
	 adc_ch2			: in std_logic_vector(17 downto 0);
	 adc_ch3			: in std_logic_vector(17 downto 0);	 
	 
	 tenkhz_trig        : out std_logic;
	 
	 fifo_rdstr         : in  std_logic;
	 fifo_dout          : out std_logic_vector(31 downto 0);
	 fifo_rdcnt         : out std_logic_vector(31 downto 0)	 	    
    );
end component;



   signal mach_clk      : std_logic;
   signal sys_clk       : std_logic;
   signal reset         : std_logic;
   signal testmode      : std_logic;
   signal adc_ch0       : std_logic_vector(17 downto 0);
   signal adc_ch1       : std_logic_vector(17 downto 0);
   signal adc_ch2       : std_logic_vector(17 downto 0);
   signal adc_ch3       : std_logic_vector(17 downto 0);
   
   signal tenkhz_trig   : std_logic;
   signal tenkhzdata_enb : std_logic;
   signal tenkhzdata_fiforst :std_logic;
   
   signal fifo_rdstr    : std_logic;
   signal fifo_dout     : std_logic_vector(31 downto 0);
   signal fifo_rdcnt    : std_logic_vector(31 downto 0);

    
     

begin
  

uut : stream10kdata
  port map(
     mach_clk           => mach_clk, 
     sys_clk            => sys_clk, 
     reset              => reset, 
     
     testmode           => testmode, 
     tenkhzdata_enb     => tenkhzdata_enb,
     tenkhzdata_fiforst => tenkhzdata_fiforst,

	 adc_ch0			=> adc_ch0, 
	 adc_ch1			=> adc_ch1, 
	 adc_ch2			=> adc_ch2, 
	 adc_ch3			=> adc_ch3, 	 
	 
	 tenkhz_trig        => tenkhz_trig, 
	 
	 fifo_rdstr         => fifo_rdstr, 
	 fifo_dout          => fifo_dout, 
	 fifo_rdcnt         => fifo_rdcnt	 	    
    );






-- system clk process
process
  begin
     sys_clk <= '0';
     wait for 5 ns;
     sys_clk <= '1';
     wait for 5 ns;
end process;

-- machine clk process
process
  begin
     mach_clk <= '0';
     wait for 1.321 us;
     mach_clk <= '1';
     wait for 1.321 us;
end process;
      
 
-- main process
process
  begin
    reset   <= '1';
    tenkhzdata_enb <= '0';
    tenkhzdata_fiforst <= '0';
    adc_ch0 <= (others => '0');
    adc_ch1 <= (others => '0');
    adc_ch2 <= (others => '0');
    adc_ch3 <= (others => '0');         
    testmode <= '1';
    fifo_rdstr <= '0';
    wait for 100 ns;
    reset <= '0';
    wait for 500 us;
    tenkhzdata_enb <= '1';
    
    wait for 1000 us;
    
    fifo_rdstr <= '1';
    wait for 20 ns;
    fifo_rdstr <= '0';
    wait for 100 ns;
    fifo_rdstr <= '1';
    wait for 20 ns;
    fifo_rdstr <= '0';
    wait for 100 ns;   
    fifo_rdstr <= '1';
    wait for 20 ns;
    fifo_rdstr <= '0';
    wait for 100 ns;
    fifo_rdstr <= '1';
    wait for 20 ns;
    fifo_rdstr <= '0';
    wait for 200 ns;   
 
    fifo_rdstr <= '1';
    wait for 20 ns;
    fifo_rdstr <= '0';
    wait for 100 ns;
    fifo_rdstr <= '1';
    wait for 20 ns;
    fifo_rdstr <= '0';
    wait for 100 ns;   
    fifo_rdstr <= '1';
    wait for 20 ns;
    fifo_rdstr <= '0';
    wait for 100 ns;
    fifo_rdstr <= '1';
    wait for 20 ns;
    fifo_rdstr <= '0';
    wait for 200 ns;   
    
    fifo_rdstr <= '1';
    wait for 20 ns;
    fifo_rdstr <= '0';
    wait for 100 ns;
    fifo_rdstr <= '1';
    wait for 20 ns;
    fifo_rdstr <= '0';
    wait for 100 ns;   
    fifo_rdstr <= '1';
    wait for 20 ns;
    fifo_rdstr <= '0';
    wait for 100 ns;
    fifo_rdstr <= '1';
    wait for 20 ns;
    fifo_rdstr <= '0';
    wait for 200 ns;        
         
    fifo_rdstr <= '1';
    wait for 20 ns;
    fifo_rdstr <= '0';
    wait for 100 ns;
    fifo_rdstr <= '1';
    wait for 20 ns;
    fifo_rdstr <= '0';
    wait for 100 ns;   
    fifo_rdstr <= '1';
    wait for 20 ns;
    fifo_rdstr <= '0';
    wait for 100 ns;
    fifo_rdstr <= '1';
    wait for 20 ns;
    fifo_rdstr <= '0';
    wait for 200 ns;      
    
    wait for 10 us;
    tenkhzdata_fiforst <= '1';
    wait for 1 us;
    tenkhzdata_fiforst <= '0';
    wait for 10 us;
    tenkhzdata_enb <= '0';
    
    wait for 1000 us;
    
    tenkhzdata_enb <= '1';
    wait for 1000 us;
    tenkhzdata_enb <= '0';
    
end process;

end behv;
