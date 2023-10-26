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

if command -v nginx &> /dev/null; then

    echo -e '\033[0;32mNginx instalado.\033[0m'

else

    echo -e '\033[0;33mNginx não instalado.\033[0m'

    echo ''

    sleep 1

    echo 'Instalando o Nginx...'

    sleep 1

    echo ''

    sudo apt-get update

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

    if command -v openssl &> /dev/null; then

        echo -e '\033[0;32mOpenSSL instalado.\033[0m'
    
    else

        echo -e '\033[0;33mNão foi possível instalar o OpenSSL.\033[0m'
        exit 1

    fi

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

    upstream sfbacks {
        server back-1.safefood.com:443;
        server back-2.safefood.com:443;
    }

    server {
        listen 443 ssl;
        server_name $ipv4;
        ssl_certificate /etc/nginx/ssl/$ssl_cert_name;
        ssl_certificate_key /etc/nginx/ssl/$ssl_key_name;

        location / {
            proxy_pass https://sfbacks;
        }
    }
}

" > /etc/nginx/nginx.conf

sudo systemctl reload nginx

echo "
52.70.171.147 back-1.safefood.com
52.72.247.151 back-2.safefood.com
" > "/etc/hosts"

sleep 1

echo -e '\033[0;32mLoad Balancer funcionando corretamente. :)\033[0m'
