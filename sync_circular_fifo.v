module sync_circular_fifo
	#(parameter DATA_WIDTH = 64, parameter NUM_FIFO_BLOCKS = 1024, parameter POINTER_NUM_BITS = $sqrt(NUM_FIFO_BLOCKS))
	(input [(DATA_WIDTH - 1) : 0] data_i, wr_en_i, clk_i, rst_n_i,
	 output full_o,
	 input rd_en_i,
	 output [(DATA_WIDTH - 1) : 0] data_o, empty_o);

	reg [(DATA_WIDTH - 1) : 0] fifo_data [(NUM_FIFO_BLOCKS - 1) : 0];
	reg [POINTER_NUM_BITS : 0] head_pointer; // Intentionally allowed one extra bit
	reg [POINTER_NUM_BITS : 0] tail_pointer; // Intentionally allowed one extra bit

	reg [2:0] FSM_STATE = 3'b000;

	always @ (posedge clk_i) begin
		if (wr_en_i == 1'b1) begin

		end
	end
endmodule