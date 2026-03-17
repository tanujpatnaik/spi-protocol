module spi_slave(
    input  wire       clk,
    input  wire       reset,
    input  wire       sclk,
    input  wire       ss,
    input  wire       mosi,
    input  wire       cpol,
    input  wire       cpha,
    input  wire [7:0] data_in,
    output reg  [7:0] data_out,
    output reg        done,
    output wire       miso
);

    localparam IDLE = 1'b0, TRANSFER = 1'b1;

    reg state;
    reg [7:0] tx_reg, rx_reg;
    reg [3:0] bit_cnt;
    reg sclk_d;

    always @(posedge clk or posedge reset) begin
        if (reset)
            sclk_d <= 0;
        else
            sclk_d <= sclk;
    end

    wire sclk_rise = (~sclk_d) & sclk;
    wire sclk_fall = sclk_d & (~sclk);

    wire leading_edge  = (cpol == 0) ? sclk_rise : sclk_fall;
    wire trailing_edge = (cpol == 0) ? sclk_fall : sclk_rise;

    wire sample_edge = (cpha == 0) ? leading_edge  : trailing_edge;
    wire shift_edge  = (cpha == 0) ? trailing_edge : leading_edge;

    assign miso = (!ss) ? tx_reg[7] : 1'bz;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state    <= IDLE;
            bit_cnt  <= 0;
            done     <= 0;
            data_out <= 0;
            tx_reg   <= 0;
            rx_reg   <= 0;
        end else begin
            case (state)

                IDLE: begin
                    done    <= 0;
                    bit_cnt <= 0;
                    rx_reg  <= 0;

                    if (!ss) begin
                        tx_reg <= data_in;
                        state  <= TRANSFER;
                    end
                end

                TRANSFER: begin
                    if (ss) begin
                        state <= IDLE;
                    end else begin

                        if (sample_edge) begin
                            if (bit_cnt == 7) begin
                                rx_reg  <= {rx_reg[6:0], mosi};
                                data_out <= {rx_reg[6:0], mosi};
                                done     <= 1;
                                state    <= IDLE;
                            end else begin
                                rx_reg  <= {rx_reg[6:0], mosi};
                                bit_cnt <= bit_cnt + 1;
                            end
                        end

                        if (shift_edge) begin
                            if ((cpha == 1'b0) || (bit_cnt != 0)) begin
                                tx_reg <= {tx_reg[6:0], 1'b0};
                            end
                        end
                    end
                end

                default: state <= IDLE;

            endcase
        end
    end

endmodule
