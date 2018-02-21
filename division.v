`timescale 1ns/10ps
module divider(result,opera1,opera2,clock,valid,muordi,start,reset);
parameter s0=3'd0,s1=3'd1,s2=3'd2,s3=3'd3,s4=3'd4,s5=3'd5;
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
			neg=0;
			next_state=s0;
			result=0;
			valid=0;
			flag=0;
			divneg=0;
			divres=0;
			sign=0;
			flag1=0;
			OPE=0;
			tempB=0;
			tempdiv=0;
			count=32'hFFFFFFFF;
			end
		default:next_state=s1;
         	endcase
		end
	
	s1: begin

		result[63:32]=32'b0;
	
		//			DIVISION

		//1'b1:begin
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
				case(flag)
				1'b1:begin
					result[31:0]=opera2[31:0];
					divneg=1;
					tempB=res;
					next_state=s2;
					flag=0;
				end
				default:begin
		
					tempB=opera1;
					flag=1;
					neg=1;	
					next_state=s1;
				end
				endcase
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
				next_state=s3;
	  	 	end
			endcase
		end
	s2:begin
		
		st2={muordi,divres,count[0]};
		case(st2)
		3'b110:begin
			result[31:0]=res;
			result[63:32]=tempdiv;			
			valid=1;
			next_state=s0;
			end
		default:begin
			result=result<<1;
			next_state=s3;
			end
		endcase
	   end
	
	s3:begin
		case(count[0])
		1'b1:result[63:32]=res;
		endcase
	
		case(result[63])
		1'b0:begin
			next_state=s4;
		end
		default:begin
			neg=0;
			next_state=s5;
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
	s4:begin
		result=result<<1;
		result[0]=1;				
		OPE=1;
		neg=1;
		next_state=s3;
		count=count>>1;
	end
	s5:begin
		result[63:32]=res;
		result=result<<1;
		result[0]=0;
		OPE=1;
		neg=1;
		next_state=s3;
		count=count>>1;
	end	   
		
	endcase
	end
	
endmodule
