module fifo_csr (
    input clk,
    input reset,
    input [1:0] avalon_address,            // Input địa chỉ chọn thanh ghi từ Avalon
    input avalon_write,                    // Tín hiệu ghi từ Avalon
    input avalon_read,                     // Tín hiệu đọc từ Avalon
    input [WIDTH-1:0] avalon_writedata,    // Dữ liệu ghi từ Avalon
    output reg [WIDTH-1:0] avalon_readdata,// Dữ liệu đọc ra Avalon
    input full,                            // Trạng thái đầy từ core
    input empty,                           // Trạng thái rỗng từ core
    input [POINTER_WIDTH:0] count,         // Số lượng phần tử hiện có trong FIFO
    output reg wr_en,                      // Xuất tín hiệu ghi enable cho core
    output reg rd_en,                      // Xuất tín hiệu đọc enable cho core
    output reg [WIDTH-1:0] fifo_input_data,// Dữ liệu ghi vào FIFO
    input [WIDTH-1:0] fifo_output_data     // Dữ liệu đọc từ FIFO
);

parameter WIDTH = 8;
parameter POINTER_WIDTH = 4;
parameter STATUS_REG_ADDR = 2'b00;         // Địa chỉ cho thanh ghi trạng thái
parameter FIFO_READ_ADDR = 2'b01;          // Địa chỉ để đọc từ FIFO
parameter FIFO_WRITE_ADDR = 2'b10;         // Địa chỉ để ghi vào FIFO
parameter CONTROL_REG_ADDR = 2'b11;        // Địa chỉ cho thanh ghi điều khiển

reg [WIDTH-1:0] control_reg;               // Thanh ghi điều khiển
reg [WIDTH-1:0] status;                    // Thanh ghi trạng thái của FIFO

// Xử lý ghi/đọc từ Avalon
always @(posedge clk or posedge reset) begin
    if (reset) begin
        wr_en <= 0;
        rd_en <= 0;
        status <= 0;
        control_reg <= 0;
        avalon_readdata <= 0;
        fifo_input_data <= 0;
    end else begin
        // Xử lý ghi từ Avalon
        if (avalon_write) begin
            if (avalon_address == FIFO_WRITE_ADDR && !full) begin
                wr_en <= 1;
                fifo_input_data <= avalon_writedata;  // Ghi dữ liệu vào FIFO
            end else if (avalon_address == CONTROL_REG_ADDR) begin
                control_reg <= avalon_writedata;      // Ghi vào thanh ghi điều khiển
            end else begin
                wr_en <= 0;
            end
        end

        // Xử lý đọc từ Avalon
        if (avalon_read) begin
            case (avalon_address)
                STATUS_REG_ADDR: begin
                    // Đọc trạng thái FIFO (2 bit trạng thái + `count`)
                    avalon_readdata <= {4'b0, full, empty, count};
                end
                FIFO_READ_ADDR: begin
                    if (!empty) begin
                        rd_en <= 1;
                        avalon_readdata <= fifo_output_data; // Đọc dữ liệu từ FIFO
                    end else begin
                        rd_en <= 0;
                    end
                end
                CONTROL_REG_ADDR: begin
                    avalon_readdata <= control_reg;    // Đọc thanh ghi điều khiển
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

        // Cập nhật thanh ghi trạng thái
        status[0] <= empty;  // bit 0: empty
        status[1] <= full;   // bit 1: full
    end
end

endmodule