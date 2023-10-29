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

 backend_server="52.70.171.147"

 nc -z -w 2 $backend_server 443

 if ! [ $? -eq 0 ]; then
     echo -e "\033[0;31mO servidor do back-end precisa estar em execução para que o front-end funcione.\033[0m"
     exit
 fi

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

if commando -v openssl &> /dev/null; then

    echo -e '\033[0;32mOpenSSL instalado.\033[0m'

else

    echo -e '\033[0;33mOpenSSL não instalado.\033[0m'
    sudo apt-get install openssl
fi

sudo mkdir -p /etc/nginx/ssl/

ssl_conf_path="/etc/nginx/ssl/openssl.cnf"

echo "
[req]
default_bits = 2048
prompt = no
default_md = sha256
distinguished_name = dn

[dn]
C=BR
ST=SP
L=São Paulo
O=Safe Food
OU=Safe Food
CN=|Vinicius
emailAddress=viniciussoaresdesouza180804@gmail.com
" > $ssl_conf_path

ssl_cert_name="sf-certificate.crt"
ssl_key_name="sf-private-key.key"

sudo openssl genpkey -algorithm RSA -out $ssl_key_name

sudo openssl req -new -x509 -config $ssl_conf_path -key $ssl_key_name -out $ssl_cert_name -days 365



sudo cp $ssl_key_name /etc/nginx/ssl/
sudo cp $ssl_cert_name /etc/nginx/ssl/

ipv4=$(curl http://checkip.amazonaws.com/)

echo "

user root;

events {

}

http {
    # Configuração específica para HTTP
    server {
        listen 443 ssl;
        server_name $ipv4;
        ssl_certificate /etc/nginx/ssl/$ssl_cert_name;
        ssl_certificate_key /etc/nginx/ssl/$ssl_key_name;

        location / {
            proxy_pass http://localhost:8080;
        }
    }
}

" > /etc/nginx/nginx.conf

sudo systemctl reload nginx

echo ''

echo "
$backend_server back-lb.safefood.com
" > "/etc/hosts"

sudo docker run -it -p 8080:8080 viniciussoares18/sf-frontend:prod6
