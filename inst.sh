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
# Возвращаем самый надежный официальный образ (который у тебя держал 1400 онлайна)!
# Поскольку у нас теперь есть свой независимый агент (agent_install.sh),
# нам больше вообще не нужен встроенный HTTP-порт статистики в самом прокси.
# Наш агент сам лезет в сеть Докера и считает юзеров!

SECRET="66201f1254d49da996da7be6f48bf4e9"
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
echo -e "${GREEN}🚀 ГОТОВО! Прокси успешно запущен!${NC}"
echo -e "Твой секрет: $SECRET"
echo -e "Тег рекламы: $TAG"
echo -e "Порт для TG: 8443 (стандартный боевой)"
echo -e "Статистику собирает наш микро-агент на порту 8888!"
echo -e "${GREEN}====================================================${NC}"
