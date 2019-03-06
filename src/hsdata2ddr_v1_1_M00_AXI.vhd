library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity hsdata2ddr_v1_1_M00_AXI is
	generic (
		-- Users to add parameters here

		-- User parameters ends
		-- Do not modify the parameters beyond this line

		-- Base address of targeted slave
		C_M_TARGET_SLAVE_BASE_ADDR	: std_logic_vector	:= x"40000000";
		-- Burst Length. Supports 1, 2, 4, 8, 16, 32, 64, 128, 256 burst lengths
		C_M_AXI_BURST_LEN	: integer	:= 16;
		-- Thread ID Width
		C_M_AXI_ID_WIDTH	: integer	:= 1;
		-- Width of Address Bus
		C_M_AXI_ADDR_WIDTH	: integer	:= 32;
		-- Width of Data Bus
		C_M_AXI_DATA_WIDTH	: integer	:= 64;
		-- Width of User Write Address Bus
		C_M_AXI_AWUSER_WIDTH	: integer	:= 0;
		-- Width of User Read Address Bus
		C_M_AXI_ARUSER_WIDTH	: integer	:= 0;
		-- Width of User Write Data Bus
		C_M_AXI_WUSER_WIDTH	: integer	:= 0;
		-- Width of User Read Data Bus
		C_M_AXI_RUSER_WIDTH	: integer	:= 0;
		-- Width of User Response Bus
		C_M_AXI_BUSER_WIDTH	: integer	:= 0
	);
	port (
		-- Users to add ports here
        FIFO_RDEN    : out std_logic;
        FIFO_RDCNT   : in  std_logic_vector(8 downto 0);
        FIFO_RDDATA  : in  std_logic_vector(63 downto 0);
        TX_ENB       : in  std_logic;
        TX_ACTIVE    : out std_logic;
        DDR_BASEADDR : in  std_logic_vector(31 downto 0);


		-- User ports ends
		-- Do not modify the ports beyond this line

		-- Initiate AXI transactions
		INIT_AXI_TXN	: in std_logic;
		-- Asserts when transaction is complete
		TXN_DONE	: out std_logic;
		-- Asserts when ERROR is detected
		ERROR	: out std_logic;
		-- Global Clock Signal.
		M_AXI_ACLK	: in std_logic;
		-- Global Reset Singal. This Signal is Active Low
		M_AXI_ARESETN	: in std_logic;
		-- Master Interface Write Address ID
		M_AXI_AWID	: out std_logic_vector(C_M_AXI_ID_WIDTH-1 downto 0);
		-- Master Interface Write Address
		M_AXI_AWADDR	: out std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0);
		-- Burst length. The burst length gives the exact number of transfers in a burst
		M_AXI_AWLEN	: out std_logic_vector(7 downto 0);
		-- Burst size. This signal indicates the size of each transfer in the burst
		M_AXI_AWSIZE	: out std_logic_vector(2 downto 0);
		-- Burst type. The burst type and the size information, 
    -- determine how the address for each transfer within the burst is calculated.
		M_AXI_AWBURST	: out std_logic_vector(1 downto 0);
		-- Lock type. Provides additional information about the
    -- atomic characteristics of the transfer.
		M_AXI_AWLOCK	: out std_logic;
		-- Memory type. This signal indicates how transactions
    -- are required to progress through a system.
		M_AXI_AWCACHE	: out std_logic_vector(3 downto 0);
		-- Protection type. This signal indicates the privilege
    -- and security level of the transaction, and whether
    -- the transaction is a data access or an instruction access.
		M_AXI_AWPROT	: out std_logic_vector(2 downto 0);
		-- Quality of Service, QoS identifier sent for each write transaction.
		M_AXI_AWQOS	: out std_logic_vector(3 downto 0);
		-- Optional User-defined signal in the write address channel.
		M_AXI_AWUSER	: out std_logic_vector(C_M_AXI_AWUSER_WIDTH-1 downto 0);
		-- Write address valid. This signal indicates that
    -- the channel is signaling valid write address and control information.
		M_AXI_AWVALID	: out std_logic;
		-- Write address ready. This signal indicates that
    -- the slave is ready to accept an address and associated control signals
		M_AXI_AWREADY	: in std_logic;
		-- Master Interface Write Data.
		M_AXI_WDATA	: out std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0);
		-- Write strobes. This signal indicates which byte
    -- lanes hold valid data. There is one write strobe
    -- bit for each eight bits of the write data bus.
		M_AXI_WSTRB	: out std_logic_vector(C_M_AXI_DATA_WIDTH/8-1 downto 0);
		-- Write last. This signal indicates the last transfer in a write burst.
		M_AXI_WLAST	: out std_logic;
		-- Optional User-defined signal in the write data channel.
		M_AXI_WUSER	: out std_logic_vector(C_M_AXI_WUSER_WIDTH-1 downto 0);
		-- Write valid. This signal indicates that valid write
    -- data and strobes are available
		M_AXI_WVALID	: out std_logic;
		-- Write ready. This signal indicates that the slave
    -- can accept the write data.
		M_AXI_WREADY	: in std_logic;
		-- Master Interface Write Response.
		M_AXI_BID	: in std_logic_vector(C_M_AXI_ID_WIDTH-1 downto 0);
		-- Write response. This signal indicates the status of the write transaction.
		M_AXI_BRESP	: in std_logic_vector(1 downto 0);
		-- Optional User-defined signal in the write response channel
		M_AXI_BUSER	: in std_logic_vector(C_M_AXI_BUSER_WIDTH-1 downto 0);
		-- Write response valid. This signal indicates that the
    -- channel is signaling a valid write response.
		M_AXI_BVALID	: in std_logic;
		-- Response ready. This signal indicates that the master
    -- can accept a write response.
		M_AXI_BREADY	: out std_logic;
		-- Master Interface Read Address.
		M_AXI_ARID	: out std_logic_vector(C_M_AXI_ID_WIDTH-1 downto 0);
		-- Read address. This signal indicates the initial
    -- address of a read burst transaction.
		M_AXI_ARADDR	: out std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0);
		-- Burst length. The burst length gives the exact number of transfers in a burst
		M_AXI_ARLEN	: out std_logic_vector(7 downto 0);
		-- Burst size. This signal indicates the size of each transfer in the burst
		M_AXI_ARSIZE	: out std_logic_vector(2 downto 0);
		-- Burst type. The burst type and the size information, 
    -- determine how the address for each transfer within the burst is calculated.
		M_AXI_ARBURST	: out std_logic_vector(1 downto 0);
		-- Lock type. Provides additional information about the
    -- atomic characteristics of the transfer.
		M_AXI_ARLOCK	: out std_logic;
		-- Memory type. This signal indicates how transactions
    -- are required to progress through a system.
		M_AXI_ARCACHE	: out std_logic_vector(3 downto 0);
		-- Protection type. This signal indicates the privilege
    -- and security level of the transaction, and whether
    -- the transaction is a data access or an instruction access.
		M_AXI_ARPROT	: out std_logic_vector(2 downto 0);
		-- Quality of Service, QoS identifier sent for each read transaction
		M_AXI_ARQOS	: out std_logic_vector(3 downto 0);
		-- Optional User-defined signal in the read address channel.
		M_AXI_ARUSER	: out std_logic_vector(C_M_AXI_ARUSER_WIDTH-1 downto 0);
		-- Write address valid. This signal indicates that
    -- the channel is signaling valid read address and control information
		M_AXI_ARVALID	: out std_logic;
		-- Read address ready. This signal indicates that
    -- the slave is ready to accept an address and associated control signals
		M_AXI_ARREADY	: in std_logic;
		-- Read ID tag. This signal is the identification tag
    -- for the read data group of signals generated by the slave.
		M_AXI_RID	: in std_logic_vector(C_M_AXI_ID_WIDTH-1 downto 0);
		-- Master Read Data
		M_AXI_RDATA	: in std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0);
		-- Read response. This signal indicates the status of the read transfer
		M_AXI_RRESP	: in std_logic_vector(1 downto 0);
		-- Read last. This signal indicates the last transfer in a read burst
		M_AXI_RLAST	: in std_logic;
		-- Optional User-defined signal in the read address channel.
		M_AXI_RUSER	: in std_logic_vector(C_M_AXI_RUSER_WIDTH-1 downto 0);
		-- Read valid. This signal indicates that the channel
    -- is signaling the required read data.
		M_AXI_RVALID	: in std_logic;
		-- Read ready. This signal indicates that the master can
    -- accept the read data and response information.
		M_AXI_RREADY	: out std_logic
	);
