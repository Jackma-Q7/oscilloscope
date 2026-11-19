module lcd_display(
    input               vga_clk                   ,                   //VGA驱动时钟
    input               sys_clk                   ,                   //系统时钟50M
    input               sys_rst_n                 ,                   //复位信号
    input       [7:0]   data_i                    ,   
    input       [29:0]  ad_freq                   , 
    input       [7 :0]  ad_vpp                    , 


    //key
    input           key_amp_add                   ,	
    input           key_amp_redu                  ,
    input           key_fre_add                   ,
    input           key_fre_redu                  ,
    
    output     [10:0]  ram_addr                   ,

    input      [10:0] pixel_xpos,               //像素点横坐标
    input      [10:0] pixel_ypos,               //像素点纵坐标    
    output reg [15:0] pixel_data                //像素点数据
    );    

//缩放按钮的显示位置
localparam  POS_Y_BUTTON = 'd224;
localparam  POS_Y_BUTTON_NUM = 'd224+'d16;
//
localparam POS_Y_NUM         = 11'd25;                    //字符区域起始点纵坐标
localparam POS_Y_DDS         = 11'd5;                    //字符区域起始点纵坐标

//字符显示

localparam POS_X  = 11'd3;                    //字符区域起始点横坐标
localparam POS_Y  = 11'd10;                    //字符区域起始点纵坐标
localparam WIDTH  = 11'd32;                    //字符区域宽度
localparam HEIGHT = 11'd32;                     //字符区域高度

localparam POS_X_FU          = 11'd150;                    //字符区域起始点横坐标
localparam POS_X_DU          = 11'd182;                    //字符区域起始点横坐标
localparam POS_X_FU_SHIWEI   = 11'd182 +'d32;                    //字符区域起始点横坐标
localparam POS_X_FU_GEWEI    = 11'd182 +'d32 +'d32;                    //字符区域起始点横坐标


localparam POS_X_NUM_BAIWEI  = 11'd3+'d64;                    //字符区域起始点横坐标
localparam POS_X_NUM_SHIWEI  = 11'd3+'d64+'d16;                    //字符区域起始点横坐标
localparam POS_X_NUM_GEWEI   = 11'd3+'d64+'d16+'d16;                    //字符区域起始点横坐标
localparam POS_X_NUM_K       = 'd3+'d64+'d16+'d16+'d16;                  //字符区域起始点横坐标
localparam POS_X_NUM_H       = 'd3+'d64+'d16+'d16+'d16+'d16;                  //字符区域起始点横坐标
localparam POS_X_NUM_Z       = 'd3+'d64+'d16+'d16+'d16+'d16+'d16;                    //字符区域起始点横坐标
localparam WIDTH_NUM         = 'd16;                    //字符区域宽度
localparam HEIGHT_NUM        = 'd16;                     //字符区域高度
//reg define
reg  [127:0] char[31:0];                        //字符数组
reg  [31 :0] char1[31:0];                        //字符数组
reg  [31 :0] char2[31:0];                        //字符数组
reg  [31 :0] char3[31:0];                        //字符数组
reg  [31 :0] char4[31:0];                        //字符数组
reg  [31 :0] num0[15:0];                        //字符数组
reg  [31 :0] num1[15:0];                        //字符数组
reg  [31 :0] num2[15:0];                        //字符数组
reg  [31 :0] num3[15:0];                        //字符数组
reg  [31 :0] num4[15:0];                        //字符数组
reg  [31 :0] num5[15:0];                        //字符数组
reg  [31 :0] num6[15:0];                        //字符数组
reg  [31 :0] num7[15:0];                        //字符数组
reg  [31 :0] num8[15:0];                        //字符数组
reg  [31 :0] num9[15:0];                        //字符数组
reg  [31 :0] char_k[15:0];                        //字符数组
reg  [31 :0] char_h[15:0];                        //字符数组
reg  [31 :0] char_z[15:0];                        //字符数组
reg  [31 :0] char_d[15:0];                        //字符数组
reg  [31 :0] char_s[15:0];                        //字符数组
reg  [31 :0] char_dian[15:0];                        //字符数组

//wire define   
wire [10:0] x_cnt;
wire [10:0] y_cnt;

wire [10:0] y_cnt_button;
wire [10:0] y_cnt_button_num;

wire [10:0] x_cnt_fu ;
wire [10:0] x_cnt_du ;

wire [10:0] x_cnt_fu_shiwei;
wire [10:0] x_cnt_fu_gewei;
wire [10:0] x_cnt_num_baiwei;
wire [10:0] x_cnt_num_shiwei;
wire [10:0] x_cnt_num_gewei;
wire [10:0] x_cnt_num_k;
wire [10:0] x_cnt_num_h;
wire [10:0] x_cnt_num_z;

wire [10:0] y_cnt_num;
wire [10:0] y_cnt_dds;

wire    [10:0]gewei;
wire    [10:0]shiwei;
wire    [10:0]baiwei;
wire    [10:0]fudugewei;
wire    [10:0]fudushiwei;

