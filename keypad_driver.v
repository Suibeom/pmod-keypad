module Keypad
(
	input		i_Clock,
	input		i_Read,
	output	[3:0]	o_Columns,
	input	[3:0]	i_Rows,
	output	[15:0]	o_Keypad_State,
	output		o_Keypad_DV,
	output		o_LED_Debug
);
parameter IDLE		= 2'b00;
parameter DRIVE_COL	= 2'b01;
parameter READ_COL	= 2'b10;
parameter DATA_READY	= 2'b11;


reg [1:0] CurrentCol 	= 2'b00;
reg [3:0] r_Columns	= 4'b1111;
reg [2:0] State 	= IDLE;
reg	r_Keypad_DV	= 0;
reg [15:0]	r_Keypad_State;
reg [15:0] 	r_Keypad_Buffer;
reg [9:0]	r_Counter	= 0;
reg	r_LED_Debug	= 0;
always @(posedge i_Clock)
begin
	case (State)
		IDLE :
		begin
			r_LED_Debug <= 0;
			r_Columns <= 4'b1111;
			if (i_Read == 1)
			begin
				CurrentCol <= 2'b00;
              			r_Counter <= 10'b0000000000;
				State <= DRIVE_COL;
				r_Keypad_DV <= 0;
			end
			else
				State <= IDLE;
		end
		DRIVE_COL :
		begin
			r_LED_Debug <= 0;
          			r_Columns <= {CurrentCol == 0 ? 1'b0 : 1'b1,CurrentCol == 1 ? 1'b0 : 1'b1,CurrentCol == 2 ? 1'b0 : 1'b1,CurrentCol == 3 ? 1'b0 : 1'b1};
          			if (r_Counter == 10'b1111_1111_11)
				State <= READ_COL;
			else
				r_Counter <= r_Counter + 1;
		end
		READ_COL :
		begin
			r_LED_Debug <= 1;
          			r_Keypad_Buffer[CurrentCol*4 +: 4] <= i_Rows;
			if (CurrentCol == 3)
				State <= DATA_READY;
			else
			begin
				CurrentCol <= CurrentCol + 1;
				r_Counter <= 10'b0000000000;
				State <= DRIVE_COL;
			end
		end
		DATA_READY :
		begin
			r_LED_Debug <= 1;
			r_Keypad_DV <= 1;
			r_Keypad_State <= r_Keypad_Buffer;
			State <= IDLE;
		end
	endcase
end
assign o_Keypad_State = r_Keypad_State;
assign o_Keypad_DV = r_Keypad_DV;
assign o_Columns = r_Columns;
assign o_LED_Debug = r_LED_Debug;

endmodule


module Keypad_Decoder(
	input [15:0]	i_Keypad_State,
	output reg		o_Key_Pressed,
	output reg [3:0]	o_Key
);

always @(*) 
begin
	o_Key_Pressed = 1;
	casez (i_Keypad_State)
		16'b0zzzzzzzzzzzzzzz : o_Key = 4'h1;
		16'b10zzzzzzzzzzzzzz : o_Key = 4'h4;
		16'b110zzzzzzzzzzzzz : o_Key = 4'h7;
		16'b1110zzzzzzzzzzzz : o_Key = 4'h0;
		16'b11110zzzzzzzzzzz : o_Key = 4'h2;
		16'b111110zzzzzzzzzz : o_Key = 4'h5;
		16'b1111110zzzzzzzzz : o_Key = 4'h8;
		16'b11111110zzzzzzzz : o_Key = 4'hf;
		16'b111111110zzzzzzz : o_Key = 4'h3;
		16'b1111111110zzzzzz : o_Key = 4'h6;
		16'b11111111110zzzzz : o_Key = 4'h9;
		16'b111111111110zzzz : o_Key = 4'he;
		16'b1111111111110zzz : o_Key = 4'ha;
		16'b11111111111110zz : o_Key = 4'hb;
		16'b111111111111110z : o_Key = 4'hc;
		16'b1111111111111110 : o_Key = 4'hd;
		default: begin
			o_Key = 4'b0000;
			o_Key_Pressed = 0;
		end
	endcase
end
endmodule
