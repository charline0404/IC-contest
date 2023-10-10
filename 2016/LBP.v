
`timescale 1ns/10ps
module LBP ( clk, reset, gray_addr, gray_req, gray_ready, gray_data, lbp_addr, lbp_valid, lbp_data, finish);
input   	clk;
input   	reset;
output  [13:0] 	gray_addr;
output         	gray_req;
input   	gray_ready;
input   [7:0] 	gray_data;
output  [13:0] 	lbp_addr;
output  	lbp_valid;
output  [7:0] 	lbp_data;
output  	finish;
//====================================================================
reg  [13:0] 	gray_addr;
reg         	gray_req;
reg  [13:0] 	lbp_addr;
reg  	lbp_valid;
reg  [7:0] 	lbp_data;
reg  	finish;

reg [3:0] counter;//load data
reg [13:0] temp;//processing
reg [7:0] map;
reg [7:0] mid;

reg [1:0] cur_state;
reg [1:0] next_state;
parameter 
load_data=2'd0,
processing=2'd1,
done=2'd2;

always@(*)
begin
	case(cur_state)
	load_data:
	begin
		if(counter==4'd8)
		  	next_state=processing;
		else
			 next_state=load_data;
	end
	processing: 
	begin
		if(temp == 14'd16383)
		   next_state=done;
		else
			 next_state=processing;
	end
	done:
		next_state=done;
	endcase
end

always@(posedge clk or posedge reset)
begin
  if(reset)
  begin
    gray_addr<=14'd0;
    gray_req<=1'd1;
    lbp_addr<=14'd0;
    lbp_valid<=1'd0;
    lbp_data<=8'd0;
    finish<=1'd0;
  end
  
  else
  begin
    cur_state<=next_state;

    case(cur_state)
      load_data:
      begin
        //if(temp<14'd129 || temp>14'd16254)
        //begin
          map<=gray_data;
          gray_addr<=gray_addr+14'd1;
          gray_req<=1'd1;
          counter<=4'd8;
          temp<=temp+14'd1;
        //end
        /*
        else
          begin
            
            case(counter)
            
              4'd0:
              begin
                mid<=gray_data;
                gray_addr<= temp - 14'd129;
                gray_req<=1'd1;
                counter<=counter + 4'd1;
              end
              
              4'd1:
              begin
                map[0]<=(gray_data>=mid);
                gray_addr<= temp - 14'd128;
                gray_req<=1'd1;
                counter<=counter + 4'd1;
              end
              4'd2:
              begin
                map[1]<=(gray_data>=mid);
                gray_addr<= temp - 14'd127;
                gray_req<=1'd1;
                counter<=counter + 4'd1;
              end
              4'd3:
              begin
                map[2]<=(gray_data>=mid);
                gray_addr<= temp - 14'd1;
                gray_req<=1'd1;
                counter<=counter + 4'd1;
              end
              4'd4:
              begin
                map[3]<=(gray_data>=mid);
                gray_addr<= temp + 14'd1;
                gray_req<=1'd1;
                counter<=counter + 4'd1;
              end
              4'd5:
              begin
                map[4]<=(gray_data>=mid);
                gray_addr<= temp + 14'd127;
                gray_req<=1'd1;
                counter<=counter + 4'd1;
              end
              4'd6:
              begin
                map[5]<=(gray_data>=mid);
                gray_addr<= temp + 14'd128;
                gray_req<=1'd1;
                counter<=counter + 4'd1;
              end
              4'd7:
              begin
                map[6]<=(gray_data>=mid);
                gray_addr<= temp + 14'd129;
                gray_req<=1'd1;
                counter<=counter + 4'd1;
              end
              4'd8:
              begin
                map[7]<=(gray_data>=mid);
                gray_addr<= temp + 14'd1;
                gray_req<=1'd1;
                counter<=counter + 4'd1;
                temp<=temp+14'd1;
              end
              
            endcase
            
          end
          */
      end
      processing:
      begin
        counter<=4'd0;
        lbp_valid<=1'b1;
        lbp_addr<=temp;
        lbp_data<=map;
      end
      done:
      begin
        gray_addr<=14'd0;
        gray_req<=1'd0;
        lbp_addr<=14'd0;
        lbp_valid<=1'd0;
        lbp_data<=8'd0;
        finish<=1'b1;
      end
    endcase
  end
  
end

//====================================================================
endmodule