assign gewei = (ad_freq/'d1000)           % 'd10; 
assign shiwei = (ad_freq/'d1000)/'d10     % 'd10; 
assign baiwei = (ad_freq/'d1000)/'d100    % 'd10; 
wire [7:0]  ad_vpp_reg;
assign ad_vpp_reg = (ad_vpp > 'd10) ? ad_vpp : 'dz; 

assign fudugewei  = (((ad_vpp *10)/25 )      % 'd10); 
assign fudushiwei = ((ad_vpp /25 *10) / 10   % 'd10); 

 										
assign x_cnt = pixel_xpos - POS_X;              //像素点相对于字符区域起始点水平坐标
assign y_cnt = pixel_ypos - POS_Y;              //像素点相对于字符区域起始点竖直坐标

assign y_cnt_button = pixel_ypos - POS_Y_BUTTON;              //像素点相对于字符区域起始点竖直坐标
assign y_cnt_button_num = pixel_ypos - POS_Y_BUTTON_NUM;              //像素点相对于字符区域起始点竖直坐标

                                    
assign x_cnt_fu     = pixel_xpos - POS_X_FU;              
assign x_cnt_du     = pixel_xpos - POS_X_DU;              
             
assign x_cnt_fu_shiwei = pixel_xpos - POS_X_FU_SHIWEI;              //像素点相对于字符区域起始点水平坐标
assign x_cnt_fu_gewei = pixel_xpos - POS_X_FU_GEWEI;              //像素点相对于字符区域起始点水平坐标
assign x_cnt_num_baiwei = pixel_xpos - POS_X_NUM_BAIWEI;              //像素点相对于字符区域起始点水平坐标
assign x_cnt_num_shiwei = pixel_xpos - POS_X_NUM_SHIWEI;              //像素点相对于字符区域起始点水平坐标
assign x_cnt_num_gewei = pixel_xpos - POS_X_NUM_GEWEI;              //像素点相对于字符区域起始点水平坐标
assign x_cnt_num_k = pixel_xpos - POS_X_NUM_K;              //像素点相对于字符区域起始点水平坐标
assign x_cnt_num_h = pixel_xpos - POS_X_NUM_H;              //像素点相对于字符区域起始点水平坐标
assign x_cnt_num_z = pixel_xpos - POS_X_NUM_Z;              //像素点相对于字符区域起始点水平坐标

assign y_cnt_num = pixel_ypos - POS_Y_NUM;              //像素点相对于字符区域起始点竖直坐标

assign y_cnt_dds = pixel_ypos - POS_Y_DDS;              //像素点相对于字符区域起始点竖直坐标


always @(posedge vga_clk) begin
    char1[0 ]  <= 'h00000000;
    char1[1 ]  <= 'h00000000;
    char1[2 ]  <= 'h00400000;
    char1[3 ]  <= 'h00600008;
    char1[4 ]  <= 'h0061FFFC;
    char1[5 ]  <= 'h00600300;
    char1[6 ]  <= 'h06600600;
    char1[7 ]  <= 'h06640400;
    char1[8 ]  <= 'h067E0408;
    char1[9 ]  <= 'h06607FFC;
    char1[10]  <= 'h06606018;
    char1[11]  <= 'h06606018;
    char1[12]  <= 'h06626218;
    char1[13]  <= 'h3FFF6398;
    char1[14]  <= 'h00406318;
    char1[15]  <= 'h00606318;
    char1[16]  <= 'h04406318;
    char1[17]  <= 'h06406318;
    char1[18]  <= 'h06426318;
    char1[19]  <= 'h0C476318;
    char1[20]  <= 'h0C466318;
    char1[21]  <= 'h184C6218;
    char1[22]  <= 'h104C6218;
    char1[23]  <= 'h20180700;
    char1[24]  <= 'h20300480;
    char1[25]  <= 'h00600C60;
    char1[26]  <= 'h00C01838;
    char1[27]  <= 'h0180301C;
    char1[28]  <= 'h0600600C;
    char1[29]  <= 'h08018004;
    char1[30]  <= 'h30060004;
    char1[31]  <= 'h00000000;//频
end
always @(posedge vga_clk) begin
    char2[0 ]  <= 'h00000000;
    char2[1 ]  <= 'h00000000;
    char2[2 ]  <= 'h00020000;
    char2[3 ]  <= 'h00038000;
    char2[4 ]  <= 'h00018000;
    char2[5 ]  <= 'h00018020;
    char2[6 ]  <= 'h1FFFFFF0;
    char2[7 ]  <= 'h00030000;
    char2[8 ]  <= 'h00030000;
    char2[9 ]  <= 'h0C061040;
    char2[10]  <= 'h070C38E0;
    char2[11]  <= 'h03983180;
    char2[12]  <= 'h013FE300;
    char2[13]  <= 'h0138C400;
    char2[14]  <= 'h00018000;
    char2[15]  <= 'h00430200;
    char2[16]  <= 'h008621C0;
    char2[17]  <= 'h030818E0;
    char2[18]  <= 'h0E3FFC30;
    char2[19]  <= 'h1C3D0C30;
    char2[20]  <= 'h08018800;
    char2[21]  <= 'h00018000;
    char2[22]  <= 'h00018018;
    char2[23]  <= 'h3FFFFFFC;
    char2[24]  <= 'h00018000;
    char2[25]  <= 'h00018000;
    char2[26]  <= 'h00018000;
    char2[27]  <= 'h00018000;
    char2[28]  <= 'h00018000;
    char2[29]  <= 'h00018000;
    char2[30]  <= 'h00010000;
    char2[31]  <= 'h00000000;//率
end
always @(posedge vga_clk) begin
    char3[0 ]  <= 'h00000000;
    char3[1 ]  <= 'h00000000;
    char3[2 ]  <= 'h01000000;
    char3[3 ]  <= 'h01800008;
    char3[4 ]  <= 'h0107FFFC;
    char3[5 ]  <= 'h01000000;
    char3[6 ]  <= 'h01000000;
    char3[7 ]  <= 'h21108040;
    char3[8 ]  <= 'h1FF8FFE0;
    char3[9 ]  <= 'h1118C060;
    char3[10]  <= 'h1118C060;
    char3[11]  <= 'h1118C060;
    char3[12]  <= 'h1118C060;
    char3[13]  <= 'h1118FFE0;
    char3[14]  <= 'h1118C060;
    char3[15]  <= 'h1118C000;
    char3[16]  <= 'h111A0000;
    char3[17]  <= 'h111BFFF8;
    char3[18]  <= 'h111B0418;
    char3[19]  <= 'h111B0418;
    char3[20]  <= 'h111B0418;
    char3[21]  <= 'h11130418;
    char3[22]  <= 'h1173FFF8;
    char3[23]  <= 'h11330418;
    char3[24]  <= 'h21030418;
    char3[25]  <= 'h01030418;
    char3[26]  <= 'h01030418;
    char3[27]  <= 'h01030418;
    char3[28]  <= 'h0103FFF8;
    char3[29]  <= 'h01030018;
    char3[30]  <= 'h01030018;
    char3[31]  <= 'h01020000;//幅0;
end
always @(posedge vga_clk) begin
    char4[0 ]  <= 'h00000000;
    char4[1 ]  <= 'h00000000;
    char4[2 ]  <= 'h00010000;
    char4[3 ]  <= 'h0000C000;
    char4[4 ]  <= 'h0000E010;
    char4[5 ]  <= 'h04004038;
    char4[6 ]  <= 'h07FFFFFC;
    char4[7 ]  <= 'h06040400;
    char4[8 ]  <= 'h06070700;
    char4[9 ]  <= 'h06060600;
    char4[10]  <= 'h06060630;
    char4[11]  <= 'h07FFFFF8;
    char4[12]  <= 'h06060600;
    char4[13]  <= 'h06060600;
    char4[14]  <= 'h06060600;
    char4[15]  <= 'h06060600;
    char4[16]  <= 'h0607FE00;
    char4[17]  <= 'h06060600;
    char4[18]  <= 'h04000100;
    char4[19]  <= 'h043FFF80;
    char4[20]  <= 'h0C040380;
    char4[21]  <= 'h0C020700;
    char4[22]  <= 'h0C030600;
    char4[23]  <= 'h08010C00;
    char4[24]  <= 'h0800D800;
    char4[25]  <= 'h18007000;
    char4[26]  <= 'h1000F800;
    char4[27]  <= 'h10039E00;
    char4[28]  <= 'h200E07F8;
    char4[29]  <= 'h207000F8;
    char4[30]  <= 'h47800010;
    char4[31]  <= 'h00000000;//度1;
end

    always @(posedge sys_clk or negedge sys_rst_n) 
        begin                                  
            num0[0 ]  <='h00000000;
            num0[1 ]  <='h00000000;
            num0[2 ]  <='h00000000;
            num0[3 ]  <='h07E00FF0;
            num0[4 ]  <='h1C383838;
            num0[5 ]  <='h381C301C;
            num0[6 ]  <='h700C700C;
            num0[7 ]  <='h700C700C;
            num0[8 ]  <='h700C700C;
            num0[9 ] <='h700C700C;
            num0[10] <='h700C301C;
            num0[11] <='h381C3818;
            num0[12] <='h1C381FF0;
            num0[13] <='h07E00180;
            num0[14] <='h00000000;
            num0[15] <='h00000000;							                                        
    end
    always @(posedge sys_clk or negedge sys_rst_n) 
        begin                                  
            num1[0 ] <=32'h00000000;
            num1[1 ] <=32'h00000000;
            num1[2 ] <=32'h00000000;
            num1[3 ] <=32'h01C001C0;
            num1[4 ] <=32'h03C007C0;
            num1[5 ] <=32'h1DC019C0;
            num1[6 ] <=32'h11C001C0;
            num1[7 ] <=32'h01C001C0;
            num1[8 ] <=32'h01C001C0;
            num1[9 ] <=32'h01C001C0;
            num1[10] <=32'h01C001C0;
            num1[11] <=32'h01C001C0;
            num1[12] <=32'h01C001C0;
            num1[13] <=32'h01C00000;
            num1[14] <=32'h00000000;
            num1[15] <=32'h00000000;							                                        
    end
    always @(posedge sys_clk or negedge sys_rst_n) 
        begin                                  
            num2[0 ] <=32'h00000000;
            num2[1 ] <=32'h00000000;
            num2[2 ] <=32'h00000000;
            num2[3 ] <=32'h0FE01FF8;
            num2[4 ] <=32'h3C38381C;
            num2[5 ] <=32'h701C001C;
            num2[6 ] <=32'h001C0018;
            num2[7 ] <=32'h00380038;
            num2[8 ] <=32'h007000E0;
            num2[9 ] <=32'h00C001C0;
            num2[10] <=32'h03800700;
            num2[11] <=32'h0E001C00;
            num2[12] <=32'h3C003FFC;
            num2[13] <=32'h3FFC0000;
            num2[14] <=32'h00000000;
            num2[15] <=32'h00000000;							                                        
    end
    always @(posedge sys_clk or negedge sys_rst_n) 
        begin                                  
            num3[0 ] <='h00000000;
            num3[1 ] <='h00000000;
            num3[2 ] <='h00000000;
            num3[3 ] <='h07E00FF8;
            num3[4 ] <='h1C38381C;
            num3[5 ] <='h301C101C;
            num3[6 ] <='h001C0018;
            num3[7 ] <='h007803E0;
            num3[8 ] <='h03F00078;
            num3[9 ] <='h001C001C;
            num3[10] <='h001C100C;
            num3[11] <='h701C381C;
            num3[12] <='h3C381FF8;
            num3[13] <='h0FE00180;
            num3[14] <='h00000000;
            num3[15] <='h00000000;							                                        
    end
    always @(posedge sys_clk or negedge sys_rst_n) 
        begin                                  
            num4[0 ] <='h00000000;
            num4[1 ] <='h00000000;
            num4[2 ] <='h00000000;
            num4[3 ] <='h00300070;
            num4[4 ] <='h007000F0;
            num4[5 ] <='h01F001B0;
            num4[6 ] <='h03B00730;
            num4[7 ] <='h0E300C30;
            num4[8 ] <='h1C303830;
            num4[9 ] <='h30307030;
            num4[10] <='hFFFEFFFE;
            num4[11] <='hFFFE0030;
            num4[12] <='h00300030;
            num4[13] <='h00300000;
            num4[14] <='h00000000;
            num4[15] <='h00000000;							                                        
    end
    always @(posedge sys_clk or negedge sys_rst_n) 
        begin                                  
            num5[0 ] <='h00000000;
            num5[1 ] <='h00000000;
            num5[2 ] <='h00000000;
            num5[3 ] <='h1FF81FF8;
            num5[4 ] <='h18001800;
            num5[5 ] <='h18003800;
            num5[6 ] <='h300037C0;
            num5[7 ] <='h3FF07878;
            num5[8 ] <='h7038001C;
            num5[9 ] <='h001C000C;
            num5[10] <='h000C201C;
            num5[11] <='h601C701C;
            num5[12] <='h70783FF0;
            num5[13] <='h1FE00780;
            num5[14] <='h00000000;
            num5[15] <='h00000000;							                                        
    end
    always @(posedge sys_clk or negedge sys_rst_n) 
        begin                                  
            num6[0 ] <='h00000000;
            num6[1 ] <='h00000000;
            num6[2 ] <='h00000000;
            num6[3 ] <='h00E000E0;
            num6[4 ] <='h01C00380;
            num6[5 ] <='h03800700;
            num6[6 ] <='h0E000E00;
            num6[7 ] <='h1FF01FF8;
            num6[8 ] <='h3C1C380E;
            num6[9 ] <='h700E700E;
            num6[10] <='h700E700E;
            num6[11] <='h700E380E;
            num6[12] <='h3C1C1FF8;
            num6[13] <='h0FF001C0;
            num6[14] <='h00000000;
            num6[15] <='h00000000;							                                        
    end
    always @(posedge sys_clk or negedge sys_rst_n) 
        begin                                  
            num7[0 ] <='h00000000;
            num7[1 ] <='h00000000;
            num7[2 ] <='h00000000;
            num7[3 ] <='h7FFE7FFE;
            num7[4 ] <='h000E001C;
            num7[5 ] <='h00180038;
            num7[6 ] <='h00300070;
            num7[7 ] <='h006000E0;
            num7[8 ] <='h00C001C0;
            num7[9 ] <='h01C00180;
            num7[10] <='h03800380;
            num7[11] <='h03000700;
            num7[12] <='h07000600;
            num7[13] <='h0E000000;
            num7[14] <='h00000000;
            num7[15] <='h00000000;						                                        
    end
    always @(posedge sys_clk or negedge sys_rst_n) 
        begin                                  
            num8[0 ] <='h00000000;
            num8[1 ] <='h00000000;
            num8[2 ] <='h00000000;
            num8[3 ] <='h0FE01FF0;
            num8[4 ] <='h3838301C;
            num8[5 ] <='h301C301C;
            num8[6 ] <='h301C3838;
            num8[7 ] <='h3C780FE0;
            num8[8 ] <='h1FF03C78;
            num8[9 ] <='h781C701C;
            num8[10] <='h600C600C;
            num8[11] <='h700C701C;
            num8[12] <='h783C3FF8;
            num8[13] <='h1FF00380;
            num8[14] <='h00000000;
            num8[15] <='h00000000;							                                        
    end
    always @(posedge sys_clk or negedge sys_rst_n) 
        begin                                  
            num9[0 ] <='h00000000;
            num9[1 ] <='h00000000;
            num9[2 ] <='h00000000;
            num9[3 ] <='h0FE01FF0;
            num9[4 ] <='h3C78703C;
            num9[5 ] <='h701C601C;
            num9[6 ] <='h601C601C;
            num9[7 ] <='h601C7038;
            num9[8 ] <='h78783FF8;
            num9[9 ] <='h1FF000E0;
            num9[10] <='h00E001C0;
            num9[11] <='h01C00380;
            num9[12] <='h03800700;
            num9[13] <='h06000E00;
            num9[14] <='h00000000;
            num9[15] <='h00000000;							                                        
    end
    always @(posedge sys_clk or negedge sys_rst_n) //字符k
        begin                                  
            char_k[0 ] <='h00000000;
            char_k[1 ] <='h00000000;
            char_k[2 ] <='h00000000;
            char_k[3 ] <='h701C703C;
            char_k[4 ] <='h70787070;
            char_k[5 ] <='h70E071C0;
            char_k[6 ] <='h73C07380;
            char_k[7 ] <='h77007F80;
            char_k[8 ] <='h7F807DC0;
            char_k[9 ] <='h79C070E0;
            char_k[10] <='h70E07070;
            char_k[11] <='h70787038;
            char_k[12] <='h703C701C;
            char_k[13] <='h700E0000;
            char_k[14] <='h00000000;
            char_k[15] <='h00000000;						                                        
    end
    always @(posedge sys_clk or negedge sys_rst_n) //字符h
        begin                                  
            char_h[0 ] <='h00000000;
            char_h[1 ] <='h00000000;
            char_h[2 ] <='h00000000;
            char_h[3 ] <='h30003000;
            char_h[4 ] <='h30003000;
            char_h[5 ] <='h30003000;
            char_h[6 ] <='h300031F0;
            char_h[7 ] <='h33F8363C;
            char_h[8 ] <='h3C1C381C;
            char_h[9 ] <='h381C301C;
            char_h[10] <='h301C301C;
            char_h[11] <='h301C301C;
            char_h[12] <='h301C301C;
            char_h[13] <='h301C0000;
            char_h[14] <='h00000000;
            char_h[15] <='h00000000;						                                        
    end
    always @(posedge sys_clk or negedge sys_rst_n) //字符z
        begin                                  
            char_z[0 ] <='h00000000;
            char_z[1 ] <='h00000000;
            char_z[2 ] <='h00000000;
            char_z[3 ] <='h00000000;
            char_z[4 ] <='h00000000;
            char_z[5 ] <='h00000000;
            char_z[6 ] <='h00003FF8;
            char_z[7 ] <='h3FF80038;
            char_z[8 ] <='h007000E0;
            char_z[9 ] <='h00E001C0;
            char_z[10] <='h03800700;
            char_z[11] <='h0E001C00;
            char_z[12] <='h38003FFC;
            char_z[13] <='h3FFC0000;
            char_z[14] <='h00000000;
            char_z[15] <='h00000000;					                                        
    end

    always @(posedge sys_clk or negedge sys_rst_n) //"."
        begin                                  
            char_dian[0 ] <='h00000000;
            char_dian[1 ] <='h00000000;
            char_dian[2 ] <='h00000000;
            char_dian[3 ] <='h00000000;
            char_dian[4 ] <='h00000000;
            char_dian[5 ] <='h00000000;
            char_dian[6 ] <='h00000000;
            char_dian[7 ] <='h00000000;
            char_dian[8 ] <='h00000000;
            char_dian[9 ] <='h00000000;
            char_dian[10] <='h00000000;
            char_dian[11] <='h00000000;
            char_dian[12] <='h18003C00;
            char_dian[13] <='h3C001800;
            char_dian[14] <='h00000000;
            char_dian[15] <='h00000000;//.;				                                        
    end


//------------------------
//------------------------
//parameter define    
parameter  H_DISP = 11'd480;                    //分辨率——行
parameter  V_DISP = 11'd275;                    //分辨率——列

parameter  XUXIAN_CNT = 'd40;               //虚线值 * n

localparam SIDE_W  = 10'd3;                    //边框宽度
localparam BLOCK_W = 10'd3;                    //方块宽度
//localparam BLUE    = 16'b00000_000000_11111;    //边框颜色 
//localparam YEllow   = 16'b00000_000000_00000;    //方块颜色 黑色
//localparam Black   = 16'b11111_111111_11111;    //背景颜色 白色
localparam BLUE    = 16'b00111_111111_11111;    //边框颜色 
localparam Black   = 16'b00000_000000_00000;    //背景颜色 
localparam GREEN   = 16'b00000_111111_00000;    
localparam RED     = 16'b11111_000000_00000;    
localparam YEllow   = 16'b11111_111111_00000;    //方块颜色 
localparam XUXIAN  = 16'b11111_111111_11111;    //虚线 白色
//reg define
reg [ 9:0] block_x;                             //方块左上角横坐标
reg [ 9:0] block_y;                             //方块左上角纵坐标
reg [21:0] div_cnt;                             //时钟分频计数器
reg        h_direct;                            //方块水平移动方向，1：右移，0：左移
reg        v_direct;                            //方块竖直移动方向，1：向下，0：向上
wire   [7:0]   data_i_reg_reg;  
wire   [7:0]   data_i_atte;

//对UART接收端口的数据延迟两个时钟周期
assign     data_i_atte = (data_i/1);  //数据衰减 

reg		[10:0]		xuxian_en;   															    
        	
//画示波器虚线
    always@(posedge vga_clk or negedge sys_rst_n)begin				
        if(!sys_rst_n)											
            xuxian_en <= 'd0;                              		    
        else if(
                    ( 
                        pixel_ypos == XUXIAN_CNT*1     ||
                        pixel_ypos == XUXIAN_CNT*2     ||
                        pixel_ypos == XUXIAN_CNT*3     ||
                        pixel_ypos == XUXIAN_CNT*4     ||
                        pixel_ypos == XUXIAN_CNT*5     ||   
                        pixel_ypos == XUXIAN_CNT*6     ||
                        pixel_ypos == XUXIAN_CNT*7     ||
                        pixel_ypos == XUXIAN_CNT*8     ||
                        pixel_ypos == XUXIAN_CNT*9     ||
                        pixel_ypos == XUXIAN_CNT*10    ||    
                        pixel_ypos == XUXIAN_CNT*11    ||    
                        pixel_ypos == XUXIAN_CNT*12    ||    
                        pixel_ypos == XUXIAN_CNT*13    ||
                        pixel_ypos == XUXIAN_CNT*14    ||
                        pixel_ypos == XUXIAN_CNT*15    ||
                        pixel_ypos == XUXIAN_CNT*16    ||
                        pixel_ypos == XUXIAN_CNT*17    ||
                        pixel_ypos == XUXIAN_CNT*18    ||
                        pixel_ypos == XUXIAN_CNT*19    ||
                        pixel_ypos == XUXIAN_CNT*20    ||
                        pixel_ypos == XUXIAN_CNT*21    ||
                        pixel_ypos == XUXIAN_CNT*22    ||
                        pixel_ypos == XUXIAN_CNT*23    ||
                        pixel_ypos == XUXIAN_CNT*24    ||
                        pixel_ypos == XUXIAN_CNT*25    
                    )
            && 
                    (
                        pixel_xpos == XUXIAN_CNT*1     ||
                        pixel_xpos == XUXIAN_CNT*2     ||
                        pixel_xpos == XUXIAN_CNT*3     ||
                        pixel_xpos == XUXIAN_CNT*4     ||
                        pixel_xpos == XUXIAN_CNT*5     ||   
                        pixel_xpos == XUXIAN_CNT*6     ||
                        pixel_xpos == XUXIAN_CNT*7     ||
                        pixel_xpos == XUXIAN_CNT*8     ||
                        pixel_xpos == XUXIAN_CNT*9     ||
                        pixel_xpos == XUXIAN_CNT*10    ||    
                        pixel_xpos == XUXIAN_CNT*11    ||    
                        pixel_xpos == XUXIAN_CNT*12    ||    
                        pixel_xpos == XUXIAN_CNT*13    ||
                        pixel_xpos == XUXIAN_CNT*14    ||
                        pixel_xpos == XUXIAN_CNT*15    ||
                        pixel_xpos == XUXIAN_CNT*16    ||
                        pixel_xpos == XUXIAN_CNT*17    ||
                        pixel_xpos == XUXIAN_CNT*18    ||
                        pixel_xpos == XUXIAN_CNT*19    ||
                        pixel_xpos == XUXIAN_CNT*20    ||
                        pixel_xpos == XUXIAN_CNT*21    ||
                        pixel_xpos == XUXIAN_CNT*22    ||
                        pixel_xpos == XUXIAN_CNT*23    ||
                        pixel_xpos == XUXIAN_CNT*24    ||
                        pixel_xpos == XUXIAN_CNT*25    
                    )	
                )
            xuxian_en <= 1;
        else
            xuxian_en <= 0;							    
        end	

    reg		[7:0]		data_i_reg;
        always @(posedge vga_clk or negedge sys_rst_n) begin
            if(!sys_rst_n)                              
                data_i_reg <= 0;	
            else 	           
                data_i_reg <= data_i_reg_reg;	//用于两点之间连线		                        
        end 										
//给不同的区域绘制不同的颜色
always @(posedge vga_clk or negedge sys_rst_n) begin         
    if (!sys_rst_n) 
        pixel_data <= YEllow;
    else begin
            if((pixel_xpos < SIDE_W) || (pixel_xpos >= H_DISP - SIDE_W)
              || (pixel_ypos < SIDE_W) || (pixel_ypos >= V_DISP - SIDE_W))
                pixel_data <= BLUE;                 //绘制边框
            else if (((pixel_ypos >= data_i_reg) && (pixel_ypos <= data_i_reg_reg))
                ||((pixel_ypos <= data_i_reg)&&(pixel_ypos >= data_i_reg_reg)))           
                pixel_data <= YEllow ;                //绘制波形
            else if(xuxian_en == 1)
                pixel_data <= XUXIAN ; 
        
            //字符  "频率"  
            else if((pixel_xpos >= POS_X) && (pixel_xpos < POS_X + WIDTH)
              && (pixel_ypos >= POS_Y) && (pixel_ypos < POS_Y + HEIGHT)) 
                begin
                    if(char1[y_cnt][ 11'd31-x_cnt])
                        pixel_data <= BLUE;             //绘制字符为蓝色      
                    else 
                    pixel_data <= Black;                //绘制背景为白色    
                end
            else if((pixel_xpos >= POS_X+'d32) && (pixel_xpos < POS_X + WIDTH+'d32)
              && (pixel_ypos >= POS_Y) && (pixel_ypos < POS_Y + HEIGHT)) 
                begin
                    if(char2[y_cnt][ 11'd31-x_cnt])
                        pixel_data <= BLUE;             //绘制字符为蓝色      
                    else 
                    pixel_data <= Black;                //绘制背景为白色    
                end
        
            //字符  "幅度"  
            else if((pixel_xpos >= POS_X_FU ) && (pixel_xpos < POS_X_FU+ WIDTH)
              && (pixel_ypos >= POS_Y_BUTTON) && (pixel_ypos < POS_Y_BUTTON + HEIGHT)) 
                begin
                    if(char3[y_cnt_button][ 11'd31-x_cnt_fu])
                        pixel_data <= GREEN;                   
                    else 
                    pixel_data <= Black;                //绘制背景为白色    
                end
            else if((pixel_xpos >= POS_X_DU ) && (pixel_xpos < POS_X_DU+ WIDTH)
              && (pixel_ypos >= POS_Y_BUTTON) && (pixel_ypos < POS_Y_BUTTON + HEIGHT)) 
                begin
                    if(char4[y_cnt_button][ 11'd31-x_cnt_du])
                        pixel_data <= GREEN;                   
                    else 
                    pixel_data <= Black;                //绘制背景为白色    
                end
            
            //数字显示区域
            else    if((pixel_xpos >= POS_X_FU_SHIWEI ) && (pixel_xpos < POS_X_FU_SHIWEI + WIDTH_NUM )
                            && (pixel_ypos >= POS_Y_BUTTON_NUM ) && (pixel_ypos < POS_Y_BUTTON_NUM + HEIGHT_NUM) &&fudushiwei== 'd0)
                            begin
                                if(num0[y_cnt_button_num][ 11'd16-x_cnt_fu_shiwei])
                                    pixel_data <= BLUE;             //绘制字符为蓝色      
                                else
                                    pixel_data <= Black;                //绘制背景为白色
                            end  
            else   if((pixel_xpos >= POS_X_FU_SHIWEI ) && (pixel_xpos < POS_X_FU_SHIWEI + WIDTH_NUM )
                            && (pixel_ypos >= POS_Y_BUTTON_NUM ) && (pixel_ypos < POS_Y_BUTTON_NUM + HEIGHT_NUM) &&fudushiwei== 'd1)
                            begin
                                if(num1[y_cnt_button_num][ 11'd16-x_cnt_fu_shiwei])
                                    pixel_data <= BLUE;             //绘制字符为蓝色      
                                else
                                    pixel_data <= Black;                //绘制背景为白色
                            end  
            else    if((pixel_xpos >= POS_X_FU_SHIWEI ) && (pixel_xpos < POS_X_FU_SHIWEI + WIDTH_NUM )
                            && (pixel_ypos >= POS_Y_BUTTON_NUM ) && (pixel_ypos < POS_Y_BUTTON_NUM + HEIGHT_NUM) &&fudushiwei== 'd2)
                            begin
                                if(num2[y_cnt_button_num][ 11'd16-x_cnt_fu_shiwei])
                                    pixel_data <= BLUE;             //绘制字符为蓝色      
                                else
                                    pixel_data <= Black;                //绘制背景为白色
                            end  
            else    if((pixel_xpos >= POS_X_FU_SHIWEI ) && (pixel_xpos < POS_X_FU_SHIWEI + WIDTH_NUM )
                            && (pixel_ypos >= POS_Y_BUTTON_NUM ) && (pixel_ypos < POS_Y_BUTTON_NUM + HEIGHT_NUM) &&fudushiwei== 'd3)
                            begin
                                if(num3[y_cnt_button_num][ 11'd16-x_cnt_fu_shiwei])
                                    pixel_data <= BLUE;             //绘制字符为蓝色      
                                else
                                    pixel_data <= Black;                //绘制背景为白色
                            end  
            else    if((pixel_xpos >= POS_X_FU_SHIWEI ) && (pixel_xpos < POS_X_FU_SHIWEI + WIDTH_NUM )
                            && (pixel_ypos >= POS_Y_BUTTON_NUM ) && (pixel_ypos < POS_Y_BUTTON_NUM + HEIGHT_NUM) &&fudushiwei== 'd4)
                            begin
                                if(num4[y_cnt_button_num][ 11'd16-x_cnt_fu_shiwei])
                                    pixel_data <= BLUE;             //绘制字符为蓝色      
                                else
                                    pixel_data <= Black;                //绘制背景为白色
                            end  
            else    if((pixel_xpos >= POS_X_FU_SHIWEI ) && (pixel_xpos < POS_X_FU_SHIWEI + WIDTH_NUM )
                            && (pixel_ypos >= POS_Y_BUTTON_NUM ) && (pixel_ypos < POS_Y_BUTTON_NUM + HEIGHT_NUM) &&fudushiwei== 'd5)
                            begin
                                if(num5[y_cnt_button_num][ 11'd16-x_cnt_fu_shiwei])
                                    pixel_data <= BLUE;             //绘制字符为蓝色      
                                else
                                    pixel_data <= Black;                //绘制背景为白色
                            end  
            else    if((pixel_xpos >= POS_X_FU_SHIWEI ) && (pixel_xpos < POS_X_FU_SHIWEI + WIDTH_NUM )
                            && (pixel_ypos >= POS_Y_BUTTON_NUM ) && (pixel_ypos < POS_Y_BUTTON_NUM + HEIGHT_NUM) &&fudushiwei== 'd6)
                            begin
                                if(num6[y_cnt_button_num][ 11'd16-x_cnt_fu_shiwei])
                                    pixel_data <= BLUE;             //绘制字符为蓝色      
                                else
                                    pixel_data <= Black;                //绘制背景为白色
                            end  
            else    if((pixel_xpos >= POS_X_FU_SHIWEI ) && (pixel_xpos < POS_X_FU_SHIWEI + WIDTH_NUM )
                            && (pixel_ypos >= POS_Y_BUTTON_NUM ) && (pixel_ypos < POS_Y_BUTTON_NUM + HEIGHT_NUM) &&fudushiwei== 'd7)
                            begin
                                if(num7[y_cnt_button_num][ 11'd16-x_cnt_fu_shiwei])
                                    pixel_data <= BLUE;             //绘制字符为蓝色      
                                else
                                    pixel_data <= Black;                //绘制背景为白色
                            end  
            else    if((pixel_xpos >= POS_X_FU_SHIWEI ) && (pixel_xpos < POS_X_FU_SHIWEI + WIDTH_NUM )
                            && (pixel_ypos >= POS_Y_BUTTON_NUM ) && (pixel_ypos < POS_Y_BUTTON_NUM + HEIGHT_NUM) &&fudushiwei== 'd8)
                            begin
                                if(num8[y_cnt_button_num][ 11'd16-x_cnt_fu_shiwei])
                                    pixel_data <= BLUE;             //绘制字符为蓝色      
                                else
                                    pixel_data <= Black;                //绘制背景为白色
                            end  
            else    if((pixel_xpos >= POS_X_FU_SHIWEI ) && (pixel_xpos < POS_X_FU_SHIWEI + WIDTH_NUM )
                            && (pixel_ypos >= POS_Y_BUTTON_NUM ) && (pixel_ypos < POS_Y_BUTTON_NUM + HEIGHT_NUM) &&fudushiwei== 'd9)
                            begin
                                if(num9[y_cnt_button_num][ 11'd16-x_cnt_fu_shiwei])
                                    pixel_data <= BLUE;             //绘制字符为蓝色      
                                else
                                    pixel_data <= Black;                //绘制背景为白色
                            end  
            //显示“ . ”
            else    if((pixel_xpos >= POS_X_FU_SHIWEI +'d16) && (pixel_xpos < POS_X_FU_SHIWEI + WIDTH_NUM +'d16)
                            && (pixel_ypos >= POS_Y_BUTTON_NUM ) && (pixel_ypos < POS_Y_BUTTON_NUM + HEIGHT_NUM))
                            begin
                                if(char_dian[y_cnt_button_num][ 11'd16-x_cnt_fu_shiwei])
                                    pixel_data <= BLUE;             //绘制字符为蓝色      
                                else
                                    pixel_data <= Black;                //绘制背景为白色
                            end  
            //个位的数字
            else    if((pixel_xpos >= POS_X_FU_GEWEI ) && (pixel_xpos < POS_X_FU_GEWEI + WIDTH_NUM )
                            && (pixel_ypos >= POS_Y_BUTTON_NUM ) && (pixel_ypos < POS_Y_BUTTON_NUM + HEIGHT_NUM) &&fudugewei== 'd0)
                            begin
                                if(num0[y_cnt_button_num][ 11'd16-x_cnt_fu_gewei])
                                    pixel_data <= BLUE;             //绘制字符为蓝色      
                                else
                                    pixel_data <= Black;                //绘制背景为白色
                            end  
            else    if((pixel_xpos >= POS_X_FU_GEWEI ) && (pixel_xpos < POS_X_FU_GEWEI + WIDTH_NUM )
                            && (pixel_ypos >= POS_Y_BUTTON_NUM ) && (pixel_ypos < POS_Y_BUTTON_NUM + HEIGHT_NUM) &&fudugewei== 'd1)
                            begin
                                if(num1[y_cnt_button_num][ 11'd16-x_cnt_fu_gewei])
                                    pixel_data <= BLUE;             //绘制字符为蓝色      
                                else
                                    pixel_data <= Black;                //绘制背景为白色
                            end  
            else    if((pixel_xpos >= POS_X_FU_GEWEI ) && (pixel_xpos < POS_X_FU_GEWEI + WIDTH_NUM )
                            && (pixel_ypos >= POS_Y_BUTTON_NUM ) && (pixel_ypos < POS_Y_BUTTON_NUM + HEIGHT_NUM) &&fudugewei== 'd2)
                            begin
                                if(num2[y_cnt_button_num][ 11'd16-x_cnt_fu_gewei])
                                    pixel_data <= BLUE;             //绘制字符为蓝色      
                                else
                                    pixel_data <= Black;                //绘制背景为白色
                            end  
            else    if((pixel_xpos >= POS_X_FU_GEWEI ) && (pixel_xpos < POS_X_FU_GEWEI + WIDTH_NUM )
                            && (pixel_ypos >= POS_Y_BUTTON_NUM ) && (pixel_ypos < POS_Y_BUTTON_NUM + HEIGHT_NUM) &&fudugewei== 'd3)
                            begin
                                if(num3[y_cnt_button_num][ 11'd16-x_cnt_fu_gewei])
                                    pixel_data <= BLUE;             //绘制字符为蓝色      
                                else
                                    pixel_data <= Black;                //绘制背景为白色
                            end  
            else    if((pixel_xpos >= POS_X_FU_GEWEI ) && (pixel_xpos < POS_X_FU_GEWEI + WIDTH_NUM )
                            && (pixel_ypos >= POS_Y_BUTTON_NUM ) && (pixel_ypos < POS_Y_BUTTON_NUM + HEIGHT_NUM) &&fudugewei== 'd4)
                            begin
                                if(num4[y_cnt_button_num][ 11'd16-x_cnt_fu_gewei])
                                    pixel_data <= BLUE;             //绘制字符为蓝色      
                                else
                                    pixel_data <= Black;                //绘制背景为白色
                            end  
            else    if((pixel_xpos >= POS_X_FU_GEWEI ) && (pixel_xpos < POS_X_FU_GEWEI + WIDTH_NUM )
                            && (pixel_ypos >= POS_Y_BUTTON_NUM ) && (pixel_ypos < POS_Y_BUTTON_NUM + HEIGHT_NUM) &&fudugewei== 'd5)
                            begin
                                if(num5[y_cnt_button_num][ 11'd16-x_cnt_fu_gewei])
                                    pixel_data <= BLUE;             //绘制字符为蓝色      
                                else
                                    pixel_data <= Black;                //绘制背景为白色
                            end  
            else    if((pixel_xpos >= POS_X_FU_GEWEI ) && (pixel_xpos < POS_X_FU_GEWEI + WIDTH_NUM )
                            && (pixel_ypos >= POS_Y_BUTTON_NUM ) && (pixel_ypos < POS_Y_BUTTON_NUM + HEIGHT_NUM) &&fudugewei== 'd6)
                            begin
                                if(num6[y_cnt_button_num][ 11'd16-x_cnt_fu_gewei])
                                    pixel_data <= BLUE;             //绘制字符为蓝色      
                                else
                                    pixel_data <= Black;                //绘制背景为白色
                            end  
            else    if((pixel_xpos >= POS_X_FU_GEWEI ) && (pixel_xpos < POS_X_FU_GEWEI + WIDTH_NUM )
                            && (pixel_ypos >= POS_Y_BUTTON_NUM ) && (pixel_ypos < POS_Y_BUTTON_NUM + HEIGHT_NUM) &&fudugewei== 'd7)
                            begin
                                if(num7[y_cnt_button_num][ 11'd16-x_cnt_fu_gewei])
                                    pixel_data <= BLUE;             //绘制字符为蓝色      
                                else
                                    pixel_data <= Black;                //绘制背景为白色
                            end  
            else    if((pixel_xpos >= POS_X_FU_GEWEI ) && (pixel_xpos < POS_X_FU_GEWEI + WIDTH_NUM )
                            && (pixel_ypos >= POS_Y_BUTTON_NUM ) && (pixel_ypos < POS_Y_BUTTON_NUM + HEIGHT_NUM) &&fudugewei== 'd8)
                            begin
                                if(num8[y_cnt_button_num][ 11'd16-x_cnt_fu_gewei])
                                    pixel_data <= BLUE;             //绘制字符为蓝色      
                                else
                                    pixel_data <= Black;                //绘制背景为白色
                            end  
            else    if((pixel_xpos >= POS_X_FU_GEWEI ) && (pixel_xpos < POS_X_FU_GEWEI + WIDTH_NUM )
                            && (pixel_ypos >= POS_Y_BUTTON_NUM ) && (pixel_ypos < POS_Y_BUTTON_NUM + HEIGHT_NUM) &&fudugewei== 'd9)
                            begin
                                if(num9[y_cnt_button_num][ 11'd16-x_cnt_fu_gewei])
                                    pixel_data <= BLUE;             //绘制字符为蓝色      
                                else
                                    pixel_data <= Black;                //绘制背景为白色
                            end  
        


            //显示数字 **********************百位区域

            else    
                if((pixel_xpos >= POS_X_NUM_BAIWEI) && (pixel_xpos < POS_X_NUM_BAIWEI + WIDTH_NUM)
                            && (pixel_ypos >= POS_Y_NUM ) && (pixel_ypos < POS_Y_NUM + HEIGHT_NUM) &&baiwei== 'd0)
                            begin
                                if(num0[y_cnt_num][ 11'd16-x_cnt_num_baiwei])
                                    pixel_data <= BLUE;             //绘制字符为蓝色      
                                else
                                    pixel_data <= Black;                //绘制背景为白色
                            end     
            else    if((pixel_xpos >= POS_X_NUM_BAIWEI) && (pixel_xpos < POS_X_NUM_BAIWEI + WIDTH_NUM)
                            && (pixel_ypos >= POS_Y_NUM) && (pixel_ypos < POS_Y_NUM + HEIGHT_NUM) &&baiwei== 'd1)
                            begin
                                if(num1[y_cnt_num][ 11'd16-x_cnt_num_baiwei])
                                    pixel_data <= BLUE;             //绘制字符为蓝色      
                                else
                                    pixel_data <= Black;                //绘制背景为白色
                            end     
            else    if((pixel_xpos >= POS_X_NUM_BAIWEI) && (pixel_xpos < POS_X_NUM_BAIWEI + WIDTH_NUM)
                            && (pixel_ypos >= POS_Y_NUM ) && (pixel_ypos < POS_Y_NUM + HEIGHT_NUM)&&baiwei== 'd2)
                            begin
                                if(num2[y_cnt_num][ 11'd16-x_cnt_num_baiwei])
                                    pixel_data <= BLUE;             //绘制字符为蓝色      
                                else
                                    pixel_data <= Black;                //绘制背景为白色
                            end
            else    if((pixel_xpos >= POS_X_NUM_BAIWEI) && (pixel_xpos < POS_X_NUM_BAIWEI + WIDTH_NUM)
                            && (pixel_ypos >= POS_Y_NUM ) && (pixel_ypos < POS_Y_NUM + HEIGHT_NUM)&&baiwei== 'd3)
                            begin
                                if(num3[y_cnt_num][ 11'd16-x_cnt_num_baiwei])
                                    pixel_data <= BLUE;             //绘制字符为蓝色      
                                else
                                    pixel_data <= Black;                //绘制背景为白色
                            end
            else    if((pixel_xpos >= POS_X_NUM_BAIWEI) && (pixel_xpos < POS_X_NUM_BAIWEI + WIDTH_NUM)
                            && (pixel_ypos >= POS_Y_NUM ) && (pixel_ypos < POS_Y_NUM + HEIGHT_NUM)&&baiwei== 'd4)
                            begin
                                if(num4[y_cnt_num][ 11'd16-x_cnt_num_baiwei])
                                    pixel_data <= BLUE;             //绘制字符为蓝色      
                                else
                                    pixel_data <= Black;                //绘制背景为白色
                            end
            else    if((pixel_xpos >= POS_X_NUM_BAIWEI) && (pixel_xpos < POS_X_NUM_BAIWEI + WIDTH_NUM)
                            && (pixel_ypos >= POS_Y_NUM ) && (pixel_ypos < POS_Y_NUM + HEIGHT_NUM)&&baiwei== 'd5)
                            begin
                                if(num5[y_cnt_num][ 11'd16-x_cnt_num_baiwei])
                                    pixel_data <= BLUE;             //绘制字符为蓝色      
                                else
                                    pixel_data <= Black;                //绘制背景为白色
                            end
            else    if((pixel_xpos >= POS_X_NUM_BAIWEI) && (pixel_xpos < POS_X_NUM_BAIWEI + WIDTH_NUM)
                            && (pixel_ypos >= POS_Y_NUM ) && (pixel_ypos < POS_Y_NUM + HEIGHT_NUM)&&baiwei== 'd6)
                            begin
                                if(num6[y_cnt_num][ 11'd16-x_cnt_num_baiwei])
                                    pixel_data <= BLUE;             //绘制字符为蓝色      
                                else
                                    pixel_data <= Black;                //绘制背景为白色
                            end
            else    if((pixel_xpos >= POS_X_NUM_BAIWEI) && (pixel_xpos < POS_X_NUM_BAIWEI + WIDTH_NUM)
                            && (pixel_ypos >= POS_Y_NUM ) && (pixel_ypos < POS_Y_NUM + HEIGHT_NUM)&&baiwei== 'd7)
                            begin
                                if(num7[y_cnt_num][ 11'd16-x_cnt_num_baiwei])
                                    pixel_data <= BLUE;             //绘制字符为蓝色      
                                else
                                    pixel_data <= Black;                //绘制背景为白色
                            end
            else    if((pixel_xpos >= POS_X_NUM_BAIWEI) && (pixel_xpos < POS_X_NUM_BAIWEI + WIDTH_NUM)
                            && (pixel_ypos >= POS_Y_NUM ) && (pixel_ypos < POS_Y_NUM + HEIGHT_NUM)&&baiwei== 'd8)
                            begin
                                if(num8[y_cnt_num][ 11'd16-x_cnt_num_baiwei])
                                    pixel_data <= BLUE;             //绘制字符为蓝色      
                                else
                                    pixel_data <= Black;                //绘制背景为白色
                            end
            else    if((pixel_xpos >= POS_X_NUM_BAIWEI) && (pixel_xpos < POS_X_NUM_BAIWEI + WIDTH_NUM)
                            && (pixel_ypos >= POS_Y_NUM ) && (pixel_ypos < POS_Y_NUM + HEIGHT_NUM)&&baiwei== 'd9)
                            begin
                                if(num9[y_cnt_num][ 11'd16-x_cnt_num_baiwei])
                                    pixel_data <= BLUE;             //绘制字符为蓝色      
                                else
                                    pixel_data <= Black;                //绘制背景为白色
                            end
   

            //显示数字 **********************十位区域
            else    
                if((pixel_xpos >= POS_X_NUM_SHIWEI) && (pixel_xpos < POS_X_NUM_SHIWEI + WIDTH_NUM)
                            && (pixel_ypos >= POS_Y_NUM ) && (pixel_ypos < POS_Y_NUM + HEIGHT_NUM) &&shiwei== 'd0)
                            begin
                                if(num0[y_cnt_num][ 11'd16-x_cnt_num_shiwei])
                                    pixel_data <= BLUE;             //绘制字符为蓝色      
                                else
                                    pixel_data <= Black;                //绘制背景为白色
                            end     
            else    if((pixel_xpos >= POS_X_NUM_SHIWEI) && (pixel_xpos < POS_X_NUM_SHIWEI + WIDTH_NUM)
                            && (pixel_ypos >= POS_Y_NUM) && (pixel_ypos < POS_Y_NUM + HEIGHT_NUM) &&shiwei== 'd1)
                            begin
                                if(num1[y_cnt_num][ 11'd16-x_cnt_num_shiwei])
                                    pixel_data <= BLUE;             //绘制字符为蓝色      
                                else
                                    pixel_data <= Black;                //绘制背景为白色
                            end     
            else    if((pixel_xpos >= POS_X_NUM_SHIWEI) && (pixel_xpos < POS_X_NUM_SHIWEI + WIDTH_NUM)
                            && (pixel_ypos >= POS_Y_NUM ) && (pixel_ypos < POS_Y_NUM + HEIGHT_NUM)&&shiwei== 'd2)
                            begin
                                if(num2[y_cnt_num][ 11'd16-x_cnt_num_shiwei])
                                    pixel_data <= BLUE;             //绘制字符为蓝色      
                                else
                                    pixel_data <= Black;                //绘制背景为白色
                            end
            else    if((pixel_xpos >= POS_X_NUM_SHIWEI) && (pixel_xpos < POS_X_NUM_SHIWEI + WIDTH_NUM)
                            && (pixel_ypos >= POS_Y_NUM ) && (pixel_ypos < POS_Y_NUM + HEIGHT_NUM)&&shiwei== 'd3)
                            begin
                                if(num3[y_cnt_num][ 11'd16-x_cnt_num_shiwei])
                                    pixel_data <= BLUE;             //绘制字符为蓝色      
                                else
                                    pixel_data <= Black;                //绘制背景为白色
                            end
            else    if((pixel_xpos >= POS_X_NUM_SHIWEI) && (pixel_xpos < POS_X_NUM_SHIWEI + WIDTH_NUM)
                            && (pixel_ypos >= POS_Y_NUM ) && (pixel_ypos < POS_Y_NUM + HEIGHT_NUM)&&shiwei== 'd4)
                            begin
                                if(num4[y_cnt_num][ 11'd16-x_cnt_num_shiwei])
                                    pixel_data <= BLUE;             //绘制字符为蓝色      
                                else
                                    pixel_data <= Black;                //绘制背景为白色
                            end
            else    if((pixel_xpos >= POS_X_NUM_SHIWEI) && (pixel_xpos < POS_X_NUM_SHIWEI + WIDTH_NUM)
                            && (pixel_ypos >= POS_Y_NUM ) && (pixel_ypos < POS_Y_NUM + HEIGHT_NUM)&&shiwei== 'd5)
                            begin
                                if(num5[y_cnt_num][ 11'd16-x_cnt_num_shiwei])
                                    pixel_data <= BLUE;             //绘制字符为蓝色      
                                else
                                    pixel_data <= Black;                //绘制背景为白色
                            end
            else    if((pixel_xpos >= POS_X_NUM_SHIWEI) && (pixel_xpos < POS_X_NUM_SHIWEI + WIDTH_NUM)
                            && (pixel_ypos >= POS_Y_NUM ) && (pixel_ypos < POS_Y_NUM + HEIGHT_NUM)&&shiwei== 'd6)
                            begin
                                if(num6[y_cnt_num][ 11'd16-x_cnt_num_shiwei])
                                    pixel_data <= BLUE;             //绘制字符为蓝色      
                                else
                                    pixel_data <= Black;                //绘制背景为白色
                            end
            else    if((pixel_xpos >= POS_X_NUM_SHIWEI) && (pixel_xpos < POS_X_NUM_SHIWEI + WIDTH_NUM)
                            && (pixel_ypos >= POS_Y_NUM ) && (pixel_ypos < POS_Y_NUM + HEIGHT_NUM)&&shiwei== 'd7)
                            begin
                                if(num7[y_cnt_num][ 11'd16-x_cnt_num_shiwei])
                                    pixel_data <= BLUE;             //绘制字符为蓝色      
                                else
                                    pixel_data <= Black;                //绘制背景为白色
                            end
            else    if((pixel_xpos >= POS_X_NUM_SHIWEI) && (pixel_xpos < POS_X_NUM_SHIWEI + WIDTH_NUM)
                            && (pixel_ypos >= POS_Y_NUM ) && (pixel_ypos < POS_Y_NUM + HEIGHT_NUM)&&shiwei== 'd8)
                            begin
                                if(num8[y_cnt_num][ 11'd16-x_cnt_num_shiwei])
                                    pixel_data <= BLUE;             //绘制字符为蓝色      
                                else
                                    pixel_data <= Black;                //绘制背景为白色
                            end
            else    if((pixel_xpos >= POS_X_NUM_SHIWEI) && (pixel_xpos < POS_X_NUM_SHIWEI + WIDTH_NUM)
                            && (pixel_ypos >= POS_Y_NUM ) && (pixel_ypos < POS_Y_NUM + HEIGHT_NUM)&&shiwei== 'd9)
                            begin
                                if(num9[y_cnt_num][ 11'd16-x_cnt_num_shiwei])
                                    pixel_data <= BLUE;             //绘制字符为蓝色      
                                else
                                    pixel_data <= Black;                //绘制背景为白色
                            end
            //显示数字 **********************个位区域
            else    
                if((pixel_xpos >= POS_X_NUM_GEWEI) && (pixel_xpos < POS_X_NUM_GEWEI + WIDTH_NUM)
                            && (pixel_ypos >= POS_Y_NUM ) && (pixel_ypos < POS_Y_NUM + HEIGHT_NUM) &&gewei== 'd0)
                            begin
                                if(num0[y_cnt_num][ 11'd16-x_cnt_num_gewei])
                                    pixel_data <= BLUE;             //绘制字符为蓝色      
                                else
                                    pixel_data <= Black;                //绘制背景为白色
                            end     
            else    if((pixel_xpos >= POS_X_NUM_GEWEI) && (pixel_xpos < POS_X_NUM_GEWEI + WIDTH_NUM)
                            && (pixel_ypos >= POS_Y_NUM) && (pixel_ypos < POS_Y_NUM + HEIGHT_NUM) &&gewei== 'd1)
                            begin
                                if(num1[y_cnt_num][ 11'd16-x_cnt_num_gewei])
                                    pixel_data <= BLUE;             //绘制字符为蓝色      
                                else
                                    pixel_data <= Black;                //绘制背景为白色
                            end     
            else    if((pixel_xpos >= POS_X_NUM_GEWEI) && (pixel_xpos < POS_X_NUM_GEWEI + WIDTH_NUM)
                            && (pixel_ypos >= POS_Y_NUM ) && (pixel_ypos < POS_Y_NUM + HEIGHT_NUM)&&gewei== 'd2)
                            begin
                                if(num2[y_cnt_num][ 11'd16-x_cnt_num_gewei])
                                    pixel_data <= BLUE;             //绘制字符为蓝色      
                                else
                                    pixel_data <= Black;                //绘制背景为白色
                            end
            else    if((pixel_xpos >= POS_X_NUM_GEWEI) && (pixel_xpos < POS_X_NUM_GEWEI + WIDTH_NUM)
                            && (pixel_ypos >= POS_Y_NUM ) && (pixel_ypos < POS_Y_NUM + HEIGHT_NUM)&&gewei== 'd3)
                            begin
                                if(num3[y_cnt_num][ 11'd16-x_cnt_num_gewei])
                                    pixel_data <= BLUE;             //绘制字符为蓝色      
                                else
                                    pixel_data <= Black;                //绘制背景为白色
                            end
            else    if((pixel_xpos >= POS_X_NUM_GEWEI) && (pixel_xpos < POS_X_NUM_GEWEI + WIDTH_NUM)
                            && (pixel_ypos >= POS_Y_NUM ) && (pixel_ypos < POS_Y_NUM + HEIGHT_NUM)&&gewei== 'd4)
                            begin
                                if(num4[y_cnt_num][ 11'd16-x_cnt_num_gewei])
                                    pixel_data <= BLUE;             //绘制字符为蓝色      
                                else
                                    pixel_data <= Black;                //绘制背景为白色
                            end
            else    if((pixel_xpos >= POS_X_NUM_GEWEI) && (pixel_xpos < POS_X_NUM_GEWEI + WIDTH_NUM)
                            && (pixel_ypos >= POS_Y_NUM ) && (pixel_ypos < POS_Y_NUM + HEIGHT_NUM)&&gewei== 'd5)
                            begin
                                if(num5[y_cnt_num][ 11'd16-x_cnt_num_gewei])
                                    pixel_data <= BLUE;             //绘制字符为蓝色      
                                else
                                    pixel_data <= Black;                //绘制背景为白色
                            end
            else    if((pixel_xpos >= POS_X_NUM_GEWEI) && (pixel_xpos < POS_X_NUM_GEWEI + WIDTH_NUM)
                            && (pixel_ypos >= POS_Y_NUM ) && (pixel_ypos < POS_Y_NUM + HEIGHT_NUM)&&gewei== 'd6)
                            begin
                                if(num6[y_cnt_num][ 11'd16-x_cnt_num_gewei])
                                    pixel_data <= BLUE;             //绘制字符为蓝色      
                                else
                                    pixel_data <= Black;                //绘制背景为白色
                            end
            else    if((pixel_xpos >= POS_X_NUM_GEWEI) && (pixel_xpos < POS_X_NUM_GEWEI + WIDTH_NUM)
                            && (pixel_ypos >= POS_Y_NUM ) && (pixel_ypos < POS_Y_NUM + HEIGHT_NUM)&&gewei== 'd7)
                            begin
                                if(num7[y_cnt_num][ 11'd16-x_cnt_num_gewei])
                                    pixel_data <= BLUE;             //绘制字符为蓝色      
                                else
                                    pixel_data <= Black;                //绘制背景为白色
                            end
            else    if((pixel_xpos >= POS_X_NUM_GEWEI) && (pixel_xpos < POS_X_NUM_GEWEI + WIDTH_NUM)
                            && (pixel_ypos >= POS_Y_NUM ) && (pixel_ypos < POS_Y_NUM + HEIGHT_NUM)&&gewei== 'd8)
                            begin
                                if(num8[y_cnt_num][ 11'd16-x_cnt_num_gewei])
                                    pixel_data <= BLUE;             //绘制字符为蓝色      
                                else
                                    pixel_data <= Black;                //绘制背景为白色
                            end
            else    if((pixel_xpos >= POS_X_NUM_GEWEI) && (pixel_xpos < POS_X_NUM_GEWEI + WIDTH_NUM)
                            && (pixel_ypos >= POS_Y_NUM ) && (pixel_ypos < POS_Y_NUM + HEIGHT_NUM)&&gewei== 'd9)
                            begin
                                if(num9[y_cnt_num][ 11'd16-x_cnt_num_gewei])
                                    pixel_data <= BLUE;             //绘制字符为蓝色      
                                else
                                    pixel_data <= Black;                //绘制背景为白色
                            end
            //*******************************************
            //*******************************************
            //k h z
            else    if((pixel_xpos >= POS_X_NUM_K) && (pixel_xpos < POS_X_NUM_K+ WIDTH_NUM)
                            && (pixel_ypos >= POS_Y_NUM ) && (pixel_ypos < POS_Y_NUM + HEIGHT_NUM))
                            begin
                                if(char_k[y_cnt_num][ 11'd16-x_cnt_num_k])
                                    pixel_data <= BLUE;             //绘制字符为蓝色      
                                else
                                    pixel_data <= Black;                //绘制背景为白色
                            end
            else    if((pixel_xpos >= POS_X_NUM_H) && (pixel_xpos < POS_X_NUM_H+ WIDTH_NUM)
                            && (pixel_ypos >= POS_Y_NUM ) && (pixel_ypos < POS_Y_NUM + HEIGHT_NUM))
                            begin
                                if(char_h[y_cnt_num][ 11'd16-x_cnt_num_h])
                                    pixel_data <= BLUE;             //绘制字符为蓝色      
                                else
                                    pixel_data <= Black;                //绘制背景为白色
                            end
            else    if((pixel_xpos >= POS_X_NUM_Z) && (pixel_xpos < POS_X_NUM_Z+ WIDTH_NUM)
                            && (pixel_ypos >= POS_Y_NUM ) && (pixel_ypos < POS_Y_NUM + HEIGHT_NUM))
                            begin
                                if(char_z[y_cnt_num][ 11'd16-x_cnt_num_z])
                                    pixel_data <= BLUE;             //绘制字符为蓝色      
                                else
                                    pixel_data <= Black;                //绘制背景为白色
                            end
            else
                    pixel_data <= Black;                //绘制背景为白色
   
                
    end    
end

/*  
/*************************** key*****************************/
//软件内调幅

     reg		[5:0]	key_cnt	;
 always@(posedge sys_clk or negedge sys_rst_n)begin
     if(!sys_rst_n)									
        key_cnt <= 5;                                         
     else if(key_amp_add &&(key_cnt < 'd8))									
        key_cnt <= key_cnt + 1'b1; 
     else if(key_amp_redu && (key_cnt >'d2))
        key_cnt <= key_cnt - 1'b1; 
     else if((key_cnt == 'd0) ) //按键加了限制 
        key_cnt <= 5;                                         
     else ;                                           
 end	
     assign     data_i_reg_reg = (key_cnt >=5)  ?  (data_i_atte * (key_cnt-4) ) 
                                                     :(data_i_atte / (5-key_cnt));
//软件内调频 独立按键
   reg		        [5:0]		pixel_ypos_cnt;   									
 always@(posedge sys_clk or negedge sys_rst_n)begin
     if(!sys_rst_n)									
        pixel_ypos_cnt <= 20;                                         
     else if(key_fre_add && (pixel_ypos_cnt < 'd42))									
        pixel_ypos_cnt <= pixel_ypos_cnt + 1'b1; 
     else if(key_fre_redu && (pixel_ypos_cnt >0))
        pixel_ypos_cnt <= pixel_ypos_cnt - 1'b1;                                       
     else ; 	
 end
    assign  ram_addr = (pixel_ypos_cnt >=20)  ?  (pixel_xpos * (pixel_ypos_cnt-19))  :(pixel_xpos / (20-pixel_ypos_cnt));


endmodule 