/************** 注释    ****************

灰度转换：RGB888-->Gray

gray = R*0.299 + G*0.587 + B*0.114
        =  （306 * R + 601 * G + 117 * B）/1024;

****************************************/

module rgb2gray(

    input           clk         ,
    input           rst_n       ,
    
    input           din_sop     ,
    input           din_eop     ,
    input           din_vld     ,
    input   [15:0]  din         ,//RGB565

    output          dout_sop    ,
    output          dout_eop    ,
    output          dout_vld    ,
    output  [7:0]   dout         //灰度输出
);

//信号定义
    reg     [7:0]       data_r  ;
    reg     [7:0]       data_g  ;
    reg     [7:0]       data_b  ;
    
    reg     [17:0]      pixel_r ;
    reg     [17:0]      pixel_g ;
    reg     [17:0]      pixel_b ;
    reg     [19:0]      pixel   ;

    reg     [1:0]       sop     ;      
    reg     [1:0]       eop     ;
    reg     [1:0]       vld     ;

//扩展    RGB565-->RGB888
    always  @(posedge clk or negedge rst_n)begin
        if(~rst_n)begin
            data_r <= 0;
            data_g <= 0;
            data_b <= 0;
        end
        else if(din_vld)begin
            data_r <= {din[15:11],din[13:11]};      //带补偿的  r5,r4,r3,r2,r1, r3,r2,r1
            data_g <= {din[10:5],din[6:5]}   ;
            data_b <= {din[4:0],din[2:0]}    ;
            /*
            data_r <= {din[15:11],3'd0};
            data_g <= {din[10:5],2'd0} ;
            data_b <= {din[4:0],3'd0}  ;
            */
        end
    end

//加权   
    //第一拍
    always  @(posedge clk or negedge rst_n)begin
        if(~rst_n)begin
            pixel_r <= 0;
            pixel_g <= 0;
            pixel_b <= 0;
        end
        else if(vld[0])begin
            pixel_r <= data_r * 306;
            pixel_g <= data_g * 601;
            pixel_b <= data_b * 117;
        end
    end
    
    //第二拍
    always  @(posedge clk or negedge rst_n)begin
        if(~rst_n)begin
            pixel <= 0;
        end
        else if(vld[1])begin
            pixel <= pixel_r + pixel_g + pixel_b;
        end
    end

    always  @(posedge clk or negedge rst_n)begin
        if(~rst_n)begin
            sop <= 0;  
            eop <= 0;  
            vld <= 0; 
        end
        else begin
            sop <= {sop[0],din_sop};  
            eop <= {eop[0],din_eop};  
            vld <= {vld[0],din_vld};
        end
    end

//输出
    assign dout = pixel[10 +:8];    //取平均
    assign dout_sop = sop[1];
    assign dout_eop = eop[1];
    assign dout_vld = vld[1];


endmodule 

