module gpio_control_ip #(
    parameter GPIO_WIDTH = 8
)(
    input  wire                     clk,
    input  wire                     rst_n,

    input  wire [3:0]               addr_i,
    input  wire                     write_en,
    input  wire                     read_en,
    input  wire [31:0]              wdata,
    output reg  [31:0]              rdata,

    input  wire [GPIO_WIDTH-1:0]    gpio_in,
    output wire [GPIO_WIDTH-1:0]    gpio_out,
    output wire [GPIO_WIDTH-1:0]    gpio_oe
);

    localparam ADDR_DATA = 2'b00;
    localparam ADDR_DIR  = 2'b01;
    localparam ADDR_READ = 2'b10;

    wire [1:0] addr_offset = addr_i[3:2];

    reg [GPIO_WIDTH-1:0] gpio_data_reg;
    reg [GPIO_WIDTH-1:0] gpio_dir_reg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            gpio_data_reg <= {GPIO_WIDTH{1'b0}};
            gpio_dir_reg  <= {GPIO_WIDTH{1'b0}};
        end else if (write_en) begin
            case (addr_offset)
                ADDR_DATA: gpio_data_reg <= wdata[GPIO_WIDTH-1:0];
                ADDR_DIR : gpio_dir_reg  <= wdata[GPIO_WIDTH-1:0];
                default  : ;
            endcase
        end
    end

    assign gpio_out = gpio_data_reg;
    assign gpio_oe  = gpio_dir_reg;

    wire [GPIO_WIDTH-1:0] gpio_pin_state;

    genvar i;
    generate
        for (i = 0; i < GPIO_WIDTH; i = i + 1) begin : GEN_READ
            assign gpio_pin_state[i] =
                gpio_dir_reg[i] ? gpio_data_reg[i] : gpio_in[i];
        end
    endgenerate

    always @(*) begin
        if (read_en) begin
            case (addr_offset)
                ADDR_DATA: rdata = {{(32-GPIO_WIDTH){1'b0}}, gpio_data_reg};
                ADDR_DIR : rdata = {{(32-GPIO_WIDTH){1'b0}}, gpio_dir_reg};
                ADDR_READ: rdata = {{(32-GPIO_WIDTH){1'b0}}, gpio_pin_state};
                default  : rdata = 32'h0;
            endcase
        end else begin
            rdata = 32'h0;
        end
    end

endmodule
