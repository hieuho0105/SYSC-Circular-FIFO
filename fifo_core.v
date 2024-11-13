module fifo_core (
    clk,                    // The Synchronous FIFO has 
							// a single clock port for both data-read and data-write operations, 
							// it means it is used for synchronising across two process 
							// when two process are running on same clock
    reset,
    wr_en,                  // Write Enable
    rd_en,                  // Read Enable
    input_data,
    output_data,
    full,
    empty,
    count                   // Output the number of current elements
);

parameter DEPTH = 16;           // D1-D16
parameter WIDTH = 8;            // 8-bit Data
parameter POINTER_WIDTH = 4;    // 4-bit Address

input clk;
input reset;
input wr_en;
input rd_en;
input [WIDTH-1:0] input_data;
output reg [WIDTH-1:0] output_data;
output reg full;
output reg empty;
output reg [POINTER_WIDTH:0] count;

reg [WIDTH-1:0] static_mem [DEPTH-1:0];    // Memory used for FIFO

reg [POINTER_WIDTH-1:0] wr_ptr;            // Circular write pointer
reg [POINTER_WIDTH-1:0] rd_ptr;            // Circular read pointer
reg [POINTER_WIDTH:0] fifo_count;          // Number of current elements in FIFO

// Check if FIFO is full or empty
always @ (*) begin
    if (reset) begin
        full <= 1'b0;
        empty <= 1'b1;				
    end
    else begin
        full <= (fifo_count == DEPTH);
        empty <= (fifo_count == 0);
    end
end


// Write data to FIFO
always @(posedge clk or posedge reset) begin
    if (reset) begin
        wr_ptr <= 0;
        full <= 0;
    end else if (wr_en && !full) begin
        static_mem[wr_ptr] <= input_data;
        wr_ptr <= (wr_ptr + 1) % DEPTH;     // Circular
        if (fifo_count == DEPTH - 1)
            full <= 1;
        else
            full <= 0;
    end
end

// Read data from FIFO
always @(posedge clk or posedge reset) begin
    if (reset) begin
        rd_ptr <= 0;
        output_data <= 0;
        empty <= 1;
    end else if (rd_en && !empty) begin
        output_data <= static_mem[rd_ptr];
        rd_ptr <= (rd_ptr + 1) % DEPTH;     // Circular
        if (fifo_count == 1)
            empty <= 1;
        else
            empty <= 0;
    end
end

// Count the number of elements in FIFO
always @(posedge clk or posedge reset) begin
    if (reset)
        fifo_count <= 0;
    else if (wr_en && !full && rd_en && !empty)
        fifo_count <= fifo_count;  // If write and read simultaneously
    else if (wr_en && !full)
        fifo_count <= fifo_count + 1;  // Write data
    else if (rd_en && !empty)
        fifo_count <= fifo_count - 1;  // Read data
end

// Output the value of fifo_count
always @(*) begin
    count = fifo_count;
end

endmodule