`timescale  1ns/1ns
module  tb_shiboqi();

reg                   clk                 ;
reg                   rst                 ;
reg                   key_1               ;
reg                   key_2               ;
reg                   key_3               ;
reg                   key_4               ;

reg   [7:0]           ad_data             ;
wire                  ad_clk              ;

wire                  clk_5m              ;
wire                  lcd_hs              ;
wire                  lcd_vs              ;
wire                  lcd_de              ;
wire [15:0]           lcd_rgb             ;
wire                  lcd_bl              ;
wire                  lcd_rst             ;
wire                  lcd_pclk            ;

initial begin
    clk = 1'b1;
    rst = 1'b0;
    key_1 = 1'b1;
    key_2 = 1'b1;
    key_3 = 1'b1;
    key_4 = 1'b1;
    ad_data = 8'd0;
    #20
    rst = 1'b1;
    #200000
    $stop;
end

always #10 clk = ~clk;

always @(posedge ad_clk or negedge rst) begin
    if(rst == 1'b0)
        ad_data <= 8'h0;
    else if(ad_data == 8'd255)
        ad_data <= 8'h0;
    else
        ad_data <= ad_data + 1'b1;
end

shiboqi shiboqi_inst(
    .clk        (clk        ),
    .rst        (rst        ),
    .key_1      (key_1      ),
    .key_2      (key_2      ),
    .key_3      (key_3      ),
    .key_4      (key_4      ),

    .ad_data    (ad_data    ),
    .ad_clk     (ad_clk     ),

    .clk_5m     (clk_5m     ),
    .lcd_hs     (lcd_hs     ),
    .lcd_vs     (lcd_vs     ),
    .lcd_de     (lcd_de     ),
    .lcd_rgb    (lcd_rgb    ),
    .lcd_bl     (lcd_bl     ),
    .lcd_rst    (lcd_rst    ),
    .lcd_pclk   (lcd_pclk   )
);

endmodule
