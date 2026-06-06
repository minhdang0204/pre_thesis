class monitor;
    virtual dut_interface vif;

    mailbox #(packet) m2s_mb;

    bit [31:0] addr_reg;
    bit        write_reg;
    bit        addr_phase_active;

    function new(virtual dut_interface vif, mailbox #(packet) m2s_mb);
        this.vif    = vif;
        this.m2s_mb = m2s_mb;
        
        // Reset các giá trị ban đầu cho thanh ghi nội bộ
        this.addr_reg          = 32'b0;
        this.write_reg         = 1'b0;
        this.addr_phase_active = 1'b0;
    endfunction

    task run();
        forever begin
            @(posedge vif.clk);
            if (!vif.rst_n) begin
                addr_reg          <= 32'b0;
                write_reg         <= 1'b0;
                addr_phase_active <= 1'b0;
            end
            else begin
                // -------------------------------------------------------------
                //                          DATA PHASE 
                // -------------------------------------------------------------
                if (addr_phase_active && vif.hready) begin
                    packet pkt = new();
                    
                    pkt.timestamp = $time;
                    pkt.irq       = vif.timer_irq; 
                    pkt.htrans    = 2'b10;         
                    pkt.haddr     = addr_reg;     
                    pkt.hwrite    = write_reg;    

                    if (write_reg) begin
                        pkt.hwdata = vif.hwdata;   
                        pkt.hrdata = 32'h0;
                    end
                    else begin
                        pkt.hwdata = 32'h0;
                        pkt.hrdata = vif.hrdata;   // Bắt dữ liệu đọc từ ngoại vi trả về
                    end

                    // Tự in log nhanh tại Monitor
                    pkt.display(); 
                    
                    // Đẩy packet sang Scoreboard qua Mailbox
                    if (m2s_mb != null) begin
                        m2s_mb.put(pkt);
                    end
                    
                    // Xóa cờ sau khi kết thúc 1 transaction
                    addr_phase_active <= 1'b0; 
                end

                // -------------------------------------------------------------
                // PHA 2: ADDRESS PHASE - Bắt yêu cầu mới khi CPU phát lệnh (htrans == NONSEQ)
                // -------------------------------------------------------------
                if (vif.htrans == 2'b10 && vif.hready) begin
                    addr_reg          <= vif.haddr;  // Lưu địa chỉ bus
                    write_reg         <= vif.hwrite; // Lưu trạng thái ghi/đọc
                    addr_phase_active <= 1'b1;       // Kích hoạt cờ chờ Data Phase ở chu kỳ sau
                end
            end
        end
    endtask
endclass