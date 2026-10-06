module sva_testbench;

    logic clk;
    logic rst;
    logic wr_en;
    logic rd_en;
    logic [7:0] wr_data;
    logic [7:0] rd_data;
    logic full;
    logic empty;
    logic [3:0] count;

    integer i;

    synchronous_fifo #(
        .DATA_WIDTH(8),
        .DEPTH(8)
    ) dut (
        .clk(clk),
        .rst(rst),
        .wr_en(wr_en),
        .rd_en(rd_en),
        .wr_data(wr_data),
        .rd_data(rd_data),
        .full(full),
        .empty(empty),
        .count(count)
    );

    fifo_assertions #(
        .DEPTH(8)
    ) assertions (
        .clk(clk),
        .rst(rst),
        .wr_en(wr_en),
        .rd_en(rd_en),
        .full(full),
        .empty(empty),
        .count(count)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    task write_fifo(input logic [7:0] data);
        begin
            @(negedge clk);
            if (!full) begin
                wr_en = 1'b1;
                rd_en = 1'b0;
                wr_data = data;
            end

            @(negedge clk);
            wr_en = 1'b0;
        end
    endtask

    task read_fifo;
        begin
            @(negedge clk);
            if (!empty) begin
                wr_en = 1'b0;
                rd_en = 1'b1;
            end

            @(negedge clk);
            rd_en = 1'b0;
        end
    endtask

    task simultaneous_access(input logic [7:0] data);
        begin
            @(negedge clk);

            if (!full && !empty) begin
                wr_en = 1'b1;
                rd_en = 1'b1;
                wr_data = data;
            end

            @(negedge clk);
            wr_en = 1'b0;
            rd_en = 1'b0;
        end
    endtask

    initial begin
        rst = 1'b1;
        wr_en = 1'b0;
        rd_en = 1'b0;
        wr_data = 8'h00;

        $dumpfile("sim/sva_verification.vcd");
        $dumpvars(0, sva_testbench);

        repeat (3) @(negedge clk);

        rst = 1'b0;

        write_fifo(8'h11);

        write_fifo(8'h22);

        write_fifo(8'h33);

        write_fifo(8'h44);

        read_fifo;

        read_fifo;

        simultaneous_access(8'h55);

        for (i = 0; i < 4; i = i + 1)
            write_fifo(8'h60 + i);

        for (i = 0; i < 4; i = i + 1)
            read_fifo;

        repeat (5) @(negedge clk);

        $finish;
    end

endmodule