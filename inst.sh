#!/bin/bash
set -e

GREEN='\033[0;32m'
NC='\033[0m'
echo -e "${GREEN}Начинаем массовое обновление MTG v2 (Google TLS + Firewall)...${NC}"

# 1. Настройка фаервола (UFW)
echo -e "${GREEN}=> Настраиваем порты...${NC}"
if command -v ufw &> /dev/null; then
    sudo ufw allow 8443/tcp
    sudo ufw allow 8080/tcp
    sudo ufw reload
    echo -e "${GREEN}Порты 8443 и 8080 открыты в UFW.${NC}"
else
    echo -e "${GREEN}UFW не найден, пропускаем настройку фаервола...${NC}"
fi

# 2. Твои данные
RAW_SECRET="66201f1254d49da996da7be6f48bf4e9"
DOMAIN_HEX="7275747562652e7275" # rutube.ru
FULL_SECRET="ee${RAW_SECRET}${DOMAIN_HEX}"
CONF_PATH="/tmp/mtg.toml"

# 3. Создаем чистый конфиг без рекламы (v2 style)
cat <<EOF > $CONF_PATH
secret = "$FULL_SECRET"
bind-to = "0.0.0.0:8080"
EOF

# 4. Зачистка и запуск
echo -e "${GREEN}=> Перезапуск контейнера...${NC}"
docker stop mtproxy &> /dev/null || true
docker rm mtproxy &> /dev/null || true

docker run -d --name mtproxy \
  --restart always \
  -p 8443:8080 \
  -v $CONF_PATH:/config.toml \
  nineseconds/mtg:latest run /config.toml

echo -e "${GREEN}====================================================${NC}"
echo -e "🚀 НОДА ОБНОВЛЕНА И ЗАПУЩЕНА!"
echo -e "Проверь статус: docker ps"
echo -e "====================================================${NC}"
