module LASER (
input CLK,
input RST,
input [3:0] X,
input [3:0] Y,
output reg [3:0] C1X,
output reg [3:0] C1Y,
output reg [3:0] C2X,
output reg [3:0] C2Y,
output reg DONE);

reg [319:0] buffer;
reg [1:0] total[39:0];
reg[3:0] total_c1,total_c2;
reg [39:0]cmp_array1;
reg [3:0]cmp_index1;
reg [39:0]cmp_array2;
reg [3:0]cmp_index2;
reg[3:0]cmp_total1,cmp_total2;

reg [3:0] temp1,temp2,temp3,temp4,temp5,temp6;

reg c1_unmove,c2_unmove;

reg[3:0] current_state,next_state;

parameter 
read = 4'd0,
init = 4'd1,
init_cal = 4'd13,
c1_up = 4'd2,
c1_down = 4'd3,
c1_left = 4'd4,
c1_right = 4'd5,
c1_best = 4'd6,
c2_up = 4'd7,
c2_down = 4'd8,
c2_left = 4'd9,
c2_right = 4'd10,
c2_best = 4'd11,
finish = 4'd12,
c1_upload=4'd14,
c2_upload=4'd15;

integer i;
reg [5:0] counter;

always@(posedge CLK)
begin
    if(RST)
        current_state<=read;
    else
        current_state<=next_state;
end

always@(*)
begin
    case(current_state)
    read:
    begin
        if(counter<40)
            next_state=read;
        else
            next_state=init;
    end
    init:
        next_state=c1_up;
    init_cal:
    begin
        if(counter<40)
            next_state=init_cal;
        else
            next_state=c1_up;
    end    
    c1_up:
    begin
        if(counter<40)
            next_state=c1_up;
        else
            next_state=c1_down;
    end
    c1_down:
    begin
        if(counter<40)
            next_state=c1_down;
        else
            next_state=c1_left;
    end
    c1_left:
    begin
        if(counter<40)
            next_state=c1_left;
        else
            next_state=c1_right;
    end
    c1_right:
    begin
        if(counter<40)
            next_state=c1_right;
        else
            next_state=c1_best;
    end
    c1_best:
        next_state=c1_upload;
    c1_upload:
    begin
        if(counter<40)
            next_state=c1_upload;
        else
            next_state=c2_up;
    end
    c2_up:
    begin
        if(counter<40)
            next_state=c2_up;
        else
            next_state=c2_down;
    end
    c2_down:
    begin
        if(counter<40)
            next_state=c2_down;
        else
            next_state=c2_left;
    end
    c2_left:
    begin
        if(counter<40)
            next_state=c2_left;
        else
            next_state=c2_right;
    end
    c2_right:
    begin
        if(counter<40)
            next_state=c2_right;
        else
            next_state=c2_best;
    end
    c2_best:
        next_state=c2_upload;
    c2_upload:
    begin
        if(counter<40)
            next_state=c2_upload;
        else
            next_state=finish;
    end
    finish:
    begin
        next_state=read;
    end
    default:
        next_state=read;
    endcase
end

