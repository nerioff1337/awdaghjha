#!/bin/bash
set -e

# Цвета для вывода
GREEN='\033[0;32m'
NC='\033[0m'
echo -e "${GREEN}Начинаем мгновенную установку MTProto Proxy (Sana Service)...${NC}"

# 1. Установка Docker (если не установлен)
if ! command -v docker &> /dev/null; then
    echo -e "${GREEN}=> Устанавливаем Docker...${NC}"
    curl -fsSL https://get.docker.com | sh
    systemctl enable docker
    systemctl start docker
    echo -e "${GREEN}Docker успешно установлен!${NC}"
else
    echo -e "${GREEN}=> Docker уже установлен, пропускаем...${NC}"
fi

# 2. Подготовка и запуск
echo -e "${GREEN}=> Зачистка старых контейнеров (если есть)...${NC}"
docker stop mtproxy &> /dev/null || true
docker rm mtproxy &> /dev/null || true

echo -e "${GREEN}=> Запуск официального MTProto Proxy...${NC}"
# Мы используем официальный образ от Telegram, 
# потому что только он "из коробки" имеет веб-порт статистики для нашего мониторинга 
# и 100% поддерживает старых "классических" клиентов с секретом 6620...

SECRET="66201f1254d49da996da7be6f48bf4e9"
WORKERS=4

docker run -d --name mtproxy \
  --restart always --network host \
  -e SECRET="${SECRET}" \
  -e WORKERS=${WORKERS} \
  telegrammessenger/proxy:latest 

# ВАЖНО: Мы используем --network host
# Это решает проблему того, что порт статистики 2398 раньше был "заперт" внутри докера.
# Теперь прокси напрямую висит на портах твоего сервера. Можешь проверять статистику локально.

echo -e "${GREEN}====================================================${NC}"
echo -e "${GREEN}🚀 ГОТОВО! Прокси успешно запущен!${NC}"
echo -e "Твой секрет: $SECRET"
echo -e "Порт для TG: 443 (стандартный боевой)"
echo -e "Порт статистики: 2398 (работает локально)"
echo -e "Проверь стат: curl http://127.0.0.1:2398/stats"
echo -e "${GREEN}====================================================${NC}"
