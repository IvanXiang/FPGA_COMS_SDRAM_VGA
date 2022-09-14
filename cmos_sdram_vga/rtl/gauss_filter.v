/************** 注释 ***********

高斯滤波系数，加权平均

	1	2	1
	2	4	2
	1	2	1

********************************/



module gauss_filter(
    input           clk         ,
    input           rst_n       ,
    
    input           din_sop     ,
    input           din_eop     ,
    input           din_vld     ,
    input   [7:0]   din         ,//灰度输入

    output          dout_sop    ,
    output          dout_eop    ,
    output          dout_vld    ,
    output  [7:0]   dout         //灰度输出     

);

//信号定义
    wire    [7:0]   taps0       ; 
    wire    [7:0]   taps1       ; 
    wire    [7:0]   taps2       ; 

    reg     [7:0]   line0_0     ;
    reg     [7:0]   line0_1     ;
    reg     [7:0]   line0_2     ;

    reg     [7:0]   line1_0     ;
    reg     [7:0]   line1_1     ;
    reg     [7:0]   line1_2     ;

    reg     [7:0]   line2_0     ;
    reg     [7:0]   line2_1     ;
    reg     [7:0]   line2_2     ;

    reg     [9:0]   sum_0       ;//第0行加权和 
    reg     [9:0]   sum_1       ;//第1行加权和
    reg     [9:0]   sum_2       ;//第2行加权和
    
    reg     [11:0]  sum         ;//三行加权和

    reg     [2:0]   sop         ;
    reg     [2:0]   eop         ;
    reg     [2:0]   vld         ;

//缓存3列数据

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

    always  @(posedge clk or negedge rst_n)begin
        if(~rst_n)begin
            sum_0 <= 0;
            sum_1 <= 0;
            sum_2 <= 0;
        end
        else if(vld[1])begin
            sum_0 <= {2'd0,line0_0} + {1'd0,line0_1,1'd0} + {2'd0,line0_2};
            sum_1 <= {1'd0,line1_0,1'd0} + {line1_1,2'd0} + {1'd0,line1_2,1'd0};
            sum_2 <= {2'd0,line2_0} + {1'd0,line2_1,1'd0} + {2'd0,line2_2};
        end
    end

    always  @(posedge clk or negedge rst_n)begin
        if(~rst_n)begin
            sum <= 0;
        end
        else if(vld[2])begin
            sum <= sum_0 + sum_1 + sum_2;
        end
    end
    
    always  @(posedge clk or negedge rst_n)begin
        if(~rst_n)begin
            sop <= 1'b0;  
            eop <= 1'b0;   
            vld <= 1'b0;   
        end
        else begin
            sop <= {sop[1:0],din_sop};   
            eop <= {eop[1:0],din_eop};   
            vld <= {vld[1:0],din_vld};   
        end
    end

//输出
    assign dout = sum[4 +:8];
    assign dout_sop = sop[2];
    assign dout_eop = eop[2];
    assign dout_vld = vld[2];

//缓存3行数据
    gs_line_buf	gs_line_buf_inst (
	.aclr       (~rst_n     ),
	.clken      (din_vld    ),
	.clock      (clk        ),
	.shiftin    (din        ),
	.shiftout   (           ),
	.taps0x     (taps0      ),
	.taps1x     (taps1      ),
	.taps2x     (taps2      )
	);

endmodule 

