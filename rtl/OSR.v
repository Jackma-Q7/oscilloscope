module  OSR(
    input                       clk                 ,
    input                       rst_n               ,
    input       [29:0]          ad_freq             ,

    output  reg                 ad_clk              ,
    output  reg                 deci_valid          ,
    output  reg [15:0]          wraddress
);

reg     [30:0]          deci_cnt                ;
reg     [20:0]          osr_value               ;

// Write RAM address accumulator.
always @(posedge ad_clk or negedge rst_n) begin
    if(!rst_n)
        wraddress <= 16'd0;
    else if(deci_valid && wraddress < 16'hffff)
        wraddress <= wraddress + 1'b1;
    else if(wraddress == 16'hffff)
        wraddress <= 16'd0;
    else
        wraddress <= wraddress;
end

// Decimation counter.
always @(posedge ad_clk or negedge rst_n) begin
    if(!rst_n)
        deci_cnt <= 31'd0;
    else if(deci_cnt >= osr_value)
        deci_cnt <= 31'd0;
    else
        deci_cnt <= deci_cnt + 1'b1;
end

always @(posedge ad_clk or negedge rst_n) begin
    if(!rst_n)
        osr_value <= 21'd0;
    else if(ad_freq > 30'd500000)
        osr_value <= 21'd100;
    else if(ad_freq > 30'd50000 && ad_freq < 30'd500000)
        osr_value <= 21'd2;
    else if(ad_freq > 30'd40000 && ad_freq < 30'd50000)
        osr_value <= 21'd2;
    else if(ad_freq > 30'd30000 && ad_freq < 30'd40000)
        osr_value <= 21'd80;
    else if(ad_freq > 30'd20000 && ad_freq < 30'd30000)
        osr_value <= 21'd80;
    else if(ad_freq > 30'd10000 && ad_freq < 30'd20000)
        osr_value <= 21'd80;
    else
        osr_value <= osr_value;
end

// Output decimation valid pulse.
always @(posedge ad_clk or negedge rst_n) begin
    if(!rst_n)
        deci_valid <= 1'b0;
    else if(deci_cnt == osr_value)
        deci_valid <= 1'b1;
    else
        deci_valid <= 1'b0;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        ad_clk <= 1'b0;
    else
        ad_clk <= ~ad_clk;
end

endmodule
