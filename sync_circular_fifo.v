module sync_circular_fifo
	#(parameter DATA_WIDTH = 64, parameter NUM_FIFO_BLOCKS = 1024, parameter POINTER_NUM_BITS = $sqrt(NUM_FIFO_BLOCKS))
	(input [(DATA_WIDTH - 1) : 0] data_i, wr_en_i, clk_i, rst_n_i,
	 output reg full_o,
	 input rd_en_i,
	 output reg [(DATA_WIDTH - 1) : 0] data_o, empty_o);

	reg [(DATA_WIDTH - 1) : 0] fifo_data [(NUM_FIFO_BLOCKS - 1) : 0];
	reg [POINTER_NUM_BITS : 0] head_pointer = 0; // Intentionally allowed one extra bit
	reg [POINTER_NUM_BITS : 0] tail_pointer = 0; // Intentionally allowed one extra bit

	reg [2:0] FSM_STATE = 3'b000;
	parameter WRITE_TOGGLE_CHECK = 3'b000;
	parameter WRITE_DENIED_FIFO_FULL = 3'b001;
	parameter WRITE_DATA_I_TO_FIFO = 3'b010;

	always @ (posedge clk_i) begin
		case(FSM_STATE)
			WRITE_TOGGLE_CHECK :
				if (wr_en_i == 1'b1) begin
					if (head_pointer == tail_pointer) begin
						FSM_STATE = WRITE_DENIED_FIFO_FULL;
					end
					else begin
						FSM_STATE = WRITE_DATA_I_TO_FIFO;
					end
				end
			WRITE_DENIED_FIFO_FULL : begin
				full_o = 1'b1;
				FSM_STATE = WRITE_TOGGLE_CHECK;
				end
			WRITE_DATA_I_TO_FIFO : begin
				fifo_data[tail_pointer] = data_i;
				tail_pointer = tail_pointer + 1;
				end
			default : $display("Your FSM is Screwed Up!");
		endcase
	end
endmodule