`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/14/2015 02:56:06 PM
// Design Name: 
// Module Name: evr_top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//
//	SFP 5    - X0Y1
//	SFP 6    - X0Y2   --- EVR Port
//
// 
//////////////////////////////////////////////////////////////////////////////////


module evr_top(

    input wire  Q0_CLK1_GTREFCLK_PAD_N_IN,	// 312.5 MHz
    input wire  Q0_CLK1_GTREFCLK_PAD_P_IN,
    input  wire         RXN_IN,
    input  wire         RXP_IN,

    input wire  drp_clk_in,
    //input wire  DRP_CLK_IN_P,		//200 MHz system clock
    //input wire  DRP_CLK_IN_N,
    input wire [7:0] trignum,
    input wire [31:0] trigdly,	
    output wire tbtclk,
    output wire fatrig,
    output wire satrig,
    output wire usrtrig,
    output wire gpstick,
    output wire [63:0] timestamp,
	output wire	[19:0] DBG_PIN	

    );
	


//    (* mark_debug = "true" *)  wire [1:0] gt0_rxcharisk_i;
//    (* mark_debug = "true" *)  wire [15:0] gt0_rxdata_i;
//    (* mark_debug = "true" *)  wire [7:0] 	EventStream;
//    (* mark_debug = "true" *)  wire [7:0] 	DataStream;
//    (* mark_debug = "true" *)  wire [4:0] 	Position;
//    (* mark_debug = "true" *)  wire [31:0] 	Seconds;	
//    (* mark_debug = "true" *)  wire [31:0] 	Offset;	
//    (* mark_debug = "true" *)  wire tsEventClock;	

//    (* mark_debug = "true" *)  wire fatrig;
//    (* mark_debug = "true" *)  wire satrig;
//    (* mark_debug = "true" *)  wire tbtclk;
            
    wire [1:0] gt0_rxcharisk_i;
    wire [15:0] gt0_rxdata_i;
    wire [7:0] 	EventStream;
    wire [7:0] 	DataStream;
    wire [4:0] 	Position;
    wire [31:0] 	Seconds;	
    wire [31:0] 	Offset;	
    wire tsEventClock;	

    wire fatrig;
    wire satrig;
    wire tbtclk;                	   
    


    wire sysclk_in_i;	
    wire locked;
    wire	gt0_rxusrclk2_i;
    wire	LocalReset;
    //wire [15:0] gt0_rxdata_i;
    wire	track_data_out;

	wire 	[63:0] 	timestamp;
	//wire [31:0] Seconds;
	//wire [31:0] Offset;
	//wire [4:0] Position;
    //wire tsEventClock;	






assign tbtclk = DataStream[0];
assign {DataStream[7:0], EventStream[7:0]} = gt0_rxdata_i;




//always @ (posedge Clock)
//	begin
//		if (evr_usrtrig = EventStream == 8'h7d) Offset <= 32'd0;
//		else Offset <= (Offset + 1);
//	end





/* clock generator */
// generate the 60MHz DRP clk
//clk_wiz_0 clk_wiz_inst
//(
//	// Clock in ports
//	.clk_in1_p(DRP_CLK_IN_P),
//	.clk_in1_n(DRP_CLK_IN_N),
//	// Clock out ports  
//	.clk_out1(sysclk_in_i),
//	// Status and control signals               
//	.reset(1'b0), 
//	.locked(locked)            
//);	
	
	
	
// GTX wrapper from example design
evr_gtx_wrapper 	evr_gtx_wrapper
(
    .Q0_CLK1_GTREFCLK_PAD_N_IN(Q0_CLK1_GTREFCLK_PAD_N_IN),	// 312.5 MHz
    .Q0_CLK1_GTREFCLK_PAD_P_IN(Q0_CLK1_GTREFCLK_PAD_P_IN),
	.sysclk_in_i(drp_clk_in),		//60 MHz clock
    .RXN_IN(RXN_IN),
    .RXP_IN(RXP_IN),
	.LocalReset(LocalReset),
	.gtxRxClk(gt0_rxusrclk2_i),
	.gtxRxData(gt0_rxdata_i),
	.gtxRxcharisk(gt0_rxcharisk_i),
	.track_data_out(track_data_out)
		
);

	
// timestamp decoder
timeofDayReceiver timestampReceiver 
(
	 .Clock(gt0_rxusrclk2_i), 
     .Reset(LocalReset), 
	 .EventStream(EventStream), 
	 .TimeStamp(timestamp), 
	 .Seconds(Seconds), 
	 .Offset(Offset), 
	 .Position(Position), 
	 .eventClock(tsEventClock)
 );




	
// 1 Hz GPS tick	
evr_EventReceiverChannel evr_gps
(
	.Clock(gt0_rxusrclk2_i), 
	.Reset(LocalReset),
	.eventStream(EventStream), 
    .myEvent(8'd125),  // 1Hz GPS event
    .myDelay(32'h0001),  
	.myWidth(32'h0175),  //creates a pulse about 3us long  
	.myPolarity(1'b0), 
	.trigger(gpstick)
);	
		
		
// 10 Hz 	
evr_EventReceiverChannel evr_sa
(
	.Clock(gt0_rxusrclk2_i), 
	.Reset(LocalReset),
	.eventStream(EventStream), 
    .myEvent(8'd30),  // 10Hz event
    .myDelay(32'h0001),  
	.myWidth(32'h0175),  //creates a pulse about 3us long  
	.myPolarity(1'b0), 
	.trigger(satrig)
);

	
// 10 KHz 	
evr_EventReceiverChannel evr_fa
(
	.Clock(gt0_rxusrclk2_i), 
	.Reset(LocalReset),
	.eventStream(EventStream), 
    .myEvent(8'd31),  // 10Hz event
    .myDelay(32'h0001),  
	.myWidth(32'h0175),   //creates a pulse about 3us long  
	.myPolarity(1'b0), 
	.trigger(fatrig)
);
	
// on-demand 	
evr_EventReceiverChannel evr_usr
(
	.Clock(gt0_rxusrclk2_i), 
	.Reset(LocalReset),
	.eventStream(EventStream), 
    .myEvent(trignum),  // 10Hz event
    .myDelay(trigdly),  
	.myWidth(32'h0175),   //creates a pulse about 3us long  
	.myPolarity(1'b0), 
	.trigger(usrtrig)
);
		
	
	
		
	

		 
		 
		 


assign DBG_PIN[0] = 0;
assign DBG_PIN[1] = 0;
assign DBG_PIN[2] = track_data_out;
assign DBG_PIN[3] = tsEventClock;
assign DBG_PIN[5] = 0;
assign DBG_PIN[6] = 0;
assign DBG_PIN[7] = 0;
	
assign DBG_PIN[8] = 0;
assign DBG_PIN[9] = 0;
		
assign DBG_PIN[19] = locked;

			 
endmodule
