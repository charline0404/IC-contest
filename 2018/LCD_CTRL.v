module LCD_CTRL(clk, reset, cmd, cmd_valid, IROM_Q, IROM_rd, IROM_A, IRAM_valid, IRAM_D, IRAM_A, busy, done);
input clk;
input reset;
input [3:0] cmd;
input cmd_valid;
input [7:0] IROM_Q;
output IROM_rd;
output [5:0] IROM_A;
output IRAM_valid;
output [7:0] IRAM_D;
output [5:0] IRAM_A;
output busy;
output done;


reg [1:0] cur_state;
reg [1:0] next_state;

parameter
LOAD_DATA=2'd0,
WAIT_CMD=2'd1,
PROCESS=2'd2,
WRITE_DONE=2'd3;

// Data process and control signal
reg IROM_rd; //IROM read enable
reg [5:0] IROM_A; //IROM address
reg [7:0] data_buff [0:63]; // buf all data
reg busy;
reg [3:0] cmd_reg;        // cmd temp
reg [2:0] row;	// 紀錄origin position Y軸
reg [2:0] col;	// 紀錄origin position X軸
reg [5:0] output_counter; //use to count the output data number
reg IRAM_valid;
reg [7:0] IRAM_D; //IRAM data
reg [5:0] IRAM_A; //IRAM address
reg done;

wire [7:0] max_1,max_2,max_3,min_1,min_2,min_3,ave_1,ave_2,ave_3;


//cmd
parameter
Write=4'd0,
Shift_Up=4'd1,
Shift_Down=4'd2,
Shift_Left=4'd3,
Shift_Right=4'd4,
Max=4'd5,
Min=4'd6,
Average=4'd7,
Counterclockwise_Rotation=4'd8,
Clockwise_Rotation=4'd9,
Mirror_X=4'd10,
Mirror_Y=4'd11;


