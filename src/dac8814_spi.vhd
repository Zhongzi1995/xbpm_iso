library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library UNISIM;
use UNISIM.VComponents.all;

entity dac8814_spi is
  
  port (
   clk         : in  std_logic;                    
   reset  	   : in  std_logic;                     
   we		   : in  std_logic;
   wrdata	   : in  std_logic_vector(31 downto 0);

   sclk        : out std_logic;                   
   sdo		   : in std_logic;
   sdi 	       : out std_logic;
   csn         : out std_logic;                
   ldacn       : out std_logic  
  );    

end dac8814_spi;

architecture rtl of dac8814_spi is

  type     state_type is (IDLE, CLKP1, CLKP2, SETLDAC, CLRLDAC); 
  signal   state                 : state_type;
  signal   sys_clk               : std_logic;                                                                              
  signal   treg                  : std_logic_vector(17 downto 0);                                                                                                                                    
  signal   bcnt                  : integer range 0 to 18;          
  signal   xfer_done             : std_logic;                      
   
  signal clk_cnt            : std_logic_vector(17 downto 0);  
 
  signal we_lat				: std_logic;
  signal we_lat_clr			: std_logic;
  
 signal spi_data				: std_logic_vector(17 downto 0);
  
begin  




-- initiate spi command on we input
process (clk, reset)
   begin
     if (reset = '1') or (we_lat_clr = '1')  then
	     spi_data <= (others => '0');
	     we_lat <= '0';
     elsif (clk'event and clk = '1') then
		   if (we = '1') then
	           we_lat <= '1';
			   spi_data <= wrdata(17 downto 0);
	    	end if;
     end if;
end process;


-- spi transfer
process (sys_clk, reset)
  begin  -- process spiStateProc
    if (reset = '1') then                 
      sclk <= '0';
      csn  <= '1';
	    sdi <= '0';
	    ldacn <= '1';
      treg <= (others => '0');
      bcnt <= 18;
      xfer_done <= '0';
		  we_lat_clr <= '0';
      state <= IDLE;

    elsif (sys_clk'event and sys_clk = '1') then  
      case state is
        when IDLE =>     
           sclk  <= '0';
           csn  <= '1';
           ldacn <= '1';
           xfer_done <= '0';
           we_lat_clr <= '0';
           if (we_lat = '1') then
                treg <= spi_data;  
                bcnt <= 18;  -- 2-bit address and 16-bit data
                state <= CLKP1;
           end if;

        when CLKP1 =>     -- CLKP1 clock phase LOW
			      sclk  <= '0';
            csn  <= '0';
            state <= CLKP2;
			      treg <= treg(16 downto 0) & '0';
            sdi <= treg(17);

        when CLKP2 =>     -- CLKP1 clock phase 2
           if (bcnt = 0) then
               csn <= '1';
			         xfer_done <= '1';
               we_lat_clr <= '1';				
               state <= SETLDAC;
           else
               sclk <= '1';
               bcnt <= bcnt - 1;
               state <= CLKP1;
			     end if;
 
        when SETLDAC => 
            ldacn <= '0';
            state <= clrldac;
            
        when CLRLDAC => 
            ldacn <= '1';
            state <= idle;            
             
    
        when others =>
            state <= IDLE;
      end case;
    end if;
  end process;





--generate sys clk for spi from 100Mhz clock
--sys_clk <= clk_cnt(4);
sysclk_bufg_inst : BUFG  port map (O => sys_clk, I => clk_cnt(4));

clkdivide : process(clk, reset)
  begin
     if (reset = '1') then  
       clk_cnt <= (others => '0');
    elsif (clk'event AND clk = '1') then  
		 	 clk_cnt <= clk_cnt + 1; 
    end if;
end process; 










  
end rtl;
