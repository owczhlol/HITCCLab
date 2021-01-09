`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//  @Copyright HIT team
//  Instruction cache
//////////////////////////////////////////////////////////////////////////////////

module cache(
    input         clk	,
    input         resetn,

    //  Sram-Like�ӿ��źŶ���:
    //  1. cpu_req     ��ʶCPU��Cache����ô�������źţ���CPU��Ҫ��Cache��ȡ����ʱ�����ź���Ϊ1
    //  2. cpu_addr    CPU��Ҫ��ȡ�������ڴ洢���еĵ�ַ,���ô��ַ
    //  3. cache_rdata ��Cache�ж�ȡ�����ݣ���Cache��CPU����
    //  4. cache_addr_ok     ��ʶCache��CPU��ַ���ֳɹ����źţ�ֵΪ1����Cache�ɹ�����CPU���͵ĵ�ַ
    //  5. cache_data_ok     ��ʶCache��CPU������ݴ��͵��źţ�ֵΪ1����CPU�ڱ�ʱ��������������ݽ���
    input         cpu_req	   ,     //��CPU������Cache
    input  [31:0] cpu_addr     ,    //��CPU������Cache
    output [31:0] cache_rdata  ,    //��Cache���ظ�CPU
    output        cache_addr_ok,    //��Cache���ظ�CPU
    output        cache_data_ok,    //��Cache���ظ�CPU

	 //  AXI�ӿ��źŶ���:
    //  Cache��AXI�����ݽ�����Ϊ�����׶Σ��������ֽ׶κ͵�ַ���ֽ׶�
	 //  ʵ������������ע����AXI�ӿ��ź�
	 output [3 :0] arid   ,
    output [31:0] araddr ,
    output        arvalid,
    input         arready,

    input  [3 :0] rid    ,
    input  [31:0] rdata  ,
    input         rlast  ,
    input         rvalid ,
    output        rready
);

    //----------------����ģ��------------------
    //-----״̬�Զ���-----
    //  ���ﶨ����Cache�Ĺ���״̬,verilog�ܹ��Զ�ʶ�𲢹����Զ���
    //  IDLE: 		��ת״̬���ڴ���д������Cache�У����״̬���ڵ���ʱ����������һ��״̬�Զ�ת�Ƶ�RUN״̬
    //  RUN:  		����״̬�������״̬���Խ���CPU�Ķ�����������ϸ������ж�������δ���У���ת�Ƶ�SEL_WAY״̬����ѡ·
    //  SEL_WAY: 	Cacheδ���У�����SEL_WAY״̬����LRU����ѡ·����ת�Ƶ�MISS״̬
    //  MISS: 		��������ڣ�Cache�����LRU��������AXI���󣬴Ӵ洢���ж�ȡδ���е��У�������豸���洢�������ܶ�������Cache���뵽����״̬REFILL
    //  REFILL: 	Cache����AXI���ص����ݣ����AXI�����ݴ����������Cache����FINISH״̬
    //  FINISH: 	���ݴ�����ɣ�Cache����һ��״̬�ص�IDLE״̬
    //  RESETN: 	��ʼ��״̬������128��ʱ�����ڣ�ֱ����ʼ��������Ϊ127ʱ�ص�IDLE״̬
    parameter IDLE    = 4'b0000;
    parameter RUN     = 4'b0001;
    parameter SEL_WAY = 4'b0010;
    parameter MISS    = 4'b0011;
    parameter REFILL  = 4'b0100;
    parameter FINISH  = 4'b0101;
    parameter RESETN  = 4'b1111;
    reg [3:0] state;
	 
    // �Զ���״̬ת��
    always @(posedge clk) begin
        if (!resetn) begin
            state <= RESETN;
        end
        else begin
				//�뽫���пհײ���������ֻ����д�Զ���״̬����
            case (state)
                IDLE:   state <= RUN;
					 //(last_req && !hit)����Ϊ������δ���е�CPU�ô����󣬼�Cache������δ����
                RUN:    state <= (last_req && !hit) ? SEL_WAY : RUN;
                SEL_WAY:state <= MISS;
					 //�洢���Ѿ��ɹ�������Cache���͵ĵ�ַ�����洢����Cache�ĵ�ַ�������
                MISS:   state <= arready ? REFILL : MISS;
					 //(rlast && rvalid && (rid == 3'd3))�źŵĺ���Ϊ����ǰ�����ݴ�������Ѿ��������������������
                REFILL: state <= (rlast && rvalid && (rid == 3'd3)) ? FINISH : REFILL;
                FINISH: state <= IDLE;
                RESETN: state <= (resetn_counter == 127)?IDLE:RESETN;
                default:state <= IDLE;
            endcase
        end
    end
	 
    //-----LRU��Ϣ-----
    //  ���ڶ�·��������Cache,����������Ŀ¼������ݴ洢�������ʹ��1λ��LRUλ�Ϳɼ�¼�ϴθ���Cacheʱ�����
    //  128�е�Cache��ÿһ�ж���Ҫ��һ��LRUλ����������ʹ��128λ������lru����¼����Cache��LRU��Ϣ
    //  LRU[i] == 0��˵�����ڵ�i�ж��ԣ���0·ʹ�õĸ��١�
    //  way_sel��ʾѡ·�Ľ����way_sel[0] == 1��ʾѡ·ʱѡ���0·��way_sel[1] == 1��ʾѡ·ʱѡ���1·.
    reg [127:0] lru;
    reg [1  :0] way_sel;
    //---LRUѡ·---
    //  ����������ȱʧ���е�LRUλΪ0ʱ��ѡ���0·
    //  ����������ȱʧ���е�LRUλΪ1ʱ��ѡ���1·
    always @(posedge clk) begin
        if (!resetn) begin
            way_sel <= 2'b0;
        end
        else if (state == SEL_WAY) begin
				//�뽫Case���ڵĴ��벹������
            case (lru[last_index])
                1'b0: way_sel <= 2'b01;
                1'b1: way_sel <= 2'b10;
            endcase
        end 
        else begin
        end
    end
    //----LRU����----
    //  ���ղ�ѡ·ʱѡ���˵�0·����ô�������ʹ�õ�·���ǵ�1·
    //  ���ղ�ѡ·ʱѡ���˵�1·����ô�������ʹ�õ�·���ǵ�0·
    always @(posedge clk) begin
        if (!resetn) begin
            lru <= 128'b0;
        end
        else if (state == MISS) begin
				//�뽫Case���ڵĴ��벹������
            case (way_sel)
                2'b01: lru[last_index] <= 1;
                2'b10: lru[last_index] <= 0;
                default:;
            endcase
        end
        else begin
        end
    end
    //-----��ʼ��������-----
    //  ���ڳ�ʼ��,���TagVģ���е�validλ
    //  ÿ�����һ��,��Ҫ���128������
    reg [6:0] resetn_counter;
    always @(posedge clk) begin
        if (!resetn) begin
            resetn_counter <= 7'b0;
        end
        else begin
            resetn_counter <= resetn_counter + 7'b1;
        end
    end
    //-----�����滻������-----
    //  ��Cache��������ȱʧʱ����Ҫ���ڴ��ж�ȡ��������
    //  ����һ��256�ֽڣ����Դ��8��32λ�����ݣ����ڴ�ͨ��AXI���ߴ�������ʱ��һ����ֻ�ܴ���32λ
    //  �����Ҫ8�����ڲ��ܴ�����һ�����ݣ�����ʹ��refill_counter����¼��ǰ�����������Cache���е�λ��
    //  ���ڿ������ݴ洢����дʹ���źŽ�����д�뵽Cache�����ݴ洢���Ķ�Ӧ���е�λ��
    reg  [2  :0] refill_counter;
    always @(posedge clk) begin
        if (!resetn) begin
            refill_counter <= 3'b0;
        end
        else if (state == MISS) begin
            refill_counter <= last_offset[4:2];
        end
        else if (rvalid && (rid == 3'd3)) begin
            refill_counter <= refill_counter + 3'b1;
        end
        else begin
        end
    end
    //-----��ˮ��״̬��ʶ-----
    //  pipeline_state�����ڱ�ʶ��ˮ��״̬�ļĴ���
    //  �����ǰCache����ˮ״̬Ϊ��������״̬����ô��ַ��ˮ����������(addr_ok == 1)��
    //  ��������ˮ�λ�δ����(data_ok == 0)����������ˮ�߻���������
    //  �����ǰCache����ˮ״̬Ϊ����������״̬����ô��ַ��ˮ�β��Ṥ��(addr_ok == 0)��
    //  ��������ˮ����������(data_ok == 1)����������ˮ�߻���뵽����״̬
    //  �ܹ����Cache��ˮ״̬���¼��У�CPUֹͣ��Cache�������ݡ�Cache����δ����
    parameter PIPELINE_RUN  = 1'b1;
    parameter PIPELINE_IDLE = 1'b0;
    reg pipeline_state;
    always @(posedge clk) begin
        if (!resetn) begin
            pipeline_state <= PIPELINE_IDLE;
        end
        else if (cache_addr_ok && !cache_data_ok) begin
            pipeline_state <= PIPELINE_RUN;
        end
        else if (!cache_addr_ok && cache_data_ok) begin
            pipeline_state <= PIPELINE_IDLE;
        end
        else begin
        end
    end


    //---------------��ַ��ˮ��-----------------
    //  ������Ҫ��ȡ�����ݵĵ�ַ����ַ�ṹ������ʾ��
	//  |  tag  | index | offset |
	//  |31   12|11    5|4      0|
    wire [19:0] tag    = cpu_addr[31:12];
    wire [6 :0] index  = cpu_addr[11:5 ];
    wire [4 :0] offset = cpu_addr[4 :0 ];

    //  �жϵ�ǰCache������״̬������ɹ����յ�ַ�ͽ���CPU���ص�addr_ok����
    assign cache_addr_ok = cpu_req && (state == RUN) && ((pipeline_state == RUN)?cache_data_ok:1'b1);

    //--------------�μ�Ĵ���------------
    //  �μ�Ĵ���Ϊ��last_req��last_tag��last_index��last_offset�����ڱ����ַ��ˮ�������յ��ĵ�ַ��Ϣ������������ˮ�ν���Cache�Ĳ���
    //  ��Щ�μ�Ĵ�����Ҫ�ڵ�ַ��ˮ�ι������ʱ(��addr_okΪ1ʱ)������Ӧ����Ϣ
    //  ��last_req�źű�ʶ��ǰ��������ˮ���Ƿ����"��ַ�Ѿ��ɹ����ա������ݻ���δ����"�����ݶ�����(����������ˮ�ε�ʹ���ź�)
    //  ��ˣ�last_req�źŻ�����������ˮ�ι������ʱ(��data_okΪ1ʱ)��last_req���
    reg          last_req;
    reg [19 :0]  last_tag;
    reg [6  :0]  last_index;
    reg [4  :0]  last_offset;

    always @(posedge clk) begin
        if (!resetn) begin
            last_req <= 1'b0;
        end
        else if (cache_addr_ok) begin
            last_req    <= cpu_req;
            last_tag    <= tag;
            last_index  <= index;
            last_offset <= offset;
        end
        else if (cache_data_ok) begin
            last_req <= 1'b0;
        end
        else begin
        end
    end

    //---------------������ˮ��-----------------
    //  �����ж�
	 //  Ŀ¼������źţ�
    //  ����ʹ�ö�·��������Cache�����ÿһ·��Ŀ¼������һ��hit�źţ���������ǰ·�Ƿ�����
    //  ���ʹ�ó���Ϊ2������hit_array����ʾ���е����
    //  ��hit_array[0] == 1ʱ����ʾ��0·���У�hit_array[1] == 1ʱ����ʾ��1·����
    //  ����·ȫδ����ʱ��hit_array[0]��hit_array[1]��Ϊ0����hit_array == 0
    wire [1  :0] hit_array;
    //  ʹ��hit�ź�����ʾ����Cache�Ƿ����У�Cache��ǰ���Խ��շô����󣬲���������ĵ�ַ��ĳһ·��Ŀ¼�������У����ж�����Cache����
    wire         hit = !(!hit_array) && (state == RUN);
    //  ʹ��hit_way�ź����жϾ�����������һ·��hit_way == 0��ʾ���е�0·��hit_way == 1��ʾ���е�1·��hit_way�źŽ���hitΪ1ʱ����Ч
    wire         hit_way = hit_array[1];

    //  ����ѡ��
    //  cache_rdata����cpu���ص��źţ�������·��������Cache�����������ݴ洢��������ڶ�ȡʱ�᷵������ֵ
    //  ��Ҫ����hit_way�ź��ж���������һ·���Ӷ�ѡ���һ����ȷ��ֵ����
    assign cache_rdata = data_rdata[hit_way];

    //  �����ź�
    //  ��Ŀǰ�����Ѿ����յ�ַ����δ�������ݵķô����󣬲���Cache��������ʱ��ֱ�ӾͿ���ͬʱ��CPU�������ݺ�data_ok
    assign cache_data_ok = last_req && hit;

    //--------------Ŀ¼������ݿ�------------
	 //  Ŀ¼�������źţ�
    //  tagv_wen��     Ŀ¼���дʹ���źţ���·��������������Ŀ¼�����ʹ�ó���Ϊ2�����飬���ֱ���Ϊ����Ŀ¼���дʹ��
    //                 tagv_wen[0]:��0·Ŀ¼���дʹ�ܣ�
    //                 tagv_wen[1]����1·Ŀ¼���дʹ��
    //                 �źŸ�ֵ˵����
    //                 ��resetʱ����·����Ҫ��ʼ�������tagv_wen��ֵΪ2'b11��
    //                 ��Cacheȱʧʱ����Ҫ����ѡ·�㷨��ѡ�����ݷ�������һ·��tagv_wen��ֵ����way_sel
    //                 ����������£�Ŀ¼��Ӧ�ñ����ģ����Ӧ��Ϊ2'b00����֤�䲻�ᱻд
    //  tagv_index_in������Ҫ���ҵĵ�ַ��index������ΪĿ¼�����������Ŀ¼����м�����
    //                 ������Cache����ʱ������Ŀ¼����Ҫ����ͬһ����ַ���������Ŀ¼����ͬһ��index�ź�
    //                 �źŸ�ֵ˵����
    //                 ��reset��ʱ����Ҫ��Ŀ¼�����н��г�ʼ�������indexӦ������resetn_counter(����0������127���ӵ�0�г�ʼ������127��)
    //                 ��Cache��������(��RUN״̬)ʱ����Ҫ��Ŀ¼���в���CPU����ĵ�ַ�Ƿ����У������Ҫʹ��index
    //                 ��Cache��������ȱʧʱ��Cache��ˮ�߱���������Ȼ���ڽ����˵�ַ����û�з������ݵķô�����
    //                 ���������Ҫʹ�öμ�Ĵ�����ֵ(last_index)���в���
    //  tag_wdata:     ��Ӧ�ڵ�ַ�ṹ�е�tagλ��������Ŀ¼���е�tagλ���бȽϡ�����Cache����ȱʧʱ�������޸�Ŀ¼���е�tagλ
    //                 �źŸ�ֵ˵����
    //                 ��Cache��������(��RUN״̬)ʱ����Ҫ��Ŀ¼���в���CPU����ĵ�ַ�Ƿ����У������Ҫʹ��tag
    //                 ��Cache��������ȱʧʱ��Cache��ˮ�߱���������Ȼ���ڽ����˵�ַ����û�з������ݵķô�����
    //                 ���������Ҫʹ�öμ�Ĵ�����ֵ(last_tag)���в���
    //  valid_wdata:   ����д��Ŀ¼��ʱ���޸�Ŀ¼���ж�Ӧ��validλ������reset��ʱ����Ҫ��Ŀ¼���е�validλ��գ������������Ҫ��validλ�޸�Ϊ1
	 wire [1  :0] tagv_wen;
    wire [6  :0] tagv_index_in;
    wire [19 :0] tag_wdata;
    wire         valid_wdata;

    assign tagv_wen      = (state == RESETN)?2'b11  :
                           (state == MISS  )?way_sel:2'b00;
    assign tagv_index_in = (state == RESETN)?resetn_counter:
                           (state == RUN   )?index:last_index;
    assign tag_wdata     = (state == RUN   )?tag:last_tag;
    assign valid_wdata   = (state == RESETN)?1'b0:1'b1;
	 //  data_wen:       дʹ���źţ���·��������Cache�����ݴ洢��ͬ����Ҫ����дʹ���ź�
    //                  data_wen[0]Ϊ��0·��дʹ���źţ�data_wen[1]Ϊ��1·��дʹ���ź�
    //                  �źŸ�ֵ˵����
    //                  ���ݴ洢����дʹ���ǰ����ֽڽ���ʹ�ܵģ���32'hf000_0000��ʾ32���ֽ�(256λ)�е�ǰ4���ֽ�(32λ)����Ҫ��д���
    //                  ���ջὫ����д�뵽���ݴ洢���ж�Ӧ�е�ǰ�ĸ��ֽ�(ǰ32λ)��
    //                  ���Ƶأ�32'h0f00_0000���Խ�����д�뵽��5����8���ֽ�(ǰ33λ��ǰ64λ)��
    //                  ��˿���ͨ��������λ(32'hf000_0000 >> refill_wen)����дʹ�ܵķ�ʽ����ʵ�������ݴ洢���е�һ��������д��8������
    //  data_index_in�� ���ڶ�ȡѡ�����ݴ洢�����кţ���Ӧ�ڵ�ַ�ṹ�е�index��
    //                  �źŸ�ֵ˵����
    //                  ��Cache��������(��RUN״̬)ʱ�������ݵķ�������ˮ�ģ�����ַ��ˮ�δ����ַ��������ˮ�ξͿ��Զ�ȡ�����ݣ������Ҫʹ��index
    //                  ��Cache��������ȱʧʱ��Cache��ˮ�߱���������Ȼ���ڽ����˵�ַ����û�з������ݵķô�����
    //                  ���������Ҫʹ�öμ�Ĵ�����ֵ(last_index)���в���
    //  data_offset_in��������һ��������ѡ����������ݣ���Ӧ�ڵ�ַ�ṹ�е�offset����ƫ����
    //                  �źŸ�ֵ˵����
    //                  Cache��������(��RUN״̬)ʱ�������ݵķ�������ˮ�ģ�����ַ��ˮ�δ����ַ��������ˮ�ξͿ��Զ�ȡ�����ݣ������Ҫʹ��offset
    //                  ��Cache��������ȱʧʱ��Cache��ˮ�߱���������Ȼ���ڽ����˵�ַ����û�з������ݵķô��������������Ҫʹ�öμ�Ĵ�����ֵ(last_offset)���в���
    //  data_wdata:     ��Cache����������ʱ����Ҫ�Ѵ��ڴ��ж�ȡ��������д��Cache�����ݴ洢����
    //                  �����ڴ�ʹ�����ߴ������ݣ�һ��ֻ����32λ��һ�����ݣ���һ��������8*32λ
    //                  �����Ҫ���д�ذ˴����ݲ������һ�����ݵ����
    //  data_rdata:     ���ڽ��մ�Cache�����ݴ洢���ж�ȡ��������
    //                  ������·��������Cache�����������ݴ洢��������ڶ�ȡʱ�᷵������ֵ
    //                  ���ʹ�ö�ά���鴢��������ֵ���ٽ��Ŀ¼����ҳ������н��(hit_array)���ж�����ʱ��cpu�����ĸ�����
    wire [31 :0] data_wen[1:0];
    wire [6  :0] data_index_in;
    wire [4  :0] data_offset_in;
    wire [255:0] data_wdata;
    wire [31 :0] data_rdata[1:0];

    wire [4:0] refill_wen = refill_counter << 2;
    assign data_wen[0]    = (way_sel[0] && rvalid && (rid == 3'd3))?(32'hf000_0000 >> refill_wen):32'h0;
    assign data_wen[1]    = (way_sel[1] && rvalid && (rid == 3'd3))?(32'hf000_0000 >> refill_wen):32'h0;
    assign data_index_in  = (state == RUN)?index:last_index;
    assign data_offset_in = (state == RUN)?offset:last_offset;
    assign data_wdata     = {8{rdata}};
    //  generate for�﷨�����ظ��Ե�������Ҫ��ģ��
    generate
        genvar i;
        for (i = 0 ; i < 2 ; i = i + 1) begin
            //�����ģ��cache_tagv�Ľ��ߣ����轫�����еĿհ״�������������
				cache_tagv Cache_TagV (
                .clk(clk),
                .en(1'b1),
					 .wen(tagv_wen[i]),
                .index(tagv_index_in),
                .tag_wdata(tag_wdata),
                .valid_wdata(valid_wdata),
                .hit(hit_array[i])
            );

            cache_data Cache_Data (
                .clk(clk),
                .en(1'b1),
                .wen(data_wen[i]),//bank 0 to 7
                .index(data_index_in),
                .offset(data_offset_in),
                .data_wdata(data_wdata),
                .data_rdata(data_rdata[i])
            );
        end
    endgenerate

    //-----------------AXI------------------
    //�����������AXI���߽���ͨ�ŵ��źţ������ע
    assign arid    = (state == MISS) ? 4'd3 : 4'd0;                 //Cache�����淢�������ʱʹ�õ�AXI�ŵ���id��
    assign araddr  = {last_tag,last_index,last_offset[4:2],2'b00};  //Cache�����淢�������ʱ��ʹ�õĵ�ַ
    assign arvalid = (state == MISS);                               //Cache�����淢�������������ź�
    assign rready  = (state == REFILL);                             //��ʶ��ǰ��Cache�Ѿ�׼���ÿ��Խ������淵�ص�����

endmodule
