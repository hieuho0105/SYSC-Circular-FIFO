module fifo_csr (
    clk,
    reset,
    avalon_address,            // Input register address selection from Avalon
    avalon_write,              // Write signal from Avalon
    avalon_read,               // Read signal from Avalon
    avalon_writedata,          // Write data from Avalon
    avalon_readdata,           // Read data to Avalon
    full,                      // Full status from core
    empty,                     // Empty status from core
    count,                     // Number of elements currently in FIFO
    wr_en,                     // Output write enable signal to core
    rd_en,                     // Output read enable signal to core
    fifo_input_data,           // Data to be written to FIFO
    fifo_output_data           // Data read from FIFO
);

parameter WIDTH = 8;
parameter POINTER_WIDTH = 4;
parameter STATUS_REG_ADDR = 2'b00;         // Address for status register
parameter FIFO_READ_ADDR = 2'b01;          // Address to read from FIFO
parameter FIFO_WRITE_ADDR = 2'b10;         // Address to write to FIFO
parameter CONTROL_REG_ADDR = 2'b11;        // Address for control register

input clk;
input reset;
input [1:0] avalon_address;
input avalon_write;
input avalon_read;
input [WIDTH-1:0] avalon_writedata;
output reg [WIDTH-1:0] avalon_readdata;
input full;
input empty;
input [POINTER_WIDTH:0] count;
output reg wr_en;
output reg rd_en;
output reg [WIDTH-1:0] fifo_input_data;
input [WIDTH-1:0] fifo_output_data;

reg [WIDTH-1:0] control_reg;               // Control register
reg [WIDTH-1:0] status;                    // FIFO status register

// Handle write/read from Avalon
always @(posedge clk or posedge reset) begin
    if (reset) begin
        wr_en <= 0;
        rd_en <= 0;
        status <= 0;
        control_reg <= 0;
        avalon_readdata <= 0;
        fifo_input_data <= 0;
    end else begin
        // Handle write from Avalon
        if (avalon_write) begin
            if (avalon_address == FIFO_WRITE_ADDR && !full) begin
                wr_en <= 1;
                fifo_input_data <= avalon_writedata;  // Write data to FIFO
            end else if (avalon_address == CONTROL_REG_ADDR) begin
                control_reg <= avalon_writedata;      // Write to control register
            end else begin
                wr_en <= 0;
            end
        end

        // Handle read from Avalon
        if (avalon_read) begin
            case (avalon_address)
                STATUS_REG_ADDR: begin
                    // Read FIFO status (2 status bits + `count`)
                    avalon_readdata <= {4'b0, full, empty, count};
                end
                FIFO_READ_ADDR: begin
                    if (!empty) begin
                        rd_en <= 1;
                        avalon_readdata <= fifo_output_data; // Read data from FIFO
                    end else begin
                        rd_en <= 0;
                    end
                end
                CONTROL_REG_ADDR: begin
                    avalon_readdata <= control_reg;    // Read control register
                end
                default: begin
                    rd_en <= 0;
                    wr_en <= 0;
                end
            endcase
        end else begin
            rd_en <= 0;
            wr_en <= 0;
        end

        // Update status register
        status[0] <= empty;  // bit 0: empty
        status[1] <= full;   // bit 1: full
    end
end

endmodule