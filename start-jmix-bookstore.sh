#!/bin/bash

SSH_KEY_PATH="$HOME/.ssh/id_ed25519"
NETWORK_NAME="network_test"
SUBNET_NAME="subnet_test"
VM_NAME="vm_test2"
ZONE="ru-central1-a"

yc vpc network create --name "$NETWORK_NAME"

# Создание облачной подсети
echo "Создание облачной подсети..."
yc vpc subnet create --name "$SUBNET_NAME" \
    --range "192.168.10.0/24" \
    --network-name "$NETWORK_NAME" \
    --zone "$ZONE"

mkdir -p "$HOME/.ssh"
ssh-keygen -t ed25519 -f "$SSH_KEY_PATH" -N ""
chmod 400 "$SSH_KEY_PATH"
PUBLIC_KEY_PATH="${SSH_KEY_PATH}.pub"

# Создание виртуальной машины
echo "Создание виртуальной машины..."
yc compute instance create "$VM_NAME" \
    --zone "$ZONE" \
    --platform standard-v3 \
    --cores 2 \
    --memory 4GB \
    --create-boot-disk size=20,image-folder-id=standard-images,image-family=ubuntu-24-04-lts \
    --network-interface subnet-name="$SUBNET_NAME",nat-ip-version=ipv4 \
    --ssh-key "$PUBLIC_KEY_PATH"

sleep 10
VM_IP=$(yc compute instance get $VM_NAME --jq .network_interfaces[0].primary_v4_address.one_to_one_nat.address)
ssh -i "$SSH_KEY_PATH" -o StrictHostKeyChecking=no  "yc-user@$VM_IP" << 'EOF'

sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io
sudo docker run -d --name jmix-bookstore -p 8080:8080 jmix/jmix-bookstore
EOF

echo "ssh -i $SSH_KEY_PATH yc-user@$VM_IP"
echo "http://$VM_IP:8080"