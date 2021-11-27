`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Alfonso de la Morena
// 
// Create Date: 04/27/2018 08:13:14 AM
// Design Name: Image Smoothen and Edge Detect
// Module Name: image_tb
// Project Name: Final Project
// Revision:
// Revision 0.01 - File Created
// 
//////////////////////////////////////////////////////////////////////////////////


module image_tb#(parameter
    WIDTH = 768, // Image width 
    HEIGHT = 512, // Image height
    BMP_HEADER_NUM = 54, // Header Elements
    TOTAL_DATA = WIDTH*HEIGHT*3, // The number of elements in our BMP file
    OUTFILE_EDGE   = "C:\\Users\\Alfonso\\Desktop\\Verilog\\Final_Project\\Circle_Edge_Detected.bmp",
    INFILE_EDGE    = "C:\\Users\\Alfonso\\Desktop\\Verilog\\Final_Project\\Circle.hex", // Input image hex file
    OUTFILE_SMOOTH = "C:\\Users\\Alfonso\\Desktop\\Verilog\\Final_Project\\Banana_Noise_Smoothed.bmp",
    INFILE_SMOOTH  = "C:\\Users\\Alfonso\\Desktop\\Verilog\\Final_Project\\Banana.hex" // Input image hex file
    );

    reg [1:0] clk;
    reg [1:0] reset;
    reg [1:0] write;
    reg [1:0] read;
    reg [23:0] RGB_Edge;
    reg [23:0] RGB_Smooth;
    reg [7:0] top_edge_detect;
    reg [7:0] bot_edge_detect;
    reg [7:0] left_edge_detect;
    reg [7:0] right_edge_detect;
    reg [7:0] top_left_edge_detect;
    reg [7:0] top_right_edge_detect;
    reg [7:0] bot_left_edge_detect;
    reg [7:0] bot_right_edge_detect;
    reg [7:0] top_smooth;
    reg [7:0] bot_smooth;
    reg [7:0] left_smooth;
    reg [7:0] right_smooth;
    reg [7:0] top_left_smooth;
    reg [7:0] top_right_smooth;
    reg [7:0] bot_left_smooth;
    reg [7:0] bot_right_smooth;
    wire [23:0] RGB_Smoothened;
    wire [23:0] RGB_Edge_Detected;
    reg [7:0] memory_storage_smooth [TOTAL_DATA:0];
    reg [7:0] memory_storage_edge [TOTAL_DATA:0];
    reg [7:0] out_BMP_Edge_Detected [TOTAL_DATA:0];
    reg [7:0] out_BMP_Smooth [TOTAL_DATA:0];
    reg [7:0] BMP_header [BMP_HEADER_NUM:0];
    integer i;
    reg [20:0] read_pointer;
    reg [20:0] write_pointer;
    integer FILE_EDGE;
    integer FILE_SMOOTH;
    reg [1:0] bot_check;
    reg [1:0] top_check;
    reg [1:0] left_check;
    reg [1:0] right_check;
    
    
    edge_detect transform_1(
        .clk(clk),
        .reset(reset),
        .RGB_Edge(RGB_Edge),
        .top(top_edge_detect),
        .bot(bot_edge_detect),
        .left(left_edge_detect),
        .right(right_edge_detect),
        .top_left(top_left_edge_detect),
        .top_right(top_right_edge_detect),
        .bot_left(bot_left_edge_detect),
        .bot_right(bot_right_edge_detect),
        .RGB_Edge_Detected(RGB_Edge_Detected)
    );
    
    smooth transform_2(
            .clk(clk),
            .reset(reset),
            .RGB_Smooth(RGB_Smooth),
            .top(top_smooth),
            .bot(bot_smooth),
            .left(left_smooth),
            .right(right_smooth),
            .top_left(top_left_smooth),
            .top_right(top_right_smooth),
            .bot_left(bot_left_smooth),
            .bot_right(bot_right_smooth),
            .RGB_Smoothened(RGB_Smoothened)
        );
    
    // Set the BMP Header values.
    initial  begin 
        BMP_header[ 0] = 66;    BMP_header[28] =24; 
        BMP_header[ 1] = 77;    BMP_header[29] = 0; 
        BMP_header[ 2] = 54;    BMP_header[30] = 0; 
        BMP_header[ 3] = 0;     BMP_header[31] = 0;
        BMP_header[ 4] = 18;    BMP_header[32] = 0;
        BMP_header[ 5] = 0;     BMP_header[33] = 0; 
        BMP_header[ 6] = 0;     BMP_header[34] = 0; 
        BMP_header[ 7] = 0;     BMP_header[35] = 0; 
        BMP_header[ 8] = 0;     BMP_header[36] = 0; 
        BMP_header[ 9] = 0;     BMP_header[37] = 0; 
        BMP_header[10] = 54;    BMP_header[38] = 0; 
        BMP_header[11] = 0;     BMP_header[39] = 0; 
        BMP_header[12] = 0;     BMP_header[40] = 0; 
        BMP_header[13] = 0;     BMP_header[41] = 0; 
        BMP_header[14] = 40;    BMP_header[42] = 0; 
        BMP_header[15] = 0;     BMP_header[43] = 0; 
        BMP_header[16] = 0;     BMP_header[44] = 0; 
        BMP_header[17] = 0;     BMP_header[45] = 0; 
        BMP_header[18] = 0;     BMP_header[46] = 0; 
        BMP_header[19] = 3;     BMP_header[47] = 0;
        BMP_header[20] = 0;     BMP_header[48] = 0;
        BMP_header[21] = 0;     BMP_header[49] = 0; 
        BMP_header[22] = 0;     BMP_header[50] = 0; 
        BMP_header[23] = 2;     BMP_header[51] = 0; 
        BMP_header[24] = 0;     BMP_header[52] = 0; 
        BMP_header[25] = 0;     BMP_header[53] = 0; 
        BMP_header[26] = 1;     BMP_header[27] = 0; 
    end
    
    // Read input values
    initial begin
      $readmemh(INFILE_EDGE, memory_storage_edge);
      $readmemh(INFILE_SMOOTH, memory_storage_smooth);
      // Open the output file
      FILE_EDGE = $fopen(OUTFILE_EDGE, "wb+");
      FILE_SMOOTH = $fopen(OUTFILE_SMOOTH, "wb+");
      $display("Files Open.");
    end
    
    // Reset all values
    initial begin 
        reset = 1;
        i = 0;
        write = 0;
        RGB_Edge = 0;
        RGB_Smooth = 0;
        read_pointer  = 0;
        write_pointer = 0;
        bot_check = 0;
        top_check = 0;
        left_check = 0;
        right_check = 0;
        #30 reset = 0; 
    end
    
    // Set clock
    initial begin 
        clk = 0;
        read = 1;
        forever #5 clk = ~clk; 
    end
    
    always @(posedge clk)begin
        if(read_pointer < TOTAL_DATA - 1)begin
            if(write)begin
            
                top_check = read_pointer < (TOTAL_DATA - WIDTH*3);
                bot_check = read_pointer > WIDTH*3;
                left_check = read_pointer %(WIDTH*3);
                right_check = read_pointer % ((WIDTH*3) -1);
                
                RGB_Smooth [7:0]     = memory_storage_smooth[read_pointer][7:0]; // blue
                RGB_Smooth [15:8]    = memory_storage_smooth[read_pointer + 1][7:0]; // green
                RGB_Smooth [23:16]   = memory_storage_smooth[read_pointer + 2][7:0]; // red
                
                RGB_Edge [7:0]     = memory_storage_edge[read_pointer][7:0]; // blue
                RGB_Edge [15:8]    = memory_storage_edge[read_pointer + 1][7:0]; // green
                RGB_Edge [23:16]   = memory_storage_edge[read_pointer + 2][7:0]; // red
                
                // Check for edges if we are at the edge then pass RGB instead as the taking the average of itself will cancel out.
                if(top_check)                   begin top_smooth       = memory_storage_smooth[read_pointer + (768*3)][7:0]; end else begin top_smooth       = RGB_Smooth [7:0]; end
                if(bot_check)                   begin bot_smooth       = memory_storage_smooth[read_pointer - (768*3)][7:0]; end else begin bot_smooth       = RGB_Smooth [7:0]; end
                if(~left_check)                 begin left_smooth      = memory_storage_smooth[read_pointer - 3][7:0];       end else begin left_smooth      = RGB_Smooth [7:0]; end
                if(~right_check)                begin right_smooth     = memory_storage_smooth[read_pointer + 3][7:0];       end else begin top_smooth       = RGB_Smooth [7:0]; end
                if(bot_check && ~left_check)    begin bot_left_smooth  = memory_storage_smooth[read_pointer - (767*3)][7:0]; end else begin bot_left_smooth  = RGB_Smooth [7:0]; end
                if(top_check && ~left_check)    begin top_left_smooth  = memory_storage_smooth[read_pointer + (767*3)][7:0]; end else begin top_left_smooth  = RGB_Smooth [7:0]; end
                if(bot_check && ~right_check)   begin bot_right_smooth = memory_storage_smooth[read_pointer - (769*3)][7:0]; end else begin bot_right_smooth = RGB_Smooth [7:0]; end
                if(top_check && ~right_check)   begin top_right_smooth = memory_storage_smooth[read_pointer + (769*3)][7:0]; end else begin top_right_smooth = RGB_Smooth [7:0]; end
               
                // Check for edges if we are at the edge then pass RGB instead as the taking the average of itself will cancel out.
                if(top_check)                   begin top_edge_detect       = memory_storage_edge[read_pointer + (768*3)][7:0]; end else begin top_edge_detect       = RGB_Edge [7:0]; end
                if(bot_check)                   begin bot_edge_detect       = memory_storage_edge[read_pointer - (768*3)][7:0]; end else begin bot_edge_detect       = RGB_Edge [7:0]; end
                if(~left_check)                 begin left_edge_detect      = memory_storage_edge[read_pointer - 3][7:0];       end else begin left_edge_detect      = RGB_Edge [7:0]; end
                if(~right_check)                begin right_edge_detect     = memory_storage_edge[read_pointer + 3][7:0];       end else begin top_edge_detect       = RGB_Edge [7:0]; end
                if(bot_check && ~left_check)    begin bot_left_edge_detect  = memory_storage_edge[read_pointer - (767*3)][7:0]; end else begin bot_left_edge_detect  = RGB_Edge [7:0]; end
                if(top_check && ~left_check)    begin top_left_edge_detect  = memory_storage_edge[read_pointer + (767*3)][7:0]; end else begin top_left_edge_detect  = RGB_Edge [7:0]; end
                if(bot_check && ~right_check)   begin bot_right_edge_detect = memory_storage_edge[read_pointer - (769*3)][7:0]; end else begin bot_right_edge_detect = RGB_Edge [7:0]; end
                if(top_check && ~right_check)   begin top_right_edge_detect = memory_storage_edge[read_pointer + (769*3)][7:0]; end else begin top_right_edge_detect = RGB_Edge [7:0]; end
                
                
                read_pointer  = read_pointer + 3;
                write_pointer = read_pointer + 3;
                
            end else if(~reset) begin
            
                // SMOOTHEN INITAL VALUES
                RGB_Smooth [7:0]       = memory_storage_smooth[0][7:0]; // blue
                RGB_Smooth [15:8]      = memory_storage_smooth[0 + 1][7:0]; // green
                RGB_Smooth [23:16]     = memory_storage_smooth[0 + 2][7:0]; // red
                top_smooth             = memory_storage_smooth[0 + (768*3)][7:0];
                bot_smooth             = RGB_Smooth [7:0];
                left_smooth            = RGB_Smooth [7:0];;
                right_smooth           = memory_storage_smooth[0 + 3][7:0];
                bot_left_smooth        = RGB_Smooth [7:0];;
                top_left_smooth        = RGB_Smooth [7:0];;
                bot_right_smooth       = RGB_Smooth [7:0];;
                top_right_smooth       = memory_storage_smooth[0 + (769*3)][7:0];
                
                // EDGE DETECT INITAL VALUES
                RGB_Edge [7:0]         = memory_storage_edge[0][7:0]; // blue
                RGB_Edge [15:8]        = memory_storage_edge[0 + 1][7:0]; // green
                RGB_Edge [23:16]       = memory_storage_edge[0 + 2][7:0]; // red
                top_edge_detect        = memory_storage_edge[0 + (768*3)][7:0];
                bot_edge_detect        = RGB_Edge [7:0];
                left_edge_detect       = RGB_Edge [7:0];;
                right_edge_detect      = memory_storage_edge[0 + 3][7:0];
                bot_left_edge_detect   = RGB_Edge [7:0];;
                top_left_edge_detect   = RGB_Edge [7:0];;
                bot_right_edge_detect  = RGB_Edge [7:0];;
                top_right_edge_detect  = memory_storage_edge[0 + (769*3)][7:0];
                
                write = 1;
            end
        end
    end
    
    // Option 1) Reset all values
    // Option 2) Save all values to output file
    // Option 3) Store inverted values in out_BMP
    always @(posedge clk)begin
        // To reset all values.
        if(reset)begin
            for(i = 0; i < TOTAL_DATA; i = i + 1)begin
                out_BMP_Edge_Detected[i][7:0]= 8'b00000000;
                out_BMP_Smooth[i][7:0]= 8'b00000000;
            end
            read_pointer  = 0;
            write_pointer = 0;
            read = 1;
            write = 0;
            i = 0;
        end
        else begin
            
            // If we have enough values to fill up the file then create it and close the file.
            if(write_pointer >= TOTAL_DATA - 1)begin
            
                $display("All values set, writing to output file.");
            
                for(i=0; i<54; i=i+1)begin
                    $fwrite(FILE_EDGE, "%c", BMP_header[i][7:0]); // write the header
                    $fwrite(FILE_SMOOTH, "%c", BMP_header[i][7:0]); // write the header
                end
                
                for(i=0; i<TOTAL_DATA; i=i+1) begin
                     // write pixels in a loop
                     $fwrite(FILE_EDGE, "%c", out_BMP_Edge_Detected[i][7:0]);
                     $fwrite(FILE_SMOOTH, "%c", out_BMP_Smooth[i][7:0]);
                end
                
                $display("Closing Files.");
                // Close the output file
                $fclose(FILE_EDGE);
                $fclose(FILE_SMOOTH);
                $display("Files Closed.");
            end
            else if(read)begin
                out_BMP_Edge_Detected[write_pointer][7:0]     = RGB_Edge_Detected[7:0];
                out_BMP_Edge_Detected[write_pointer + 1][7:0] = RGB_Edge_Detected[15:8];
                out_BMP_Edge_Detected[write_pointer + 2][7:0] = RGB_Edge_Detected[23:16];
                out_BMP_Smooth[write_pointer][7:0]     = RGB_Smoothened[7:0];
                out_BMP_Smooth[write_pointer + 1][7:0] = RGB_Smoothened[15:8];
                out_BMP_Smooth[write_pointer + 2][7:0] = RGB_Smoothened[23:16];
                read = 1;
            end
            else begin
                // Do nothing
            end
        end
    end
    
endmodule