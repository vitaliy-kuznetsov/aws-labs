#!/bin/bash
set -ex

yum install -y amazon-ssm-agent
systemctl enable amazon-ssm-agent && systemctl start amazon-ssm-agent

ENI_CONFIG=${NODE_TYPE}-$(curl 169.254.169.254/latest/meta-data/placement/availability-zone)

/etc/eks/bootstrap.sh \
    --b64-cluster-ca '${B64_CLUSTER_CA}' \
    --apiserver-endpoint '${API_SERVER_URL}' ${bootstrap_extra_args} \
    --kubelet-extra-args '"--allowed-unsafe-sysctls=net.ipv4.*"' '${CLUSTER_NAME}'
