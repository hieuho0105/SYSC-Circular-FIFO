module fifo_wrapper (
    clk,
    reset,
    avalon_address,            // Register address from Avalon Bus
    avalon_write,              // Write signal from Avalon Bus
    avalon_read,               // Read signal from Avalon Bus
    avalon_writedata,          // Write data from Avalon Bus
    avalon_readdata,           // Read data to Avalon Bus
    avalon_status              // FIFO status
);

parameter WIDTH = 8;
parameter DEPTH = 16;
parameter POINTER_WIDTH = 4;

input clk;
input reset;
input [1:0] avalon_address;
input avalon_write;
input avalon_read;
input [WIDTH-1:0] avalon_writedata;
output [WIDTH-1:0] avalon_readdata;
output [1:0] avalon_status;

wire wr_en, rd_en;
wire full, empty;
wire [WIDTH-1:0] fifo_output_data;
wire [POINTER_WIDTH:0] count;              // Number of elements in FIFO
wire [WIDTH-1:0] fifo_input_data;

// Connect CSR module
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
    .count(count)                          // Connect count signal
);

// Connect Core module
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
    .count(count)                         // Output count signal from core
);

// FIFO status to Avalon
assign avalon_status = {full, empty};

endmodule