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
        wrdata      		: in  std_logic_vector(31 downto 0);
        rddata      		: out std_logic_vector(31 downto 0);			  

        burst_len           : out std_logic_vector(31 downto 0);
		leds				: out std_logic_vector(31 downto 0);
		
        ddr_baseaddr        : out std_logic_vector(31 downto 0); 		

  	    tenhz_divide        : out std_logic_vector(31 downto 0);
  	    tenhz_irqenb        : out std_logic;
  	    
  	    dbg                 : out std_logic_vector(31 downto 0)		 	

		);
			  
end iobus_interface;


  

architecture Behavioral of iobus_interface is


signal leds_i					: std_logic_vector(31 downto 0);
signal softtrig_i				: std_logic_vector(31 downto 0);
signal testdata_en_i			: std_logic_vector(31 downto 0);
signal burst_len_i  			: std_logic_vector(31 downto 0);
signal tenhz_divide_i           : std_logic_vector(31 downto 0);
signal tenhz_irqenb_i           : std_logic;
signal ddr_baseaddr_i        : std_logic_vector(31 downto 0);


--debug signals (connect to ila)
attribute mark_debug     : string;
attribute mark_debug of leds_i: signal is "true";
attribute mark_debug of softtrig_i: signal is "true";  
attribute mark_debug of testdata_en_i: signal is "true";
--attribute mark_debug of ddr_baseaddr_i: signal is "true";
--attribute mark_debug of hs_ddr_baseaddr: signal is "true";


begin

leds				<= leds_i;
burst_len           <= burst_len_i;
tenhz_divide        <= tenhz_divide_i;
tenhz_irqenb        <= tenhz_irqenb_i;
ddr_baseaddr        <= ddr_baseaddr_i;
dbg                 <= ddr_baseaddr_i;

readwrite_gen: process(clk, rst)  
	begin
		if (rst = '1') then
			rddata      			<= x"12345678"; --(others => '0');
			leds_i					<= (others => '0');
			softtrig_i              <= (others => '0');
			testdata_en_i           <= (others => '0');
			burst_len_i             <= x"00000600";
			tenhz_divide_i          <= x"00000000";
			tenhz_irqenb_i          <= '0';
			ddr_baseaddr_i       <= x"10000000";
		 
		else
			if (clk = '1' and clk'event) then
				if  cs = '1' then
					case addr(7 downto 0) is
					    --Soft Trigger 
					    --Ethernet Address : 0
						when x"00" =>	if (rnw = '0') then 	softtrig_i <= wrdata;   
										else      				rddata <= softtrig_i;
										end if;

                        --Enable Test Data
                        --Ethernet Address : 1
						when x"04" =>	if (rnw = '0') then 	testdata_en_i <= wrdata;   
										else				    rddata <= testdata_en_i; 
										end if;
  
                        -- controls LED's
                        --Ethernet Address : 2
                        when x"08" =>  if (rnw = '0') then	    leds_i <= wrdata;
									   else			            rddata <= leds_i;			  			
									   end if;  

						--FPGA_version
						--Ethernet Address : 3					
						when x"0C" =>   rddata <= x"00000005"; --CONV_STD_LOGIC_VECTOR(FPGA_VERSION,32);	


                        -- DDR burst length
                        --Ethernet Address : 4
                        when x"10" =>  if (rnw = '0') then	    burst_len_i <= wrdata;
									   else			            rddata <= burst_len_i;			  			
									   end if;  


                        -- 10 Hz Divide value
                        --Ethernet Address : 5
                        when x"14" =>  if (rnw = '0') then	    tenhz_divide_i <= wrdata;
									   else			            rddata <= tenhz_divide_i;			  			
									   end if;  

                        -- 10 Hz irq enable
                        --Ethernet Address : 6
                        when x"18" =>  if (rnw = '0') then	    tenhz_irqenb_i <= wrdata(0);
									   else			            rddata <= x"0000000" & "000" & tenhz_irqenb_i;			  			
									   end if;  


                        -- High Speed DDR BaseAddr
                        --Ethernet Address : 7
                        when x"1C" =>  if (rnw = '0') then	    ddr_baseaddr_i <= wrdata;
									   else			            rddata <= ddr_baseaddr_i;			  			
									   end if;  




						when others =>
									   null;
				   end case;
					

				end if;
			end if;
		end if;
	end process;
						



end Behavioral;

