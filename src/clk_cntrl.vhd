library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library UNISIM;
use UNISIM.VComponents.all;

 

entity clk_cntrl is
  
  port (
    clk                 : in std_logic;
    reset               : in std_logic;
       
    mach_clk_sel        : in std_logic_vector(1 downto 0);
    machclk_divide      : in std_logic_vector(7 downto 0);
    tenkhz_divide       : in std_logic_vector(31 downto 0);
    tenhz_divide        : in std_logic_vector(31 downto 0);
      
    ext_tbtclk          : in std_logic;
    evr_tbtclk          : in std_logic;
    evr_fatrig          : in std_logic;
    evr_satrig          : in std_logic;
    
    mach_clk            : out std_logic;
    fa_trig             : out std_logic;
    sa_trig             : out std_logic
    
  );

end clk_cntrl;




architecture rtl of clk_cntrl is

   signal mach_clk_int      : std_logic;
   signal mach_clk_i        : std_logic;
   signal mach_clk_src      : std_logic;
   signal clk_cnt           : std_logic_vector(7 downto 0);
   
   signal tenhz_cnt_i       : std_logic_vector(31 downto 0);
   signal tenkhz_cnt_i      : std_logic_vector(31 downto 0);
   
   signal tenhz_trig        : std_logic;
   signal tenkhz_trig       : std_logic;
   
   

begin  

mach_clk <= mach_clk_i;  

--mach_clk_sel  0=ext, 1=int, 2=evr (for ext and int, generate tenhz and tenkhz trig internally,
--for evr, sa and fa triggiers come from event link)  
sa_trig  <= evr_satrig  when (mach_clk_sel = "10") else tenhz_trig;  
fa_trig  <= evr_fatrig  when (mach_clk_sel = "10") else tenkhz_trig;  


--generate internal machine clk from sys_clk
process(clk,reset)
  begin
     if (reset = '1') then
        mach_clk_int <= '0';
        clk_cnt <= (others => '0');
     elsif (clk'event and clk = '1') then
        if (clk_cnt = machclk_divide) then  -- 66decimal @50MHz clock 378.788KHz
           mach_clk_int <= not mach_clk_int; 
           clk_cnt <= (others => '0');
        else
           clk_cnt <= clk_cnt + 1;
        end if;
     end if;
end process;


--evr_tbtclk doesn't stay high on evr in ring, but works in lab.
--for now, just use tbtclk from back panel.
--mach_clk_src  <= evr_tbtclk  when (mach_clk_sel = "10") else 
--                mach_clk_int when (mach_clk_sel = "01")  else
--                ext_tbtclk;
                
mach_clk_src  <= ext_tbtclk  when (mach_clk_sel = "10") else 
                 mach_clk_int when (mach_clk_sel = "01")  else
                 ext_tbtclk;  
  
                
                

mach_clk_bufg_inst : BUFG  port map (O => mach_clk_i, I => mach_clk_src);




-- generate 10Hz clk internally
process(reset,mach_clk_i)
  begin
     if (reset = '1') then
        tenhz_trig <= '0';
        tenhz_cnt_i <= (others => '0');    
     elsif (mach_clk_i'event and mach_clk_i = '1') then
        if (tenhz_cnt_i >= (tenhz_divide-1)) then
           tenhz_trig <= '1';
           tenhz_cnt_i <= x"00000000";
        else
           tenhz_trig <= '0';
           tenhz_cnt_i <= tenhz_cnt_i + 1;
        end if;
     end if;
end process;



-- generate 10kHz clk internally
process(reset,mach_clk_i)
  begin
     if (reset = '1') then
        tenkhz_trig <= '0';
        tenkhz_cnt_i <= (others => '0');
        
     elsif (mach_clk_i'event and mach_clk_i = '1') then
        if (tenkhz_cnt_i >= (tenkhz_divide-1)) then
           tenkhz_trig <= '1';
           tenkhz_cnt_i <= x"00000000"; 
        else
           tenkhz_trig <= '0';
           tenkhz_cnt_i <= tenkhz_cnt_i + 1;
        end if;
     end if;
end process;









  
end rtl;
