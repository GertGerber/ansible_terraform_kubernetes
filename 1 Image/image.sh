#! /bin/bash

VMID=8200
STORAGE=local-lvm
CLOUD_IMAGE_UR="https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
LOCAL_IMAGE="noble-server-cloudimg-amd64.img"
TEMPLATE_NAME="ubuntu-noble-template"
MEMORY=2048
CORES=2
BRIDGE="vmbr0"

set -x
# rm -f $LOCAL_IMAGE
# wget -q --show-progress $CLOUD_IMAGE_UR
qemu-img resize $LOCAL_IMAGE 8G
qm destroy $VMID
qm create $VMID --name $TEMPLATE_NAME --ostype l26 \
    --memory $MEMORY \
    --agent 1 \
    --bios ovmf --machine q35 --efidisk0 $STORAGE:0,pre-enrolled-keys=0 \
    --cpu host --cores $CORES --numa 1 \
    --vga serial0 --serial0 socket  \
    --net0 virtio,bridge=$BRIDGE,mtu=1
qm importdisk $VMID $LOCAL_IMAGE $STORAGE
qm set $VMID --scsihw virtio-scsi-pci --virtio0 $STORAGE:vm-$VMID-disk-1,discard=on
qm set $VMID --boot order=virtio0
qm set $VMID --ide2 $STORAGE:cloudinit

mkdir -p /var/lib/vz/snippets
cat << EOF | tee /var/lib/vz/snippets/ubuntu.yaml
#cloud-config
runcmd:
    - apt-get update
    - apt-get install -y qemu-guest-agent
    - systemctl enable ssh
    - systemctl start qemu-guest-agent
    - apt install libguestfs-tools -y
    - reboot
# Taken from https://forum.proxmox.com/threads/combining-custom-cloud-init-with-auto-generated.59008/page-3#post-428772
EOF

qm set $VMID --cicustom "vendor=local:snippets/ubuntu.yaml"
qm set $VMID --tags ubuntu-template,noble,cloudinit
qm set $VMID --ciuser $USER
qm set $VMID --sshkeys ~/.ssh/authorized_keys
qm set $VMID --ipconfig0 ip=dhcp
qm template $VMID