
`timescale 1ns/10ps

module  CONV(clk,reset,busy,ready,iaddr,idata,cwr,caddr_wr,cdata_wr,crd,caddr_rd,cdata_rd,csel);

input		clk;
input		reset;
output		busy;	
input		ready;

output	[11:0]  iaddr;
input	[19:0]	idata;

output	 	cwr;
output	 [11:0]	caddr_wr;
output	 [19:0]	cdata_wr;

output	 	crd;
output	 [11:0]	caddr_rd;
input	[19:0] 	cdata_rd;

output	 [2:0]	csel;

reg		busy;	
reg	[11:0]  iaddr;
reg	 	cwr;
reg	 [11:0]	caddr_wr;
reg	 [19:0]	cdata_wr;
reg	 	crd;
reg	 [11:0]	caddr_rd;
reg	 [2:0]	csel;

reg [19:0] mat [4355:0];
wire [19:0] kernel[8:0];

assign kernel[0]=20'h0A89E;
assign kernel[1]=20'h092D5;
assign kernel[2]=20'h06D43;
assign kernel[3]=20'h01004;
assign kernel[4]=20'hF8F71;
assign kernel[5]=20'hF6E54;
assign kernel[6]=20'hFA6D7;
assign kernel[7]=20'hFC834;
assign kernel[8]=20'hFAC19;

parameter init = 3'd0,
read = 3'd1,
layer0 = 3'd2,
output_layer0 = 3'd3,
layer1 = 3'd4,
output_layer1 = 3'd5,
finish = 3'd6;

reg [2:0] current_state,next_state;

reg [3:0] layer0_current,layer0_next;

integer i;
reg layer0_done,layer1_done;
reg [5:0] idx_x,idx_y;
reg [5:0] counter_x,counter_y;
reg[12:0] counter;

//calaulate circuit
wire [12:0] pos_0 = {7'd0,idx_x}+{7'd0,idx_y};
wire [12:0] pos_1= {7'd0,idx_x}+{7'd0,idx_y}+13'd1;
wire [12:0] pos_2 = {7'd0,idx_x}+{7'd0,idx_y}+13'd2;
wire [12:0] pos_3 = {7'd0,idx_x}+{7'd0,idx_y}+13'd66;
wire [12:0] pos_4 = {7'd0,idx_x}+{7'd0,idx_y}+13'd67;
wire [12:0] pos_5 = {7'd0,idx_x}+{7'd0,idx_y}+13'd68;
wire [12:0] pos_6 = {7'd0,idx_x}+{7'd0,idx_y}+13'd132;
wire [12:0] pos_7 = {7'd0,idx_x}+{7'd0,idx_y}+13'd133;
wire [12:0] pos_8 = {7'd0,idx_x}+{7'd0,idx_y}+13'd134;

reg signed[39:0]sum;

wire [12:0] mapo_0 = {7'd0,idx_x}+{6'd0,idx_y,1'd0};
wire [12:0] mapo_1 = {7'd0,idx_x}+{6'd0,idx_y,1'd0};
wire [12:0] mapo_2 = {7'd0,idx_x}+{6'd0,idx_y,1'd0};
wire [12:0] mapo_3 = {7'd0,idx_x}+{6'd0,idx_y,1'd0};

always@(posedge clk or posedge reset)
begin
	if(reset)
	begin
		current_state<=init;
		layer0_current <=4'd0;
	end
	else
	begin
		current_state<=next_state;
		layer0_current<=layer0_next;
	end

end

always@(*)
begin
	if(current_state==layer0)
	begin
		if(layer0_current == 4'd8)
			layer0_next = 4'd0;
		else
			layer0_next = layer0_current + 4'd1;
	end
	else
		layer0_next = 4'd0;
end

always@(*)
begin
	case(current_state)
		init:
		begin
			if(ready)
				next_state=read;
			else
				next_state=init;
		end
		read:
		begin
			if(iaddr == 12'd4095)
				next_state=layer0;
			else
				next_state=read;
		end
		layer0:
		begin
			if(layer0_done)
				next_state=output_layer0;
			else
				next_state=layer0;
		end
		output_layer0:
		begin
			if(caddr_wr == 12'd4095)
				next_state=layer1;
			else
				next_state=layer0;
		end
		layer1:
		begin
			next_state=output_layer1;
		end
		output_layer1:
		begin
			if(caddr_wr == 12'd1023)
				next_state=finish;
			else
				next_state=layer1;
		end
		finish:
			next_state=init;
	endcase
end

always@(posedge clk or posedge reset)
begin
	if(reset)
	begin
		busy<=1'b0;
		iaddr<=12'd0;
		crd<=1'b0;
		caddr_rd<=12'd0;
		cwr<=1'b0;
		cdata_wr<=12'd0;
		caddr_wr<=12'd0;
		csel<=3'd0;

		sum <= 40'd0;

		for(i=0;i<4355;i=i+1)
			mat[i]<=20'd0;

		counter<=13'd67;
		counter_x<=6'd0;
		counter_y<=6'd0;
		
		idx_x<=6'd0;
		idx_y<=6'd0;
	end

	else
	begin
		case(current_state)
			init:
			begin
				iaddr<=12'd0;
				crd<=1'b0;
				caddr_rd<=12'd0;
				cwr<=1'b0;
				cdata_wr<=12'd0;
				caddr_wr<=12'd0;
				csel<=3'd0;

				sum <= 40'd0;

				for(i=0;i<4355;i=i+1)
					mat[i]<=20'd0;

				counter<=12'd67;
				counter_x<=6'd0;
				counter_y<=6'd0;
					
				idx_x<=6'd0;
				idx_y<=6'd0;
				if(ready)
					busy<=1'b1;
				else
					busy<=1'b0;
			end
			read:
			begin
				if(iaddr == 12'd4095)
				begin
					iaddr<=12'd0;
					sum<=40'h00AB900000;
				end
				else
					iaddr<=iaddr+12'd1;

				if(counter_y==6'd63)
				begin
					counter_x<=counter_x+6'd1;
					counter_y<=6'd0;
					counter<=counter+13'd3;
				end
				else
				begin
					counter_y<=counter_y+6'd1;
					counter<=counter+13'd1;
				end

				mat[counter]<=idata;
					
			end
			layer0:
			begin	
				case(layer0_current)
				4'd0:
				begin
					sum<=sum+mat[pos_0]*kernel[0];
				end
				4'd1:
				begin
					sum<=sum+mat[pos_1]*kernel[1];
				end
				4'd2:
				begin
					sum<=sum+mat[pos_2]*kernel[2];
				end
				4'd3:
				begin
					sum<=sum+mat[pos_3]*kernel[3];
				end
				4'd4:
				begin
					sum<=sum+mat[pos_4]*kernel[4];
				end
				4'd5:
				begin
					sum<=sum+mat[pos_5]*kernel[5];
				end
				4'd6:
				begin
					sum<=sum+mat[pos_6]*kernel[6];
				end
				4'd7:
				begin
					sum<=sum+mat[pos_7]*kernel[7];
					layer0_done<=1'b1;
				end
				4'd8:
				begin
					sum<=sum+mat[pos_8]*kernel[8];
					cwr<=1'b1;
					csel<=3'b001;

				end

				endcase
			end

			output_layer0:
			begin
				cwr<=1'b0;
				csel<=3'd0;
				if(sum[35]===1'b1)
				begin
					cdata_wr<=20'd0;
					mat[pos_0]<=20'd0;
				end
				else
				begin
					if(sum[15] == 1'b1)
					begin
						cdata_wr <= sum[35:16] +1;
						mat[pos_0] <= sum[35:16] +1;
					end
					else
					begin
						cdata_wr<=sum[35:16];
						mat[pos_0]<=sum[35:16];
					end

				end

				sum<=40'h00AB900000;
				if(caddr_wr == 12'd4095)
				begin
					caddr_wr<=12'd0;
					idx_x<=6'd0;
					idx_y<=6'd0;
				end
				else
				begin
					caddr_wr<=caddr_wr+12'd1;
					if(idx_y==6'd63)
					begin
						idx_x<=idx_x+6'd1;
						idx_y<=6'd0;
					end
					else
						idx_y<=idx_y+6'd1;
				end
			end
			layer1:
			begin
				layer1_done<=1'b1;
				cwr<=1'b1;
				csel<=3'b011;
				cdata_wr<=20'd0;
			end
			output_layer1:
			begin
				cwr<=1'b0;
				csel<=3'd0;
				if(caddr_wr == 12'd1023)
				begin
					caddr_wr<=12'd0;
				end
				else
					caddr_wr<=caddr_wr+12'd1;
			end
			finish:
			begin
				busy<=1'b0;
			end
		endcase
	end
end

endmodule




