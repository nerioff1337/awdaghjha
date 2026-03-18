#!/bin/bash
set -e

GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${GREEN}Начинаем установку микро-агента статистики Sana...${NC}"

# Проверяем, есть ли на сервере Python 3 (он есть почти всегда по умолчанию)
if ! command -v python3 &> /dev/null; then
    echo "Python 3 не найден. Устанавливаем..."
    apt-get update && apt-get install -y python3
fi

# 1. Создаем папку для нашего агента
mkdir -p /opt/sana_agent

# 2. Записываем сам код микро-агента (Python скрипт)
cat << 'EOF' > /opt/sana_agent/agent.py
#!/usr/bin/env python3
import subprocess
import time
from http.server import BaseHTTPRequestHandler, HTTPServer

class StatsAgent(BaseHTTPRequestHandler):
    def do_GET(self):
        try:
            # 1. Получаем нагрузки CPU в чистом Python (без сторонних либ)
            with open('/proc/stat', 'r') as f:
                cpu1 = list(map(int, f.readline().split()[1:]))
            time.sleep(0.1)
            with open('/proc/stat', 'r') as f:
                cpu2 = list(map(int, f.readline().split()[1:]))
            idle1, total1 = cpu1[3], sum(cpu1)
            idle2, total2 = cpu2[3], sum(cpu2)
            cpu_usage = int(100.0 * (1.0 - (idle2 - idle1) / (total2 - total1)))
            
            # 2. Получаем нагрузку на RAM
            with open('/proc/meminfo', 'r') as f:
                lines = f.readlines()
            total_ram = int(lines[0].split()[1])
            available_ram = int(lines[2].split()[1]) # MemAvailable
            ram_usage = int((total_ram - available_ram) / total_ram * 100)
            
            # 3. Считаем активные подключения прямо внутри сети Docker-контейнера
            # Читаем /proc/net/tcp внутри контейнера mtproxy. Состояние ' 01 ' = ESTABLISHED.
            cmd_users = "docker exec mtproxy cat /proc/net/tcp /proc/net/tcp6 2>/dev/null | grep -c ' 01 ' || true"
            users_output = subprocess.check_output(cmd_users, shell=True).decode('utf-8').strip()
            users_count = int(users_output) if users_output else 0
            
            # 4. Получаем uptime сервера
            with open('/proc/uptime', 'r') as f:
                uptime_sec = int(float(f.readline().split()[0]))
                
            response = f"total_special_connections\t{users_count}\nuptime\t{uptime_sec}\ncpu_usage\t{cpu_usage}\nram_usage\t{ram_usage}\n"
            
            self.send_response(200)
            self.send_header("Content-type", "text/plain")
            self.end_headers()
            self.wfile.write(response.encode("utf-8"))
        except Exception as e:
            self.send_response(500)
            self.end_headers()
            self.wfile.write(str(e).encode("utf-8"))
            
    # Выключаем вывод каждого HTTP-запроса в консоль, чтобы не мусорить логи
    def log_message(self, format, *args):
        pass

if __name__ == "__main__":
    server = HTTPServer(('0.0.0.0', 8888), StatsAgent)
    server.serve_forever()
EOF

chmod +x /opt/sana_agent/agent.py

# 3. Создаем системную службу (daemon) для автозапуска и работы в фоне
echo -e "${GREEN}Настраиваем системную службу (systemd)...${NC}"
cat << 'EOF' > /etc/systemd/system/sana-agent.service
[Unit]
Description=Sana Telegram Stats Agent
After=network.target

[Service]
Type=simple
User=root
ExecStart=/usr/bin/python3 /opt/sana_agent/agent.py
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# 4. Включаем и запускаем
systemctl daemon-reload
systemctl enable sana-agent
systemctl restart sana-agent

echo -e "${GREEN}================================================${NC}"
echo -e "${GREEN}✔️ Агент статистики успешно запущен в фоне!${NC}"
echo -e "Теперь сервер отдает свой онлайн на порту 8888"
echo -e "Проверь работу: curl http://127.0.0.1:8888/stats"
echo -e "${GREEN}================================================${NC}"
