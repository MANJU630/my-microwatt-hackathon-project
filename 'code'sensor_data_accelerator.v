module sensor_data_accelerator #(
    parameter WIDTH = 16,
    parameter AVG_WINDOW = 8
)(
    input wire clk,
    input wire rst_n,
    input wire cyc_i,
    input wire stb_i,
    input wire we_i,
    input wire [3:0] adr_i,
    input wire [31:0] dat_i,
    output reg [31:0] dat_o,
    output reg ack_o,
    output reg irq_o,
    input wire [WIDTH-1:0] sensor_data_in
);

    reg [WIDTH-1:0] threshold;
    reg [31:0] scale_factor;
    reg [WIDTH-1:0] filter_coeff;
    reg [3:0] sensor_type;
    reg [WIDTH-1:0] samples[0:AVG_WINDOW-1];
    integer i;
    reg [WIDTH+7:0] sum;
    reg [WIDTH-1:0] filtered_data;
    reg event_detected;
    reg [47:0] scaled_val;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            ack_o <= 0;
            dat_o <= 0;
            threshold <= 16'd1000;
            scale_factor <= 32'd1;
            sensor_type <= 4'd0;
            filter_coeff <= 16'd0;
            irq_o <= 0;
            event_detected <= 0;
            sum <= 0;
            filtered_data <= 0;
            for (i=0; i<AVG_WINDOW; i=i+1)
                samples[i] <= 0;
        end else begin
            ack_o <= 0;

            if (cyc_i & stb_i & we_i & !ack_o) begin
                case (adr_i)
                    4'h0: threshold <= dat_i[WIDTH-1:0];
                    4'h1: scale_factor <= dat_i;
                    4'h2: sensor_type <= dat_i[3:0];
                    4'h3: filter_coeff <= dat_i[WIDTH-1:0];
                    default: ;
                endcase
                ack_o <= 1;
            end else if (cyc_i & stb_i & !we_i & !ack_o) begin
                case (adr_i)
                    4'h0: dat_o <= {16'd0, threshold};
                    4'h1: dat_o <= scale_factor;
                    4'h2: dat_o <= {28'd0, sensor_type};
                    4'h3: dat_o <= {16'd0, filter_coeff};
                    4'h4: dat_o <= {16'd0, filtered_data};
                    4'h5: dat_o <= {31'd0, event_detected};
                    default: dat_o <= 32'd0;
                endcase
                ack_o <= 1;
            end

            sum <= sum - samples[AVG_WINDOW-1];
            for (i=AVG_WINDOW-1; i>0; i=i-1)
                samples[i] <= samples[i-1];
            samples[0] <= sensor_data_in;
            sum <= sum + sensor_data_in;
            filtered_data <= sum / AVG_WINDOW;

            scaled_val = filtered_data * scale_factor;

            if (filtered_data >= threshold)
                event_detected <= 1'b1;
            else
                event_detected <= 1'b0;
            irq_o <= event_detected;
        end
    end
endmodule




Testbench CODE:


`timescale 1ns/1ps
module sensor_data_accelerator_tb;
   parameter WIDTH = 16;
    parameter AVG_WINDOW = 8;
    reg clk, rst_n;
    reg cyc_i, stb_i, we_i;
    reg [3:0] adr_i;
    reg [31:0] dat_i;
    wire [31:0] dat_o;
    wire ack_o;
    wire irq_o;
    reg [WIDTH-1:0] sensor_data_in;
    sensor_data_accelerator #(
        .WIDTH(WIDTH),
        .AVG_WINDOW(AVG_WINDOW)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .cyc_i(cyc_i),
        .stb_i(stb_i),
        .we_i(we_i),
        .adr_i(adr_i),
        .dat_i(dat_i),
        .dat_o(dat_o),
        .ack_o(ack_o),
        .irq_o(irq_o),
        .sensor_data_in(sensor_data_in)
    );
    initial clk = 0;
    always #5 clk = ~clk;
    task wb_write(input [3:0] addr, input [31:0] data);
    begin
        @(negedge clk);
        cyc_i = 1; stb_i = 1; we_i = 1;
        adr_i = addr; dat_i = data;
        @(posedge ack_o);
        cyc_i = 0; stb_i = 0; we_i = 0;
    end
    endtask
    task wb_read(input [3:0] addr, output [31:0] data);
    begin
        @(negedge clk);
        cyc_i = 1; stb_i = 1; we_i = 0;
        adr_i = addr;
        @(posedge ack_o);
        data = dat_o;
        cyc_i = 0; stb_i = 0;
    end
    endtask
    integer i;
    reg [31:0] readback;
    initial begin
        cyc_i = 0; stb_i = 0; we_i = 0; adr_i = 0; dat_i = 0;
        sensor_data_in = 0;
        rst_n = 0;
        #20
        rst_n = 1;
        #10
        wb_write(4'h0, 16'd400);
        wb_write(4'h1, 32'd2);
        wb_write(4'h3, 16'd0);
        for (i = 0; i < AVG_WINDOW; i = i + 1) begin
            sensor_data_in = 10 * (i + 1);
            #10;
        end
        wb_read(4'h4, readback);
        $display("Filtered data: %d", readback);
        sensor_data_in = 16'd450;
        #10;
        wb_read(4'h4, readback);
        $display("After threshold-exceeding input, filtered data: %d", readback);
        wb_read(4'h5, readback);
        $display("Event detected (should be 1): %d", readback);
        $display("IRQ output (should be 1): %d", irq_o);
        sensor_data_in = 16'd300;
        #10;
        wb_read(4'h4, readback);
        $display("Check scaling, filtered data (not scaled): %d", readback);
        sensor_data_in = 16'd100;
        #10;
        wb_read(4'h5, readback);
        $display("Event detected after low input (should be 0): %d", readback);
        $display("IRQ output after low input (should be 0): %d", irq_o);
        #20;
        $finish;
    end
endmodule

