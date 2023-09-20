#!/bin/bash

if [ "$EUID" -ne 0 ]; then
    echo -e "\033[0;31m[ SafeFood ]: Para executar o script de containers, deve-se estar com o usuário root.\033[0m"
    sudo bash "$0"
    exit
fi

 echo -e '\033[0;33m   _____        __       ______              _ 
  / ____|      / _|     |  ____|            | |
 | (___   __ _| |_ ___  | |__ ___   ___   __| |
  \___ \ / _` |  _/ _ \ |  __/ _ \ / _ \ / _` |
  ____) | (_| | ||  __/ | | | (_) | (_) | (_| |
 |_____/ \__,_|_| \___| |_|  \___/ \___/ \__,_|
                                               
 \033[0m'

 echo ' Saudações ao Script de Subida de Containers'

 echo ''
 sleep 1
 echo 'Verificando se o Docker está instalado...'
 sleep 1
 echo ''

if command -v docker &> /dev/null; then

    echo -e '\033[0;32mDocker instalado.\033[0m'

else

    echo -e '\033[0;33mDocker não instalado.\033[0m'

    echo ''

    sleep 1

    echo 'Instalando o Docker...'

    sleep 1

    echo ''

    sudo apt-get install ca-certificates curl gnupg

    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg

    echo \
    "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    sudo apt-get update

    echo "Y" | sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    service docker start

    if command -v docker &> /dev/null; then
        echo ''
        echo -e '\033[0;32mDocker instalado.\033[0m'
	sudo usermod -a -G docker ec2-user
    else
        echo -e '\033[0;33mNão foi possível instalar o Docker.\033[0m'
        exit 1
    fi

fi

if command -v nginx &> /dev/null; then

    echo -e '\033[0;32mNginx instalado.\033[0m'

else

    echo -e '\033[0;33mNginx não instalado.\033[0m'

    echo ''

    sleep 1

    echo 'Instalando o Nginx...'

    sleep 1

    echo ''

    sudo apt install nginx -y

    sudo systemctl start nginx

    if command -v nginx &> /dev/null; then

        echo -e '\033[0;32mNginx instalado.\033[0m'
    
    else

        echo -e '\033[0;33mNão foi possível instalar o Nginx.\033[0m'
        exit 1

    fi

fi

ipv4=$(curl http://checkip.amazonaws.com/)

echo "

user root;

events {

}

http {
    # Configuração específica para HTTP
    server {
        listen 80;
        server_name $ipv4;

        location / {
            proxy_pass http://localhost:8080;
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        }
    }
}

" > /etc/nginx/nginx.conf

sudo systemctl reload nginx

echo ''

sudo docker run -it -p 8080:80 viniciussoares18/safe-food-be-container-image:prod