module FIFO(clk, rst, wr_en, rd_en, buf_in, buf_out, buf_full, buf_empty, fifo_counter);
  input clk, rst, wr_en, rd_en;
  input [7:0] buf_in;
  output [7:0] buf_out;
  output buf_full, buf_empty;
  output [7:0] fifo_counter;

  reg [7:0] buf_out;
  reg buf_full, buf_empty;
  reg [7:0] buf_mem[63:0];
  reg [3:0] wr_ptr, rd_ptr;
  reg [7:0] fifo_counter;

  
  always @(fifo_counter) begin
    buf_empty = (fifo_counter == 0);
    buf_full = (fifo_counter == 64);
  end

  always @(posedge clk or posedge rst)
    if (rst)
      fifo_counter <= 0;
    else if ((!buf_full && wr_en) && (!buf_empty && rd_en))
      fifo_counter <= fifo_counter;
    else if (!buf_full && wr_en)
      fifo_counter <= fifo_counter + 1;
    else if (!buf_empty && rd_en)
      fifo_counter <= fifo_counter - 1;
    else
      fifo_counter <= fifo_counter;


  always @(posedge clk or posedge rst)
    if (rst)
      buf_mem[0] <= 0;
    else if (!buf_full && wr_en)
      buf_mem[wr_ptr] <= buf_in;
    else
      buf_mem[wr_ptr] <= buf_mem[wr_ptr];

  always @(posedge clk or posedge rst)
    if (rst)
      wr_ptr <= 0;
    else if (!buf_full && wr_en)
      wr_ptr <= wr_ptr + 1;
    else
      wr_ptr <= wr_ptr;


  always @(posedge clk or posedge rst)
    if (rst)
      buf_out <= 0;
    else if (!buf_empty && rd_en)
      buf_out <= buf_mem[rd_ptr];
    else
      buf_out <= buf_out;

  always @(posedge clk or posedge rst)
    if (rst)
      rd_ptr <= 0;
    else if (!buf_empty && rd_en)
      rd_ptr <= rd_ptr + 1;
    else
      rd_ptr <= rd_ptr;

endmodule