`timescale 1ns/1ps

module fifo_core_tb;

    parameter DEPTH = 16;
    parameter WIDTH = 8;
    parameter POINTER_WIDTH = 4;

    reg clk;
    reg reset;
    reg wr_en;
    reg rd_en;
    reg [WIDTH-1:0] input_data;
    wire [WIDTH-1:0] output_data;
    wire full;
    wire empty;
    wire [POINTER_WIDTH:0] count;

    // Instantiate the fifo_core module
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
        .empty(empty),
        .count(count)
    );

    // Clock generation
    always #5 clk = ~clk;

    initial begin
        // Initialize signals
        clk = 0;
        reset = 1;
        wr_en = 0;
        rd_en = 0;
        input_data = 0;

        // Reset the FIFO
        #10 reset = 0;

        // Write data to FIFO
        #10;
        wr_en = 1;
        input_data = 8'hA5;
        #10;
        wr_en = 0;

        // Write another data
        #10;
        wr_en = 1;
        input_data = 8'h5A;
        #10;
        wr_en = 0;

        // Write another data
        #10;
        wr_en = 1;
        input_data = 8'hA5;
        #10;
        wr_en = 0;

        // Write another data
        #10;
        wr_en = 1;
        input_data = 8'h5A;
        #10;
        wr_en = 0;


        // Read data from FIFO
        #10;
        rd_en = 1;
        #10;
        rd_en = 0;

        // Read another data
        #10;
        rd_en = 1;
        #10;
        rd_en = 0;

        // Write and read simultaneously
        #10;
        wr_en = 1;
        rd_en = 1;
        input_data = 8'hFF;
        #10;
        wr_en = 0;
        rd_en = 0;

        // Finish simulation
        #20;
        $stop;
    end

endmodule