//next state logic
always@(*)
begin
	case(cur_state)
	LOAD_DATA:
	begin
		if(IROM_A==6'd63)
			next_state=WAIT_CMD;
		else
			next_state=LOAD_DATA;
	end
	WAIT_CMD: 
	begin
		if(cmd_valid)
			next_state=PROCESS;
		else
			next_state=WAIT_CMD;
	end
	PROCESS: 
	begin
		if(cmd_reg == Write)
		begin
			if(output_counter == 6'd63)
				next_state=WRITE_DONE;
			else
				next_state=PROCESS;
		end
		else
			next_state=WAIT_CMD;
	end
	WRITE_DONE:
		next_state=WAIT_CMD;
	endcase
end

//Data process and control signal  (state register)
always@( posedge clk or posedge reset ) 
begin  
    if (reset) 
	  begin
		cur_state<=LOAD_DATA;
		IROM_rd<=1'd1;
		IROM_A<=6'd0;
		busy<=1'd1;
		cmd_reg<=Write;
		row<=3'd4;	//origin=(4,4)
    col<=3'd4;
		output_counter<=6'd0;
		IRAM_valid<=1'd0;
		IRAM_D<=8'd0;
		IRAM_A<=6'd0;	
		done<=1'd0;
    end
    else 
	  begin
		  cur_state<=next_state;
		  
		  case(cur_state)
		    LOAD_DATA:
		    begin
		      
		      IROM_rd<=1'b1;
		      IROM_A<=IROM_A+6'd1;
		      data_buff[IROM_A]<=IROM_Q;
		    
		    end
		    
		    WAIT_CMD:
		    begin
		      
		      IROM_rd<=1'd0;
		      IRAM_valid<=1'd0;
			    done<=1'd0;
		      if(cmd_valid)
		      begin
		        cmd_reg<=cmd;
		        busy<=1'b1;
		      end
		      else
		       begin
		         busy<=1'b0;
		       end
		      
		    end
		    
		    PROCESS:
		    begin
		      
		      case(cmd_reg)
		        Write:
		        begin
		          output_counter<=output_counter + 6'd1;
		          IRAM_valid<=1'd1;
		          IRAM_D<=data_buff[output_counter];
				      IRAM_A<=output_counter;  
		        end
		        
		        Shift_Up:
		        begin
		          if(row<=1)
		            row<=row;
		          else
		            row<=row-3'd1;
		        end
		        Shift_Down:
		        begin
		          if(row>=7)
		            row<=row;
		          else
		            row<=row+3'd1;
		        end
		        Shift_Left:
		        begin
		          if(col<=1)
		            col<=col;
		          else
		            col<=col-3'd1;
		        end
		        Shift_Right:
		        begin
		          if(col>=7)
		            col<=col;
		          else
		            col<=col+3'd1;
		        end
		        
		        Max:
		        begin
		          data_buff[{row,col}-9]<=max_3;
					    data_buff[{row,col}-8]<=max_3;
					    data_buff[{row,col}-1]<=max_3;
					    data_buff[{row,col}]<=max_3;
		        end
		        
		        Min:
		        begin
		          data_buff[{row,col}-9]<=min_3;
					    data_buff[{row,col}-8]<=min_3;
					    data_buff[{row,col}-1]<=min_3;
					    data_buff[{row,col}]<=min_3;
		        end
		        
		        Average:
		        begin
		          data_buff[{row,col}-9]<=ave_3;
					    data_buff[{row,col}-8]<=ave_3;
					    data_buff[{row,col}-1]<=ave_3;
					    data_buff[{row,col}]<=ave_3;
		        end
		        
		        Counterclockwise_Rotation:
		        begin
				      data_buff[{row,col}-9]<=data_buff[{row,col}-8];
				      data_buff[{row,col}-8]<=data_buff[{row,col}];
				      data_buff[{row,col}]<=data_buff[{row,col}-1];
				      data_buff[{row,col}-1]<=data_buff[{row,col}-9];
			      end
			      
			      Clockwise_Rotation:
			      begin
			        data_buff[{row,col}-9]<=data_buff[{row,col}-1];
				      data_buff[{row,col}-1]<=data_buff[{row,col}];
				      data_buff[{row,col}]<=data_buff[{row,col}-8];
				      data_buff[{row,col}-8]<=data_buff[{row,col}-9];
			      end
			      
			      Mirror_X:
			      begin
			        data_buff[{row,col}-9]<=data_buff[{row,col}-1];
				      data_buff[{row,col}-8]<=data_buff[{row,col}];
				      data_buff[{row,col}-1]<=data_buff[{row,col}-9];
				      data_buff[{row,col}]<=data_buff[{row,col}-8];
			      end
			      Mirror_Y:
			      begin
			        data_buff[{row,col}-9]<=data_buff[{row,col}-8];
				      data_buff[{row,col}-8]<=data_buff[{row,col}-9];
				      data_buff[{row,col}-1]<=data_buff[{row,col}];
				      data_buff[{row,col}]<=data_buff[{row,col}-1];
			      end
			      
			    endcase
			  end
			  WRITE_DONE:
			  begin
			    done<=1'b1;
			  end
			endcase
		    
		end
end

compare max1_1 (data_buff[{row,col}-9],data_buff[{row,col}-8],1,max_1);
compare max1_2 (data_buff[{row,col}-1],data_buff[{row,col}],1,max_2);
compare max2 (max_1,max_2,1,max_3);
compare min1_1 (data_buff[{row,col}-9],data_buff[{row,col}-8],0,min_1);
compare min1_2 (data_buff[{row,col}-1],data_buff[{row,col}],0,min_2);
compare min2 (min_1,min_2,0,min_3);
average ave1_1 (data_buff[{row,col}-9],data_buff[{row,col}-8],ave_1);
average ave1_2 (data_buff[{row,col}-1],data_buff[{row,col}],ave_2);
average ave2 (ave_1,ave_2,ave_3);

endmodule

module compare(a,b,sel,re);
input [7:0] a,b;
input sel;
output[7:0] re;
reg[7:0] re;

always@(*)
begin
  if(sel)//max
  begin
    if(a>b)
      re<=a;
    else
      re<=b;
  end
  else//min
  begin
    if(a<b)
      re<=a;
    else
      re<=b;
  end
end

endmodule

module average(a,b,r);
input [7:0] a,b;
output [7:0] r;
reg [7:0] r;

always@(*)
  r<=( {1'b0,a}+{1'b0,b} )>>1;

endmodule


