`timescale 1ns / 1ps

module cache_tagv(
    input         clk,
    input         en,
    input         wen,
    input [6:0]   index,
    input [19:0]  tag_wdata,
    input         valid_wdata,

    //TODO:ɾ����������ź�
    output [19:0] tag_rdata,
    output        hit,
    output        valid
    );
    //--------TagV Ram-------
    /*
         Tag  Valid
        20:1   0:0
    */
    //Ŀ¼��Ľṹ
    //128�е�Ŀ¼��ÿ�еĵ�0λΪvalidλ����ʶ��ǰ���Ƿ���Ч����1-20λΪtagλ�����ڽ���Cache�Ĳ��ң��ж��Ƿ�����
    //����index��Ϊ����������Ŀ¼��
    reg [20:0] tagv_ram[127:0];
    //---Write---
    //Ŀ¼��ĸ���
    //��Cache�Ӵ洢����ȡ���µ����ݵ�ʱ��Ŀ¼���дʹ����Ч����ʱ���Ŀ¼����и���
    //�ֱ����Ӧ�е�tagλ��validλд���µ����ݣ���tag_wdata��valid_wdata
    always @(posedge clk) begin
        if (wen) begin
            tagv_ram[index] <= {tag_wdata,valid_wdata};
        end
        else begin
        end
    end
    //---Read---
    //Ŀ¼��Ĳ���
    //Ŀ¼���Cache���Ӧ��Ҳ��Ϊ��ַ��ˮ�κ�������ˮ��
    //���е�ַ��ˮ�λὫ���յ��ĵ�ַ��Ϣ��Ŀ¼��Ĳ��ҽ���洢���μ�Ĵ���last_tag��tagv_dout
    //last_tagΪ��ַ��ˮ�ν��յĵ�ַ��Ϣ��tagv_doutΪĿ¼��Ĳ��ҽ��(��Ŀ¼����index��Ӧ�ĵ���������)
    reg [20:0] tagv_dout;
    always @(posedge clk) begin
        tagv_dout <= tagv_ram[index];
    end
    //-------Last Tag--------
    reg [19:0] last_tag;
    always @(posedge clk) begin
        last_tag <= tag_wdata;
    end

    //��������ˮ�θ�����Ӧ�Ĳ��ҽ��
    //���ҵ���������Ϊ������index��Ϊ����������Ŀ¼���õ���Ӧ��validλ��tagλ
    //��validΪ1����˵��Ŀ¼���е�ǰ��������Ч������Ŀ¼���е�ǰ��������Ч����ֱ���ж�������
    //��valid == 1ʱ���Ƚ������ַ��tagλ��Ŀ¼���е�tagλ������ͬ��˵��cache���У���֮������
    //���м����ź�hit�Ҹ�
    //---------Output---------
    assign tag_rdata = tagv_dout[20:1];
    assign valid     = tagv_dout[0];
    assign hit       = (last_tag == tag_rdata) && valid;
endmodule

