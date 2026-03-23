#!/bin/bash
set -e

GREEN='\033[0;32m'
NC='\033[0m'
echo -e "${GREEN}Исправляем установку MTG (добавляем hex-префикс)...${NC}"

# 1. Зачистка (удаляем того, кто "набуянил")
docker stop mtproxy &> /dev/null || true
docker rm mtproxy &> /dev/null || true

# 2. Твои параметры
SECRET="66201f1254d49da996da7be6f48bf4e9"
DOMAIN="google.com"
TAG="0830b5fd80ddc800eb4d37e0147c924d"

# 3. Запуск с правильным префиксом hex перед секретом
# Важно: mtg по умолчанию слушает внутри 8080, пробрасываем на твой 8443
docker run -d --name mtproxy \
  --restart always \
  -p 8443:8080 \
  nineseconds/mtg:latest run \
  -d $DOMAIN \
  -t $TAG \
  hex$SECRET

echo -e "${GREEN}====================================================${NC}"
echo -e "${GREEN}🚀 ТЕПЕРЬ ВСЁ ЧЕТКО!${NC}"
echo -e "Контейнер должен запуститься без ошибок."
echo -e "Проверь статус командой: docker ps"
echo -e "${GREEN}====================================================${NC}"
