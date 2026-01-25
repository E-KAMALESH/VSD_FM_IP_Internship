module gpio_ip (
    input         clk,
    input         rst_n,      // active-low reset

    input  [3:0]  addr,       // byte offset: 0x0, 0x4, ...
    input  [31:0] wdata,
    input         wen,        // write enable
    output [31:0] rdata,      // readback

    output [31:0] gpio_out,   // output value register
    output [31:0] gpio_oe     // output enable register
);
    reg [31:0] reg_out;
    reg [31:0] reg_oe;

    // write logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            reg_out <= 32'h0000_0000;
            reg_oe  <= 32'h0000_0000;
        end else if (wen) begin
            case (addr)
                4'h0: reg_out <= wdata;  // offset 0x0
                4'h4: reg_oe  <= wdata;  // offset 0x4
                default: ;               // ignore other addresses
            endcase
        end
    end

    // readback mux
    reg [31:0] rdata_reg;
    always @(*) begin
        case (addr)
            4'h0: rdata_reg = reg_out;
            4'h4: rdata_reg = reg_oe;
            default: rdata_reg = 32'h0000_0000;
        endcase
    end

    assign rdata    = rdata_reg;
    assign gpio_out = reg_out;
    assign gpio_oe  = reg_oe;

endmodule

