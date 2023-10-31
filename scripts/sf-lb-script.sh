# Atualizando Lista de Pacotes
sudo apt-get update &&
# Instala o Docker Compose e o Git
sudo apt-get install docker-compose -y && sudo apt-get install git &&
# Clona o repositório que contém os recursos de infraestrutura da Safe Food e vai para o diretório do Docker Compose
sudo git clone https://github.com/Pesquisa-e-Inovacao-Grupo-06/safe-food-infra-resources.git && cd safe-food-infra-resources/docker-compose/for_lb &&
# Realiza a subida do Docker Compose
sudo docker-compose up