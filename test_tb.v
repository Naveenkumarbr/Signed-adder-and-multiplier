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
multiplier cnt(.result(result),.opera1(opera1),.opera2(opera2),.clock(clock),.valid(valid),.muordi(muordi),.start(start),.reset(reset));
integer i,j;
initial begin

reset=1;start=1;muordi=0;opera1=0;opera2=0;i=0;j=0;#9
reset=0;start=1;#15
start=0;
opera1=2;opera2=32;muordi=0; #450;
start=1;#15
start=0;
opera1=-2;opera2=32;#550;
start=1;#20
start=0;
opera1=2;opera2=-32;#550;
start=1;#20
start=0;
opera1=-2;opera2=-32;#500;
#5 $finish;
end


always @(valid) begin
	i=result[63:32];
	j=result[31:0];
	if(valid==1)
	$display("Multiplicand=",opera1,"| Multiplier=",opera2,"|| Result--",j);
	
end

initial begin
clock=1;
forever #6 clock=~clock;
end

initial begin

$dumpfile("multiplier.vcd");
$dumpvars(0,test);

end
endmodule
