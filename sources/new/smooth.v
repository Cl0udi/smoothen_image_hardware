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


module smooth(
    input clk,
    input reset,
    input [23:0] RGB_Smooth,// 0 - 7 Blue, 8 - 15, Green, 16 - 23 Red
    input [7:0] top,
    input [7:0] bot,
    input [7:0] left,
    input [7:0] right,
    input [7:0] top_left,
    input [7:0] top_right,
    input [7:0] bot_left,
    input [7:0] bot_right,
    output reg [23:0] RGB_Smoothened
    );
    
    
    integer transform;
    
    // Set initial values and open file.
    initial begin
        // Set initial values and open file
        RGB_Smoothened   = 0;
    end
    
    // Option 1) Reset all values
    // Option 2) Save all values to output file
    // Option 3) Store inverted values in out_BMP
    always @(posedge clk)begin
        // To reset all values.
        if(reset)begin
            RGB_Smoothened   = 0;
            end
        else begin
            // Operation
            transform =  RGB_Smooth[15:8] +
                         top +
                         bot +
                         left +
                         right +
                         top_left +
                         top_right +
                         bot_left +
                         bot_right;
                         
            // To approximate dividing by 9 we use transform >> 5 + transform >> 5 + transform >> 5 + transform >> 6 which
            // equals .109375 times its original value
            RGB_Smoothened[7:0]=(transform >> 3) - (transform >> 6); // blue
            RGB_Smoothened[15:8]=(transform >> 3) - (transform >> 6); // green
            RGB_Smoothened[23:16]=(transform >> 3) - (transform >> 6); // red
            end
       end
    
endmodule