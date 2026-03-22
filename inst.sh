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

echo -e "${GREEN}=> Запуск стабильного официального C-Proxy...${NC}"

# Передаем ОБА секрета через запятую
# 1. Старый секрет для тех, кто на Wi-Fi
# 2. Fake TLS секрет (маскировка под rutube.ru) для мобильного интернета
SECRET="66201f1254d49da996da7be6f48bf4e9,ee66201f1254d49da996da7be6f48bf4e97275747562652e7275"
WORKERS=4
TAG="0830b5fd80ddc800eb4d37e0147c924d"

docker run -d --name mtproxy \
  --restart always \
  -p 8443:443 \
  -e SECRET="${SECRET}" \
  -e WORKERS=${WORKERS} \
  -e TAG="${TAG}" \
  telegrammessenger/proxy:latest 

echo -e "${GREEN}====================================================${NC}"
echo -e "${GREEN}🚀 ГОТОВО! Прокси успешно запущен с ДВУМЯ ключами!${NC}"
echo -e "Ключ 1 (Стандартный): 66201f1254d49da996da7be6f48bf4e9"
echo -e "Ключ 2 (Fake TLS - Rutube): ee66201f1254d49da996da7be6f48bf4e97275747562652e7275"
echo -e "Тег рекламы: $TAG"
echo -e "Порт для TG: 8443 (стандартный боевой)"
echo -e "Статистику собирает наш микро-агент на порту 8888!"
echo -e "${GREEN}====================================================${NC}"
