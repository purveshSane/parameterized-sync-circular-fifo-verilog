//==============================================================================
//                                                                             |
//    Project: Parameterized Sync Circular FIFO                                |
//                                                                             |
//    Module:  Sync Circular FIFO.                                             |
//    Version:                                                                 |
//             TBD,   January 18, 2021                                         |
//                                                                             |
//    Author:  Purvesh Sane, (purvesh96@gmail.com)                             |
//                                                                             |
//==============================================================================

module sync_circular_fifo
	#(parameter DATA_WIDTH = 64, parameter NUM_FIFO_BLOCKS = 1024, parameter POINTER_NUM_BITS = $clog2(NUM_FIFO_BLOCKS))
	(input [(DATA_WIDTH - 1) : 0] data_in, wr_en_in, clk_in, rst_n_in,
	 output reg full_out,
	 input rd_en_in,
	 output reg [(DATA_WIDTH - 1) : 0] data_out, empty_out);

	// FIFO and its cooresponding head/tail pointers + phase bits
	reg [(DATA_WIDTH - 1) : 0] fifo_data [(NUM_FIFO_BLOCKS - 1) : 0];
	reg [(POINTER_NUM_BITS - 1) : 0] head_pointer = 0;
	reg head_pointer_phase_bit = 0;
	reg [(POINTER_NUM_BITS - 1) : 0] tail_pointer = 0;
	reg tail_pointer_phase_bit = 0;

	// FSM States for Write Operations
	reg [1:0] WRITE_FSM_STATE = 2'b00;
	parameter WRITE_TOGGLE_CHECK = 2'b00;
	parameter WRITE_DENIED_FIFO_FULL = 2'b01;
	parameter WRITE_DATA_IN_TO_FIFO = 2'b10;

	// FSM States for Read Operations
	reg [1:0] READ_FSM_STATE = 2'b00;
	parameter READ_TOGGLE_CHECK = 2'b00;
	parameter READ_DENIED_FIFO_EMPTY = 2'b01;
	parameter READ_DATA_OUT_FROM_FIFO = 2'b10;

	always @ (posedge clk_in) begin
		case(WRITE_FSM_STATE)
			WRITE_TOGGLE_CHECK :
				if (wr_en_in == 1'b1) begin
					if (head_pointer == tail_pointer && head_pointer_phase_bit != tail_pointer_phase_bit) begin // Logic for if it is full
						WRITE_FSM_STATE = WRITE_DENIED_FIFO_FULL;
					end
					else begin
						WRITE_FSM_STATE = WRITE_DATA_IN_TO_FIFO;
					end
				end
			WRITE_DENIED_FIFO_FULL : begin
				full_out = 1'b1;
				WRITE_FSM_STATE = WRITE_TOGGLE_CHECK;
				end
			WRITE_DATA_IN_TO_FIFO : begin
				fifo_data[tail_pointer] = data_in;
				if (tail_pointer != (POINTER_NUM_BITS - 1)) begin
					tail_pointer = tail_pointer + 1;
				end
				else begin
					tail_pointer = 0;
					tail_pointer_phase_bit = tail_pointer_phase_bit ^ 1'b1;
				end
				WRITE_FSM_STATE = WRITE_TOGGLE_CHECK;
				end
			default : $display("Your WRITE FSM is Screwed Up!");
		endcase
	end
	always @ (posedge clk_in) begin
		case(READ_FSM_STATE)
			READ_TOGGLE_CHECK :
				if (rd_en_in == 1'b1) begin
					if (head_pointer == tail_pointer && head_pointer_phase_bit == tail_pointer_phase_bit) begin // Logic for if it is empty
						READ_FSM_STATE = READ_DENIED_FIFO_EMPTY;
					end
					else begin
						READ_FSM_STATE = READ_DATA_OUT_FROM_FIFO;
					end
				end
			READ_DENIED_FIFO_EMPTY : begin
				empty_out = 1'b1;
				READ_FSM_STATE = READ_TOGGLE_CHECK;
				end
			READ_DATA_OUT_FROM_FIFO : begin
				data_out = fifo_data[head_pointer];
				if (head_pointer != (POINTER_NUM_BITS - 1)) begin
					head_pointer = head_pointer + 1;
				end
				else begin
					head_pointer = 0;
					head_pointer = head_pointer_phase_bit ^ 1'b1;
				end
				READ_FSM_STATE = READ_TOGGLE_CHECK;
				end
			default : $display("Your READ FSM is Screwed Up!");
		endcase
	end
endmodule