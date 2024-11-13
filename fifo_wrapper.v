module fifo_wrapper (
    input clk,
    input reset,
    input [1:0] avalon_address,            // Địa chỉ thanh ghi từ Avalon Bus
    input avalon_write,                    // Tín hiệu ghi từ Avalon Bus
    input avalon_read,                     // Tín hiệu đọc từ Avalon Bus
    input [WIDTH-1:0] avalon_writedata,    // Dữ liệu ghi từ Avalon Bus
    output [WIDTH-1:0] avalon_readdata,    // Dữ liệu đọc ra Avalon Bus
    output [1:0] avalon_status             // Trạng thái FIFO
);

parameter WIDTH = 8;
parameter DEPTH = 16;
parameter POINTER_WIDTH = 4;

wire wr_en, rd_en;
wire full, empty;
wire [WIDTH-1:0] fifo_output_data;
wire [POINTER_WIDTH:0] count;              // Số lượng phần tử trong FIFO
wire [WIDTH-1:0] fifo_input_data;

// Kết nối CSR module
fifo_csr #(
    .WIDTH(WIDTH),
    .POINTER_WIDTH(POINTER_WIDTH)
) csr_inst (
    .clk(clk),
    .reset(reset),
    .avalon_address(avalon_address),
    .avalon_write(avalon_write),
    .avalon_read(avalon_read),
    .avalon_writedata(avalon_writedata),
    .avalon_readdata(avalon_readdata),
    .full(full),
    .empty(empty),
    .wr_en(wr_en),
    .rd_en(rd_en),
    .fifo_input_data(fifo_input_data),
    .fifo_output_data(fifo_output_data),
    .count(count)                          // Kết nối tín hiệu count
);

// Kết nối Core module
fifo_core #(
    .DEPTH(DEPTH),
    .WIDTH(WIDTH),
    .POINTER_WIDTH(POINTER_WIDTH)
) core_inst (
    .clk(clk),
    .reset(reset),
    .wr_en(wr_en),
    .rd_en(rd_en),
    .input_data(fifo_input_data),
    .output_data(fifo_output_data),
    .full(full),
    .empty(empty),
    .count(count)                         // Xuất tín hiệu count từ core
);

// Trạng thái FIFO ra Avalon
assign avalon_status = {full, empty};

endmodule