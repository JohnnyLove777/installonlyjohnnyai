#!/bin/bash

# Função para solicitar informações ao usuário e armazená-las em variáveis
function solicitar_informacoes {    
   
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
    IP_VPS_INPUT=$IP_VPS
}

# Função para instalar JohnnyZap
function instalar_johnnyzap {
    # Atualização e upgrade do sistema
    sudo apt update
    sudo apt upgrade -y
    sudo apt-add-repository universe
    
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

    # Solicita informações ao usuário
    solicitar_informacoes    
    

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
instalar_johnnyzap