module param_measure(
    input               sys_clk ,     // 系统时钟
    input               rst_n  ,     // 复位信号

    input      [7:0]    trig_level,
    
    input               ad_clk,     // AD时钟
    input               clk_200m,     
    input      [7:0]    ad_data,    // AD输入数据
    
    output     [29:0]   ad_freq,    // 被测时钟频率输出
    output     [7:0]    ad_vpp,     // AD峰峰值 
    output     [7:0]    ad_max,     // AD最大值
    output     [7:0]    ad_min      // AD最小值
);

//parameter define
parameter CLK_FS = 26'd50_000_000;  // 基准时钟频率值

//wire define
wire ad_pulse;   //由AD采样值转换的脉冲信号

//脉冲生成模块
pulse_gen u_pulse_gen(
    .rst_n          (rst_n),        //系统复位，低电平有效

    .trig_level     (trig_level),
    
    .ad_clk         (ad_clk),       //AD9280驱动时钟
    .ad_data        (ad_data),      //AD输入数据

    .ad_pulse       (ad_pulse)      //输出的脉冲信号
    );


//等精度频率计模块
cymometer #(
    .CLK_FS         (CLK_FS)        // 基准时钟频率值
) u_cymometer(
    .clk_fs         (sys_clk),
    .rst_n          (rst_n),

     .clk_fx         (ad_pulse),     // 被测时钟信号
    //.clk_fx         (clk_5m),     // 被测时钟信号
    .data_fx        (ad_freq)       // 被测时钟频率输出
    );

//计算峰峰值
vpp_measure u_vpp_measure(
    .rst_n          (rst_n),
    
    .ad_clk         (ad_clk), 
    .ad_data        (ad_data),
    .ad_pulse       (ad_pulse),
    .ad_vpp         (ad_vpp),
    .ad_max         (ad_max),
    .ad_min         (ad_min)
    );

endmodule 