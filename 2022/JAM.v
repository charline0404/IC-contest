module JAM (
input CLK,
input RST,
output reg [2:0] W,
output reg [2:0] J,
input [6:0] Cost,
output reg [3:0] MatchCount,
output reg [9:0] MinCost,
output reg Valid );

parameter cal_cost=3'd0, find_point=3'd1, exchange=3'd2, reverse=3'd3, done=3'd4, find_max= 3'd5;
reg [2:0] current_state, next_state;
reg [2:0] pivot;
reg [2:0] mem [0:7];
reg [3:0] read_idx;//denotes which mem position are we reading
reg  found;//1:pivot found
reg [9:0]sum;

reg [2:0] change_point;
reg [2:0] change_data;
reg [2:0] now;

always @(posedge CLK) begin
    if(RST)
        current_state <= cal_cost;
    else
        current_state <= next_state;
end

always @(*) begin
    case (current_state)
        cal_cost:
        begin
            if(read_idx == 9)
                next_state = find_point;
            else
                next_state = cal_cost;
        end
        find_point:
        begin
            if(pivot == 0)
                next_state = done;
            else if(found)
                next_state = find_max;
            else
                next_state = find_point; 
        end
        find_max:
            if(now==pivot)
                next_state = exchange;
            else
                next_state = find_max;
        exchange:
            next_state = reverse;
        reverse:
            next_state = cal_cost;
    endcase
end

always @(posedge CLK) begin
    if(RST)begin
        W <= 0;
        J <= 0;
        MatchCount <= 0;
        MinCost <= 10'h3FF;
        Valid  <= 0;
        mem[0] <= 0;
        mem[1] <= 1;
        mem[2] <= 2;
        mem[3] <= 3;
        mem[4] <= 4;
        mem[5] <= 5;
        mem[6] <= 6;
        mem[7] <= 7;

        pivot <= 7;
        read_idx <= 0;
        found<= 0;
        sum <= 0;
        change_point <= 7;
        now <= 0;
    end
    else begin
        case (current_state)
            cal_cost: 
            begin
                if(read_idx == 9)
                begin
                    read_idx <= 0;

                    if(sum + Cost < MinCost)begin
                        MinCost <= sum + {3'd0, Cost};
                        MatchCount <= 1;
                    end
                    else if(sum + Cost == MinCost)begin
                        MatchCount <= MatchCount +1;
                        $display("%d %d %d %d %d %d %d %d ", mem[0], mem[1], mem[2], mem[3], mem[4], mem[5], mem[6], mem[7]);
                        $display("cost %d sum %d", Cost, sum);
                    end
                end

                else
                begin
                    W <= mem[read_idx];
                    J <= read_idx;
                    read_idx <= read_idx + 1;
                    if(read_idx>1)
                    begin
                        sum <= sum + {3'd0, Cost};
                    end
                        
                    else
                        sum <= 0;
                end
                
            end

            find_point:
            begin
                if(!found) begin
                    if(mem[pivot] > mem[pivot-1])begin
                        found <= 1;
                        now <= 7;
                        change_data <= 7;
                    end
                        
                    else begin
                        found <= 0;
                        pivot <= pivot - 1;
                    end
                        
                end

            end

            find_max:
            begin
                found <= 0;
                    
                now <= now -1;
                if((mem[now] > mem[pivot-1]) && (mem[now]<=change_data)) begin
                    change_data <= mem[now];
                    change_point <=  now;
                end
                    
            end

            exchange:
            begin
                mem[pivot-1] <= mem[change_point];
                mem[change_point] <= mem[pivot-1];
                change_data <= 7;
            end
            reverse:
            begin
                pivot <= 7;
                case (pivot)
				3'd6 : begin
					mem[6] <= mem[7];
					mem[7] <= mem[6];
				end
				3'd5 : begin
					mem[5] <= mem[7];
					mem[7] <= mem[5];
				end
				3'd4 : begin
					mem[4] <= mem[7];
					mem[7] <= mem[4];
					mem[5] <= mem[6];
					mem[6] <= mem[5];
				end
				3'd3 : begin
					mem[3] <= mem[7];
					mem[7] <= mem[3];
					mem[4] <= mem[6];
					mem[6] <= mem[4];
				end
				3'd2 : begin
					mem[2] <= mem[7];
					mem[7] <= mem[2];
					mem[3] <= mem[6];
					mem[6] <= mem[3];
					mem[4] <= mem[5];
					mem[5] <= mem[4];
				end
				3'd1 : begin
					mem[1] <= mem[7];
					mem[7] <= mem[1];
					mem[2] <= mem[6];
					mem[6] <= mem[2];
					mem[3] <= mem[5];
					mem[5] <= mem[3];
				end
			    endcase
            end

            done:
                Valid <= 1;

        endcase
    end
end

endmodule


