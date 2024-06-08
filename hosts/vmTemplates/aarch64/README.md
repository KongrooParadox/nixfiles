# NixOS cloud-init image to bootstrap VM

Barebones flake to generate NixOS cloud-init VM image.

Based on [flake from voidus](https://gist.github.com/voidus/1230b200043b7f815e2513663d16353b)

## Build

```shell
nix build .#image
```

## Copy image to local pool

```shell
sudo cp result/nixos.qcow2 /var/lib/libvirt/images/nixos-cloudinit.qcow2
sudo qemu-img create -b /var/lib/libvirt/images/nixos-cloudinit.qcow2 -f qcow2 -F qcow2 /var/lib/libvirt/images/nixos-cloudinit-50G.qcow2 50G
```

## Copy image to target machine

```shell
scp result/nixos.qcow2 nixos-m1s1.skynet.local:~
ssh nixos-m1s1.skynet.local 'sudo mv nixos.qcow2 /var/lib/libvirt/images/nixos-cloudinit.qcow2;sudo qemu-img create -b /var/lib/libvirt/images/nixos-cloudinit.qcow2 -f qcow2 -F qcow2 /var/lib/libvirt/images/nixos-cloudinit-50G.qcow2 50G'
```

## Create VM on libvirt host

```shell
virt-install --name=nixkube-1 \
  --ram=2048 \
  --vcpus=2 \
  --import \
  --disk path=/var/lib/libvirt/images/nixkube-1-20G.qcow2,format=qcow2 \
  --disk path=/var/lib/libvirt/images/cidata.iso,device=cdrom \
  --os-variant=nixos-unstable \
  --network bridge=virbr0,model=virtio \
  --graphics vnc,listen=0.0.0.0 \
  --noautoconsole \
  --connect local

virt-install --name=nixkube-2 \
  --memory=2048 \
  --vcpus=2 \
  --machine q35\
  --cloud-init meta-data=meta-data,user-data=user-data \
  --disk size=30,backing_store=/var/lib/libvirt/images/nixkube-2-20G.qcow2,format=qcow2 \
  --os-variant=nixos-unstable \
  --network bridge=virbr0,model=virtio \
  --graphics vnc,listen=0.0.0.0 \
  --noautoconsole \
  --connect local

virt-install --name=nixkube-1 \
  --memory=2048 \
  --vcpus=2 \
  --machine q35\
  --cloud-init meta-data=meta-data,user-data=user-data \
  --boot uefi \
  --disk size=30,backing_store=/var/lib/libvirt/images/debian-11-genericcloud-amd64.qcow2,format=qcow2 \
  --os-variant=nixos-unstable \
  --network bridge=virbr0,model=virtio \
  --graphics vnc,listen=0.0.0.0 \
  --noautoconsole \
  --connect local
```
