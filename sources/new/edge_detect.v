`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Alfonso de la Morena
// 
// Create Date: 04/27/2018 08:13:14 AM
// Design Name: Smoothen Image
// Module Name: smooth
// Project Name: Final Project
// Revision:
// Revision 0.01 - File Created
// 
//////////////////////////////////////////////////////////////////////////////////


module edge_detect(
    input clk,
    input reset,
    input [23:0] RGB_Edge,// 0 - 7 Blue, 8 - 15, Green, 16 - 23 Red
    input [7:0] top,
    input [7:0] bot,
    input [7:0] left,
    input [7:0] right,
    input [7:0] top_left,
    input [7:0] top_right,
    input [7:0] bot_left,
    input [7:0] bot_right,
    output reg [23:0] RGB_Edge_Detected
    );
    
    
    integer transform;
    
    // Set initial values and open file.
    initial begin
        // Set initial values and open file
        RGB_Edge_Detected   = 0;
    end
    
    // Option 1) Reset all values
    // Option 2) Save all values to output file
    // Option 3) Store inverted values in out_BMP
    always @(posedge clk)begin
        // To reset all values.
        if(reset)begin
            RGB_Edge_Detected   = 0;
            end
        else begin
            // Operation
            transform =  (RGB_Edge[15:8] << 3) -
                         top -
                         bot -
                         left -
                         right -
                         top_left -
                         top_right-
                         bot_left -
                         bot_right;
                         
            RGB_Edge_Detected[7:0]=transform; // blue
            RGB_Edge_Detected[15:8]=transform; // green
            RGB_Edge_Detected[23:16]=transform; // red
            end
       end
    
endmodule