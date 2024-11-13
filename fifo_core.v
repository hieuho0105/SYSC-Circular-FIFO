module fifo_core (
    input clk,
    input reset,
    input wr_en,
    input rd_en,
    input [WIDTH-1:0] input_data,
    output reg [WIDTH-1:0] output_data,
    output reg full,
    output reg empty,
    output reg [POINTER_WIDTH:0] count      // Xuất số lượng phần tử hiện có
);

parameter DEPTH = 16;
parameter WIDTH = 8;
parameter POINTER_WIDTH = 4;

reg [WIDTH-1:0] static_mem [DEPTH-1:0];    // Bộ nhớ dùng cho FIFO

reg [POINTER_WIDTH-1:0] wr_ptr;            // Con trỏ ghi vòng
reg [POINTER_WIDTH-1:0] rd_ptr;            // Con trỏ đọc vòng
reg [POINTER_WIDTH:0] fifo_count;          // Số lượng phần tử hiện có trong FIFO

// Ghi dữ liệu vào FIFO
always @(posedge clk or posedge reset) begin
    if (reset) begin
        wr_ptr <= 0;
        full <= 0;
    end else if (wr_en && !full) begin
        static_mem[wr_ptr] <= input_data;
        wr_ptr <= (wr_ptr + 1) % DEPTH;     // Vòng
        if (fifo_count == DEPTH - 1)
            full <= 1;
        else
            full <= 0;
    end
end

// Đọc dữ liệu từ FIFO
always @(posedge clk or posedge reset) begin
    if (reset) begin
        rd_ptr <= 0;
        output_data <= 0;
        empty <= 1;
    end else if (rd_en && !empty) begin
        output_data <= static_mem[rd_ptr];
        rd_ptr <= (rd_ptr + 1) % DEPTH;     // Vòng
        if (fifo_count == 1)
            empty <= 1;
        else
            empty <= 0;
    end
end

// Đếm số phần tử trong FIFO
always @(posedge clk or posedge reset) begin
    if (reset)
        fifo_count <= 0;
    else if (wr_en && !full && rd_en && !empty)
        fifo_count <= fifo_count;  // Nếu ghi và đọc đồng thời
    else if (wr_en && !full)
        fifo_count <= fifo_count + 1;  // Ghi dữ liệu
    else if (rd_en && !empty)
        fifo_count <= fifo_count - 1;  // Đọc dữ liệu
end

// Xuất giá trị fifo_count
always @(*) begin
    count = fifo_count;
end

endmodule