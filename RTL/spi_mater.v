module spi_master(
    input  wire       clk,
    input  wire       reset,
    input  wire       start,
    input  wire [7:0] data_in,
    input  wire       miso,
    input  wire       cpol,
    input  wire       cpha,
    input  wire [7:0] clk_div,
    output reg  [7:0] data_out,
    output reg        done,
    output reg        sclk,
    output wire       mosi,
    output reg        ss
);
    localparam IDLE = 2'b00, TRANSFER = 2'b01, FINISH = 2'b10;
    reg [1:0] state;
    reg [7:0] tx_reg, rx_reg;
    reg [3:0] bit_cnt;
    reg [7:0] div_cnt;
    reg spi_clk_reg, spi_clk_d;
    assign mosi = tx_reg[7];
    always @(posedge clk or posedge reset) begin
        if (reset) spi_clk_d <= 0;
        else       spi_clk_d <= spi_clk_reg;
    end

    wire leading_edge  = (~spi_clk_d) & spi_clk_reg;
    wire trailing_edge = spi_clk_d & (~spi_clk_reg);
    wire sample_edge   = (cpha == 1'b0) ? leading_edge  : trailing_edge;
    wire shift_edge    = (cpha == 1'b0) ? trailing_edge : leading_edge;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            div_cnt <= 0; spi_clk_reg <= 0;
        end else if (state == TRANSFER) begin
            if (div_cnt >= clk_div) begin
                div_cnt <= 0; spi_clk_reg <= ~spi_clk_reg;
            end else div_cnt <= div_cnt + 1;
        end else begin
            div_cnt <= 0; spi_clk_reg <= 0;
        end
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE; ss <= 1; done <= 0; sclk <= 0; tx_reg <= 0; bit_cnt <= 0;
        end else begin
            case (state)
                IDLE: begin
                    ss <= 1; done <= 0; bit_cnt <= 0; sclk <= cpol;
                    if (start) begin
                        tx_reg <= data_in;
                        ss     <= 0;
                        state  <= TRANSFER;
                    end
                end

                TRANSFER: begin
                    sclk <= spi_clk_reg ^ cpol;
                    
                    if (sample_edge) begin
                        rx_reg  <= {rx_reg[6:0], miso};
                        bit_cnt <= bit_cnt + 1;
                    end
                    
                    if (shift_edge) begin
                        if (bit_cnt == 8) begin
                            state <= FINISH;
                        end else if ((cpha == 1'b0) || (bit_cnt != 0)) begin
                            tx_reg <= {tx_reg[6:0], 1'b0};
                        end
                    end
                end

                FINISH: begin
                    sclk <= cpol; ss <= 1; done <= 1; data_out <= rx_reg; state <= IDLE;
                end
                
                default: state <= IDLE;
            endcase
        end
    end
endmodule