always@(posedge CLK)
begin
    if(RST)
    begin
        C1X<=0;
        C1Y<=0;
        C2X<=0;
        C2Y<=0;
        DONE<=0;
        buffer<=0;
        for(i=0;i<40;i=i+1)
        begin
            total[i]<=0;
            cmp_array1[i]<=0;
            cmp_array2[i]<=0;
        end
        cmp_index1<=0;
        cmp_index2<=0;
        counter<=0;
        total_c1<=0;
        total_c2<=0;
        c1_unmove<=0;
        c2_unmove<=0;
    end
    else
    begin
        case(current_state)

        read:
        begin
            DONE<=0;
            C1X<=0;
            C1Y<=0;
            C2X<=0;
            C2Y<=0;
            
            if(counter<40)
            begin
                counter<=counter+1;
                buffer<={buffer[319:8],X,Y};
            end
            else
            begin
                counter<=0;
                $display("finish reading");
            end
        end
        init:
        begin
            C1X<=C1X+4;
            C1Y<=C1Y+7;
            C2X<=C2X+11;
            C2Y<=C2Y+7;

            counter<=0;
            
            buffer<=0;
            for(i=0;i<40;i=i+1)
            begin
                total[i]<=0;
                cmp_array1[i]<=0;
                cmp_array2[i]<=0;
            end
            cmp_index1<=0;
            cmp_index2<=0;
            total_c1<=0;
            total_c2<=0;

        end

        init_cal:
        begin
           if(buffer[319-{counter[5:3],3'd0}] > C1X)
                temp1<=buffer[319-{counter[5:3],3'd0}] - C1X;
            else
                temp1<=C1X - buffer[319-{counter[5:3],3'd0}];

            if(buffer[315-{counter[5:3],3'd0}] > C1Y)
                temp2<=buffer[315-{counter[5:3],3'd0}] - C1Y;
            else
                temp2<=C1Y - buffer[315-{counter[5:3],3'd0}];

           if(buffer[319-{counter[5:3],3'd0}] > C2X)
                temp3<=buffer[319-{counter[5:3],3'd0}] - C2X;
            else
                temp3<=C2X - buffer[319-{counter[5:3],3'd0}];

            if(buffer[315-{counter[5:3],3'd0}] > C2Y)
                temp4<=buffer[315-{counter[5:3],3'd0}] - C2Y;
            else
                temp4<=C2Y - buffer[315-{counter[5:3],3'd0}];        

            temp3<=temp1+temp2;
            temp6<=temp4+temp5;

            if(counter==0)
            begin
                counter<=counter+1;
            end
            else if(counter==40)
            begin
                counter<=0;
                if(temp3<=4)
                begin
                    total[counter-1]<=2'd1;
                    total_c1<=total_c1+1;
                end
                else
                begin
                    if(temp6<=4)
                    begin
                        total[counter-1]<=2'b11;
                        total_c2<=total_c2+1;
                    end
                    else
                    begin
                        total[counter-1]<=0;
                    end
                end

            end
            else
            begin
                counter<=counter+1;
                if(temp3<=4)
                begin
                    total[counter-1]<=2'd1;
                    total_c1<=total_c1+1;
                end
                else
                begin
                    if(temp6<=4)
                    begin
                        total[counter-1]<=2'b11;
                        total_c2<=total_c2+1;
                    end
                    else
                    begin
                        total[counter-1]<=0;
                    end
                end
            end         
        end
        
        c1_up:
        begin
            DONE<=0;

            if(buffer[319-{counter[5:3],3'd0}] > C1X)
                temp1<=buffer[319-{counter[5:3],3'd0}] - C1X;
            else
                temp1<=C1X - buffer[319-{counter[5:3],3'd0}];

            if(buffer[315-{counter[5:3],3'd0}] > C1Y)
                temp2<=buffer[315-{counter[5:3],3'd0}] - C1Y +1;
            else
                temp2<=C1Y - buffer[315-{counter[5:3],3'd0}] +1;

            temp3<=temp1+temp2;
            if(counter==0)
            begin
                cmp_array1[0]<=0;
                counter<=counter+1;
            end
            else if(counter==40)
            begin
            $display("c1_up finish");
                counter<=0;
                if(temp3<=4)
                begin
                    cmp_array1[counter-1]<=1;
                    cmp_total1<=cmp_total1+1;
                end
                else
                begin
                    cmp_array1[counter-1]<=0;
                end
            end
            else
            begin
                counter<=counter+1;
                if(temp3<=4)
                begin
                    if(total[counter-1]==2'b11)
                    begin
                        cmp_array1[counter-1]<=0;
                        cmp_total1<=cmp_total1;
                    end
                    else
                    begin
                        cmp_array1[counter-1]<=1;
                        cmp_total1<=cmp_total1+1;
                    end
                end
                else
                begin
                    cmp_array1[counter-1]<=0;
                end
            end
        end
            
        c1_down:
        begin
            if(buffer[319-{counter[5:3],3'd0}] > C1X)
                temp1<=buffer[319-{counter[5:3],3'd0}] - C1X;
            else
                temp1<=C1X - buffer[319-{counter[5:3],3'd0}];

            if(buffer[315-{counter[5:3],3'd0}] > C1Y)
                temp2<=buffer[315-{counter[5:3],3'd0}] - C1Y -1;
            else
                temp2<=C1Y - buffer[315-{counter[5:3],3'd0}] -1;

            temp3<=temp1+temp2;

            if(counter==0)
            begin
                cmp_array2[0]<=0;
                counter<=counter+1;
            end
            else if(counter==40)
            begin
            $display("c1_down finish");
                counter<=0;
                if(temp3<=4)
                begin
                    cmp_array2<=0;
                    cmp_total2<=0;
                    if(cmp_total1 < (cmp_total2+1) )
                    begin
                        cmp_index1<=2'd1;
                        cmp_array1<=cmp_array2+{1'b1,39'd0};
                        cmp_total1<=cmp_total2+1;
                    end
                end
                else
                begin
                    cmp_array2<=0;
                    cmp_total2<=0;
                    if(cmp_total1 < (cmp_total2+1) )
                    begin
                        cmp_index1<=2'd1;
                        cmp_array1<=cmp_array2;
                        cmp_total1<=cmp_total2;
                    end
                end
            end
            else
            begin
                counter<=counter+1;
                if(temp3<=4)
                begin
                    if(total[counter-1]==2'b11)
                    begin
                        cmp_array1[counter-1]<=0;
                        cmp_total1<=cmp_total1;
                    end
                    else
                    begin
                        cmp_array1[counter-1]<=1;
                        cmp_total1<=cmp_total1+1;
                    end
                end
                else
                begin
                    cmp_array2[counter-1]<=0;
                end
            end

        end
            
        c1_left:
        begin
            if(buffer[319-{counter[5:3],3'd0}] > C1X)
                temp1<=buffer[319-{counter[5:3],3'd0}] - C1X -1;
            else
                temp1<=C1X - buffer[319-{counter[5:3],3'd0}] -1;

            if(buffer[315-{counter[5:3],3'd0}] > C1Y)
                temp2<=buffer[315-{counter[5:3],3'd0}] - C1Y;
            else
                temp2<=C1Y - buffer[315-{counter[5:3],3'd0}];

            temp3<=temp1+temp2;

            if(counter==0)
            begin
                counter<=counter+1;
                cmp_array2[0]<=0;
            end
            else if(counter==40)
            begin
            $display("c1_left finish");
                counter<=0;
                if(temp3<=4)
                begin
                    cmp_array2<=0;
                    cmp_total2<=0;
                    if(cmp_total1 < (cmp_total2+1) )
                    begin
                        cmp_index1<=2'd2;
                        cmp_array1<=cmp_array2+{1'b1,39'd0};
                        cmp_total1<=cmp_total2+1;
                    end
                end
                else
                begin
                    cmp_array2<=0;
                    cmp_total2<=0;
                    if(cmp_total1 < (cmp_total2+1) )
                    begin
                        cmp_index1<=2'd2;
                        cmp_array1<=cmp_array2;
                        cmp_total1<=cmp_total2;
                    end
                end
            end
            else
            begin
                counter<=counter+1;
                if(temp3<=4)
                begin
                    if(total[counter-1]==2'b11)
                    begin
                        cmp_array1[counter-1]<=0;
                        cmp_total1<=cmp_total1;
                    end
                    else
                    begin
                        cmp_array1[counter-1]<=1;
                        cmp_total1<=cmp_total1+1;
                    end
                end
                else
                begin
                    cmp_array2[counter-1]<=0;
                end
            end
        end
            
        c1_right:
        begin
            if(buffer[319-{counter[5:3],3'd0}] > C1X)
                temp1<=buffer[319-{counter[5:3],3'd0}] - C1X +1;
            else
                temp1<=C1X - buffer[319-{counter[5:3],3'd0}] +1;

            if(buffer[315-{counter[5:3],3'd0}] > C1Y)
                temp2<=buffer[315-{counter[5:3],3'd0}] - C1Y;
            else
                temp2<=C1Y - buffer[315-{counter[5:3],3'd0}];

            temp3<=temp1+temp2;

            if(counter==0)
            begin
                counter<=counter+1;
                cmp_array2[0]<=0;
            end
            else if(counter==40)
            begin
            $display("c1_right finish");
                counter<=0;
                if(temp3<=4)
                begin
                    cmp_array2<=0;
                    cmp_total2<=0;
                    if(cmp_total1 < (cmp_total2+1) )
                    begin
                        cmp_index1<=2'd3;
                        cmp_array1<=cmp_array2+{1'b1,39'd0};
                        cmp_total1<=cmp_total2+1;
                    end
                end
                else
                begin
                    cmp_array2<=0;
                    cmp_total2<=0;
                    if(cmp_total1 < (cmp_total2+1) )
                    begin
                        cmp_index1<=2'd3;
                        cmp_array1<=cmp_array2;
                        cmp_total1<=cmp_total2;
                    end
                end
            end
            else
            begin
                counter<=counter+1;
                if(temp3<=4)
                begin
                    if(total[counter-1]==2'b11)
                    begin
                        cmp_array1[counter-1]<=0;
                        cmp_total1<=cmp_total1;
                    end
                    else
                    begin
                        cmp_array1[counter-1]<=1;
                        cmp_total1<=cmp_total1+1;
                    end
                end
                else
                begin
                    cmp_array2[counter-1]<=0;
                end
            end
        end
            
        c1_best:
        begin
            if(cmp_total1>total_c1)
            begin
                case(cmp_index1)
                2'd0:
                    C1Y<=C1Y+1;
                2'd1:
                    C1Y<=C1Y-1;
                2'd2:
                    C1X<=C1X-1;
                2'd3:
                    C1X<=C1X+1;
                endcase
            end
            else
                c1_unmove<=1'b1;
            cmp_array1<=0;
            cmp_total1<=0;
            cmp_index1<=0;

        end

        c1_upload:
        begin
            if(counter<40)
            begin
                counter<=counter+1;
                if(cmp_array1[counter]==1'd1)
                    total[counter]<=2'd1;
            end

            else
            begin
                counter<=0;
            end
        end
            
        c2_up:
          begin
            if(buffer[319-{counter[5:3],3'd0}] > C2X)
                temp1<=buffer[319-{counter[5:3],3'd0}] - C2X;
            else
                temp1<=C2X - buffer[319-{counter[5:3],3'd0}];

            if(buffer[315-{counter[5:3],3'd0}] > C2Y)
                temp2<=buffer[315-{counter[5:3],3'd0}] - C2Y +1;
            else
                temp2<=C1Y - buffer[315-{counter[5:3],3'd0}] +1;

            temp3<=temp1+temp2;
            if(counter==0)
            begin
                cmp_array1[0]<=0;
                counter<=counter+1;
            end
            else if(counter==40)
            begin
            $display("c2_up finish");
                counter<=0;
                if(temp3<=4)
                begin
                    cmp_array1[counter-1]<=1;
                    cmp_total1<=cmp_total1+1;
                end
                else
                begin
                    cmp_array1[counter-1]<=0;
                end
            end
            else
            begin
                counter<=counter+1;
                if(temp3<=4)
                begin
                    if(total[counter-1]==2'b11)
                    begin
                        cmp_array1[counter-1]<=0;
                        cmp_total1<=cmp_total1;
                    end
                    else
                    begin
                        cmp_array1[counter-1]<=1;
                        cmp_total1<=cmp_total1+1;
                    end
                end
                else
                begin
                    cmp_array1[counter-1]<=0;
                end
            end
        end
            
        c2_down:
        begin
            if(buffer[319-{counter[5:3],3'd0}] > C2X)
                temp1<=buffer[319-{counter[5:3],3'd0}] - C2X;
            else
                temp1<=C2X - buffer[319-{counter[5:3],3'd0}];

            if(buffer[315-{counter[5:3],3'd0}] > C2Y)
                temp2<=buffer[315-{counter[5:3],3'd0}] - C2Y -1;
            else
                temp2<=C2Y - buffer[315-{counter[5:3],3'd0}] -1;

            temp3<=temp1+temp2;

            if(counter==0)
            begin
                cmp_array2[0]<=0;
                counter<=counter+1;
            end
            else if(counter==40)
            begin
            $display("c2_down finish");
                counter<=0;
                if(temp3<=4)
                begin
                    cmp_array2<=0;
                    cmp_total2<=0;
                    if(cmp_total1 < (cmp_total2+1) )
                    begin
                        cmp_index1<=2'd1;
                        cmp_array1<=cmp_array2+{1'b1,39'd0};
                        cmp_total1<=cmp_total2+1;
                    end
                end
                else
                begin
                    cmp_array2<=0;
                    cmp_total2<=0;
                    if(cmp_total1 < (cmp_total2+1) )
                    begin
                        cmp_index1<=2'd1;
                        cmp_array1<=cmp_array2;
                        cmp_total1<=cmp_total2;
                    end
                end
            end
            else
            begin
                counter<=counter+1;
                if(temp3<=4)
                begin
                    if(total[counter-1]==2'b11)
                    begin
                        cmp_array1[counter-1]<=0;
                        cmp_total1<=cmp_total1;
                    end
                    else
                    begin
                        cmp_array1[counter-1]<=1;
                        cmp_total1<=cmp_total1+1;
                    end
                end
                else
                begin
                    cmp_array2[counter-1]<=0;
                end
            end
        end

            
        c2_left:
        begin
            if(buffer[319-{counter[5:3],3'd0}] > C2X)
                temp1<=buffer[319-{counter[5:3],3'd0}] - C2X -1;
            else
                temp1<=C2X - buffer[319-{counter[5:3],3'd0}] -1;

            if(buffer[315-{counter[5:3],3'd0}] > C2Y)
                temp2<=buffer[315-{counter[5:3],3'd0}] - C2Y;
            else
                temp2<=C2Y - buffer[315-{counter[5:3],3'd0}];

            temp3<=temp1+temp2;

            if(counter==0)
            begin
                counter<=counter+1;
                cmp_array2[0]<=0;
            end
            else if(counter==40)
            begin
            $display("c2_left finish");
                counter<=0;
                if(temp3<=4)
                begin
                    cmp_array2<=0;
                    cmp_total2<=0;
                    if(cmp_total1 < (cmp_total2+1) )
                    begin
                        cmp_index1<=2'd2;
                        cmp_array1<=cmp_array2+{1'b1,39'd0};
                        cmp_total1<=cmp_total2+1;
                    end
                end
                else
                begin
                    cmp_array2<=0;
                    cmp_total2<=0;
                    if(cmp_total1 < (cmp_total2+1) )
                    begin
                        cmp_index1<=2'd2;
                        cmp_array1<=cmp_array2;
                        cmp_total1<=cmp_total2;
                    end
                end
            end
            else
            begin
                counter<=counter+1;
                if(temp3<=4)
                begin
                    if(total[counter-1]==2'b11)
                    begin
                        cmp_array1[counter-1]<=0;
                        cmp_total1<=cmp_total1;
                    end
                    else
                    begin
                        cmp_array1[counter-1]<=1;
                        cmp_total1<=cmp_total1+1;
                    end
                end
                else
                begin
                    cmp_array2[counter-1]<=0;
                end
            end
        end
            
        c2_right:
        begin
            if(buffer[319-{counter[5:3],3'd0}] > C2X)
                temp1<=buffer[319-{counter[5:3],3'd0}] - C2X +1;
            else
                temp1<=C2X - buffer[319-{counter[5:3],3'd0}] +1;

            if(buffer[315-{counter[5:3],3'd0}] > C2Y)
                temp2<=buffer[315-{counter[5:3],3'd0}] - C2Y;
            else
                temp2<=C2Y - buffer[315-{counter[5:3],3'd0}];

            temp3<=temp1+temp2;

            if(counter==0)
            begin
                counter<=counter+1;
                cmp_array2[0]<=0;
            end
            else if(counter==40)
            begin
            $display("c2_right finish");
                counter<=0;
                if(temp3<=4)
                begin
                    cmp_array2<=0;
                    cmp_total2<=0;
                    if(cmp_total1 < (cmp_total2+1) )
                    begin
                        cmp_index1<=2'd3;
                        cmp_array1<=cmp_array2+{1'b1,39'd0};
                        cmp_total1<=cmp_total2+1;
                    end
                end
                else
                begin
                    cmp_array2<=0;
                    cmp_total2<=0;
                    if(cmp_total1 < (cmp_total2+1) )
                    begin
                        cmp_index1<=2'd3;
                        cmp_array1<=cmp_array2;
                        cmp_total1<=cmp_total2;
                    end
                end
            end
            else
            begin
                counter<=counter+1;
                if(temp3<=4)
                begin
                    if(total[counter-1]==2'b11)
                    begin
                        cmp_array1[counter-1]<=0;
                        cmp_total1<=cmp_total1;
                    end
                    else
                    begin
                        cmp_array1[counter-1]<=1;
                        cmp_total1<=cmp_total1+1;
                    end
                end
                else
                begin
                    cmp_array2[counter-1]<=0;
                end
            end
        end
            
        c2_best:
        begin
            if(cmp_total1>total_c1)
            begin
                case(cmp_index1)
                2'd0:
                    C2Y<=C2Y+1;
                2'd1:
                    C2Y<=C2Y-1;
                2'd2:
                    C2X<=C2X-1;
                2'd3:
                    C2X<=C2X+1;
                endcase
            end
            else
                c2_unmove<=1'b1;
            cmp_array1<=0;
            cmp_total1<=0;
            cmp_index1<=0;

        end

        c2_upload:
        begin
            if(counter<40)
            begin
                counter<=counter+1;
                if(cmp_array1[counter]==1'd1)
                    total[counter]<=2'b11;
            end

            else
            begin
                counter<=0;
            end
        end
        
        finish:
        begin
            DONE<=1;
        end

        endcase
    end
end

endmodule
