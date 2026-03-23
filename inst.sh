#!/bin/bash
set -e

GREEN='\033[0;32m'
NC='\033[0m'
echo -e "${GREEN}Начинаем установку MTG Proxy (Google + Promo Tag)...${NC}"

# 1. Зачистка
docker stop mtproxy &> /dev/null || true
docker rm mtproxy &> /dev/null || true

# 2. Твои параметры
SECRET="66201f1254d49da996da7be6f48bf4e9"
DOMAIN="google.com"
TAG="0830b5fd80ddc800eb4d37e0147c924d"

# 3. Запуск контейнера mtg с тегом (-t)
# Теперь прокси будет показывать твой канал пользователям
docker run -d --name mtproxy \
  --restart always \
  -p 8443:8080 \
  nineseconds/mtg:latest run \
  -d $DOMAIN \
  -t $TAG \
  $SECRET

echo -e "${GREEN}====================================================${NC}"
echo -e "${GREEN}🚀 ВСЁ ГОТОВО! Прокси работает с твоим тегом!${NC}"
echo -e "Маскировка: $DOMAIN"
echo -e "Промо-тег: $TAG"
echo -e "Порт: 8443"
echo -e "${GREEN}====================================================${NC}"
