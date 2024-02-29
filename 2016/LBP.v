`timescale 1ns/10ps
module LBP ( clk, reset, gray_addr, gray_req, gray_ready, gray_data, lbp_addr, lbp_valid, lbp_data, finish);
input   	clk;
input   	reset;
output reg  [13:0] 	gray_addr;
output reg         	gray_req;
input   	gray_ready;
input   [7:0] 	gray_data;
output reg  [13:0] 	lbp_addr;
output reg  	lbp_valid;
output reg  [7:0] 	lbp_data;
output reg  	finish;

reg [7:0] mem[0:8];
reg [2:0] current_state, next_state;
parameter idle = 3'd0, write = 3'd1, read = 3'd2, cal = 3'd3, done = 3'd4;

reg [6:0] row, col;
reg [7:0] result;
reg [3:0] count;

 always @(posedge clk or posedge reset) begin
    if(reset)begin
        current_state <= idle;
    end
    else begin
        current_state <= next_state;
    end
    
 end

 always @(*) begin
    case (current_state)
        idle:begin
            if(reset)begin
                next_state = idle;
            end
            else begin
                next_state = write;
            end
        end  
        write: begin
            if(row>7'd0 && row<7'd127 && col<7'd126)//non-zero
                next_state = read;
            else if(row == 7'd127 && col == 7'd127)//last one
                next_state = done;
            else
                next_state = write;
        end 
        read: begin
            if( count == 2'd0)
                next_state = cal;
            else
                next_state = read;
        end
        cal: begin
            next_state = write;
        end
        done:
            next_state = idle;
    endcase
 end

 always @(posedge clk or posedge reset) begin
    if(reset)
    begin
        gray_addr <= 14'd0;
        gray_req <= 1'd0;
        lbp_addr <= 14'd0;
        lbp_data <= 8'd0;
        lbp_valid <= 1'd0;
        finish <= 1'd0;
        row <= 7'd0;
        col <= 7'd0;
        result <= 8'd0;
        count <= 4'd9;
    end
    else
    begin
        case (current_state)
            idle:begin
                gray_addr <= 14'd0;
                gray_req <= 1'd0;
                lbp_addr <= 14'd0;
                lbp_data <= 8'd0;
                lbp_valid <= 1'd0;
                finish <= 1'd0;
                row <= 7'd0;
                col <= 7'd0;
                result <= 8'd0;
                count <= 4'd9;
            end 
            write:begin
                lbp_valid <= 1'd1;
                lbp_addr <= {row, col};
                lbp_data <= result;
                result <= 8'd0;
                count <= 4'd9;
                if(col==127) begin
                    row <= row + 7'd1;
                    col <= 7'd0;
                end
                else begin
                    col <= col + 7'd1;
                end
            end
            read:begin
                case (count)
                    4'd9: begin
                        gray_req <= 1'd1;
                        gray_addr <= {(row-7'd1), (col-7'd1)};
                        count <= count - 4'd1;
                    end
                    4'd8: begin
                        gray_req <= 1'd1;
                        gray_addr <= {(row-7'd1), (col)};
                        mem[0] <= gray_data;
                        count <= count - 4'd1;
                    end
                    4'd7: begin
                        gray_req <= 1'd1;
                        gray_addr <= {(row-7'd1), (col+7'd1)};
                        mem[1] <= gray_data;
                        count <= count - 4'd1;
                    end
                    4'd6: begin
                        gray_req <= 1'd1;
                        gray_addr <= {(row), (col-7'd1)};
                        mem[2] <= gray_data;
                        count <= count - 4'd1;
                    end
                    4'd5: begin
                        gray_req <= 1'd1;
                        gray_addr <= {(row), (col)};
                        mem[3] <= gray_data;
                        count <= count - 4'd1;
                    end
                    4'd4: begin
                        gray_req <= 1'd1;
                        gray_addr <= {(row), (col+7'd1)};
                        mem[4] <= gray_data;
                        count <= count - 4'd1;
                    end
                    4'd3: begin
                        gray_req <= 1'd1;
                        gray_addr <= {(row+7'd1), (col-7'd1)};
                        mem[5] <= gray_data;
                        count <= count - 4'd1;
                    end
                    4'd2: begin
                        gray_req <= 1'd1;
                        gray_addr <= {(row+7'd1), (col)};
                        mem[6] <= gray_data;
                        count <= count - 4'd1;
                    end
                    4'd1: begin
                        gray_req <= 1'd1;
                        gray_addr <= {(row+7'd1), (col+7'd1)};
                        mem[7] <= gray_data;
                        count <= count - 4'd1;
                    end
                    4'd0: begin
                        gray_req <= 1'd0;
                        mem[8] <= gray_data;
                    end
                    default: begin
                        gray_addr <= 14'd0;
                        gray_req <= 1'd0;
                    end
                endcase

            end

            cal: begin
                result[7] <= !(mem[8] < mem[4]);
                result[6] <= !(mem[7] < mem[4]);
                result[5] <= !(mem[6] < mem[4]);
                result[4] <= !(mem[5] < mem[4]);
                result[3] <= !(mem[3] < mem[4]);
                result[2] <= !(mem[2] < mem[4]);
                result[1] <= !(mem[1] < mem[4]);
                result[0] <= !(mem[0] < mem[4]);
            end

            done: begin
                finish <= 1'd1;
            end
        endcase
    end
 end

endmodule