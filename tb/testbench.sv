`timescale 1ns/1ps

module testbench;

    import tb_pkg::*;       // environment + monitor + scoreboard + base_test
    import test_pkg::*;     // testcase

    // ---------------------------------------------------
    // DUT interface
    // ---------------------------------------------------
    dut_interface d_if();

	 // ---------------------------------------------------
    // Testcase objects
    // ---------------------------------------------------
    base_test       base;
    timer_test     timer_tc;

    // ---------------------------------------------------
    // DUT
    // ---------------------------------------------------
    top_soc u_top_soc (
        .clk            (d_if.clk),
        .rst_n          (d_if.rst_n),
        .timer_irq      (d_if.timer_irq),

        // Cập nhật map các chân xuất chuẩn AHB ra Interface (d_if)
        .htrans_out     (d_if.htrans),
        .hwrite_out     (d_if.hwrite),    
        .haddr_out      (d_if.haddr),     
        .hwdata_out     (d_if.hwdata),    
        .hrdata_out     (d_if.hrdata),    
        .hready_out     (d_if.hready)
    );

    // ---------------------------------------------------
    // Reset signal
    // ---------------------------------------------------
    initial begin
        d_if.rst_n = 0;
        #100ns;
        d_if.rst_n = 1;
    end

    // ---------------------------------------------------
    // 50 MHz pclk
    // ---------------------------------------------------
    initial begin
        d_if.clk = 0;
        forever #10 d_if.clk = ~d_if.clk;  // 50 MHz -> 20 ns period

    end

    // ---------------------------------------------------
    // Time out
    // ---------------------------------------------------
    initial begin
        #10ms;
        $display("[testbench] Time out... Seems your tb is hung!");
        $finish;
    end


    // ---------------------------------------------------
    // Initial block: create objects
    // ---------------------------------------------------
    initial begin
        // Create testcase instances
        timer_tc = new(d_if);

        // Select testcase via plusargs
        if ($test$plusargs("timer_check")) begin
            base = timer_tc;
        end else begin
            $display("[testbench] No testcase selected, defaulting to timer_check");
            base = timer_tc;
        end

        // Assign DUT interface
        base.dut_vif = d_if;

        // Run the testcase (build + run environment)
        base.build();
        base.run();
    end

endmodule