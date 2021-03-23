module bus_sync #(
                  parameter WIDTH = 4
	         ) (
  input             reset_n,
  input             a_clk,
  input             b_clk,
  input [WIDTH-1:0] a_data_in,
  input             a_ld_pls,
  output reg        b_data_out
);

//------------------------------------------------
//  Register Declarations
//------------------------------------------------
reg [WIDTH-1 :0] a_data_out;
reg              a_pls_tgle_out;
wire             a_pls_tgle_in;
wire             b_pls;
reg              b_pls_tgle_out_synca; 
reg              b_pls_tgle_out_syncb; 

//------------------------------------------------
//  MUX Load Logic TX Domain
//------------------------------------------------
  always @ (posedge a_clk or negedge reset_n)
    begin
      if(!reset_n)
        begin
	  a_data_out <= 'b0;
        end
      else if(a_ld_pls)
        begin
          a_data_out <= a_data_in;
	end
      else
        begin
          a_data_out <= a_data_out;
	end
    end

//------------------------------------------------
//  Pulse Toggling
//------------------------------------------------
  always @ (posedge a_clk or negedge reset_n)
    begin
      if(!reset_n)
        begin
	  a_pls_tgle_out <= 1'b0;
        end
      else
        begin
          a_pls_tgle_out <= a_pls_tgle_in;
	end
    end

//------------------------------------------------
//  Pulse Sychronized using 2FF
//------------------------------------------------
  always @ (posedge b_clk or negedge reset_n)
    begin
      if(!reset_n)
        begin
	  b_pls_tgle_out_synca <= 1'b0;
	  b_pls_tgle_out_syncb <= 1'b0;
        end
      else
        begin
	  b_pls_tgle_out_synca <= a_pls_tgle_out;
          b_pls_tgle_out_syncb <= a_pls_tgle_out_synca;
	end
    end

//------------------------------------------------
//  Delay Logic For pulse
//------------------------------------------------
  always @ (posedge b_clk or negedge reset_n)
    begin
      if(!reset_n)
        begin
	  b_pls_tgle_out_sync <= 1'b0;
        end
      else
        begin
	  b_pls_tgle_out_sync <= b_pls_tgle_out_syncb;
	end
    end

//------------------------------------------------
//  Sampling Data with MuX recirculation
//------------------------------------------------
  always @ (posedge b_clk or negedge reset_n)
    begin
      if(!reset_n)
        begin
	  b_data_out <= 'b0;
        end
      else if(b_pls)
        begin
	  b_data_out <= a_data_out;
	end
      else
        begin
	  b_data_out <= b_data_out;
	end
    end

//------------------------------------------------
//  Assign Statements
//------------------------------------------------
assign a_pls_tgle_in = a_ld_pls ^ a_pls_tgle_out;
assign b_pls         = b_pls_tgle_out_syncb ^ b_pls_tgle_out_sync;


endmodule
