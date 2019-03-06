///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   / 
// /___/  \  /    Vendor: Xilinx 
// \   \   \/     Version : 3.4
//  \   \         Application : 7 Series FPGAs Transceivers  Wizard
//  /   /         Filename : evr_gtx_gt_usrclk_source.v
// /___/   /\      
// \   \  /  \ 
//  \___\/\___\ 
//
//
// Module evr_gtx_GT_USRCLK_SOURCE (for use with GTs)
// Generated by Xilinx 7 Series FPGAs Transceivers Wizard
// 
// 
// (c) Copyright 2010-2012 Xilinx, Inc. All rights reserved.
// 
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
// 
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
// 
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
// 
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES. 


`timescale 1ns / 1ps

//***********************************Entity Declaration*******************************

module evr_gtx_GT_USRCLK_SOURCE 
(
    input  wire  Q0_CLK1_GTREFCLK_PAD_N_IN,
    input  wire  Q0_CLK1_GTREFCLK_PAD_P_IN,
    output wire  Q0_CLK1_GTREFCLK_OUT,
 
    output          GT0_RXUSRCLK_OUT,
    output          GT0_RXUSRCLK2_OUT,
    input           GT0_RXOUTCLK_IN
	
/*
    input	        DRPCLK_IN_P,
    input	        DRPCLK_IN_N,
    output          DRPCLK_OUT
*/
);


`define DLY #1

//*********************************Wire Declarations**********************************
    wire            DRPCLK_IN;
    wire            tied_to_ground_i;
    wire            tied_to_vcc_i;
 
    wire            gt0_txoutclk_i; 
    wire            gt0_rxoutclk_i;
    wire  q0_clk1_gtrefclk /*synthesis syn_noclockbuf=1*/;

    wire            gt0_rxusrclk_i;


//*********************************** Beginning of Code *******************************

    //  Static signal Assigments    
    assign tied_to_ground_i             = 1'b0;
    assign tied_to_vcc_i                = 1'b1;
    assign gt0_rxoutclk_i = GT0_RXOUTCLK_IN;
     
    assign Q0_CLK1_GTREFCLK_OUT = q0_clk1_gtrefclk;

    //IBUFDS_GTE2
    IBUFDS_GTE2 ibufds_instQ0_CLK1  
    (
        .O               (q0_clk1_gtrefclk),
        .ODIV2           (),
        .CEB             (tied_to_ground_i),
        .I               (Q0_CLK1_GTREFCLK_PAD_P_IN),
        .IB              (Q0_CLK1_GTREFCLK_PAD_N_IN)
    );

	
	/*
    IBUFDS IBUFDS_DRP_CLK
     (
        .I  (DRPCLK_IN_P),
        .IB (DRPCLK_IN_N),
        .O  (DRPCLK_IN)
     );

    BUFG DRP_CLK_BUFG
    (
        .I                              (DRPCLK_IN),
        .O                              (DRPCLK_OUT) 
    );

*/

    // Instantiate a MMCM module to divide the reference clock. Uses internal feedback
    // for improved jitter performance, and to avoid consuming an additional BUFG

    BUFG rxoutclk_bufg0_i
    (
        .I                              (gt0_rxoutclk_i),
        .O                              (gt0_rxusrclk_i)
    );



 
assign GT0_RXUSRCLK_OUT = gt0_rxusrclk_i;
assign GT0_RXUSRCLK2_OUT = gt0_rxusrclk_i;

endmodule