#!/bin/bash

echo '================================Atualizando Kernel====================================='
sudo apt update
sudo apt install -y --install-recommends linux-generic-hwe-20.04

echo '================================Desinstalar Kaspersky ====================================='
sudo systemctl  stop kesl klnagent64

sudo apt remove -y klnagent64 kesl

sudo rm -rf /opt/kaspersky
sudo rm -rf /var/opt/kaspersky
sudo rm -rf /etc/opt/kaspersky
sudo rm -rf /var/log/kaspersky

echo '===============================Instalando Kaspersky===================================='
SESSION_NAME="kaspersky"

tmux new-session -d -s $SESSION_NAME # kaspersky

tmux send-keys -t $SESSION_NAME "chmod +x /tmp/ansible/klnagent64_13.2.2-1263_amd64.deb" Enter 
sleep 3
tmux send-keys "dpkg -i /tmp/ansible/klnagent64_13.2.2-1263_amd64.deb" Enter
sleep 10
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
	tmux kill-session -t kaspersky
	echo '===============================Kaspersky finalizado===================================='
	sleep 3
