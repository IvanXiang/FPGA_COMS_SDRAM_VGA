`include"param.v"
module sdram_controller(
    input           clk     ,//100M 控制器主时钟
    input           clk_in  ,//数据输入时钟
    input           clk_out ,//数据输出时钟
    input           rst_n   ,
    input   [15:0]  din     ,
    input           din_vld ,
    input           din_sop ,
    input           din_eop ,
    input           rd_req  ,//读请求
    output  [15:0]  dout    ,//
    output          dout_vld,
    //sdram接口
    output          cke     ,
    output          csn     ,
    output          rasn    ,
    output          casn    ,
    output          wen     ,
    output  [1:0]   bank    ,
    output  [12:0]  addr    ,
    inout   [15:0]  dq      ,
    output  [1:0]   dqm         
);
//信号定义
 
    wire                avm_write      ; 
    wire                avm_read       ; 
    wire    [23:0]      avm_addr       ; 
    wire    [15:0]      avm_wrdata     ; 
    wire    [15:0]      avs_rddata     ; 
    wire                avs_rddata_vld ; 
    wire                avs_waitrequest; 


 //模块例化

    sdram_ctrl  u_ctrl(
    /*input               */.clk             (clk           ),
    /*input               */.clk_in          (clk_in        ),
    /*input               */.clk_out         (clk_out       ),
    /*input               */.rst_n           (rst_n         ),
    //数据输入
    /*input   [15:0]      */.din             (din           ),//摄像头输入像素数据
    /*input               */.din_sop         (din_sop       ),
    /*input               */.din_eop         (din_eop       ),    
    /*input               */.din_vld         (din_vld       ),
    //数据输出
    /*input               */.rdreq           (rd_req        ),//vga的读数据请求
    /*output  [15:0]      */.dout            (dout          ),//输出给vga的数据
    /*output              */.dout_vld        (dout_vld      ),//输出给vga的数据有效标志
    //sdram_interface
    /*output              */.avm_write       (avm_write      ),//输出给sdram 接口 IP 的写请求
    /*output              */.avm_read        (avm_read       ),//输出给sdram 接口 IP 的读请求
    /*output  [23:0]      */.avm_addr        (avm_addr       ),//输出给sdram 接口 IP 的读写地址
    /*output  [15:0]      */.avm_wrdata      (avm_wrdata     ),//输出给sdram 接口 IP 的写数据
    /*input   [15:0]      */.avs_rddata      (avs_rddata     ),//sdram 接口 IP 输入的读数据
    /*input               */.avs_rddata_vld  (avs_rddata_vld ),
    /*input               */.avs_waitrequest (avs_waitrequest)   
    
    );


    sdram_interface u_interface (
        .clk_clk           (clk             ),           //     clk.clk
        .reset_reset_n     (rst_n           ),     //   reset.reset_n
        .avs_address       (avm_addr        ),       //     avs.address
        .avs_byteenable_n  (2'b00           ),  //        .byteenable_n
        .avs_chipselect    (1'b1            ),    //        .chipselect
        .avs_writedata     (avm_wrdata      ),     //        .writedata
        .avs_read_n        (avm_read        ),        //        .read_n
        .avs_write_n       (avm_write       ),       //        .write_n
        .avs_readdata      (avs_rddata      ),      //        .readdata
        .avs_readdatavalid (avs_rddata_vld  ), //        .readdatavalid
        .avs_waitrequest   (avs_waitrequest ),   //        .waitrequest
        .mem_pin_addr      (addr            ),      // mem_pin.addr
        .mem_pin_ba        (bank            ),        //        .ba
        .mem_pin_cas_n     (casn            ),     //        .cas_n
        .mem_pin_cke       (cke             ),       //        .cke
        .mem_pin_cs_n      (csn             ),      //        .cs_n
        .mem_pin_dq        (dq              ),        //        .dq
        .mem_pin_dqm       (dqm             ),       //        .dqm
        .mem_pin_ras_n     (rasn            ),     //        .ras_n
        .mem_pin_we_n      (wen             )       //        .we_n
    );

endmodule      

