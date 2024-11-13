`timescale 1ns/1ps

module tb_fifo_core();

    // Thông số
    parameter WIDTH = 8;
    parameter DEPTH = 16;
    parameter POINTER_WIDTH = 4;

    // Tín hiệu đầu vào
    reg clk;
    reg reset;
    reg wr_en;
    reg rd_en;
    reg [WIDTH-1:0] input_data;

    // Tín hiệu đầu ra
    wire [WIDTH-1:0] output_data;
    wire full;
    wire empty;

    // Kết nối module fifo_core
    fifo_core #(
        .DEPTH(DEPTH),
        .WIDTH(WIDTH),
        .POINTER_WIDTH(POINTER_WIDTH)
    ) uut (
        .clk(clk),
        .reset(reset),
        .wr_en(wr_en),
        .rd_en(rd_en),
        .input_data(input_data),
        .output_data(output_data),
        .full(full),
        .empty(empty)
    );

    // Clock 10ns chu kỳ
    always #5 clk = ~clk;

    // Khởi tạo ban đầu
    initial begin
        // Khởi tạo tín hiệu
        clk = 0;
        reset = 1;
        wr_en = 0;
        rd_en = 0;
        input_data = 0;

        // Reset hệ thống
        #10 reset = 0;
        #10 reset = 1;
        #10 reset = 0;

        // Ghi dữ liệu vào FIFO
        $display("\n== Start Writing to FIFO ==");
        write_data_to_fifo(8'hA5);  // Ghi 0xA5 vào FIFO
        write_data_to_fifo(8'h5A);  // Ghi 0x5A vào FIFO
        write_data_to_fifo(8'hFF);  // Ghi 0xFF vào FIFO

        // Đọc dữ liệu từ FIFO
        $display("\n== Start Reading from FIFO ==");
        read_data_from_fifo();
        read_data_from_fifo();
        read_data_from_fifo();

        // Dừng mô phỏng
        #10 $finish;
    end

    // Task ghi dữ liệu vào FIFO
    task write_data_to_fifo(input [WIDTH-1:0] data);
        begin
            wr_en = 1;
            input_data = data;
            #10 wr_en = 0;
            $display("Wrote 0x%h to FIFO", data);
        end
    endtask

    // Task đọc dữ liệu từ FIFO
    task read_data_from_fifo();
        begin
            rd_en = 1;
            #10 rd_en = 0;
            $display("Read 0x%h from FIFO", output_data);
        end
    endtask

endmodule