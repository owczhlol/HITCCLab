`timescale 1ns / 1ps

module cache_data(
    input          clk,
    input          en,
    input  [31:0]  wen,//按字节使能
    input  [6:0]   index,
    input  [4:0]   offset,
    input  [255:0] data_wdata,
    output [31:0]  data_rdata
    );
    //地址流水段：在数据存储器中地址流水段没有工作

    //-----段间寄存器----
    reg [4:0] last_offset;
    always @(posedge clk) begin
        last_offset <= offset;
    end

    //-----调用IP核搭建Cache的数据存储器-----
    /*
        Cache_Data_RAM: 128行，每行256bit
        接口信号含义：   clka：时钟信号
                        ena: 使能信号，控制整个ip核是否工作
                        wea：写使能信号：
                                当写使能为0时，整个ip核仅执行读的功能，即：将地址addra处的数据读取至douta中
                                当写使能为1时，整个ip核仅执行写的功能，即：将输入的数据dina写入至地址dina处
                        addra：地址信号，说明读/写的地址
                        dina：需要写入的数据，仅在wea == 1时有效
                        douta：读取的数据，在wea == 0时有效，从地址addra处读取出数据
    */
    wire [255:0] bank_douta;

    cache_data_ram BANK_0_7(
        .clka(clk),
        .ena(en),
        .wea(wen),
        .addra(index),
        .dina(data_wdata),
        .douta(bank_douta)
    );

    //bank_douta：在Cache的数据存储器中，以index为地址读取出的数据，位宽为256，即一次性读取出一行的8个数据
    //buf_rdata： 将bank_douta中包含的8个数据拆解成二维数组
    //data_rdata：根据offset选取出Cache中命中的数据，由于在Cache的数据流水段才返回数据，因此offset使用段间寄存器中存储的值，即last_offset
    wire [31:0]  buf_rdata[7:0];
    assign {buf_rdata[0],buf_rdata[1],buf_rdata[2],buf_rdata[3],buf_rdata[4],buf_rdata[5],buf_rdata[6],buf_rdata[7]} = bank_douta;
    assign data_rdata = buf_rdata[last_offset[4:2]];
endmodule

