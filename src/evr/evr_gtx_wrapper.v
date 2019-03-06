
`timescale 1ns / 1ps
`define DLY #1

(* DowngradeIPIdentifiedWarnings="yes" *)
//***********************************Entity Declaration************************
(* CORE_GENERATION_INFO = "evr_gtx,gtwizard_v3_4,{protocol_file=Start_from_scratch}" *)


module evr_gtx_wrapper #
(
    parameter EXAMPLE_CONFIG_INDEPENDENT_LANES     =   1,//configuration for frame gen and check
    parameter EXAMPLE_LANE_WITH_START_CHAR         =   0,         // specifies lane with unique start frame char
    parameter EXAMPLE_WORDS_IN_BRAM                =   512,       // specifies amount of data in BRAM
    parameter EXAMPLE_SIM_GTRESET_SPEEDUP          =   "TRUE",    // simulation setting for GT SecureIP model
    parameter EXAMPLE_USE_CHIPSCOPE                =   0,         // Set to 1 to use Chipscope to drive resets
    parameter STABLE_CLOCK_PERIOD                  =   16

)
(
    input wire  Q0_CLK1_GTREFCLK_PAD_N_IN,	// 312.5 MHz
    input wire  Q0_CLK1_GTREFCLK_PAD_P_IN,
	input 				sysclk_in_i,		//60 MHz clock
    input  wire         RXN_IN,
    input  wire         RXP_IN,
	output wire			LocalReset,
	output wire			gtxRxClk,
	output 		[15:0] 	gtxRxData,
	output		[1:0]   gtxRxcharisk,
	output		track_data_out
		
);


    wire soft_reset_i;
    //(*mark_debug = "TRUE" *) wire soft_reset_vio_i;

//************************** Register Declarations ****************************

    wire            gt_txfsmresetdone_i;
    wire            gt_rxfsmresetdone_i;
    (* ASYNC_REG = "TRUE" *)reg             gt_txfsmresetdone_r;
    (* ASYNC_REG = "TRUE" *)reg             gt_txfsmresetdone_r2;
    wire            gt0_txfsmresetdone_i;
    wire            gt0_rxfsmresetdone_i;
    (* ASYNC_REG = "TRUE" *)reg             gt0_rxresetdone_r;
    (* ASYNC_REG = "TRUE" *)reg             gt0_rxresetdone_r2;
    (* ASYNC_REG = "TRUE" *)reg             gt0_rxresetdone_r3;
    (* ASYNC_REG = "TRUE" *)reg             gt0_rxresetdone_vio_r;
    (* ASYNC_REG = "TRUE" *)reg             gt0_rxresetdone_vio_r2;
    (* ASYNC_REG = "TRUE" *)reg             gt0_rxresetdone_vio_r3;

    reg [5:0] reset_counter = 0;
    reg     [3:0]   reset_pulse;

