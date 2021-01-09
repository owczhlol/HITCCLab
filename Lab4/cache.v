`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//  @Copyright HIT team
//  Instruction cache
//////////////////////////////////////////////////////////////////////////////////

module cache(
    input         clk	,
    input         resetn,

    //  Sram-Like接口信号定义:
    //  1. cpu_req     标识CPU向Cache发起访存请求的信号，当CPU需要从Cache读取数据时，该信号置为1
    //  2. cpu_addr    CPU需要读取的数据在存储器中的地址,即访存地址
    //  3. cache_rdata 从Cache中读取的数据，由Cache向CPU返回
    //  4. cache_addr_ok     标识Cache和CPU地址握手成功的信号，值为1表明Cache成功接收CPU发送的地址
    //  5. cache_data_ok     标识Cache和CPU完成数据传送的信号，值为1表明CPU在本时钟周期内完成数据接收
    input         cpu_req	   ,     //由CPU发送至Cache
    input  [31:0] cpu_addr     ,    //由CPU发送至Cache
    output [31:0] cache_rdata  ,    //由Cache返回给CPU
    output        cache_addr_ok,    //由Cache返回给CPU
    output        cache_data_ok,    //由Cache返回给CPU

	 //  AXI接口信号定义:
    //  Cache与AXI的数据交换分为两个阶段：数据握手阶段和地址握手阶段
	 //  实验过程中无需关注下列AXI接口信号
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

    //----------------控制模块------------------
    //-----状态自动机-----
    //  这里定义了Cache的工作状态,verilog能够自动识别并构造自动机
    //  IDLE: 		空转状态，在存在写操作的Cache中，这个状态用于调整时序。它会在下一个状态自动转移到RUN状态
    //  RUN:  		运行状态，在这个状态可以接收CPU的读请求。如果在上个周期有读请求且未命中，会转移到SEL_WAY状态进行选路
    //  SEL_WAY: 	Cache未命中，会在SEL_WAY状态根据LRU进行选路，并转移到MISS状态
    //  MISS: 		在这个周期，Cache会更新LRU，并发起AXI请求，从存储器中读取未命中的行，如果从设备（存储器）接受读请求，则Cache进入到接收状态REFILL
    //  REFILL: 	Cache接收AXI传回的数据，如果AXI的数据传输结束，则Cache进入FINISH状态
    //  FINISH: 	数据传输完成，Cache在下一个状态回到IDLE状态
    //  RESETN: 	初始化状态，持续128个时钟周期，直到初始化计数器为127时回到IDLE状态
    parameter IDLE    = 4'b0000;
    parameter RUN     = 4'b0001;
    parameter SEL_WAY = 4'b0010;
    parameter MISS    = 4'b0011;
    parameter REFILL  = 4'b0100;
    parameter FINISH  = 4'b0101;
    parameter RESETN  = 4'b1111;
    reg [3:0] state;
	 
    // 自动机状态转移
    always @(posedge clk) begin
        if (!resetn) begin
            state <= RESETN;
        end
        else begin
				//请将下列空白补充完整，只需填写自动机状态即可
            case (state)
                IDLE:   state <= RUN;
					 //(last_req && !hit)含义为：存在未命中的CPU访存请求，即Cache发生了未命中
                RUN:    state <= (last_req && !hit) ? SEL_WAY : RUN;
                SEL_WAY:state <= MISS;
					 //存储器已经成功接收了Cache发送的地址，即存储器与Cache的地址握手完成
                MISS:   state <= arready ? REFILL : MISS;
					 //(rlast && rvalid && (rid == 3'd3))信号的含义为：当前的数据传输过程已经结束，即数据握手完成
                REFILL: state <= (rlast && rvalid && (rid == 3'd3)) ? FINISH : REFILL;
                FINISH: state <= IDLE;
                RESETN: state <= (resetn_counter == 127)?IDLE:RESETN;
                default:state <= IDLE;
            endcase
        end
    end
	 
    //-----LRU信息-----
    //  对于二路组相联的Cache,仅存在两个目录表和数据存储器，因此使用1位的LRU位就可记录上次更改Cache时的情况
    //  128行的Cache，每一行都需要有一个LRU位，所以最终使用128位的数组lru来记录整个Cache的LRU信息
    //  LRU[i] == 0，说明对于第i行而言，第0路使用的更少。
    //  way_sel表示选路的结果。way_sel[0] == 1表示选路时选择第0路，way_sel[1] == 1表示选路时选择第1路.
    reg [127:0] lru;
    reg [1  :0] way_sel;
    //---LRU选路---
    //  当发生数据缺失的行的LRU位为0时，选择第0路
    //  当发生数据缺失的行的LRU位为1时，选择第1路
    always @(posedge clk) begin
        if (!resetn) begin
            way_sel <= 2'b0;
        end
        else if (state == SEL_WAY) begin
				//请将Case块内的代码补充完整
            case (lru[last_index])
                1'b0: way_sel <= 2'b01;
                1'b1: way_sel <= 2'b10;
            endcase
        end 
        else begin
        end
    end
    //----LRU更新----
    //  若刚才选路时选择了第0路，那么最近最少使用的路就是第1路
    //  若刚才选路时选择了第1路，那么最近最少使用的路就是第0路
    always @(posedge clk) begin
        if (!resetn) begin
            lru <= 128'b0;
        end
        else if (state == MISS) begin
				//请将Case块内的代码补充完整
            case (way_sel)
                2'b01: lru[last_index] <= 1;
                2'b10: lru[last_index] <= 0;
                default:;
            endcase
        end
        else begin
        end
    end
    //-----初始化计数器-----
    //  用于初始化,清空TagV模块中的valid位
    //  每次清空一行,需要清空128个周期
    reg [6:0] resetn_counter;
    always @(posedge clk) begin
        if (!resetn) begin
            resetn_counter <= 7'b0;
        end
        else begin
            resetn_counter <= resetn_counter + 7'b1;
        end
    end
    //-----数据替换计数器-----
    //  当Cache发生数据缺失时，需要从内存中读取所需数据
    //  由于一行256字节，可以存放8个32位的数据，而内存通过AXI总线传输数据时，一周期只能传输32位
    //  因此需要8个周期才能传输完一行数据，所以使用refill_counter来记录当前传输的数据在Cache行中的位置
    //  便于控制数据存储器的写使能信号将数据写入到Cache的数据存储器的对应行中的位置
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
    //-----流水线状态标识-----
    //  pipeline_state是用于标识流水线状态的寄存器
    //  如果当前Cache的流水状态为刚启动的状态，那么地址流水段正常工作(addr_ok == 1)，
    //  而数据流水段还未工作(data_ok == 0)，接下来流水线会正常运行
    //  如果当前Cache的流水状态为即将结束的状态，那么地址流水段不会工作(addr_ok == 0)，
    //  而数据流水段正常工作(data_ok == 1)，接下来流水线会进入到空闲状态
    //  能够打断Cache流水状态的事件有：CPU停止向Cache请求数据、Cache发生未命中
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


    //---------------地址流水段-----------------
    //  解析需要读取的数据的地址，地址结构如下所示：
	//  |  tag  | index | offset |
	//  |31   12|11    5|4      0|
    wire [19:0] tag    = cpu_addr[31:12];
    wire [6 :0] index  = cpu_addr[11:5 ];
    wire [4 :0] offset = cpu_addr[4 :0 ];

    //  判断当前Cache的运行状态，如果成功接收地址就将向CPU返回的addr_ok拉高
    assign cache_addr_ok = cpu_req && (state == RUN) && ((pipeline_state == RUN)?cache_data_ok:1'b1);

    //--------------段间寄存器------------
    //  段间寄存器为：last_req、last_tag、last_index、last_offset，用于保存地址流水段所接收到的地址信息，用于数据流水段进行Cache的查找
    //  这些段间寄存器需要在地址流水段工作完成时(即addr_ok为1时)保存相应的信息
    //  而last_req信号标识当前的数据流水段是否存在"地址已经成功接收、但数据还尚未返回"的数据读请求(用作数据流水段的使能信号)
    //  因此，last_req信号还需在数据流水段工作完成时(即data_ok为1时)将last_req清空
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

    //---------------数据流水段-----------------
    //  命中判断
	 //  目录表输出信号：
    //  由于使用二路组相联的Cache，因此每一路的目录表都会有一个hit信号，来表明当前路是否命中
    //  因此使用长度为2的数组hit_array来表示命中的情况
    //  当hit_array[0] == 1时，表示第0路命中；hit_array[1] == 1时，表示第1路命中
    //  当两路全未命中时，hit_array[0]和hit_array[1]都为0，即hit_array == 0
    wire [1  :0] hit_array;
    //  使用hit信号来表示整个Cache是否命中：Cache当前可以接收访存请求，并且所请求的地址在某一路的目录表中命中，则判断整个Cache命中
    wire         hit = !(!hit_array) && (state == RUN);
    //  使用hit_way信号来判断究竟命中了哪一路，hit_way == 0表示命中第0路，hit_way == 1表示命中第1路。hit_way信号仅在hit为1时才有效
    wire         hit_way = hit_array[1];

    //  数据选择
    //  cache_rdata是向cpu返回的信号，由于两路组相联的Cache存在两个数据存储器，因此在读取时会返回两个值
    //  需要根据hit_way信号判断命中了哪一路，从而选择出一个正确的值返回
    assign cache_rdata = data_rdata[hit_way];

    //  握手信号
    //  当目前还有已经接收地址但还未返回数据的访存请求，并且Cache正常命中时，直接就可以同时向CPU返回数据和data_ok
    assign cache_data_ok = last_req && hit;

    //--------------目录表和数据块------------
	 //  目录表输入信号：
    //  tagv_wen：     目录表的写使能信号，二路组相联存在两个目录表，因此使用长度为2的数组，来分别作为两个目录表的写使能
    //                 tagv_wen[0]:第0路目录表的写使能；
    //                 tagv_wen[1]：第1路目录表的写使能
    //                 信号赋值说明：
    //                 在reset时，两路都需要初始化，因此tagv_wen的值为2'b11；
    //                 在Cache缺失时，需要根据选路算法来选择将数据放置在哪一路，tagv_wen的值等于way_sel
    //                 在其他情况下，目录表不应该被更改，因此应当为2'b00，保证其不会被写
    //  tagv_index_in：所需要查找的地址的index，会作为目录表的行索引对目录表进行检索。
    //                 由于在Cache查找时，两个目录表都需要查找同一个地址，因此两个目录表共用同一个index信号
    //                 信号赋值说明：
    //                 在reset的时候，需要对目录表逐行进行初始化，因此index应当等于resetn_counter(即从0递增至127，从第0行初始化到第127行)
    //                 在Cache正常运行(即RUN状态)时，需要在目录表中查找CPU传入的地址是否命中，因此需要使用index
    //                 在Cache发生数据缺失时，Cache流水线被阻塞，仍然存在接受了地址但并没有返回数据的访存请求，
    //                 因此这里需要使用段间寄存器的值(last_index)进行查找
    //  tag_wdata:     对应于地址结构中的tag位，用于于目录表中的tag位进行比较。并当Cache发生缺失时，用于修改目录表中的tag位
    //                 信号赋值说明：
    //                 在Cache正常运行(即RUN状态)时，需要在目录表中查找CPU传入的地址是否命中，因此需要使用tag
    //                 在Cache发生数据缺失时，Cache流水线被阻塞，仍然存在接受了地址但并没有返回数据的访存请求，
    //                 因此这里需要使用段间寄存器的值(last_tag)进行查找
    //  valid_wdata:   用于写入目录表时，修改目录表中对应的valid位。仅在reset的时候需要将目录表中的valid位清空，其余情况都需要将valid位修改为1
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
	 //  data_wen:       写使能信号，两路组相联的Cache的数据存储器同样需要两个写使能信号
    //                  data_wen[0]为第0路的写使能信号，data_wen[1]为第1路的写使能信号
    //                  信号赋值说明：
    //                  数据存储器的写使能是按照字节进行使能的，即32'hf000_0000表示32个字节(256位)中的前4个字节(32位)是需要被写入的
    //                  最终会将数据写入到数据存储器中对应行的前四个字节(前32位)里
    //                  类似地，32'h0f00_0000可以将数据写入到第5到第8个字节(前33位到前64位)里
    //                  因此可以通过不断移位(32'hf000_0000 >> refill_wen)控制写使能的方式，来实现向数据存储器中的一行里依次写入8个数据
    //  data_index_in： 用于读取选择数据存储器中行号，对应于地址结构中的index。
    //                  信号赋值说明：
    //                  在Cache正常运行(即RUN状态)时，对数据的访问是流水的，即地址流水段传入地址，数据流水段就可以读取出数据，因此需要使用index
    //                  在Cache发生数据缺失时，Cache流水线被阻塞，仍然存在接受了地址但并没有返回数据的访存请求，
    //                  因此这里需要使用段间寄存器的值(last_index)进行查找
    //  data_offset_in：用于在一行数据中选择出所需数据，对应于地址结构中的offset，即偏移量
    //                  信号赋值说明：
    //                  Cache正常运行(即RUN状态)时，对数据的访问是流水的，即地址流水段传入地址，数据流水段就可以读取出数据，因此需要使用offset
    //                  在Cache发生数据缺失时，Cache流水线被阻塞，仍然存在接受了地址但并没有返回数据的访存请求，因此这里需要使用段间寄存器的值(last_offset)进行查找
    //  data_wdata:     当Cache发生不命中时，需要把从内存中读取出的数据写到Cache的数据存储器里
    //                  由于内存使用总线传输数据，一次只传输32位的一个数据，而一行数据有8*32位
    //                  因此需要逐次写回八次数据才能完成一行数据的填充
    //  data_rdata:     用于接收从Cache的数据存储器中读取出的数据
    //                  由于两路组相联的Cache存在两个数据存储器，因此在读取时会返回两个值
    //                  因此使用二维数组储存这两个值，再结合目录表查找出的命中结果(hit_array)来判断命中时向cpu返回哪个数据
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
    //  generate for语法用于重复性地生成需要的模块
    generate
        genvar i;
        for (i = 0 ; i < 2 ; i = i + 1) begin
            //请完成模块cache_tagv的接线，仅需将代码中的空白处补充完整即可
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
    //与连接主存的AXI总线进行通信的信号，无需关注
    assign arid    = (state == MISS) ? 4'd3 : 4'd0;                 //Cache向主存发起读请求时使用的AXI信道的id号
    assign araddr  = {last_tag,last_index,last_offset[4:2],2'b00};  //Cache向主存发起读请求时所使用的地址
    assign arvalid = (state == MISS);                               //Cache向主存发起读请求的请求信号
    assign rready  = (state == REFILL);                             //标识当前的Cache已经准备好可以接收主存返回的数据

endmodule
