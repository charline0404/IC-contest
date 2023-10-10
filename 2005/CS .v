`timescale 1ns/10ps
/*
 * IC Contest Computational System (CS)
*/
module CS(Y, X, reset, clk);

input clk, reset; 
input [7:0] X;
output [9:0] Y;

//equation1
wire [11:0] sum;
reg [11:0] storesum;
wire [7:0] avg;
//equatiion2
reg [71:0] num;//9 8-bit numbers
//equatiion3
wire [8:0] check;//check if fits any num
reg [8:0] store_check;

wire fst_check1,fst_check2,fst_check3,fst_check4,sec_check1,sec_check2,thi_check,fou_check;
wire [7:0] fst_r1,fst_r2,fst_r3,fst_r4,sec_r1,sec_r2,thi_r,fou_r;
//equation4
wire [12:0] total;
reg [3:0] valid;
/*
always@(posedge clk or posedge reset)
begin
  if(reset)
    begin
      storesum<=12'b0;
      num<=72'b0;
      store_check<=8'b0;
    end
  else
    begin
      storesum <= sum;
      num <= { num[63:0], X };
      store_check <= check;
    end
end
*/
assign sum = storesum - { 4'b0, num[71:64] } + { 4'b0, X };
assign avg = sum/9;
//equation3
//check[i] = num [i]<= avg
assign check[0] = (num[63:56] <= avg);
assign check[1] = (num[55:48] <= avg);
assign check[2] = (num[47:40] <= avg);
assign check[3] = (num[39:32] <= avg);
assign check[4] = (num[31:24] <= avg);
assign check[5] = (num[23:16] <= avg);
assign check[6] = (num[15:8] <= avg);
assign check[7] = (num[7:0] <= avg);
assign check[8] = (X <= avg);

//find max among check[i]==1
compare first_1(store_check[0], store_check[1], num[71:64], num[63:56], fst_check1, fst_r1);
compare first_2(store_check[2], store_check[3], num[55:48], num[47:40], fst_check2, fst_r2);
compare first_3(store_check[4], store_check[5], num[39:32], num[31:24], fst_check3, fst_r3);
compare first_4(store_check[6], store_check[7], num[23:16], num[15:8], fst_check4, fst_r4);

compare second_1(fst_check1, fst_check2, fst_r1, fst_r2, sec_check1, sec_r1);
compare second_2(fst_check3, fst_check4, fst_r3, fst_r4, sec_check2, sec_r2);

compare third(sec_check1, sec_check2, sec_r1, sec_r2, thi_check, thi_r);

compare fourth(thi_check, store_check[8], thi_r, num[7:0], fou_check, fou_r);

assign total = {1'b0, storesum} + { 2'b0, fou_r, 3'b0} + {5'b0, fou_r};
assign Y = total[12:3];


endmodule


module compare(check1,check2,num1,num2,output_check,result);
input check1,check2;
input [7:0] num1,num2;
output output_check;
output[7:0] result;

reg output_check;
reg[7:0] result;

always@(*)
begin

  case( {check1, check2} )
    2'b11:
    begin
      output_check<=1;
      if(num1>num2)
        result<=num1;
      else
        result<=num2;
    end
    2'b10:
    begin
      output_check<=1;
      result<=num1;
    end
    2'b01:
    begin
      output_check<=1;
      result<=num2;
    end
    default:
    begin
      output_check<=0;
      result<=8'b0;
    end
  endcase
  
end

endmodule
