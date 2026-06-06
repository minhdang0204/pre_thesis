class timer_test extends base_test;

    function new(virtual dut_interface dut_vif);
        super.new(dut_vif);
    endfunction

    virtual task run_scenario();
        // Chờ Timer IRQ bật
        wait(dut_vif.timer_irq == 1);
        $display("[%0t] Timer IRQ triggered! irq=%b", $time, dut_vif.timer_irq);

    endtask
endclass