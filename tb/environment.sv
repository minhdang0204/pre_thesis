class environment;
    // Mailbox
    mailbox #(packet) m2s_mb; // Monitor đến Scoreboard

    // Component
    monitor mon;
    scoreboard scb;

    // Virtual interface
    virtual dut_interface dut_vif;

    function new(virtual dut_interface dut_vif);
        this.dut_vif = dut_vif;
    endfunction

    function void build();
        $display("%0t [Environment] Build", $time);
        m2s_mb = new();

        // Tạo Monitor & Scoreboard
        mon  = new(dut_vif, m2s_mb);
        scb  = new(m2s_mb);
    endfunction

    task run();
        fork
            mon.run();
            scb.run();
        join
    endtask
endclass