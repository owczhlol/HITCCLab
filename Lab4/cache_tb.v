`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//  @Copyright HIT team
//  Automated test environment
//////////////////////////////////////////////////////////////////////////////////

//注意：由于ISE并不完整支持相对路径，因此请将这里文件路径的宏定义修改为你自己实际项目中的文件绝对路径
`define CACHE_ADDR_TRACE_FILE "D:/Hardware/cache/lab/trace/cache_addr_trace.txt"
`define CACHE_DATA_TRACE_FILE "D:/Hardware/cache/lab/trace/cache_data_trace.txt"
`define END_ADDR 32'h0000_0000

module cache_tb(  );

/*
    测试说明:
		自动化测试环境会检测cache功能实现的正确性和LRU算法的有效性。
		当Cache功能错误时，会返回错误的数据；而当LRU算法错误时，Cache的命中率会下降
		当出现错误时，控制台会打印相应的信息来，帮助你定位Cache的错误

		测试使用IP核Block memory generator 7.3来模拟存储器
		使用CoreMark在mips 32编译器下编译的coe文件来进行指令存储器的填充，
		CoreMark为用于测量嵌入式系统中使用的中央处理器(CPU)的性能的标准Benchmark
		使用AXI4 接口来进行Cache和存储器间的握手通信
		指令访存的顺序与CoreMark运行的顺序一致，从而保证测试的有效性
*/

//----------CONTROL MODULE----------
//-----Control signals-----
reg         clk;
reg         resetn;
//-----Assign control signals-----
initial
begin
    clk 			= 1'b0;
    resetn 		= 1'b0;
    #2000;
    resetn 		= 1'b1;
end
always #5 clk 	= ~clk;
//------------------------------------



//----------CACHE/AXI MODULE----------
//-----Cache signals-----
//inputs
reg         cpu_req;
reg  [31:0] cpu_addr;
//outputs
wire [31:0] cache_rdata;
wire        cache_addr_ok;
wire        cache_data_ok;

//-----AXI signal-----
wire [3 :0] s_axi_arid;
wire [31:0] s_axi_araddr;
wire        s_axi_arvalid;
wire        s_axi_arready;

wire [3 :0] s_axi_rid;
wire [31:0] s_axi_rdata;
wire        s_axi_rlast;
wire        s_axi_rvalid;
wire        s_axi_rready;



//-----Module call-----
cache u_cache(
    //Control signal
    .clk            (clk            ),
    .resetn         (resetn         ),

    //Sram-like interface(from CPU core)
    .cpu_req        (cpu_req        ),
    .cpu_addr       (cpu_addr       ),
    .cache_rdata    (cache_rdata    ),
    .cache_addr_ok  (cache_addr_ok  ),
    .cache_data_ok  (cache_data_ok  ),

    //axi interface(from RAM)
    .arid           (s_axi_arid     ),
    .araddr         (s_axi_araddr   ),
    .arvalid        (s_axi_arvalid  ),
    .arready        (s_axi_arready  ),
    .rid            (s_axi_rid      ),
    .rdata          (s_axi_rdata    ),
    .rlast          (s_axi_rlast    ),
    .rvalid         (s_axi_rvalid   ),
    .rready         (s_axi_rready   )
    );

    assign arlen   = 8'd7;
    assign arsize  = 3'd2;
    assign arburst = 2'b10;//Wrap Mode
    assign awid    = 4'd0;
    assign awlen   = 8'd0;
    assign awburst = 2'b00;
    assign awsize  = 3'd2;
    assign awaddr  = 32'b0;
    assign awvalid = 4'b0;
    assign wdata   = 32'b0;
    assign wvalid  = 4'b0;
    assign wlast   = 3'b0;
    assign bready  = 4'b0;

