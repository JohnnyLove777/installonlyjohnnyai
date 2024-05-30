#!/bin/bash

# Função para solicitar informações ao usuário e armazená-las em variáveis
function solicitar_informacoes {

    # Loop para solicitar e verificar o dominio
    while true; do
        read -p "Digite o domínio (por exemplo, johnny.com.br): " DOMINIO
        # Verifica se o subdomínio tem um formato válido
        if [[ $DOMINIO =~ ^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
            break
        else
            echo "Por favor, insira um domínio válido no formato, por exemplo 'johnny.com.br'."
        fi
    done    

    # Loop para solicitar e verificar o e-mail
    while true; do
        read -p "Digite o e-mail para cadastro do Certbot (sem espaços): " EMAIL
        # Verifica se o e-mail tem o formato correto e não contém espaços
        if [[ $EMAIL =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
            break
        else
            echo "Por favor, insira um endereço de e-mail válido sem espaços."
        fi
    done

    # Loop para solicitar e verificar o IP da VPS
    while true; do
        read -p "Digite o IP da VPS: " IP_VPS
        # Verifica se o IP tem um formato válido
        if [[ $IP_VPS =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
            break
        else
            echo "Por favor, insira um IP válido."
        fi
    done

    # Armazena as informações inseridas pelo usuário nas variáveis globais
    EMAIL_INPUT=$EMAIL
    DOMINIO_INPUT=$DOMINIO
    IP_VPS_INPUT=$IP_VPS
}

# Função para instalar Evolution API e JohnnyZap
function instalar_evolution_api_johnnyzap {
    # Atualização e upgrade do sistema
    sudo apt update
    sudo apt upgrade -y
    sudo apt-add-repository universe

    # Instalação das dependências
    sudo apt install -y python2-minimal nodejs npm git curl apt-transport-https ca-certificates software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
    sudo apt update
    sudo apt install -y docker-ce docker-compose
    sudo apt update
    sudo apt install nginx
    sudo apt update
    sudo apt install certbot
    sudo apt install python3-certbot-nginx
    sudo apt update

    # Instalar Node.js e npm
    echo "Instalando Node.js e npm..."
    sudo apt install -y nodejs npm

    # Verificar a versão do Node.js
    echo "Verificando a versão do Node.js instalada..."
    node -v

    sudo apt install curl -y

    # Instalar PM2 globalmente
    echo "Instalando PM2..."
    sudo npm install -g pm2

    # Adiciona usuário ao grupo Docker
    sudo usermod -aG docker ${USER}

    # Solicita informações ao usuário
    solicitar_informacoes

    # Criação do arquivo johnnyzap_server_config.sh com base nas informações fornecidas
cat <<EOF > johnnyzap_server_config.sh
server {
    server_name server.$DOMINIO_INPUT;

    location / {
        proxy_pass http://127.0.0.1:3030;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOF

    # Copia os arquivos de configuração para o diretório do nginx
    sudo cp johnnyzap_server_config.sh /etc/nginx/sites-available/server

    # Cria links simbólicos para ativar os sites no nginx
    sudo ln -s /etc/nginx/sites-available/server /etc/nginx/sites-enabled

    # Solicita e instala certificados SSL usando Certbot
    sudo certbot --nginx --email $EMAIL_INPUT --redirect --agree-tos -d server.$DOMINIO_INPUT

    # Instalação do JohnnyZap
    echo "Instalando JohnnyZap..."
    cd /
    git clone https://github.com/JohnnyLove777/johnnyzap-inteligente.git
    cd johnnyzap-inteligente

    echo "Instalando dependências do JohnnyZap..."
    npm install

    echo "Instalando ffmpeg..."
    sudo apt install ffmpeg -y

    # Criação do arquivo .env com o IP da VPS
    echo "Criando arquivo .env..."
cat <<EOF > .env
IP_VPS=http://$IP_VPS_INPUT
EOF

    # Iniciando JohnnyZap com pm2
    echo "Iniciando JohnnyZap com pm2..."
    pm2 start ecosystem.config.js

    echo "JohnnyZap instalado e configurado com sucesso!"
}

# Chamada das funções
instalar_evolution_api_johnnyzap
