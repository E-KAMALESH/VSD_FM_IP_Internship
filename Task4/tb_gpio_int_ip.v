`timescale 1ns/1ps

module tb_gpio_int_ip;

    reg clk;
    reg rst_n;
    reg [4:0] addr;
    reg write_en;
    reg read_en;
    reg [31:0] wdata;
    wire [31:0] rdata;

    reg  [31:0] gpio_in;
    wire [31:0] gpio_out;
    wire [31:0] gpio_oe;
    wire irq;

    gpio_int_ip uut (
        .clk(clk),
        .rst_n(rst_n),
        .addr_i(addr),
        .write_en(write_en),
        .read_en(read_en),
        .wdata(wdata),
        .rdata(rdata),
        .gpio_in(gpio_in),
        .gpio_out(gpio_out),
        .gpio_oe(gpio_oe),
        .irq(irq)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst_n = 0;
        write_en = 0;
        read_en = 0;
        gpio_in = 0;
        #20 rst_n = 1;

        // Set lower 4 pins as output
        write(5'h00, 32'h0000000F);

        // Write output pattern
        write(5'h04, 32'h00000005);

        // Atomic set
        write(5'h0C, 32'h00000008);

        // Configure pin 8 as input
        write(5'h00, 32'h0000000F);

        // Enable interrupt on pin 8
        write(5'h18, 32'h00000100);

        // Generate rising edge on pin 8
        #20 gpio_in[8] = 1;

        #20 read(5'h1C);

        #50 $finish;
    end

    task write(input [4:0] a, input [31:0] d);
    begin
        @(posedge clk);
        addr = a;
        wdata = d;
        write_en = 1;
        @(posedge clk);
        write_en = 0;
    end
    endtask

    task read(input [4:0] a);
    begin
        @(posedge clk);
        addr = a;
        read_en = 1;
        @(posedge clk);
        read_en = 0;
    end
    endtask

endmodule
