class base_test;
    virtual dut_interface dut_vif;
    environment env;

    function new(virtual dut_interface dut_vif);
        this.dut_vif = dut_vif;
    endfunction

    function void build();
        env = new(dut_vif);
        env.build();
    endfunction

    virtual task run_scenario(); endtask

    task run();
        fork
            env.run();
            run_scenario();
        join_any

        #100ns;
        $display("[base_test] Test completed.");
        $finish;
    endtask
endclass