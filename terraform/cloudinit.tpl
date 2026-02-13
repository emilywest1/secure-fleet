#cloud-config

package_update: true
package_upgrade: true

packages:
  - containerd

runcmd:
  - swapoff -a
  - modprobe br_netfilter
  - sysctl -w net.ipv4.ip_forward=1

  - curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
  - echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' > /etc/apt/sources.list.d/kubernetes.list
  - apt update
  - apt install -y kubelet kubeadm kubectl
  - systemctl enable kubelet

  - ${join_command}
