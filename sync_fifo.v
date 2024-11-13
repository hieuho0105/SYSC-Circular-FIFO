module sync_fifo (
					clk,	// The Synchronous FIFO has 
							// a single clock port for both data-read and data-write operations, 
							// it means it is used for synchronising across two process 
							// when two process are running on same clock
					reset,
					wr_en,		// Write Enable
					rd_en,		// Read Enable
					input_data,
					empty,
					full,
					output_data
);

parameter DEPTH = 16;			// D1-D16
parameter WIDTH = 8;			// 8-bit Data
parameter POINTER_WIDTH = 4;	// 4-bit Address

input clk;
input reset;
input wr_en;
input rd_en;
input [WIDTH-1:0] input_data;
output empty;
output full;
output [WIDTH-1:0] output_data;

reg [POINTER_WIDTH:0] wr_ptr;	// Write Pointer
reg [POINTER_WIDTH:0] rd_ptr;	// Read Pointer
reg empty;
reg full;
reg [WIDTH-1:0] output_data;

reg [WIDTH-1:0] static_mem [DEPTH-1:0]; // Static Memory

wire [POINTER_WIDTH-1:0] wr_ptr_int;
wire [POINTER_WIDTH-1:0] rd_ptr_int;
//wire full;
//wire empty;
wire [POINTER_WIDTH:0] wr_rd;
wire put_e;
wire get_e;

assign wr_rd = wr_ptr - rd_ptr;
//assign full = (wr_rd == 4'b1000);
//assign empty = (wr_rd == 4'b0000);
assign put_e = (wr_en && full == 1'b0);
assign get_e = (rd_en && empty == 1'b0);
assign wr_ptr_int = wr_ptr[POINTER_WIDTH-1:0];
assign rd_ptr_int = rd_ptr[POINTER_WIDTH-1:0];

always @ (posedge clk)
	begin
		if (!reset)
			begin
				wr_ptr <= 3'b000;
				rd_ptr <= 3'b000;
			end 
		else
			begin
				if (put_e)
					begin
						static_mem [wr_ptr_int] <= input_data;
						wr_ptr <= wr_ptr + 3'b001;
					end
				if (get_e)
					begin
						rd_ptr <= rd_ptr + 3'b001;
					end
			end
	end

always @ (rd_ptr_int)
	begin
		output_data <= static_mem [rd_ptr_int - 3'b001];
	end

always @ (posedge clk) 
	begin
		if (!reset)
			begin
				full <= 1'b0;
				empty <= 1'b0;				
			end
		else
			begin
				full <= (wr_rd == 4'b1000);
				empty <= (wr_rd == 4'b0000);
			end
	end

/*
always @(empty or full)
	begin
		empty <= ~empty;
		full <= ~full;
	end
*/
endmodule
