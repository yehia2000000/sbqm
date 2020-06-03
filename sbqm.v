module sensor (z,x,reset,clk); // clk is predict time to enter the person
input x, reset ,clk;
output reg z ;

reg nextstate;
reg currentstate;

parameter a=1'b0,b=1'b1; //states in one sensor 

always @(x,currentstate)
begin

case (currentstate)

a: if (x==0)begin nextstate<=b; z<=1; end
else begin nextstate<=a; z<=0;   end 
b: if (x==0)begin nextstate<=b; z<=1; end
else begin nextstate<=a; z<=0;   end 

endcase

end

always @(posedge clk)
begin 

if (reset != 0)
begin
nextstate <= currentstate;
end

else 
begin
currentstate <=a;
end 

end

endmodule
//---------------------------------------------------
module rom ( address ,data); // assum the full pcout 3 person in queue
input [2:0] address ;              // address represent the pout
parameter tcout =1;

output reg [3:0] data ;
always @ (address)
begin
if (address==0)
begin data <= 3*(address+tcout-1)/tcout;    end 
else if (address==1)
begin data <= 3*(address+tcout-1)/tcout ;   end 
else if (address==2)
begin data <= 3*(address+tcout-1)/tcout ;   end 
else if (address==3)
begin data <= 3*(address+tcout-1)/tcout ;   end
else 
begin data<= 3;      end

end

endmodule 
module updowncounter (in1 ,in2  ,reset,clk,pout,full,empty);
input in1 ,in2 ,reset ,clk ;
output reg [2:0] pout ;
output reg full ,empty;
always @ (in1 , in2 ,posedge clk,reset)
begin 
if ( in1 == 1 && in2 == 0 && pout!=7  )begin  pout <= pout +1;   end 
else if ( in1 == 0 && in2 == 1 && pout!=0  )begin  pout <= pout -1;   end 
else if (reset ==0) begin pout <=0; end 

end 
always @(pout)
begin
if (pout == 7)begin full<=1;     end
else if ( pout ==0) begin  empty <= 1; end 
else  begin full<=0 ; empty<=0; end

end

endmodule
module mini_project (x1,x2,clk ,reset, wtime,full ,empty);
input x1, x2 , clk ,reset ;
output  [3:0] wtime ;
output full ,empty ;
wire z1 ,z2;
wire [2:0] pout;
sensor s1 (z1,x1,reset,clk);
sensor s2 (z2,x2,reset,clk);
updowncounter c1 (z1 ,z2  ,reset,clk,pout ,full ,empty);
rom r1(pout ,wtime);


endmodule
// test bench
module tb_sensor ();
reg clk, reset ,x;
wire z;
reg [19:0] chain;
integer i;
initial
begin
chain = 20'b1001_0100_1011_0001_1111;
clk =0;
i=0;
reset =0;
#11
reset =1;
$monitor ("%b %b %b " ,clk ,x,z);


end


always 
begin
#5
clk=~clk;
end
always @ (negedge clk)
begin
if (i<20)
begin
x= chain[i];
i=i+1;
end
else 
begin
x= chain[19];
end 
end


sensor s1 (z,x,reset,clk);

endmodule 
module tb_rom ();
reg[1:0] address;
wire [3:0] data;
initial 
begin
$monitor ("%d %d",address,data);
address = 0; 
#1

address =2;
#1
address =3;



end

rom r1 (address ,data);

endmodule 

module tb_counter ();
reg in1 ,in2 ,reset ,clk ;
wire [2:0] pout ;
wire full,empty;
reg [19:0] chain  ;
integer i;
initial
begin
$monitor ("%b  %b   %b   %b     %b %b  %b ",in1,in2,clk ,reset,pout ,full ,empty);
reset =0 ;
#11
reset =1 ;
clk =0;
chain = 20'b1111_0101_1010_0000_1010;
i=0;


end  
always @ (negedge clk )
begin
if (i<20)
begin
in1=chain[i];
i=i+1;
end
end
always @ (negedge clk )
begin
if (i<20)
begin
in2=chain[19-i];
i=i+1;
end
end
always 
begin
#5
clk=~clk;

end
updowncounter g1 (in1 ,in2  ,reset,clk,pout ,full, empty);

endmodule 

module tb_mini ();
reg x1, x2 , clk ,reset ;
wire [3:0] wtime ;
reg [19:0] chain ;
wire full, empty;
integer i;
initial
begin
$monitor ("%b  %b  %b    %b  %b %b",clk,x1,x2,wtime ,full ,empty);
chain = 20'b0010_1001_1111_0101_0011;
i=0;
clk =0;
reset =0;
#11
reset =1;



end
always 
begin
#5
clk=~clk;
end
always @ (negedge clk)
begin
if (i<20)
begin
x1 = chain [i];
x2 =  chain [19-i];
i=i+1;
end

end
mini_project p1 (x1,x2,clk ,reset, wtime ,full ,empty);

endmodule 