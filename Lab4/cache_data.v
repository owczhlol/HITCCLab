`timescale 1ns / 1ps

module cache_data(
    input          clk,
    input          en,
    input  [31:0]  wen,//���ֽ�ʹ��
    input  [6:0]   index,
    input  [4:0]   offset,
    input  [255:0] data_wdata,
    output [31:0]  data_rdata
    );
    //��ַ��ˮ�Σ������ݴ洢���е�ַ��ˮ��û�й���

    //-----�μ�Ĵ���----
    reg [4:0] last_offset;
    always @(posedge clk) begin
        last_offset <= offset;
    end

    //-----����IP�˴Cache�����ݴ洢��-----
    /*
        Cache_Data_RAM: 128�У�ÿ��256bit
        �ӿ��źź��壺   clka��ʱ���ź�
                        ena: ʹ���źţ���������ip���Ƿ���
                        wea��дʹ���źţ�
                                ��дʹ��Ϊ0ʱ������ip�˽�ִ�ж��Ĺ��ܣ���������ַaddra�������ݶ�ȡ��douta��
                                ��дʹ��Ϊ1ʱ������ip�˽�ִ��д�Ĺ��ܣ����������������dinaд������ַdina��
                        addra����ַ�źţ�˵����/д�ĵ�ַ
                        dina����Ҫд������ݣ�����wea == 1ʱ��Ч
                        douta����ȡ�����ݣ���wea == 0ʱ��Ч���ӵ�ַaddra����ȡ������
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

    //bank_douta����Cache�����ݴ洢���У���indexΪ��ַ��ȡ�������ݣ�λ��Ϊ256����һ���Զ�ȡ��һ�е�8������
    //buf_rdata�� ��bank_douta�а�����8�����ݲ��ɶ�ά����
    //data_rdata������offsetѡȡ��Cache�����е����ݣ�������Cache��������ˮ�βŷ������ݣ����offsetʹ�öμ�Ĵ����д洢��ֵ����last_offset
    wire [31:0]  buf_rdata[7:0];
    assign {buf_rdata[0],buf_rdata[1],buf_rdata[2],buf_rdata[3],buf_rdata[4],buf_rdata[5],buf_rdata[6],buf_rdata[7]} = bank_douta;
    assign data_rdata = buf_rdata[last_offset[4:2]];
endmodule

