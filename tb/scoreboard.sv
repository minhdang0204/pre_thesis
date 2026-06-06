class scoreboard;
    mailbox #(packet) m2s_mb;

    function new(mailbox #(packet) m2s_mb);
        this.m2s_mb = m2s_mb;
    endfunction

    task run();
        packet pkt;
        forever begin
            // 1. Nhận packet từ Monitor
            m2s_mb.get(pkt);
            
            // 2. Phân tích packet để thực hiện kiểm tra (Checker)
            // Vì Monitor đã tách riêng R/W, Scoreboard chỉ việc in ra hoặc kiểm tra giá trị
            if (pkt.hwrite) begin
                // Xử lý logic GHI: Kiểm tra xem dữ liệu ghi có hợp lệ không
                $display("[Scoreboard] CHECK: WRITE to Addr 0x%8h with Data 0x%8h", 
                         pkt.haddr, pkt.hwdata);
                
                // Ở đây bác có thể gọi hàm so sánh với model mẫu (Golden Model)
                // check_write(pkt.haddr, pkt.hwdata);
            end 
            else begin
                // Xử lý logic ĐỌC: Kiểm tra xem dữ liệu đọc về có đúng không
                $display("[Scoreboard] CHECK: READ from Addr 0x%8h | Received Data 0x%8h", 
                         pkt.haddr, pkt.hrdata);
                
            end
        end
    endtask
endclass