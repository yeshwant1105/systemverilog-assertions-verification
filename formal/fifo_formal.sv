module fifo_formal;

    parameter DATA_WIDTH = 8;
    parameter DEPTH = 8;

    logic clk;
    (* anyseq *) logic rst;
    (* anyseq *) logic wr_en;
    (* anyseq *) logic rd_en;
    (* anyseq *) logic [DATA_WIDTH-1:0] wr_data;

    logic [DATA_WIDTH-1:0] rd_data;
    logic full;
    logic empty;
    logic [$clog2(DEPTH+1)-1:0] count;

    synchronous_fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH(DEPTH)
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

    always @($global_clock) begin
        if ($initstate)
            clk <= 1'b0;
        else
            clk <= !clk;
    end

    initial begin
        assume(count == 0);
    end

    always @($global_clock) begin
        assert(count <= DEPTH);
        assert(empty == (count == 0));
        assert(full == (count == DEPTH));
        assert(!(full && empty));
    end

endmodule
