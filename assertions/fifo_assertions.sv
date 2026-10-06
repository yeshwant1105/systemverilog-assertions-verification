module fifo_assertions #(
    parameter DEPTH = 8
)(
    input logic clk,
    input logic rst,
    input logic wr_en,
    input logic rd_en,
    input logic full,
    input logic empty,
    input logic [$clog2(DEPTH+1)-1:0] count
);

    property p_reset_empty;
        @(posedge clk) rst |=> empty;
    endproperty

    property p_empty_count_zero;
        @(posedge clk) disable iff (rst) empty |-> (count == 0);
    endproperty

    property p_full_count_depth;
        @(posedge clk) disable iff (rst) full |-> (count == DEPTH);
    endproperty

    property p_count_within_range;
        @(posedge clk) disable iff (rst) count <= DEPTH;
    endproperty

    property p_no_write_when_full;
        @(posedge clk) disable iff (rst) full |-> !(wr_en && full);
    endproperty

    property p_no_read_when_empty;
        @(posedge clk) disable iff (rst) empty |-> !(rd_en && empty);
    endproperty

    property p_write_increments_count;
        @(posedge clk) disable iff (rst) (wr_en && !full && !rd_en) |=> count == ($past(count) + 1);
    endproperty

    property p_read_decrements_count;
        @(posedge clk) disable iff (rst) (rd_en && !empty && !wr_en) |=> count == ($past(count) - 1);
    endproperty

    property p_simultaneous_access_preserves_count;
        @(posedge clk) disable iff (rst) (wr_en && !full && rd_en && !empty) |=> count == $past(count);
    endproperty

    property p_empty_rises_when_count_reaches_zero;
        @(posedge clk) disable iff (rst) $rose(empty) |-> (count == 0);
    endproperty

    property p_full_rises_when_count_reaches_depth;
        @(posedge clk) disable iff (rst) $rose(full) |-> (count == DEPTH);
    endproperty

    property p_count_stable_without_access;
        @(posedge clk) disable iff (rst) (!wr_en && !rd_en) |=> $stable(count);
    endproperty

    a_reset_empty:
        assert property (p_reset_empty)
        else $error("ASSERTION FAILED: FIFO is not empty after reset");

    a_empty_count_zero:
        assert property (p_empty_count_zero)
        else $error("ASSERTION FAILED: EMPTY asserted with non-zero count");

    a_full_count_depth:
        assert property (p_full_count_depth)
        else $error("ASSERTION FAILED: FULL asserted with incorrect count");

    a_count_within_range:
        assert property (p_count_within_range)
        else $error("ASSERTION FAILED: FIFO count outside legal range");

    a_no_write_when_full:
        assert property (p_no_write_when_full)
        else $error("ASSERTION FAILED: WRITE attempted while FIFO is full");

    a_no_read_when_empty:
        assert property (p_no_read_when_empty)
        else $error("ASSERTION FAILED: READ attempted while FIFO is empty");

    a_write_increments_count:
        assert property (p_write_increments_count)
        else $error("ASSERTION FAILED: FIFO count did not increment after write");

    a_read_decrements_count:
        assert property (p_read_decrements_count)
        else $error("ASSERTION FAILED: FIFO count did not decrement after read");

    a_simultaneous_access:
        assert property (p_simultaneous_access_preserves_count)
        else $error("ASSERTION FAILED: FIFO count changed during simultaneous read/write");

    a_empty_rises:
        assert property (p_empty_rises_when_count_reaches_zero)
        else $error("ASSERTION FAILED: EMPTY rose with non-zero count");

    a_full_rises:
        assert property (p_full_rises_when_count_reaches_depth)
        else $error("ASSERTION FAILED: FULL rose with incorrect count");

    a_count_stable:
        assert property (p_count_stable_without_access)
        else $error("ASSERTION FAILED: FIFO count changed without access");

endmodule