//**************************** Wire Declarations ******************************//
    //------------------------ GT Wrapper Wires ------------------------------
    //________________________________________________________________________
    //________________________________________________________________________
    //GT0  (X1Y0)
    //------------------------------- CPLL Ports -------------------------------
    wire            gt0_cpllfbclklost_i;
    wire            gt0_cplllock_i;
    wire            gt0_cpllrefclklost_i;
    wire            gt0_cpllreset_i;
    //-------------------------- Channel - DRP Ports  --------------------------
    wire    [8:0]   gt0_drpaddr_i;
    wire    [15:0]  gt0_drpdi_i;
    wire    [15:0]  gt0_drpdo_i;
    wire            gt0_drpen_i;
    wire            gt0_drprdy_i;
    wire            gt0_drpwe_i;
    //------------------------- Digital Monitor Ports --------------------------
    wire    [7:0]   gt0_dmonitorout_i;
    //------------------- RX Initialization and Reset Ports --------------------
    wire            gt0_eyescanreset_i;
    wire            gt0_rxuserrdy_i;
    //------------------------ RX Margin Analysis Ports ------------------------
    wire            gt0_eyescandataerror_i;
    wire            gt0_eyescantrigger_i;
    //---------------- Receive Ports - FPGA RX interface Ports -----------------
    wire    [15:0]  gt0_rxdata_i;
    //---------------- Receive Ports - RX 8B/10B Decoder Ports -----------------
    wire    [1:0]   gt0_rxdisperr_i;
    wire    [1:0]   gt0_rxnotintable_i;
    //------------------------- Receive Ports - RX AFE -------------------------
    wire            gt0_gtxrxp_i;
    //---------------------- Receive Ports - RX AFE Ports ----------------------
    wire            gt0_gtxrxn_i;
    //------------ Receive Ports - RX Byte and Word Alignment Ports ------------
    wire            gt0_rxcommadet_i;
    wire            gt0_rxmcommaalignen_i;
    wire            gt0_rxpcommaalignen_i;
    //------------------- Receive Ports - RX Equalizer Ports -------------------
    wire            gt0_rxdfelpmreset_i;
    wire    [6:0]   gt0_rxmonitorout_i;
    wire    [1:0]   gt0_rxmonitorsel_i;
    //------------- Receive Ports - RX Fabric Output Control Ports -------------
    wire            gt0_rxoutclk_i;
    //----------- Receive Ports - RX Initialization and Reset Ports ------------
    wire            gt0_gtrxreset_i;
    wire            gt0_rxpmareset_i;
    //----------------- Receive Ports - RX8B/10B Decoder Ports -----------------
    wire    [1:0]   gt0_rxchariscomma_i;
    wire    [1:0]   gt0_rxcharisk_i;
    //------------ Receive Ports -RX Initialization and Reset Ports ------------
    wire            gt0_rxresetdone_i;
    //------------------- TX Initialization and Reset Ports --------------------
    wire            gt0_gttxreset_i;

    //____________________________COMMON PORTS________________________________
    //----------- Common Block  - Dynamic Reconfiguration Port (DRP) -----------
    wire    [7:0]   gt0_drpaddr_common_i;
    wire    [15:0]  gt0_drpdi_common_i;
    wire    [15:0]  gt0_drpdo_common_i;
    wire            gt0_drpen_common_i;
    wire            gt0_drprdy_common_i;
    wire            gt0_drpwe_common_i;
    //----------------------- Common Block - QPLL Ports ------------------------
    wire            gt0_qplllock_i;
    wire            gt0_qpllrefclklost_i;
    wire            gt0_qpllreset_i;


    //----------------------------- Global Signals -----------------------------

    wire            drpclk_in_i;
    wire            gt0_tx_system_reset_c;
    wire            gt0_rx_system_reset_c;
    wire            tied_to_ground_i;
    wire    [63:0]  tied_to_ground_vec_i;
    wire            tied_to_vcc_i;
    wire    [7:0]   tied_to_vcc_vec_i;
    wire            GTTXRESET_IN;
    wire            GTRXRESET_IN;
    wire            CPLLRESET_IN;
    wire            QPLLRESET_IN;

     //--------------------------- User Clocks ---------------------------------
     wire            gt0_txusrclk_i; 
     wire            gt0_txusrclk2_i; 
     wire            gt0_rxusrclk_i; 
     wire            gt0_rxusrclk2_i; 
 
    //--------------------------- Reference Clocks ----------------------------
    
    //wire            q0_clk1_refclk_i;


    //--------------------- Frame check/gen Module Signals --------------------
    wire            gt0_matchn_i;
    
    wire    [5:0]   gt0_txcharisk_float_i;
   
    wire    [15:0]  gt0_txdata_float16_i;
    wire    [43:0]  gt0_txdata_float_i;
    
    
    wire            gt0_block_sync_i;
    wire            gt0_track_data_i;
    wire    [7:0]   gt0_error_count_i;
    wire            gt0_frame_check_reset_i;
    wire            gt0_inc_in_i;
    wire            gt0_inc_out_i;
    wire    [15:0]  gt0_unscrambled_data_i;

    wire            reset_on_data_error_i;
    //wire            track_data_out_i;
  



    wire            gttxreset_i;
    wire            gtrxreset_i;

    wire            user_tx_reset_i;
    wire            user_rx_reset_i;
    wire            tx_vio_clk_i;
    wire            tx_vio_clk_mux_out_i;    
    wire            rx_vio_ila_clk_i;
    wire            rx_vio_ila_clk_mux_out_i;

    wire            cpllreset_i;
    


//**************************** Main Body of Code *******************************

    //  Static signal Assigments    
    assign tied_to_ground_i             = 1'b0;
    assign tied_to_ground_vec_i         = 64'h0000000000000000;
    assign tied_to_vcc_i                = 1'b1;
    assign tied_to_vcc_vec_i            = 8'hff;



    
	
