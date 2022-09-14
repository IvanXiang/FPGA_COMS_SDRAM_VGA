
/************** 注释 ***********

Sobel算子模板系数：

y 				x
-1	0	1		1	2	1
-2	0	2		0	0	0
-1	0	1		-1	-2	-1

g = |x_g| + |y_g|


*******************************/


module sobel(
    input           clk     ,
    input           rst_n   ,
    input           din     ,//输入二值图像
    input           din_sop ,
    input           din_eop ,
    input           din_vld ,

    output          dout    ,
    output          dout_sop,
    output          dout_eop,
    output          dout_vld 
);

//信号定义
    wire            taps0   ; 
    wire            taps1   ; 
    wire            taps2   ; 

    reg             line0_0 ;
    reg             line0_1 ;
    reg             line0_2 ;

    reg             line1_0 ;
    reg             line1_1 ;
    reg             line1_2 ;

    reg             line2_0 ;
    reg             line2_1 ;
    reg             line2_2 ;
    
    reg     [3:0]   sop     ;
    reg     [3:0]   eop     ;
    reg     [3:0]   vld     ;
    
    reg     [2:0]   x0_sum  ;
    reg     [2:0]   x2_sum  ;

    reg     [2:0]   y0_sum  ;
    reg     [2:0]   y2_sum  ;

    reg     [3:0]   x_abs   ;
    reg     [3:0]   y_abs   ;
    
    reg     [3:0]   g       ;

//缓存3行

sobel_line_buf	sobel_line_buf_inst (
	.aclr       (~rst_n     ),
	.clken      (din_vld    ),
	.clock      (clk        ),
	.shiftin    (din        ),
	.shiftout   (           ),
	.taps0x     (taps0      ),
	.taps1x     (taps1      ),
	.taps2x     (taps2      )
	);

//缓存3列   第一级流水
    always  @(posedge clk or negedge rst_n)begin
        if(~rst_n)begin
            line0_0 <= 0;line0_1 <= 0;line0_2 <= 0;
            line1_0 <= 0;line1_1 <= 0;line1_2 <= 0;
            line2_0 <= 0;line2_1 <= 0;line2_2 <= 0;
        end
        else if(vld[0])begin
            line0_0 <= taps0;line0_1 <= line0_0;line0_2 <= line0_1;
            line1_0 <= taps1;line1_1 <= line1_0;line1_2 <= line1_1;
            line2_0 <= taps2;line2_1 <= line2_0;line2_2 <= line2_1;
        end
    end

//x0_sum    第二级流水
    always  @(posedge clk or negedge rst_n)begin
        if(~rst_n)begin
            x0_sum <= 0;
            x2_sum <= 0;
            y0_sum <= 0;
            y2_sum <= 0;
        end
        else if(vld[1])begin
            x0_sum <= {2'd0,line0_0} + {1'd0,line0_1,1'd0} + {2'd0,line0_2};
            x2_sum <= {2'd0,line2_0} + {1'd0,line2_1,1'd0} + {2'd0,line2_2};
            y0_sum <= {2'd0,line0_0} + {1'd0,line1_0,1'd0} + {2'd0,line2_0};
            y2_sum <= {2'd0,line0_2} + {1'd0,line1_2,1'd0} + {2'd0,line2_2};
        end
    end    

    //第3级流水 计算x 、y方向梯度绝对值
    always  @(posedge clk or negedge rst_n)begin
        if(~rst_n)begin
            x_abs <= 0;
            y_abs <= 0;
        end
        else if(vld[2])begin
            x_abs <= (x0_sum >= x2_sum)?(x0_sum-x2_sum):(x2_sum-x0_sum);
            y_abs <= (y0_sum >= y2_sum)?(y0_sum-y2_sum):(y2_sum-y0_sum);
        end
    end

    //第4级计算梯度
    always  @(posedge clk or negedge rst_n)begin
        if(~rst_n)begin
            g <= 0;
        end
        else if(vld[3])begin
            g <= x_abs + y_abs;//绝对值之和 近似 平方和开根号
        end
    end

//打拍
    always  @(posedge clk or negedge rst_n)begin
        if(~rst_n)begin
            sop <= 0;
            eop <= 0;
            vld <= 0;
        end
        else begin
            sop <= {sop[2:0],din_sop};
            eop <= {eop[2:0],din_eop};
            vld <= {vld[2:0],din_vld};
        end
    end


    assign  dout     = g >= 3;//阈值假设为3 当某一个像素点的梯度值大于3，认为其是一个边缘点
    assign  dout_sop = sop[3];
    assign  dout_eop = eop[3];
    assign  dout_vld = vld[3];

endmodule 

