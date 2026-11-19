module lcd_driver
(
input           lcd_clk         ,     //lcd模块驱动时钟
input           sys_rst_n       ,     //复位信号
//RGB LCD接口                        
output          lcd_hs          ,     //LCD 行同步信号
output          lcd_vs          ,     //LCD 场同步信号
output          lcd_de          ,     //LCD 数据输入使能
output  [15:0]  lcd_rgb         ,     //LCD RGB565颜色数据
output          lcd_bl          ,     //LCD 背光控制信号
output          lcd_rst         ,     //LCD 复位信号
output          lcd_pclk        ,     //LCD 采样时钟
 
 output			  data_req      ,

input   [15:0]  pixel_data      ,   //像素点数据
output  [10:0]  pixel_xpos      ,   //像素点横坐标
output  [10:0]  pixel_ypos          //像素点纵坐标
);                             
 

//parameter define
parameter H_SYNC    =   11'd1    ,   //行同步
          H_BACK    =   11'd46   ,   //行时序后沿
          H_VALID   =   11'd800  ,   //行有效数据
          H_FRONT   =   11'd210  ,   //行时序前沿
          H_TOTAL   =   11'd1057 ;   //行扫描周期

parameter V_SYNC    =   11'd1    ,   //场同步
          V_BACK    =   11'd23   ,   //场时序后沿
          V_VALID   =   11'd480  ,   //场有效数据
          V_FRONT   =   11'd22   ,   //场时序前沿
          V_TOTAL   =   11'd526  ;   //场扫描周期

//wire  define
wire            rgb_valid       ;   //VGA有效显示区域

//reg   define
reg     [10:0]   cnt_h   ;   //行扫描计数器
reg     [10:0]   cnt_v   ;   //场扫描计数器


//O_tft_clk,lcd_de,tft_bl：TFT像素时钟、数据使能、背光信号
assign  O_tft_clk = lcd_clk    ;
assign  lcd_de  = rgb_valid     ;
assign  lcd_bl  = sys_rst_n     ;
assign lcd_rst  = 1'b1;           //RGB LCD显示模块系统复位信号
assign lcd_pclk = lcd_clk;        //RGB LCD显示模块采样时钟


//cnt_h:行同步信号计数器
always@(posedge lcd_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_h   <=  11'd0   ;
    else    if(cnt_h == H_TOTAL - 1'd1)
        cnt_h   <=  11'd0   ;
    else
        cnt_h   <=  cnt_h + 1'd1   ;

//lcd_hs:行同步信号
assign  lcd_hs = (cnt_h  <=  H_SYNC - 1'd1) ? 1'b1 : 1'b0  ;

//cnt_v:场同步信号计数器
always@(posedge lcd_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_v   <=  11'd0 ;
    else    if((cnt_v == V_TOTAL - 1'd1) &&  (cnt_h == H_TOTAL-1'd1))
        cnt_v   <=  11'd0 ;
    else    if(cnt_h == H_TOTAL - 1'd1)
        cnt_v   <=  cnt_v + 1'd1 ;
    else
        cnt_v   <=  cnt_v ;

//lcd_vs:场同步信号
assign  lcd_vs = (cnt_v  <=  V_SYNC - 1'd1) ? 1'b1 : 1'b0  ;

//rgb_valid:VGA有效显示区域
assign  rgb_valid = (((cnt_h >= H_SYNC + H_BACK)
                    && (cnt_h < H_SYNC + H_BACK + H_VALID))
                    &&((cnt_v >= V_SYNC + V_BACK)
                    && (cnt_v < V_SYNC + V_BACK + V_VALID)))
                    ? 1'b1 : 1'b0;

//data_req:像素点色彩信息请求信号,超前rgb_valid信号一个时钟周期
assign  data_req = (((cnt_h >= H_SYNC + H_BACK - 1'b1)
                    && (cnt_h < H_SYNC + H_BACK + H_VALID - 1'b1))
                    &&((cnt_v >= V_SYNC + V_BACK)
                    && (cnt_v < V_SYNC + V_BACK + V_VALID)))
                    ? 1'b1 : 1'b0;

//pixel_xpos,pixel_ypos:VGA有效显示区域像素点坐标
assign  pixel_xpos = (data_req == 1'b1)
                ? (cnt_h - (H_SYNC + H_BACK - 1'b1)) : 11'h3ff;
assign  pixel_ypos = (data_req == 1'b1)
                ? (cnt_v - (V_SYNC + V_BACK )) : 11'h3ff;

//lcd_rgb:输出像素点色彩信息
assign  lcd_rgb = (rgb_valid == 1'b1) ? pixel_data : 16'b0 ;

endmodule 