module 		key_top  		(	
            input 		    clk                 ,	
            input 		    rst                 ,
            input           key_1               ,           //幅度按键＋	
            input           key_2               ,           //幅度按键-	
            input           key_3               ,           //频率按键＋	
            input           key_4               ,           //频率按键-

            output   reg    key_amp_add         ,
            output   reg    key_amp_redu        ,
            output   reg    key_fre_add         ,
            output   reg    key_fre_redu        
);  
//把按键key_flag_amp_redu && (~key_value_amp_redu) 合并输出
always@(posedge clk or negedge rst)begin
    if(!rst)									
        key_amp_add <= 0;                                                
    else if(key_flag_amp_add && (~key_value_amp_add))									
        key_amp_add <= 1; 
    else 
        key_amp_add <= 0;                                                
    end										
always@(posedge clk or negedge rst)begin
    if(!rst)									
        key_amp_redu <= 0;                                                
    else if(key_flag_amp_redu && (~key_value_amp_redu))									
        key_amp_redu <= 1; 
    else 
        key_amp_redu <= 0;                                                
    end										
always@(posedge clk or negedge rst)begin
    if(!rst)									
        key_fre_add <= 0;                                                
    else if(key_flag_fre_add && (~key_value_fre_add))									
        key_fre_add <= 1; 
    else 
        key_fre_add <= 0;                                                
    end										
always@(posedge clk or negedge rst)begin
    if(!rst)									
        key_fre_redu <= 0;                                                
    else if(key_flag_fre_redu && (~key_value_fre_redu))									
        key_fre_redu <= 1; 
    else 
        key_fre_redu <= 0;                                                
    end										


key_debounce u1_key_debounce(
	.sys_clk		(clk                ),              //外部50M时钟
	.sys_rst_n		(rst                ),        	    //外部复位信号，低有效
	.key			(key_1              ),             	//外部按键输入
	.key_flag		(key_flag_amp_add   ),         		//按键数据有效信号
	.key_value		(key_value_amp_add  )         		//按键消抖后的数据  
    );

key_debounce u2_key_debounce(
	.sys_clk		(clk                ),          		//外部50M时钟
	.sys_rst_n		(rst                ),        			//外部复位信号，低有效
	.key			(key_2              ),              	//外部按键输入
	.key_flag		(key_flag_amp_redu  ),         			//按键数据有效信号
	.key_value		(key_value_amp_redu )        			//按键消抖后的数据  
    );
key_debounce u3_key_debounce(
	.sys_clk		(clk                ),          		//外部50M时钟
	.sys_rst_n		(rst                ),        			//外部复位信号，低有效
	.key			(key_3              ),              	//外部按键输入
	.key_flag		(key_flag_fre_add   ),         			//按键数据有效信号
	.key_value		(key_value_fre_add  )        			//按键消抖后的数据  
    );
key_debounce u4_key_debounce(
	.sys_clk		(clk                ),          		//外部50M时钟
	.sys_rst_n		(rst                ),        			//外部复位信号，低有效
	.key			(key_4              ),              	//外部按键输入
	.key_flag		(key_flag_fre_redu  ),         			//按键数据有效信号
	.key_value		(key_value_fre_redu )        			//按键消抖后的数据  
    );
endmodule