axi u_axi(
    .s_aresetn      (resetn         ),//I,1
    .s_aclk         (clk            ),//I,1
    .s_axi_awid     (4'd0   	    ),//I,4
    .s_axi_awaddr   (32'b0       	),//I,32
    .s_axi_awlen    (8'd0         	),//I,8
    .s_axi_awsize   (3'd2        	),//I,3
    .s_axi_awburst  (2'b00      	),//I,2
    .s_axi_awvalid  (4'b0       	),//I,1
    .s_axi_awready  (),               //O,1

    .s_axi_wdata    (32'b0        	),//I,32
    .s_axi_wstrb    (),               //I,4
    .s_axi_wlast    (3'b0         	),//I,1
    .s_axi_wvalid   (4'b0        	),//I,1
    .s_axi_wready   (),               //O,1

    .s_axi_bid      (),               //O,4
    .s_axi_bresp    (),               //O,2
    .s_axi_bvalid   (),               //O,1
    .s_axi_bready   (4'b0	        ),//I,1

    .s_axi_arid     (s_axi_arid   	),//I,4
    .s_axi_araddr   (s_axi_araddr 	),//I,32
    .s_axi_arlen    (8'd7  	        ),//I,8
    .s_axi_arsize   (3'd2 	        ),//I,3
    .s_axi_arburst  (2'b10      	),//I,2
    .s_axi_arvalid  (s_axi_arvalid	),//I,1
    .s_axi_arready  (s_axi_arready  ),//O,1

    .s_axi_rid      (s_axi_rid      ),//O,4
    .s_axi_rresp    (),               //O,2
    .s_axi_rdata    (s_axi_rdata    ),//O,32
    .s_axi_rlast    (s_axi_rlast    ),//O,1
    .s_axi_rvalid   (s_axi_rvalid   ),//O,1
    .s_axi_rready   (s_axi_rready 	) //I,1
);
//------------------------------------




//----------TEST MODULE----------
//-----test signals-----
reg         test_err;
reg         test_end;

//-----open trace file-----
integer cache_addr_trace_ref;
integer cache_data_trace_ref;
initial begin
    cache_addr_trace_ref = $fopen(`CACHE_ADDR_TRACE_FILE, "r");
    cache_data_trace_ref = $fopen(`CACHE_DATA_TRACE_FILE, "r");
    $fscanf(cache_addr_trace_ref, "%h %h", cpu_req, cpu_addr);
end

//-----read input data(Simulate CPU)-----
always @(posedge clk)
begin
    if(cache_addr_ok)
    begin
        if(!($feof(cache_addr_trace_ref)) && resetn)
        begin
            $fscanf(cache_addr_trace_ref, "%h %h", cpu_req, cpu_addr);
        end
    end
end

//-----read reference data-----
reg [31:0]  ref_cache_data;
always @(posedge clk)
begin
    #1;
    if(cache_data_ok)
    begin
        if(!($feof(cache_data_trace_ref)) && resetn)
        begin
            $fscanf(cache_data_trace_ref, "%h", ref_cache_data);
        end
    end
end

//-----compare the cache data to the reference data-----
always @(posedge clk)
begin
    #2;
    if(!resetn)
    begin
        test_err <= 1'b0;
    end
    else if(!test_end && cache_data_ok)
    begin
        if (cache_rdata!==ref_cache_data)
        begin
            $display("--------------------------------------------------------------");
            $display("[%t] Error!!!",$time);
            $display("    Cache Address = 0x%8h", cpu_addr);
            $display("    Reference Cache Data = 0x%8h, Error Cache Data = 0x%8h",ref_cache_data, cache_rdata);
            $display("--------------------------------------------------------------");
            test_err <= 1'b1;
            #40;
            $finish;
        end
    end
end

//-----monitor test-----
initial
begin
    $timeformat(-9,0," ns",10);
    while(resetn) #5;
    $display("==============================================================");
    $display("Test begin!");

    #10000;
end

//-----Calculate the cache miss rate-----
parameter TEST_TIME     = 410526;
parameter REF_MISS_TIME = 1275;
parameter IDLE          = 4'b0000;
parameter RUN           = 4'b0001;
parameter SEL_WAY       = 4'b0010;
parameter MISS          = 4'b0011;
parameter REFILL        = 4'b0100;
parameter FINISH        = 4'b0101;
parameter RESETN        = 4'b1111;
reg [31:0] miss_time;
initial begin
    miss_time = 0;
end
always @(posedge clk)
begin
    if (u_cache.state == SEL_WAY) begin
        miss_time <= miss_time + 1;
    end
    else begin
	end
end
//-------------------------------


//-----Finish the test-----
always @(posedge clk)
begin
    if (!resetn)
    begin
        test_end <= 1'b0;
    end
    else if(cpu_addr==`END_ADDR && !test_end)
    begin
        test_end <= 1'b1;
        $display("==============================================================");
        $display("Test end!");
        #40;
        $fclose(cache_addr_trace_ref);
        $fclose(cache_data_trace_ref);
        if (test_err)
        begin
            $display("Fail!!! Cache function errors! Check your code!");
        end
        else if (miss_time > REF_MISS_TIME)
        begin
            $display("--------------------------------------------------------------");
            $display("[%t] Error!!!",$time);
            $display("    Reference  Cache Miss Rate = %d / %d", REF_MISS_TIME, TEST_TIME);
            $display("    Your Error Cache Miss Rate = %d / %d", miss_time    , TEST_TIME);
            $display("--------------------------------------------------------------");
            $display("Fail!!! LRU algorithm errors! Check your code!");
        end
        else
        begin
            $display("----PASS!!!");
        end
	    $finish;
	end
end
//-------------------------------


endmodule