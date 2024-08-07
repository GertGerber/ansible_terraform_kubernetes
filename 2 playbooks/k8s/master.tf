resource "proxmox_vm_qemu" "test-clone" {
  name        = "VM-test"
  desc        = "Clone demo"
  target_node = "proxmox"
  
  ### or for a Clone VM operation
  clone = "ubuntu-noble-template-nvidia-runtime"
  cores = 2
  sockets = 4
}