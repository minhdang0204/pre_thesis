class packet;
    int timestamp;
    logic irq;
    
    // Thuần túy là các trường chứa dữ liệu do Monitor đẩy vào
    logic [31:0] haddr;
    logic [31:0] hwdata;
    logic [31:0] hrdata;
    logic        hwrite;
    logic [1:0]  htrans; // 2'b10: NONSEQ (Active), 2'b00: IDLE

    // Hàm hiển thị thô, Monitor nạp gì in nấy
    function void display();
        if (htrans == 2'b10) begin
            if (hwrite) begin
                $display("[%0t][Scoreboard/Monitor] Received packet: WRITE | Addr=0x%8h | WData=0x%8h | irq=%b",
                         timestamp, haddr, hwdata, irq);
            end
            else begin
                $display("[%0t][Scoreboard/Monitor] Received packet: READ  | Addr=0x%8h | RData=0x%8h | irq=%b",
                         timestamp, haddr, hrdata, irq);
            end
        end
        else begin
            $display("[%0t][Scoreboard/Monitor] Received packet: BUS IDLE | irq=%b", timestamp, irq);
        end
    endfunction
endclass