`timescale 1ns/1ns
module tb_counter();






initial
    begin
    sys_clk = 1'b1;
    sys_rst_n <= 1'b0;
    #20
    sys_rst_n <= 1'b1;
    end

always #10 sys_clk = ~sys_clk;

counter 
#(




)
counter_inst
(




);
endmodule