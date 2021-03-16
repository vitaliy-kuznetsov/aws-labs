[settings]

  [settings.host-containers]

    [settings.host-containers.admin]

      # Bottlerocket Admin Container
      enabled = true

  [settings.kubernetes]

    # Kubernetes Control Plane API Endpoint
    api-server = "${API_SERVER_URL}"

    # Kubernetes Cluster CA Certificate
    cluster-certificate = "${B64_CLUSTER_CA}"

    # Kubernetes Cluster Name
    cluster-name = "${CLUSTER_NAME}"