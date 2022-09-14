`include"param.v"
module imag_process(

    input           clk         ,
    input           rst_n       ,
    
    input           din_sop     ,
    input           din_eop     ,
    input           din_vld     ,
    input   [15:0]  din         ,//RGB565

    output          dout_sop    ,
    output          dout_eop    ,
    output          dout_vld    ,
    output  [15:0]  dout         
);

//信号定义
    wire            gray_sop    ; 
    wire            gray_eop    ; 
    wire            gray_vld    ; 
    wire    [7:0]   gray        ;

    wire            gray_din_sop; 
    wire            gray_din_eop; 
    wire            gray_din_vld; 
    wire    [7:0]   gray_din    ; 
    
    wire            binary_sop  ; 
    wire            binary_eop  ; 
    wire            binary_vld  ; 
    wire            binary      ; 

    wire            sobel       ; 
    wire            sobel_sop   ; 
    wire            sobel_eop   ; 
    wire            sobel_vld   ; 

//模块例化
 rgb2gray u_gray(
    /*input           */.clk         (clk       ),
    /*input           */.rst_n       (rst_n     ),
    /*input           */.din_sop     (din_sop   ),
    /*input           */.din_eop     (din_eop   ),
    /*input           */.din_vld     (din_vld   ),
    /*input   [15:0]  */.din         (din       ),//RGB565
    /*output          */.dout_sop    (gray_sop  ),
    /*output          */.dout_eop    (gray_eop  ),
    /*output          */.dout_vld    (gray_vld  ),
    /*output  [7:0]   */.dout        (gray      ) //灰度输出
);

`ifdef  ENABLE_GAUSS
    wire            gs_dout_sop ; 
    wire            gs_dout_eop ; 
    wire            gs_dout_vld ; 
    wire    [7:0]   gs_dout     ; 

    gauss_filter u_guass(
    /*input           */.clk         (clk           ),
    /*input           */.rst_n       (rst_n         ),
    /*input           */.din_sop     (gray_sop      ),
    /*input           */.din_eop     (gray_eop      ),
    /*input           */.din_vld     (gray_vld      ),
    /*input   [7:0]   */.din         (gray          ),//灰度输入
    /*output          */.dout_sop    (gs_dout_sop   ),
    /*output          */.dout_eop    (gs_dout_eop   ),
    /*output          */.dout_vld    (gs_dout_vld   ),
    /*output  [7:0]   */.dout        (gs_dout       ) //灰度输出     
    );
    assign gray_din_sop = gs_dout_sop  ; 
    assign gray_din_eop = gs_dout_eop  ; 
    assign gray_din_vld = gs_dout_vld  ; 
    assign gray_din     = gs_dout      ; 

`else
    assign gray_din_sop = gray_sop  ; 
    assign gray_din_eop = gray_eop  ; 
    assign gray_din_vld = gray_vld  ; 
    assign gray_din     = gray      ; 
`endif

    gray2bin u_bin(
    /*input           */.clk         (clk           ),
    /*input           */.rst_n       (rst_n         ),
    /*input           */.din_sop     (gray_din_sop  ),
    /*input           */.din_eop     (gray_din_eop  ),
    /*input           */.din_vld     (gray_din_vld  ),
    /*input   [7:0]   */.din         (gray_din      ),//灰度输入
    /*output          */.dout_sop    (binary_sop    ),
    /*output          */.dout_eop    (binary_eop    ),
    /*output          */.dout_vld    (binary_vld    ),
    /*output          */.dout        (binary        ) //二值输出  
);

 sobel u_sobel(
    /*input           */.clk     (clk       ),
    /*input           */.rst_n   (rst_n     ),
    /*input           */.din     (binary    ),//输入二值图像
    /*input           */.din_sop (binary_sop),
    /*input           */.din_eop (binary_eop),
    /*input           */.din_vld (binary_vld),
    /*output          */.dout    (sobel     ),
    /*output          */.dout_sop(sobel_sop ),
    /*output          */.dout_eop(sobel_eop ),
    /*output          */.dout_vld(sobel_vld )

);

    assign dout_sop = sobel_sop;
    assign dout_eop = sobel_eop; 
    assign dout_vld = sobel_vld;
    assign dout     = {16{sobel}}; 

endmodule 