end hsdata2ddr_v1_1_M00_AXI;

architecture implementation of hsdata2ddr_v1_1_M00_AXI is



  type  state_type is (IDLE, ADDR_ACTIVE, DATA_ACTIVE, BURST, HOLD);  
  signal state :  state_type;

  signal burstcnt : INTEGER RANGE 0 TO 255;

  signal axi_awaddr_i : std_logic_vector(27 downto 0);
  
  --signal fifo_rden   : std_logic;
  --signal fifo_rddata : std_logic_vector(63 downto 0);
  signal fifo_empty  : std_logic;
  --signal fifo_rdcnt  : std_logic_vector(9 downto 0);





begin



-- Read Interface is never used
M_AXI_ARID	   <= (others => '0');
M_AXI_ARADDR   <= (others => '0');
M_AXI_ARLEN	   <= (others => '0'); 
M_AXI_ARSIZE   <= (others => '0');
M_AXI_ARBURST  <= (others => '0');
M_AXI_ARLOCK   <= '0'; 
M_AXI_ARCACHE  <= (others => '0');
M_AXI_ARPROT   <= (others => '0');
M_AXI_ARQOS	   <= (others => '0');
M_AXI_ARUSER   <= (others => '0'); 
M_AXI_ARVALID  <= '0';
M_AXI_RREADY   <= '0'; 
	


