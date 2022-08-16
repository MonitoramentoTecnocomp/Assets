#!/bin/bash
clear

# Script de instalação limpa do Zabbix Agent2 6.0 LTS
# Versão para CentOS 7

# Verificação de super usuário
if [ "$EUID" -ne 0 ]
  then echo "Por favor, inicie o script como super usuário (SUDO)"
  exit
fi

# Limpeza dos arquivos antigos
yum autoremove zabbix-agent zabbix-agent2 -y
rm -dfvr /etc/zabbix
rm -dfvr /var/logs/zabbix

# Instalação das dependencias
rpm -Uvh https://repo.zabbix.com/zabbix/6.0/rhel/7/x86_64/zabbix-release-6.0-2.el7.noarch.rpm
yum clean all

# Instalação e configuração do Agent2
yum install zabbix-agent2 -y

# Configuração do Agent2
rm /etc/zabbix/zabbix_agent2.conf
{
    echo 'PidFile=/var/run/zabbix/zabbix_agent2.pid'
    echo 'LogFile=/var/log/zabbix/zabbix_agent2.log'
    echo 'LogFileSize=0'
    echo 'Server=10.10.1.211'
    echo 'ServerActive=10.10.1.211'
    echo 'Include=/etc/zabbix/zabbix_agent2.d/*.conf'
    echo 'ControlSocket=/tmp/agent.sock'
    echo 'Include=./zabbix_agent2.d/plugins.d/*.conf'
} >> /etc/zabbix/zabbix_agent2.conf

# Habilitar inicialização automática
systemctl enable zabbix-agent2.service

# Reiniciar o Agent
systemctl restart zabbix-agent2.service
