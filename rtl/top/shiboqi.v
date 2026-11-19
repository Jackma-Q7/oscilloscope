module   shiboqi    (  
    input                       clk                 ,  
    input                       rst                 ,
    input                       key_1               ,//幅度按键＋
    input                       key_2               ,//幅度按键-
    input                       key_3               ,//频率按键＋
    input                       key_4               ,//频率按键-

    //AD芯片接口        
    input       [7:0]           ad_data             ,  //AD输入数据
    output  wire                 ad_clk              ,   //AD(AD9280)驱动时钟,最大支持32Mhz时钟 

    output                      clk_5m              ,   //测试 
    output                      lcd_hs              ,   //LCD 行同步信号
    output                      lcd_vs              ,   //LCD 场同步信号
    output                      lcd_de              ,   //LCD 数据输入使能
    output      [15:0]          lcd_rgb             ,   //LCD RGB565颜色数据
    output                      lcd_bl              ,   //LCD 背光控制信号
    output                      lcd_rst             ,   //LCD 复位信号
    output                      lcd_pclk                //LCD 采样时钟          
);
parameter CLK_FS = 26'd50000000;    // 频率计基准时钟频率50Mhz
wire    [7:0 ]          fifo_data               ;          
wire    [10:0]          address                 ;      
wire    [10:0 ]         ram_addr                ;            
wire    [10:0 ]         pixel_ypos_w            ;                
wire                    key_amp_add             ;            
wire                    key_amp_redu            ;              
wire                    key_fre_add             ;          
wire                    key_fre_redu            ;              
wire                    lcd_clk_w               ;          
wire                    full                    ;      
wire    [7:0 ]          data_i                  ;      
wire    [7:0 ]          data                    ;      
reg     [1:0]           ram_addr_dly            ;              
reg     [1:0]           pixel_ypos_w_dly        ;                  
reg                     fifo_rd                 ;      
reg     [10:0]          cnt_y                   ;      
wire                    data_req                ;          
wire                    clk_100m                ;          
wire                    clk_1m                  ;          
wire                    locked_w                ;          
wire    [29:0]          ad_freq                 ;          

wire    [ 7:0]          ad_vpp                  ;      //AD输入信号峰峰值
wire    [ 7:0]          ad_max                  ;      //AD输入信号最大值
wire    [ 7:0]          ad_min                  ;      //AD输入信号最小值
wire    [15:0]          wraddress               ;
wire                    deci_valid              ;

//pll
pll_top  u_pll_top(                  //时钟分频模块
        .inclk0                     (clk                        ),    
        .areset                     (~rst                       ),

        .c0                         (clk_100m                   ),   
        .c1                         (clk_1m                     ),//5m
        .c2                         (clk_5m                     ),//1m
        .locked                     (locked_w                   )
); 

adram uad_ram2 (
            .data                       (ad_data                    ), 
            .wraddress                  (wraddress                  ),     
            .wrclock                    (ad_clk                     ),     
            .wren                       (deci_valid                 ), 
            .rdaddress                  (ram_addr                   ),     
            .rdclock                    (lcd_clk_w                  ),     
            .rden                       (data_req                   ), 
            .q                          (data_i                     )
    );

OSR u_OSR(  
            .clk                        (clk                        ),  
            .rst_n                      (rst                        ),
            .ad_freq                    (ad_freq                    ),
             
            .ad_clk                     (ad_clk                     ), 
            .deci_valid                 (deci_valid                 ),
            .wraddress                  (wraddress                  )
);


    key_top   u_key_top  (  
            .clk                        (clk                        ),  
            .rst                        (rst                        ),
            .key_1                      (key_1                      ),                        //幅度按键＋  
            .key_2                      (key_2                      ),                        //幅度按键-  
            .key_3                      (key_3                      ),                        //频率按键＋  
            .key_4                      (key_4                      ),                        //频率按键-
            .key_amp_add                (key_amp_add                ),           
            .key_amp_redu               (key_amp_redu               ),          
            .key_fre_add                (key_fre_add                ),           
            .key_fre_redu               (key_fre_redu               )
    );
    lcd_rgb_char u_lcd_rgb_char(
            .sys_clk                    (clk                        ),        //系统时钟
            .sys_rst_n                  (rst                        ),      //复位信号                
            .lcd_hs                     (lcd_hs                     ),         //LCD 行同步信号
            .lcd_vs                     (lcd_vs                     ),         //LCD 场同步信号
            .lcd_de                     (lcd_de                     ),         //LCD 数据输入使能
            .lcd_rgb                    (lcd_rgb                    ),        //LCD RGB565颜色数据
            .lcd_bl                     (lcd_bl                     ),         //LCD 背光控制信号
            .lcd_rst                    (lcd_rst                    ),        //LCD 复位信号
            .lcd_pclk                   (lcd_pclk                   ),        //LCD 采样时钟
            .key_amp_add                (key_amp_add                ),                       
            .key_amp_redu               (key_amp_redu               ),                      
            .key_fre_add                (key_fre_add                ),                       
            .key_fre_redu               (key_fre_redu               ),                      
            .data_i                     (data_i                     ),  
            .lcd_clk_w                  (lcd_clk_w                  ),  
            .pixel_ypos_w               (pixel_ypos_w               ),
            .data_req                   (data_req                   ),   
            .ad_freq                    (ad_freq                    ),
            .ad_vpp                     (ad_vpp                     ),
            .ram_addr                   (ram_addr                   )
    );
  
    //参数测量模块，测量输入波形峰峰值和频率    
    param_measure #(
            .CLK_FS                     (CLK_FS                     )// 系统时钟频率值
    ) u_param_measure                         (
            .sys_clk                    (clk                        ),
            .rst_n                      (rst                        ),
            .trig_level                 ('d120                      ),
            .ad_clk                     (ad_clk                     ), 
            .clk_200m                   (clk_100m                   ),
            .ad_data                    (ad_data                    ),
            .ad_freq                    (ad_freq                    ),      // 频率
            .ad_vpp                     (ad_vpp                     ),       // 峰峰值
            .ad_max                     (ad_max                     ),
            .ad_min                     (ad_min                     )
    );  

    

    
endmodule

