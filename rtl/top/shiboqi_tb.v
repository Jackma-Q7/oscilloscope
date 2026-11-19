`timescale 1 ns / 1 ps
 //****************************************Copyright (c)***********************************//
//Copyright(C)  
//All rights reserved
//----------------------------------------------------------------------------------------
// File name:           
// Last modified Date:   2022/01/11 18:51:39
// Last Version:        V1.0
// Descriptions:        
//----------------------------------------------------------------------------------------
// Created by:          jiang quan cai 
// Created date:        2022/01/11 18:51:39
// Version:             V1.0
// Descriptions:        
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//
module 		shiboqi_tb  ();
            reg 		        clk;	
            reg 		        rst;	
    shiboqi  u_shiboqi		
    (	
		.clk        (clk	    ),	
		.rst        (rst        )
    );
initial begin
            #2 
            rst = 0;
            clk = 0;
            #2
            rst = 1;
                  
        end
        always #10 clk =~clk;
/*reg		[20:0]		cnt;
always@(posedge clk or negedge rst)begin
    if(!rst)							
        cnt <= 0; 
    else if(cnt == 'd4096)
        cnt <= 'd0;
    else 
        cnt <= cnt +1'b1;                                
    end									

assign address = cnt ;*/
endmodule