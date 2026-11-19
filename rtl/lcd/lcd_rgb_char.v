module lcd_rgb_char(
    input           sys_clk,        //系统时钟
    input           sys_rst_n,      //复位信号
    //key
    input           key_amp_add                  ,	
    input           key_amp_redu                 ,
    input           key_fre_add                  ,
    input           key_fre_redu                 ,
    //
    input   [7:0]   data_i                       ,  
    input   [29:0]  ad_freq                      ,  
    input   [7 :0]  ad_vpp                       ,  
    output  [10:0]  ram_addr                     ,          //像素点横坐标
    output wire [10:0]  pixel_ypos_w             ,          //像素点横坐标
        
    output wire     lcd_clk_w                    ,               //PLL分频得到33.3Mhz时钟
	 output			  data_req,
    //lcd接口                          
    output          lcd_hs,         //LCD 行同步信号
    output          lcd_vs,         //LCD 场同步信号
    output          lcd_de,         //LCD 数据输入使能
    output  [15:0]  lcd_rgb,        //LCD RGB565颜色数据
    output          lcd_bl,         //LCD 背光控制信号
    output          lcd_rst,        //LCD 复位信号
    output          lcd_pclk        //LCD 采样时钟
    );

//wire define
//wire         lcd_clk_w;             //PLL分频得到33.3Mhz时钟
wire         locked_w;              //PLL输出稳定信号
wire         rst_n_w;               //内部复位信号
wire [15:0]  pixel_data_w;          //像素点数据
(* keep *)wire [10:0]  pixel_xpos_w;          //像素点横坐标
//(* keep *)wire [10:0]  pixel_ypos_w;          //像素点纵坐标    

//待PLL输出稳定之后，停止复位
assign rst_n_w = sys_rst_n && locked_w;
   
lcd_pll	u_lcd_pll(                  //时钟分频模块
	.inclk0         (sys_clk),    
	.areset         (~sys_rst_n),
    
	.c0             (lcd_clk_w),    //lcd驱动时钟
	.locked         (locked_w)
	); 

lcd_driver u_lcd_driver(            //lcd驱动模块
    .lcd_clk        (lcd_clk_w),    
    .sys_rst_n      (rst_n_w),    

    .lcd_hs         (lcd_hs),       
    .lcd_vs         (lcd_vs),       
    .lcd_de         (lcd_de),       
    .lcd_rgb        (lcd_rgb),
    .lcd_bl         (lcd_bl),
    .lcd_rst        (lcd_rst),
    .lcd_pclk       (lcd_pclk),
	 .data_req		  (data_req),
    
    .pixel_data     (pixel_data_w), 
    .pixel_xpos     (pixel_xpos_w), 
    .pixel_ypos     (pixel_ypos_w)
    ); 

lcd_display u_lcd_display(
    .vga_clk        (lcd_clk_w),
    .sys_clk        (sys_clk),
    .sys_rst_n      (rst_n_w),

    //key
    .key_amp_add    (key_amp_add  ),	
    .key_amp_redu   (key_amp_redu ),
    .key_fre_add    (key_fre_add  ),
    .key_fre_redu   (key_fre_redu ),

    .ram_addr       (ram_addr    ),
    
    .pixel_xpos     (pixel_xpos_w),
    .pixel_ypos     (pixel_ypos_w),
    .pixel_data     (pixel_data_w),
    .ad_freq        (ad_freq     ),
    .ad_vpp         (ad_vpp      ), 
    .data_i         (data_i      )
    );     
endmodule 