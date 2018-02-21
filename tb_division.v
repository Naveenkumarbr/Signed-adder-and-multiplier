`timescale 1ns/10ps

module test();
wire [63:0]result;
reg [31:0]opera1;
reg [63:0]opera2;
reg clock;
wire valid;
reg muordi;
reg reset;
reg start;
divider cnt(.result(result),.opera1(opera1),.opera2(opera2),.clock(clock),.valid(valid),.muordi(muordi),.start(start),.reset(reset));
integer i,j;
initial begin

reset=1;start=1;muordi=0;opera1=0;opera2=0;i=0;j=0;#20
reset=0;start=1;#30
start=0;
opera1=2;opera2=7;muordi=1; #1300;
reset=0;start=1;#35
start=0;
opera1=2;opera2=-7;muordi=1; #1600;
reset=0;start=1;#35
start=0;
opera1=-2;opera2=7;muordi=1; #1600;
reset=0;start=1;#35
start=0;
opera1=-2;opera2=-7;muordi=1; #1600;
#5 $finish;
end


always @(valid) begin
	i=result[63:32];
	j=result[31:0];
	if(valid==1)
	$display("Divisor=",opera1,"| Dividend=",opera2,"|| Remainder---",i," || Quotient--",j);
	
end

initial begin
clock=0;
forever #9 clock=~clock;
end

initial begin

$dumpfile("divider.vcd");
$dumpvars(0,test);

end
endmodule

