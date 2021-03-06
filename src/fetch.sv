//-----------------------------------------------------
	// This is design of the fetch stage of the pipeline
	// Design Name : IF
	// File Name   : fetch.sv
	// Function    :
	// Authors     : de Sainte Marie Nils - Edde Jean-Baptiste
//-----------------------------------------------------

/*
module NAME (PORTS LIST);

	PORTS DECLARATION
	VARIABLES DECLARATION

	MODULES INSTANTIATION
	ASSIGNMENT
	initial AND always BLOCS
	TASKS AND FUNCTIONS

endmodule
*/


module fetch_PC_REG ( clk, rst, hold_pc, old_pc, new_pc );

	//Inputs Declaration
	input clk, rst, hold_pc;
	input [31:0] new_pc;

	//Ouputs Declaration
	output reg [31:0] old_pc;

	//------Code starts Here------//
	always_ff @( posedge clk, posedge rst )
		begin
			if (rst)
				old_pc <= 0;
			else if ( hold_pc==0 )
				old_pc <= new_pc;
		end

endmodule // End of Module fetch_PC_REG


module fetch_MUX ( inc_pc, pc_branch, br, except, new_pc );

	//Inputs Declaration
	input [31:0] inc_pc;	//old_pc "+ 4"
	input [31:0] pc_branch;
	input br, except;

	//Outputs Declaration
	output reg [31:0] new_pc;


	//------Code starts Here------//
	always_comb
		begin
			case ( {br,except} )
				0: new_pc = inc_pc + 4;
				1: new_pc = 32'h8000_0180;
				2: new_pc = pc_branch;
				default: new_pc = inc_pc + 4;
			endcase
		end

endmodule // End of Module fetch_MUX


module IF ( clk, inst_rom, rst, hold_pc, hold_if, pc_branch, br, except, pc_rom, pc_out, inst_out );

	//Inputs Declaration
	input clk, rst, hold_pc, hold_if;
	input [31:0] pc_branch;
	input [31:0] inst_rom;
	input br, except;

	//Outputs Declaration
	output [31:0] pc_rom;
	output reg [31:0] pc_out;
	output reg [31:0] inst_out;

	//Variables declaration
	wire [31:0] pc;
	reg [31:0] pc_4;
	reg [31:0] inst_out_mux;


	//------Modules Instantiation------//
	fetch_PC_REG pc_REG(

      	.clk    	(	clk   	  ), // input
      	.rst    	(	rst   	  ), // input
      	.hold_pc  (	hold_pc   ), // input
      	.old_pc 	(	pc    	  ), // input	[31:0]
      	.new_pc 	(	pc_4  	  )  // output	[31:0]

	);

	fetch_MUX mux(

		.inc_pc   	(	pc				), // input	[31:0]
		.pc_branch  (	pc_branch	), // input	[31:0]
		.br  				(	br   			), // input
		.except 		(	except  	), // input
		.new_pc 		(	pc_4    	)  // output	[31:0]

	);


	//------Code starts Here------//
	assign pc_rom = pc;

	always_comb
		begin
			case( br )
					1: inst_out_mux = 0;
					0: inst_out_mux = inst_rom;
					default: inst_out_mux = inst_rom;
      endcase
		end

	always_ff @( posedge clk )
		begin
			pc_out <= pc;
			if ( hold_if==0 )
				inst_out <= inst_out_mux;
		end

endmodule // End of Module IF
