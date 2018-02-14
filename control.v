
`timescale 1ns/10ps
module control_test(result,opera1,opera2,clock,valid,muordi,start,reset);
parameter s0=3'd0,s1=3'd1,s2=3'd2,s3=3'd3,s4=3'd4,s5=3'd5,s6=3'd6;
output [63:0]result;
input [63:0]opera2;
input [31:0]opera1;
input clock;
output valid;
input muordi;
input start,reset;
wire [31:0]res,opera1;
reg [31:0]tempB;
wire reset,start,cout;
reg sign,flag,flag1;
reg [2:0] state;
reg [2:0] next_state;
reg OPE,neg,valid;
reg [31:0]count;
reg [63:0]result;
reg divres,divneg;
reg [31:0]tempdiv;
reg [1:0] multi,chk;
reg [2:0] st2;


add32 add1(.sum(res),.cout(cout),.a(tempB),.b(result[63:32]),.cin(neg));

always @ (posedge clock) begin
	chk={reset,start};
	case(chk)
	2'b11:
		state=s0;
	2'b01:
		state=s1;
	default:
		state=next_state;
	endcase
	case(state)
	s0: begin
		case (start)
		1'b1:begin
			next_state=s0;
			result=0;
			valid=0;
			flag=0;
			divneg=0;
			divres=0;
			sign=0;
			flag1=0;
			OPE=0;
			neg=0;
			tempB=0;
			tempdiv=0;
			count=32'hFFFFFFFF;
			end
		1'b0:next_state=s1;
         	endcase
		end
	
	s1: begin

		result[63:32]=32'b0;
		//			MULTIPLICATION
		
		case(muordi)
		1'b0:begin
			multi={opera2[31],opera1[31]};
			case(multi)
			2'b10:begin
				flag=1;
				tempB=opera2[31:0];
				result[31:0]=opera1;
				neg=1;	
				next_state=s3;
			end
			2'b01:begin
				tempB=opera1;
				flag=1;
				result[31:0]=opera2[31:0];
				neg=1;	
				next_state=s3;
			end
			2'b11:begin				
				neg=1;
				case (flag1)
				1'b0:begin
					tempB=opera2[31:0];
					flag1=1;
					next_state=s1;
				end
				1'b1:begin
					tempB=opera1;
					result[31:0]=res;
					next_state=s3;
				end
				endcase
				end
			default:begin
			result[31:0]=opera1;
			tempB=opera2[31:0];
			neg=0;	
			next_state=s3;
			end
			endcase
		end
	
		//			DIVISION
		1'b1:begin
			multi={opera2[63],opera1[31]};
			case(multi)
			2'b10:begin	
				divneg=1;
				chk={flag,flag1};
				case(chk)
				2'b11:begin
					result[63:32]=res;
					tempB=opera1;
					next_state=s2;
					flag=0;
					neg=1;
				end
				2'b01:begin
					neg=0;
					result[31:0]=res;
					tempB=~opera2[63:32];
					result[32]=cout;
					flag=1;	
					next_state=s1;
				end
				default:begin
					tempB=opera2[31:0];
					neg=1;	
					flag1=1;
					next_state=s1;
				end
				endcase
			end
			2'b01:begin
				if(flag==1) begin
					
					result[31:0]=opera2[31:0];
					divneg=1;
					tempB=res;
					next_state=s2;
					flag=0;
				end
				else begin
					tempB=opera1;
					flag=1;
					neg=1;	
					next_state=s1;
				end
			end
			2'b11:begin
				case(sign)
				1'b1:begin
					chk={flag,flag1};
					case(chk)
					2'b11:begin					
						result[63:32]=res;
						tempB=tempdiv;
						next_state=s2;
						flag=0;
						
						neg=1;
					end
					2'b01:begin
					
						neg=0;
						result[31:0]=res;
						tempB=~opera2[63:32];
						result[32]=cout;
						flag=1;	
						next_state=s1;
					end
					default:begin
						tempdiv=res;
						tempB=opera2[31:0];
						neg=1;	
						flag1=1;
						next_state=s1;
					end
					endcase
				end
				default:begin
					tempB=opera1;
					sign=1;
					next_state=s1;
					neg=1;
				end
				endcase
			end
			default:begin
				result=opera2;
				tempB=opera1;
				OPE=1;
				neg=1;
				result=result<<1;
				next_state=s4;
	  	 	end
			endcase
		end
	    
	endcase
	end
	s2:begin
		st2={flag,count[0],muordi};
		case(st2)
		3'b100:begin
		result[31:0]=res;
		valid=1;		
	  	 end
		endcase
		st2={muordi,divres,count[0]};
		case(st2)
		3'b100:begin
			result=result<<1;
			next_state=s4;
			end
		3'b110:begin
			result[31:0]=res;
			result[63:32]=tempdiv;			
			valid=1;
			next_state=s0;
			end
		endcase
	   end
	s3:begin
		case(count[0])
		1'b1:begin
			OPE=result[0];
				case(OPE)
				1'b1:begin
				result[63:32]=res;
				end
				endcase
			result=result>>1;
			count=count>>1;	
		
			next_state=s3;
		end
		default:begin
			chk={flag,count[0]};
			case(chk)
			2'b01:begin
				tempB=result[31:0];
				neg=1;
				next_state=s2;
			end
			default:begin
				valid=1;
				next_state=s0;
			end
			endcase	
		end
		endcase

	end
	s4:begin
		case(count[0])
		1'b1:result[63:32]=res;
		endcase
	
		case(result[63])
		1'b0:begin
			next_state=s5;
		end
		1'b1:begin
			neg=0;
			next_state=s6;
		end
		endcase		
		case(count[0])
		1'b0:begin
			case(divneg)
			1'b1:begin
				divres=1;
				neg=1;
				tempB=result[31:0];
				tempdiv=result[63:32]>>1;
				result[63:32]=0;
				next_state=s2;
			end
			default:begin
				valid=1;
				next_state=s0;
				result[63:32]=result[63:32]>>1;
			end	
			endcase	
		end
		endcase
	     end
	s5:begin
		result=result<<1;
		result[0]=1;				
		OPE=1;
		neg=1;
		next_state=s4;
		count=count>>1;
	end
	s6:begin
		result[63:32]=res;
		result=result<<1;
		result[0]=0;
		OPE=1;
		neg=1;
		next_state=s4;
		count=count>>1;
	end	   
		
	endcase
	end
	
endmodule

module add32(sum,cout,a,b,cin);
output [31:0]sum;
output cout;
input [31:0]a;
input [31:0]b;
input cin;
wire [32:0]cout1;


reg [31:0]temp;


assign cout1[0]=cin;
assign cout=cout1[32];


always @ (cin or a) begin
if (cin==1) 
	 temp=~a;
else
	 temp=a;
end

genvar i;
generate

		
		for(i=0;i<=31;i=i+1) begin : generate_block 		
			fulladd f1(.sum(sum[i]),.cin(cout1[i]),.a(temp[i]),.b(b[i]),.cout(cout1[i+1]));
			
		
		end

endgenerate


endmodule








module fulladd(sum,cout,a,b,cin);
output sum,cout;
input a,b,cin;
//reg sum,carry;
wire a,b,sum1,carry2,carry1,cin;

adder a1(.sum(sum1),.carry(carry1),.a(a),.b(b));
adder a2(.sum(sum),.carry(carry2),.a(cin),.b(sum1));

or o1(cout,carry1,carry2);

endmodule
module adder(sum,carry,a,b);
output sum,carry;
input a,b;

assign sum=a^b;
assign carry=a&b;
endmodule
