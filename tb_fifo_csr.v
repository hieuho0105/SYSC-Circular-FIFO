`timescale 1ns/1ps

module tb_fifo_csr();

    // Thông số
    parameter WIDTH = 8;

    // Tín hiệu đầu vào
    reg clk;
    reg reset;
    reg [1:0] avalon_address;
    reg avalon_write;
    reg avalon_read;
    reg [WIDTH-1:0] avalon_writedata;
    reg full;
    reg empty;
    reg [WIDTH-1:0] fifo_output_data;

    // Tín hiệu đầu ra
    wire [WIDTH-1:0] avalon_readdata;
    wire wr_en;
    wire rd_en;
    wire [WIDTH-1:0] fifo_input_data;

    // Kết nối module fifo_csr
    fifo_csr #(
        .WIDTH(WIDTH)
    ) uut (
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
        .fifo_output_data(fifo_output_data)
    );

    // Clock 10ns chu kỳ
    always #5 clk = ~clk;

    // Khởi tạo ban đầu
    initial begin
        // Khởi tạo tín hiệu
        clk = 0;
        reset = 1;
        avalon_address = 2'b00;
        avalon_write = 0;
        avalon_read = 0;
        avalon_writedata = 0;
        full = 0;
        empty = 1;
        fifo_output_data = 8'hFF;

        // Reset hệ thống
        #10 reset = 0;
        #10 reset = 1;
        #10 reset = 0;

        // Ghi dữ liệu vào FIFO qua CSR
        $display("\n== Start Writing to FIFO via CSR ==");
        avalon_address = 2'b10;   // FIFO_WRITE_ADDR
        avalon_writedata = 8'hA5;
        avalon_write = 1;
        #10 avalon_write = 0;

        $display("FIFO Input Data: 0x%h", fifo_input_data);

        // Đọc dữ liệu từ FIFO qua CSR
        $display("\n== Start Reading from FIFO via CSR ==");
        avalon_address = 2'b01;  // FIFO_READ_ADDR
        avalon_read = 1;
        #10 avalon_read = 0;

        $display("FIFO Output Data: 0x%h", avalon_readdata);

        // Dừng mô phỏng
        #10 $finish;
    end

endmodule