module sync_circular_fifo
	#(parameter DATA_WIDTH = 64, parameter NUM_FIFO_BLOCKS = 1024)
	(input [(DATA_WIDTH - 1) : 0] data_i, wr_en_i, clk_i, rst_n_i,
	 output full_o,
	 input rd_en_i,
	 output [(DATA_WIDTH - 1) : 0] data_o, empty_o);

	always @ (posedge clk_i)
		begin
		
		end
endmodule