module gray2bin(
    input           clk         ,
    input           rst_n       ,
    
    input           din_sop     ,
    input           din_eop     ,
    input           din_vld     ,
    input   [7:0]   din         ,//灰度输入

    output          dout_sop    ,
    output          dout_eop    ,
    output          dout_vld    ,
    output          dout         //二值输出  

);
//信号定义

    reg             binary      ;
    reg             binary_sop  ;
    reg             binary_eop  ;
    reg             binary_vld  ;

    always  @(posedge clk or negedge rst_n)begin
        if(~rst_n)begin
            binary     <= 0 ;
            binary_sop <= 0 ;
            binary_eop <= 0 ;
            binary_vld <= 0 ;
        end
        else begin
            binary     <= din>100 ;//二值化阈值可自定义
            binary_sop <= din_sop ;
            binary_eop <= din_eop ;
            binary_vld <= din_vld ;
        end
    end

   assign dout_sop = binary_sop; 
   assign dout_eop = binary_eop;
   assign dout_vld = binary_vld;
   assign dout     = binary;


endmodule 