--Base address is 0x10000000
M_AXI_AWADDR <= "0001" & axi_awaddr_i;

M_AXI_WDATA <= FIFO_RDDATA;


process (M_AXI_ACLK, M_AXI_ARESETN, TX_ENB)
   begin
      if (M_AXI_ARESETN = '0') or (TX_ENB = '0') then
		   axi_awaddr_i <= x"0000000"; --(others => '0');
		   M_AXI_AWVALID	<= '0';
		   M_AXI_AWBURST    <= "00";
		   M_AXI_AWCACHE	<= "0000";
		   M_AXI_AWLEN  	<= x"00";
		   M_AXI_AWPROT 	<= "000";
		   M_AXI_AWSIZE 	<= "000";

		   --axi_wdata   <= (others => '0');
		   FIFO_RDEN        <= '0';
		   M_AXI_WVALID	    <= '0';
		   M_AXI_WLAST  	<= '0';
		   M_AXI_WSTRB      <= x"00"; 
		   M_AXI_AWID       <= (others => '0');
		   M_AXI_AWQOS      <= "0000";
			
		   M_AXI_BREADY   	<= '0';
		   
		   TX_ACTIVE        <= '0';
			
		   burstcnt <= 0;	
	       state <= idle;

			
    elsif (M_AXI_ACLK'event and M_AXI_ACLK = '1') then
        case state is
           when IDLE => 
                 burstcnt <= 0;
				 M_AXI_BREADY <= '1';					 --response always ready
					
				 if (FIFO_RDCNT >= "100000000")  then
					TX_ACTIVE <= '1';
					M_AXI_AWVALID <= '1';
				    M_AXI_AWBURST <= "01"; 			-- incrementing address type
					M_AXI_AWLEN   <= x"FF";   			-- 256 transfer per burst
					M_AXI_AWSIZE  <= "011";            -- 8 bytes per beat					
					burstcnt <= 0;			
					M_AXI_WSTRB   <= x"FF";			
					state <= addr_active;
				end if;
				
				
			when ADDR_ACTIVE =>
				--address transaction
				if (M_AXI_AWREADY = '1') then
					M_AXI_AWVALID <= '0';
					M_AXI_WVALID  <= '1';					
					state <= data_active;
				end if;
				
				
			when DATA_ACTIVE =>				
				if (M_AXI_WREADY = '1') then
				    M_AXI_WVALID <= '0';
				    FIFO_RDEN <= '1';
				    state <= burst;
				end if;
				    
					
			when BURST =>		
				--data transaction
				-- could have problems if axi_wready goes low in the 
				-- middle of the burst.
				M_AXI_WVALID <= '1';
				--if (axi_wready = '1') then
				    FIFO_RDEN <= '1';
				    --axi_wdata <= fifo_rddata;
				    if (burstcnt = 254) then
				        M_AXI_WLAST <= '1';
                        state <= hold;
                    else
                        burstcnt <= burstcnt + 1;
				    end if;
				--else
				--    fifo_rden <= '0';
				--end if;

			when HOLD =>
			    TX_ACTIVE  <= '0';
			    FIFO_RDEN <= '0'; 
				M_AXI_WVALID <= '0';
				M_AXI_WLAST  <= '0';
				M_AXI_WSTRB <= x"00"; 		
			    if (M_AXI_BVALID = '1') then
					if (axi_awaddr_i < x"7F00000") then
						axi_awaddr_i <= axi_awaddr_i +  2048;
					else
					    axi_awaddr_i <= (others => '0');
					end if;
				    state <= idle;
				end if;
					
					
			when others =>
			    state <= IDLE;
          end case;			 
      end if;
   end process;


	
	
	

end implementation;
