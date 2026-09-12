`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.09.2026 23:18:12
// Design Name: 
// Module Name: tb_counter
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb_counter;
//оголошуємо наші сигнали
reg clk;
reg rst;
reg load;
reg [3:0] data_in;
reg en;
reg up_down;
wire [3:0] count;

counter dut(
        .clk     (clk),
        .rst     (rst),
        .load    (load),
        .data_in (data_in),
        .en      (en),
        .up_down (up_down),
        .count   (count)
    );
    initial clk = 0;
    always #5 clk = ~clk;
    
    
    task automatic check_count(input [3:0] expected, input [8*32-1:0] name);
        if (count === expected)
            $display("PASS: %0s, count = %0d", name, count);
        else
            $display("FAIL: %0s, count = %0d (expected %0d)", name, count, expected);
    endtask


    // 3 пункт задачі
     initial begin
        rst     = 1;
        load    = 0;
        data_in = 4'd0;
        en      = 0;
        up_down = 1;

        @(posedge clk); #1;
        rst = 0;

        // 2. load=1, data_in=10, чекаємо фронт такту
        load    = 1;
        data_in = 4'd10;
        @(posedge clk); #1;

        // 3. load=0
        load = 0;
        
  check_count(10, "load test");
  
// === 4. ПЕРЕВІРКА РАХУНКУ ВГОРУ, ВКЛЮЧНО З ПЕРЕХОДОМ ЧЕРЕЗ МЕЖУ ===
        en      = 1;
        up_down = 1;

        @(posedge clk); #1;
        @(posedge clk); #1;
        @(posedge clk); #1;

   check_count(13, "count up test (step 1)");
   
        @(posedge clk); #1;
        @(posedge clk); #1;
        @(posedge clk); #1;

 check_count(0, "count up test (overflow)");
 
 // === 5. ПЕРЕВІРКА УТРИМАННЯ ЗНАЧЕННЯ (EN=0) ===
        en = 0;
        // up_down лишаємо як є — не повинен впливати

        @(posedge clk); #1;
        @(posedge clk); #1;

 check_count(0, "hold test (en=0)");
 

 // === 6. ПЕРЕВІРКА РАХУНКУ ВНИЗ ІЗ ПЕРЕХОДОМ ЧЕРЕЗ МЕЖУ ===
        en      = 1;
        up_down = 0;

        @(posedge clk); #1;

        check_count(15, "count down test (underflow)");
      // === 7. ПЕРЕВІРКА ПРІОРИТЕТУ LOAD НАД EN ===
        load    = 1;
        data_in = 4'd5;
        en      = 1;
        up_down = 1;

        @(posedge clk); #1;

    check_count(5, "load priority over en");
        load = 0;
        
        $finish;
    end

endmodule
