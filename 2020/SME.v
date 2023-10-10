module SME(clk,reset,chardata,isstring,ispattern,valid,match,match_index);
input clk;
input reset;
input [7:0] chardata;
input isstring;
input ispattern;
output match;
output [4:0] match_index;
output valid;

reg match;
reg [4:0] match_index;
reg valid;

reg [7:0] string[31:0];
reg [7:0] pattern[7:0];
reg [4:0] index_s;//for compare
reg [2:0] index_p;//for compare

reg [4:0]counters;//for input
reg [2:0]counterp;//for input

integer i;

reg done;

reg [2:0] current_state,next_state;
parameter 
init=3'd0,
reads=3'd1,
readp=3'd2,
process=3'd3,
finish=3'd4;

reg [2:0] current_pro,next_pro;
parameter 
prepare=3'd0,
compare=3'd1,
maybe=3'd2,
wrong=3'd3,
done_match=3'd4,
done_unmatch=3'd5,
wait=3'd6;

reg check;


wire [4:0] limit=counters-{2'd0,counterp};
reg front,back;

always@(posedge clk or posedge reset)
begin
    if(reset)
    begin
        current_state<=init;
        current_pro<=prepare;
    end
    else
    begin
        current_state<=next_state;
        current_pro<=next_pro;
    end
end

always@(*)
begin
    case(current_state)
        init:
        begin
            if(isstring)
                next_state=reads;
            else if(ispattern)
                next_state=readp;
            else
                next_state=init;
        end
        reads:
        begin
            if(isstring)
                next_state=reads;
            else
                next_state=readp;
        end
        readp:
        begin
            if(ispattern)
                next_state=readp;
            else
                next_state=process;
        end
        process:
        begin
            if(done)
                next_state=finish;
            else
                next_state=process;
        end
        finish:
        begin
            if(isstring)
                next_state=reads;
            else if(ispattern)
                next_state=readp;
            else
                next_state=init;
        end
    endcase
end

always@(*)
begin
    if(current_state == process)
    begin
        case(current_pro)
            prepare:
                next_pro=compare;
            compare:
            begin
                next_pro=wait;
            end
            wait:
            begin
                if(check)
                    next_pro=maybe;
                else
                    next_pro=wrong;
            end
            maybe:
            begin
                if(index_p == counterp-3'd1)
                    next_pro=done_match;
                else
                    next_pro=compare;
            end
            wrong:
            begin
                if(index_s == limit)
                    next_pro=done_unmatch;
                else
                    next_pro=compare;
            end
            done_match:
                next_pro=prepare;
            done_unmatch:
                next_pro=prepare;
        endcase
    end
    else
        next_pro=prepare;
end

always@(posedge clk or reset)
begin
    if(reset)
    begin
        for(i=0;i<32;i=i+1)
            string[i]<=8'd0;
        for(i=0;i<8;i=i+1)
            pattern[i]<=8'd0;
        counterp<=3'd0;
        counters<=5'd0;

        index_s<=5'd0;
        index_p<=3'd0;
        match_index<=5'd0;
        done<=1'd0;
    end
    else
    begin
    case(current_state)
        init:
        begin
            done<=1'd0;
            match_index<=5'd0;

            if(isstring)
            begin
                for(i=0;i<32;i=i+1)
                    string[i]<=8'd0;
                for(i=0;i<8;i=i+1)
                    pattern[i]<=8'd0;
                counters<=5'd0;
                counterp<=3'd0;
            end

            else if(ispattern)
            begin
                for(i=0;i<8;i=i+1)
                    pattern[i]<=8'd0;
                counterp<=3'd0;
            end
        end

        reads:
        begin
            string[counters]<=chardata;
            counters<=counters+5'd1;
            done<=1'd0;
        end

        readp:
        begin
            if(chardata == 8'h5E)//^
            begin
                front<=1'd1;
            end
            else if(chardata == 8'h24)//$
            begin
                back<=1'd1;
            end
            else
            begin
                pattern[counterp]<=chardata;
                counterp<=counterp+3'd1;
                done<=1'd0;
            end
        end

        process:
        begin
            case(current_pro)
            prepare:
            begin
                index_p<=3'd0;
                index_s<=5'd0;
            end

            compare:
            begin
                if( (string[index_s] == pattern[index_p])  or pattern[index_p]==8'h2E)
                begin
                    check<=1'd1;
                end
                else
                begin
                    check<=1'd0;
                end
            end

            wait:
            begin
                check<=check
            end

            maybe:
            begin
                if(index_p==counterp-3'd1)//done_match
                    index_p<=3'd0;
                else
                    index_p<=index_p+3'd1;
            end

            wrong:
            begin
                if(index_s == limit)//done_unmatch
                begin
                    index_s<=5'd0;
                    index_p<=3'd0;
                end
                else
                begin
                    index_s<=index_s + 5'd1;
                    index_p<=3'd0;
                end
            end

            done_match:
            begin
                done<=1'b1;
                match_index<=index_s;
            end

            done_unmatch:
            begin
                done<=1'b1;
                match_index<=5'd0;
            end

            endcase

        end

        finish:
        begin
            match_index<=5'd0;
            done<=1'd0;
            if(isstring)
            begin
                for(i=0;i<32;i=i+1)
                    string[i]<=8'd0;
                for(i=0;i<8;i=i+1)
                    pattern[i]<=8'd0;
                counters<=5'd0;
                counterp<=3'd0;
            end

            else if(ispattern)
            begin
                for(i=0;i<8;i=i+1)
                    pattern[i]<=8'd0;
                counterp<=3'd0;
            end
        end
    endcase
    end
end

//match
always@(posedge clk or posedge reset) begin
  if(reset) match<=1'd0;
  else if(next_pro ==done_match) match<=1'd1;
  else if(next_pro ==done_unmatch)  match<=1'd0;
end

//valid
always@(posedge clk or posedge reset) begin
  if(reset) valid<=1'd0;
  else if(next_state==finish) valid<=1'd1;
  else valid<=1'd0;
end

endmodule
