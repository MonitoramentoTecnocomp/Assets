#!/bin/bash

## Introdução do Script
clear
echo "Instalação do Zabbix Proxy 6.0.x LTS [SQLite3 em Docker]"
echo "Desenvolvido para RHEL 8 | CentOS 8 | Oracle Linux 8 "
echo ""
echo ""

## Verificação de acesso administrativo [SUDO]
if [ "$EUID" -ne 0 ]
    then echo "Por favor, inicie o script usando um acesso administrativo!"
    exit
fi

## Preparação do ambiente docker

# Remoção opicional de arquivos antigos
echo "Fazer a instalação limpa do docker, S ou N"
read uninstallDocker
if [[ $uninstallDocker = "s" || $uninstallDocker = "S" ]] 
then 
    echo "Verificando e removendo o Docker Engine instalado\n"
    yum remove -y docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-engine

elif [[ $uninstallDocker = "n" || $uninstallDocker = "N" ]]
then 
    echo "Mantendo a instalação do Docker Engine instalado\n"
else
    clear
    echo "Opção invalida, inicie novamente o script!"
    exit
fi

# Configuração das pendencias
yum install -y yum-utils
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

# Instalação do Docker Engine
yum install docker-ce docker-ce-cli containerd.io docker-compose-plugin

## Preparação do Zabbix Proxy

# Variaveis iniciais
zabbixServer="proxy.tecnocomp.com.br"           # IP ou DNS do Zabbix Server
versionTag="6.0-centos-latest"                  # Define a variável de versão utilizada (Padrão: 6.0 CentOS Latest)

echo "Zabbix Server: $zabbixServer \n"
echo "Digite o Proxy Name da maquina: "
read proxyName

# Diretório padrão na maquina host
mkdir /etc/zabbix/

# Instalação do Zabbix Agent2 (Opcional, o Proxy pode monitorar suas funções básicas)
docker run --name ZabbixAgent2 \                # Nome do Container
           --privileged \                       # Garantia de privilegios na maquina
           -e ZBX_HOSTNAME="$proxyName" \       # Nome do Proxy (Definido préviamente no Front End do Zabbix)
           -e ZBX_SERVER_HOST="localhost" \     # Endereço do Zabbix Server ou Proxy (Padrão: localhost)
           -d zabbix/zabbix-agent2:$versionTag  # Imagem utilizada (Padrão: 6.0 latest centos)

# Instalação do Zabbix Agent2 (Opcional, o Proxy pode monitorar suas funções básicas)
docker run --name ZabbixProxy \                 # Nome do Container
           --privileged \                       # Garantia de privilegios na maquina
           -e ZBX_HOSTNAME="$proxyName" \       # Nome do Proxy (Definido préviamente no Front End do Zabbix)
           -e ZBX_SERVER_HOST="$zabbixServer" \ # Endereço do Zabbix Server ou Proxy (Padrão: localhost)
           -d zabbix/zabbix-agent2:$versionTag  # Imagem utilizada (Padrão: 6.0 latest centos)

