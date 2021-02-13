#!/bin/bash
systemctl unmask docker
systemctl start docker
systemctl start kubelet
# Run kubeadm
kubeadm join ${ip_address}:6443 \
--token ${token} \
--discovery-token-unsafe-skip-ca-verification \
--node-name ${clustername}-worker-${count_index}
systemctl enable docker kubelet
# Indicate completion of bootstrapping on this node
touch /home/ubuntu/done