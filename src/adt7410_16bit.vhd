library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library UNISIM;
use UNISIM.VComponents.all;


entity adt7410_16bit is
  
  port (
     clk         : in  std_logic;                     
     reset       : in  std_logic;         
     scl		 : out  std_logic;
	 sda		 : inout std_logic;
	 temp0		 : out std_logic_vector(15 downto 0);
	 temp1		 : out std_logic_vector(15 downto 0);
	 temp2		 : out std_logic_vector(15 downto 0);
	 temp3		 : out std_logic_vector(15 downto 0);
	 debug		 : out std_logic_vector(7 downto 0) 

  );    

end adt7410_16bit;

architecture rtl of adt7410_16bit is


  type     state_type is (IDLE,CR_IDLE,CR_START_P1,CR_START_P2,CR_START_P3,CR_CLK_P1,CR_CLK_P2,CR_CLK_P3,CR_STOP_P1,CR_STOP_P2,CR_STOP_P3,CR_WAIT,
                          SA_IDLE,SA_START_P1,SA_START_P2,SA_START_P3,SA_CLK_P1,SA_CLK_P2,SA_CLK_P3,SA_STOP_P1,SA_STOP_P2,SA_STOP_P3,SA_WAIT,
                          RT_IDLE,RT_START_P1,RT_START_P2,RT_START_P3,RT_CLK_P1,RT_CLK_P2,RT_CLK_P3,RT_STOP_P1,RT_STOP_P2,RT_STOP_P3,RT_WAIT,RT_STROBE);                          
                          
signal   state        : state_type;
  signal   sys_clk      : std_logic;                      -- system clock to operate logic    
  signal   sys_clk_i    : std_logic;                                                      
  signal   treg         : std_logic_vector(27 downto 0);  -- transfer register,
                                                             
  signal   rreg         : std_logic_vector(27 downto 0);   -- receiver register,
                                                     
  signal   bcnt         : integer range 0 to 63;          -- transfer counter
    
  signal   int_scl		: std_logic;
  signal   int_sda		: std_logic;  
  signal   strobe			: std_logic;
  signal   sda_dir		: std_logic;
  
  signal   clkcnt 		: std_logic_vector(31 downto 0);
  
  signal   addr			: std_logic_vector(1 downto 0);  
  signal   dlytime      : std_logic_vector(7 downto 0);
  signal   readtemp     : std_logic;
  
