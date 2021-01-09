`timescale 1ns / 1ps

module cache_tagv(
    input         clk,
    input         en,
    input         wen,
    input [6:0]   index,
    input [19:0]  tag_wdata,
    input         valid_wdata,

    //TODO:删除两个输出信号
    output [19:0] tag_rdata,
    output        hit,
    output        valid
    );
    //--------TagV Ram-------
    /*
         Tag  Valid
        20:1   0:0
    */
    //目录表的结构
    //128行的目录表，每行的第0位为valid位，标识当前行是否有效；第1-20位为tag位，用于进行Cache的查找，判断是否命中
    //根据index作为行索引查找目录表
    reg [20:0] tagv_ram[127:0];
    //---Write---
    //目录表的更新
    //当Cache从存储器读取回新的数据的时候，目录表的写使能有效，此时会对目录表进行更新
    //分别向对应行的tag位和valid位写入新的数据，即tag_wdata和valid_wdata
    always @(posedge clk) begin
        if (wen) begin
            tagv_ram[index] <= {tag_wdata,valid_wdata};
        end
        else begin
        end
    end
    //---Read---
    //目录表的查找
    //目录表和Cache相对应，也分为地址流水段和数据流水段
    //其中地址流水段会将接收到的地址信息和目录表的查找结果存储进段间寄存器last_tag和tagv_dout
    //last_tag为地址流水段接收的地址信息，tagv_dout为目录表的查找结果(即目录表中index对应的的整行数据)
    reg [20:0] tagv_dout;
    always @(posedge clk) begin
        tagv_dout <= tagv_ram[index];
    end
    //-------Last Tag--------
    reg [19:0] last_tag;
    always @(posedge clk) begin
        last_tag <= tag_wdata;
    end

    //在数据流水段给出相应的查找结果
    //查找的完整过程为：利用index作为行索引查找目录表，得到对应的valid位和tag位
    //若valid为1，则说明目录表中当前行数据有效。否则目录表中当前行数据无效，可直接判定不命中
    //在valid == 1时，比较输入地址的tag位和目录表中的tag位，若相同则说明cache命中，反之则不命中
    //命中即将信号hit挂高
    //---------Output---------
    assign tag_rdata = tagv_dout[20:1];
    assign valid     = tagv_dout[0];
    assign hit       = (last_tag == tag_rdata) && valid;
endmodule

