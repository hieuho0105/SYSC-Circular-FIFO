`timescale 1ns/1ps

module tb_fifo_wrapper();

    // Thông số
    parameter WIDTH = 8;
    parameter DEPTH = 16;
    parameter POINTER_WIDTH = 4;
    
    // Tín hiệu đầu vào
    reg clk;
    reg reset;
    reg avalon_write;
    reg avalon_read;
    reg [1:0] avalon_address;
    reg [WIDTH-1:0] avalon_writedata;
    
    // Tín hiệu đầu ra
    wire [WIDTH-1:0] avalon_readdata;
    wire [1:0] avalon_status;

    // Kết nối module fifo_wrapper
    fifo_wrapper #(
        .WIDTH(WIDTH),
        .DEPTH(DEPTH),
        .POINTER_WIDTH(POINTER_WIDTH)
    ) uut (
        .clk(clk),
        .reset(reset),
        .avalon_address(avalon_address),
        .avalon_write(avalon_write),
        .avalon_read(avalon_read),
        .avalon_writedata(avalon_writedata),
        .avalon_readdata(avalon_readdata),
        .avalon_status(avalon_status)
    );

    // Clock 10ns chu kỳ
    always #5 clk = ~clk;

    // Khởi tạo ban đầu
    initial begin
        // Khởi tạo tín hiệu
        clk = 0;
        reset = 1;
        avalon_write = 0;
        avalon_read = 0;
        avalon_address = 2'b00;
        avalon_writedata = 0;

        // Reset hệ thống
        #10 reset = 0;
        #10 reset = 1;
        #10 reset = 0;

        // Kiểm tra ghi dữ liệu vào FIFO
        $display("\n== Start Writing to FIFO ==");
        write_data_to_fifo(8'hA5);  // Ghi 0xA5 vào FIFO
        write_data_to_fifo(8'h5A);  // Ghi 0x5A vào FIFO
        write_data_to_fifo(8'hFF);  // Ghi 0xFF vào FIFO

        // Kiểm tra đọc trạng thái FIFO
        #10 avalon_address = 2'b00;  // Địa chỉ STATUS
        avalon_read = 1;
        #10 avalon_read = 0;
        $display("FIFO Status: %b (Full: %b, Empty: %b)", avalon_status, avalon_status[1], avalon_status[0]);

        // Kiểm tra đọc dữ liệu từ FIFO
        $display("\n== Start Reading from FIFO ==");
        read_data_from_fifo();  // Đọc dữ liệu từ FIFO
        read_data_from_fifo();  // Đọc dữ liệu từ FIFO
        read_data_from_fifo();  // Đọc dữ liệu từ FIFO

        // Kiểm tra trạng thái FIFO sau khi đọc hết dữ liệu
        #10 avalon_address = 2'b00;  // Địa chỉ STATUS
        avalon_read = 1;
        #10 avalon_read = 0;
        $display("FIFO Status: %b (Full: %b, Empty: %b)", avalon_status, avalon_status[1], avalon_status[0]);

        // Dừng mô phỏng
        #10 $finish;
    end

    // Task ghi dữ liệu vào FIFO
    task write_data_to_fifo(input [WIDTH-1:0] data);
        begin
            avalon_address = 2'b10;  // Địa chỉ FIFO_WRITE
            avalon_write = 1;
            avalon_writedata = data;
            #10 avalon_write = 0;
            $display("Wrote 0x%h to FIFO", data);
        end
    endtask

    // Task đọc dữ liệu từ FIFO
    task read_data_from_fifo();
        begin
            avalon_address = 2'b01;  // Địa chỉ FIFO_READ
            avalon_read = 1;
            #10 avalon_read = 0;
            $display("Read 0x%h from FIFO", avalon_readdata);
        end
    endtask

endmodule