begin  


  debug(0) <= '0'; --sys_clk;
  debug(1) <= strobe;
  debug(7 downto 2) <= (others => '0');


  clkgen: process(clk, reset)
  begin
    if (reset = '1') then
		   clkcnt <= (others => '0');
	 elsif (clk'event and clk = '1') then
			clkcnt <= clkcnt + 1;
    end if;
  end process clkgen;	 
	 
 
  scl <= int_scl;		
  sda <= int_sda when (sda_dir = '0') else 'Z';

  sda_dir <= '0' when ((((bcnt <= 27) AND (bcnt >= 19)) OR (bcnt = 9) OR (bcnt = 0)) AND (readtemp = '1')) OR --else '1';
                      ((((bcnt <= 27) AND (bcnt >= 19)) OR ((bcnt <= 17) AND (bcnt >= 10)) OR ((bcnt <= 8) AND (bcnt >= 1)) OR (bcnt = 0)) AND (readtemp = '0')) else '1';  


  --for real
  sys_clk_i <= clkcnt(9);
   sys_clk_bufg_inst : BUFG  port map (O => sys_clk, I => sys_clk_i);
  strobe <= '1' when (clkcnt(26 downto 15) = x"FFF") else '0';  --100ms update
 
   --for simulation
  --sys_clk <= clkcnt(0);
  --strobe <= '1' when (clkcnt(15 downto 0) = x"FFFF") else '0';
 

  read_adt7410: process (sys_clk, reset)
  begin 
    if (reset = '1') then 
      dlytime <= x"00";
      int_scl  <= '0';
      addr <= "00";
	  rreg <= (others => '0');
      treg <= (others => '0');
      readtemp <= '0';

      bcnt <= 26;
      state <= idle;

    elsif (sys_clk'event and sys_clk = '1') then  
    case state is
         when IDLE =>
             if (dlytime = x"10") then
               state <= cr_idle;
               dlytime <= x"00";
             else
               dlytime <= dlytime + 1;
             end if;              

          --Write Config Register for 16 bit mode
          when CR_IDLE =>   
              int_scl  <= '0';
              int_sda <= '1';
					--fix addr  addr   r/w   ack    msb    ack    lsb    ack   stop
			  treg <= "10010" & addr & "0" & "0" & x"03" & "0" & x"80" & "0" & "0";  
              bcnt <= 27;  
              state <= cr_start_p1;


	      when CR_START_P1 =>
		      int_scl <= '1';
		      state <= cr_start_p2;

	      when CR_START_P2 =>
 	 	      int_sda <= '0';
	 	      state <= cr_start_p3;
			 
	      when CR_START_P3 =>
		      int_scl <= '0';
		      state <= cr_clk_p1;
			 
          when CR_CLK_P1 => 
              --write out sda
              int_sda <= treg(bcnt);
		      if (bcnt = 0) then
			     state <= cr_stop_p1;
		      else
			     bcnt <= bcnt - 1;
                 state <= cr_clk_p2;
              end if;
			 
	      when CR_CLK_P2 =>
		      int_scl <= '1';
		      state <= cr_clk_p3;
			 
	      when CR_CLK_P3 =>
		      rreg(bcnt) <= sda;
		      int_scl <= '0';
		      state <= cr_clk_p1;

          when CR_STOP_P1 =>
              int_scl <= '1';   
              state <= cr_stop_p2;              
        
          when CR_STOP_P2 =>
              int_sda <= '1';
              state <= cr_stop_p3;
        
          when CR_STOP_P3 =>
              int_scl <= '0';

              state <= cr_wait;    
              
          when CR_WAIT =>
              if (dlytime = x"10") then
                 state <= sa_idle;
                 dlytime <= x"00";
              else
                 dlytime <= dlytime + 1;
              end if;                         
              
      
          --Set Address Pointer to 0 for Temp Readback
          when SA_IDLE =>   
              int_scl  <= '0';


              int_sda <= '1';
		        --fix addr  addr   r/w   ack    msb    ack    lsb    ack   stop
		      treg <= "10010" & addr & "0" & "0" & x"00" & "0" & x"00" & "0" & "0";  
              bcnt <= 27;  
              state <= sa_start_p1;


	      when SA_START_P1 =>
		      int_scl <= '1';
		      state <= sa_start_p2;

	      when SA_START_P2 =>
		      int_sda <= '0';
		      state <= sa_start_p3;
			 
	      when SA_START_P3 =>
			  int_scl <= '0';
			  state <= sa_clk_p1;
			 
          when SA_CLK_P1 => 
              --write out sda
              int_sda <= treg(bcnt);
		      if (bcnt = 0) then
			       state <= sa_stop_p1;
		       else
			       bcnt <= bcnt - 1;
                   state <= sa_clk_p2;
               end if;
			 
	      when SA_CLK_P2 =>
		      int_scl <= '1';
		      state <= sa_clk_p3;
			 
	      when SA_CLK_P3 =>
		      rreg(bcnt) <= sda;
		      int_scl <= '0';
		      state <= sa_clk_p1;

          when SA_STOP_P1 =>
              int_scl <= '1';   
              state <= sa_stop_p2;              
        
          when SA_STOP_P2 =>
              int_sda <= '1';
              state <= sa_stop_p3;
        
          when SA_STOP_P3 =>
              int_scl <= '0';
              state <= sa_wait;
              
          when SA_WAIT =>
              if (dlytime = x"F0") then

                 dlytime <= x"00";
                 if (addr = "11") then
                     readtemp <= '1';
                     state <= rt_idle; 
                     addr <= "00";
                 else
                     addr <= addr + 1;        
                     state <= cr_idle;
                 end if;
              else
                 dlytime <= dlytime + 1;
              end if;                 
              


       
      
      --Read Temperature Register      
          when RT_IDLE =>   
              int_scl  <= '0';
              int_sda <= '1';              
			        --fix addr  addr   r/w   ack    msb    ack    lsb    ack   stop
			  treg <= "10010" & addr & "1" & "0" & x"00" & "0" & x"00" & "1" & "0";  
              bcnt <= 27;  
              state <= rt_start_p1;
              

	      when RT_START_P1 =>
		      int_scl <= '1';
		      state <= rt_start_p2;

 	      when RT_START_P2 =>
		      int_sda <= '0';
		      state <= rt_start_p3;
			 
	      when RT_START_P3 =>
		      int_scl <= '0';
		      state <= rt_clk_p1;
			 
          when RT_CLK_P1 => 
              --write out sda
              int_sda <= treg(bcnt);
		     if (bcnt = 0) then
		        state <= rt_stop_p1;
		     else
			    bcnt <= bcnt - 1;
                state <= rt_clk_p2;
             end if;
			 
	      when RT_CLK_P2 =>
		      int_scl <= '1';
		      state <= rt_clk_p3;
			 
	      when RT_CLK_P3 =>
		      rreg(bcnt) <= sda;
		      int_scl <= '0';
		      state <= rt_clk_p1;

          when RT_STOP_P1 =>
              int_scl <= '1';   
              state <= rt_stop_p2;              
          
          when RT_STOP_P2 =>
              int_sda <= '1';
              state <= rt_stop_p3;
          
          when RT_STOP_P3 =>
              int_scl <= '0';
			  case addr is
			     when "00" 	=>   temp0 <= rreg (17 downto 10) & rreg(8 downto 1);			 
			     when "01" 	=>   temp1 <= rreg (17 downto 10) & rreg(8 downto 1);
				 when "10" 	=>   temp2 <= rreg (17 downto 10) & rreg(8 downto 1);
				 when "11" 	=>   temp3 <= rreg (17 downto 10) & rreg(8 downto 1);			 						  
				 when others 	=>   null; 
			  end case;

              state <= rt_wait;

          when RT_WAIT =>
              if (dlytime = x"10") then

                 dlytime <= x"00";
                 if (addr = "11") then
                    addr <= "00";
                    state <= rt_strobe;

                 else
                    addr <= addr + 1;
                    state <= rt_idle;
                 end if;
              else
                 dlytime <= dlytime + 1;
              end if;                 


          when RT_STROBE =>
                if (strobe = '1') then
                   state <= rt_idle;
                end if;
       

          
      end case;
    end if;
  end process read_adt7410;





  
end rtl;