`ifdef AAAA	
	wire sysclk_in_i;	
	wire locked;
  clk_wiz_0 clk_wiz_inst
  (
     // Clock in ports
      .clk_in1_p(DRP_CLK_IN_P),
      .clk_in1_n(DRP_CLK_IN_N),
      // Clock out ports  
      .clk_out1(sysclk_in_i),
      // Status and control signals               
      .reset(1'b0), 
      .locked(locked)            
  );	
`endif	
	

    //***********************************************************************//
    //                                                                       //
    //--------------------------- The GT Wrapper ----------------------------//
    //                                                                       //
    //***********************************************************************//
    
    // Use the instantiation template in the example directory to add the GT wrapper to your design.
    // In this example, the wrapper is wired up for basic operation with a frame generator and frame 
    // checker. The GTs will reset, then attempt to align and transmit data. If channel bonding is 
    // enabled, bonding should occur after alignment.

    
    evr_gtx_support #
    (
        .EXAMPLE_SIM_GTRESET_SPEEDUP    (EXAMPLE_SIM_GTRESET_SPEEDUP),
        .STABLE_CLOCK_PERIOD            (STABLE_CLOCK_PERIOD)
    )
    evr_gtx_support_i
    (
		.soft_reset_in                  (soft_reset_i),
		.dont_reset_on_data_error_in    (tied_to_ground_i),
		.q0_clk1_gtrefclk_pad_n_in(Q0_CLK1_GTREFCLK_PAD_N_IN),
		.q0_clk1_gtrefclk_pad_p_in(Q0_CLK1_GTREFCLK_PAD_P_IN),
		.gt0_tx_fsm_reset_done_out      (gt0_txfsmresetdone_i),
		.gt0_rx_fsm_reset_done_out      (gt0_rxfsmresetdone_i),
		.gt0_data_valid_in              (gt0_track_data_i),

		.gt0_rxusrclk_out(gt0_rxusrclk_i),
		.gt0_rxusrclk2_out(gt0_rxusrclk2_i),


        //_____________________________________________________________________
        //_____________________________________________________________________
        //GT0  (X1Y0)

        //------------------------------- CPLL Ports -------------------------------
        .gt0_cpllfbclklost_out          (gt0_cpllfbclklost_i),
        .gt0_cplllock_out               (gt0_cplllock_i),
        .gt0_cpllreset_in               (tied_to_ground_i),
        //-------------------------- Channel - DRP Ports  --------------------------
        .gt0_drpaddr_in                 (gt0_drpaddr_i),
        .gt0_drpdi_in                   (gt0_drpdi_i),
        .gt0_drpdo_out                  (gt0_drpdo_i),
        .gt0_drpen_in                   (gt0_drpen_i),
        .gt0_drprdy_out                 (gt0_drprdy_i),
        .gt0_drpwe_in                   (gt0_drpwe_i),
        //------------------------- Digital Monitor Ports --------------------------
        .gt0_dmonitorout_out            (gt0_dmonitorout_i),
        //------------------- RX Initialization and Reset Ports --------------------
        .gt0_eyescanreset_in            (tied_to_ground_i),
        .gt0_rxuserrdy_in               (tied_to_ground_i),
        //------------------------ RX Margin Analysis Ports ------------------------
        .gt0_eyescandataerror_out       (gt0_eyescandataerror_i),
        .gt0_eyescantrigger_in          (tied_to_ground_i),
        //---------------- Receive Ports - FPGA RX interface Ports -----------------
        .gt0_rxdata_out                 (gt0_rxdata_i),
        //---------------- Receive Ports - RX 8B/10B Decoder Ports -----------------
        .gt0_rxdisperr_out              (gt0_rxdisperr_i),
        .gt0_rxnotintable_out           (gt0_rxnotintable_i),
        //------------------------- Receive Ports - RX AFE -------------------------
        .gt0_gtxrxp_in                  (RXP_IN),
        //---------------------- Receive Ports - RX AFE Ports ----------------------
        .gt0_gtxrxn_in                  (RXN_IN),
        //------------ Receive Ports - RX Byte and Word Alignment Ports ------------
        .gt0_rxcommadet_out             (gt0_rxcommadet_i),
        .gt0_rxmcommaalignen_in         (gt0_rxmcommaalignen_i),
        .gt0_rxpcommaalignen_in         (gt0_rxpcommaalignen_i),
        //------------------- Receive Ports - RX Equalizer Ports -------------------
        .gt0_rxdfelpmreset_in           (tied_to_ground_i),
        .gt0_rxmonitorout_out           (gt0_rxmonitorout_i),
        .gt0_rxmonitorsel_in            (2'b00),
        //----------- Receive Ports - RX Initialization and Reset Ports ------------
        .gt0_gtrxreset_in               (tied_to_ground_i),
        .gt0_rxpmareset_in              (gt0_rxpmareset_i),
        //----------------- Receive Ports - RX8B/10B Decoder Ports -----------------
        .gt0_rxchariscomma_out          (gt0_rxchariscomma_i),
        .gt0_rxcharisk_out              (gt0_rxcharisk_i),
        //------------ Receive Ports -RX Initialization and Reset Ports ------------
        .gt0_rxresetdone_out            (gt0_rxresetdone_i),
        //------------------- TX Initialization and Reset Ports --------------------
        .gt0_gttxreset_in               (tied_to_ground_i),


		.gt0_drpaddr_common_in(8'b00000000),
		.gt0_drpdi_common_in(16'b0000000000000000),
		.gt0_drpdo_common_out(),
		.gt0_drpen_common_in(1'b0),
		.gt0_drprdy_common_out(),
		.gt0_drpwe_common_in(1'b0),
		//____________________________COMMON PORTS________________________________
		.gt0_qplloutclk_out(),
		.gt0_qplloutrefclk_out(),

		.sysclk_in_i ( sysclk_in_i )	// 60 MHz

    );

 
    //***********************************************************************//
    //                                                                       //
    //--------------------------- User Module Resets-------------------------//
    //                                                                       //
    //***********************************************************************//
    // All the User Modules i.e. FRAME_GEN, FRAME_CHECK and the sync modules
    // are held in reset till the RESETDONE goes high. 
    // The RESETDONE is registered a couple of times on *USRCLK2 and connected 
    // to the reset of the modules
    
always @(posedge gt0_rxusrclk2_i or negedge gt0_rxresetdone_i)

    begin
        if (!gt0_rxresetdone_i)
        begin
            gt0_rxresetdone_r    <=   `DLY 1'b0;
            gt0_rxresetdone_r2   <=   `DLY 1'b0;
            gt0_rxresetdone_r3   <=   `DLY 1'b0;
        end
        else
        begin
            gt0_rxresetdone_r    <=   `DLY gt0_rxresetdone_i;
            gt0_rxresetdone_r2   <=   `DLY gt0_rxresetdone_r;
            gt0_rxresetdone_r3   <=   `DLY gt0_rxresetdone_r2;
        end
    end

    
    assign gt0_frame_check_reset_i = (EXAMPLE_CONFIG_INDEPENDENT_LANES==0)?reset_on_data_error_i:gt0_matchn_i;

    // gt0_frame_check0 is always connected to the lane with the start of char 
    // and this lane starts off the data checking on all the other lanes. The INC_IN port is tied off
    assign gt0_inc_in_i = 1'b0;

    evr_gtx_GT_FRAME_CHECK #
    (
		.RX_DATA_WIDTH ( 16 ),
		.RXCTRL_WIDTH ( 2 ),
		.COMMA_DOUBLE ( 16'h02bc ),
		.WORDS_IN_BRAM(EXAMPLE_WORDS_IN_BRAM),
		.START_OF_PACKET_CHAR ( 16'h02bc )
    )
    gt0_frame_check
    (
        // GT Interface
        .RX_DATA_IN                     (gt0_rxdata_i),
        .RXCTRL_IN                      (gt0_rxcharisk_i),
        .RXENMCOMMADET_OUT              (gt0_rxmcommaalignen_i),
        .RXENPCOMMADET_OUT              (gt0_rxpcommaalignen_i),
        .RX_ENCHAN_SYNC_OUT             ( ),
        .RX_CHANBOND_SEQ_IN             (tied_to_ground_i),
        // Control Interface
        .INC_IN                         (gt0_inc_in_i),
        .INC_OUT                        (gt0_inc_out_i),
        .PATTERN_MATCHB_OUT             (gt0_matchn_i),
        .RESET_ON_ERROR_IN              (gt0_frame_check_reset_i),
        // System Interface
        .USER_CLK                       (gt0_rxusrclk2_i),
        .SYSTEM_RESET                   (gt0_rx_system_reset_c),
        .ERROR_COUNT_OUT                (gt0_error_count_i),
        .TRACK_DATA_OUT                 (gt0_track_data_i)
    );


    assign track_data_out = gt0_track_data_i ;


	//------------ optional Ports assignments --------------
	//------GTH/GTP
	assign  gt0_rxdfelpmreset_i                  =  tied_to_ground_i;
	assign  gt0_rxpmareset_i                     =  tied_to_ground_i;
	//------------------------------------------------------
	// assign resets for frame_gen modules

	// assign resets for frame_check modules
	assign  gt0_rx_system_reset_c = !gt0_rxresetdone_r3;

	assign gt0_drpaddr_i = 9'd0;
	assign gt0_drpdi_i = 16'd0;
	assign gt0_drpen_i = 1'b0;
	assign gt0_drpwe_i = 1'b0;
	assign soft_reset_i = tied_to_ground_i;
	
	
	
	assign 			LocalReset = !gt0_rxresetdone_i;	//reset
	assign			gtxRxClk   = gt0_rxusrclk2_i;		//RX clock 125 MHz
	assign			gtxRxData  = gt0_rxdata_i;			//Data
	assign          gtxRxcharisk = gt0_rxcharisk_i;     //K code
	
	
	

		
endmodule
    

