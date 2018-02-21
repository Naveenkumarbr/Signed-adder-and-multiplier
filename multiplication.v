`timescale 1ns/10ps
module multiplier(result,opera1,opera2,clock,valid,muordi,start,reset);
parameter s0=3'd0,s1=3'd1,s2=3'd2,s3=3'd3;
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
reg flag,flag1;
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
	casex(chk)
	2'b1x:
		state=s0;
	2'b01:
		state=s0;
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
			OPE=0;
			neg=0;
			tempB=0;
			count=32'hFFFFFFFF;
			end
		1'b0:next_state=s1;
         	endcase
		end
	
	s1: begin

		result[63:32]=32'b0;
		//			MULTIPLICATION
		
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
				case (flag)
				1'b0:begin
					tempB=opera2[31:0];
					flag=1;
					next_state=s1;
				end
				1'b1:begin
					tempB=opera1;
					result[31:0]=res;
					next_state=s3;
					flag=0;
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
	s2:begin
		
		result[31:0]=res;
		valid=1;		
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
			2'b10:begin
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
	endcase

	end
	
endmodule
