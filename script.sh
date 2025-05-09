#!/bin/bash

set -uo pipefail  # remove 'set -e' para permitir que o script continue em outros erros

echo '================================Atualizando Kernel====================================='
sudo apt update
sudo apt install -y --install-recommends linux-generic-hwe-20.04
sudo apt install -y network-manager
sudo apt install -y netplan
sudo apt install -y mtr
sudo apt install -y nmtui
sudo apt install -y nload
sudo apt install -y net-tools
sudo systemctl daemon-reload

echo "==================== Parando serviços relacionados ao Kaspersky ===================="

# Tenta parar os serviços se estiverem carregados
sudo systemctl stop klnagent64 2>/dev/null || echo "Serviço klnagent64 não encontrado ou já parado."
sudo systemctl stop kesl 2>/dev/null || echo "Serviço kesl não encontrado ou já parado."

echo "==================== Removendo pacotes ===================="

# Remove o pacote via dpkg ou apt
if dpkg -l | grep -q klnagent64; then
  sudo apt remove -y klnagent64 || sudo dpkg --purge klnagent64
else
  echo "Pacote klnagent64 não está instalado."
fi

echo "==================== Removendo diretórios residuais ===================="

sudo rm -rf /opt/kaspersky
sudo rm -rf /var/opt/kaspersky
sudo rm -rf /etc/opt/kaspersky
sudo rm -rf /var/log/kaspersky

echo "==================== Remoção completa ===================="




echo "==================== Excluindo .deb anterior ===================="

DEB_FILE="/tmp/klnagent64_13.2.2-1263_amd64.deb"

sudo rm -rf "$DEB_FILE"

echo '===============================Instalando Kaspersky===================================='


DOWNLOAD_URL="https://downloads.hsprevent.com.br/klnagent64_13.2.2-1263_amd64.deb"

# Baixar apenas se o arquivo não existir
if [ -f "$DEB_FILE" ]; then
  echo "Arquivo .deb já existe: $DEB_FILE. Pulando o download."
else
  echo "Baixando arquivo .deb para /tmp..."
  wget -O "$DEB_FILE" "$DOWNLOAD_URL"
fi

# Instala o pacote fora do tmux
chmod +x "$DEB_FILE"
echo "Instalando pacote $DEB_FILE..."
if ! sudo dpkg -i "$DEB_FILE"; then
  echo "Erro ao instalar o pacote .deb. Encerrando script."
  exit 1
fi

# Executa o restante da configuração em tmux
SESSION_NAME="kaspersky"

# Encerra a sessão tmux existente, se houver
if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
  echo "Sessão tmux '$SESSION_NAME' já existe. Encerrando..."
  tmux kill-session -t "$SESSION_NAME"
fi

tmux new-session -d -s $SESSION_NAME

tmux send-keys -t $SESSION_NAME "cd /opt/kaspersky/klnagent64/lib/bin/setup" Enter
sleep 2
tmux send-keys "./postinstall.pl" Enter
sleep 2
tmux send-keys C-c
sleep 2
tmux send-keys y
sleep 2
tmux send-keys Enter
sleep 2
tmux send-keys 172.40.0.3
sleep 2
tmux send-keys Enter
sleep 2
tmux send-keys 14000
sleep 2
tmux send-keys Enter
sleep 2
tmux send-keys 13000
sleep 2
tmux send-keys Enter
sleep 2
tmux send-keys y
sleep 2
tmux send-keys Enter
sleep 2
tmux send-keys 2
sleep 2
tmux send-keys Enter
sleep 2
tmux send-keys "cd /opt/kaspersky/klnagent64/bin" Enter
sleep 2
tmux send-keys "./klmover -address 172.40.0.3" Enter
sleep 2
sudo systemctl restart klnagent64
sleep 2
sudo systemctl status klnagent64 --no-pager

# Limpa o arquivo .deb após instalação
echo "Removendo arquivo .deb: $DEB_FILE"
rm -f "$DEB_FILE"

tmux kill-session -t kaspersky

echo '===============================Kaspersky finalizado===================================='
sleep 3
