## Portworx-ready cluster for Kubernetes on Digital Ocean

This should "just work".
But if it loops on startup with the messages `JWS token not being created in cluster-info ConfigMap`,
then log on to the master and run the script segment from [this comment](https://github.com/kubernetes/kubeadm/issues/335#issuecomment-312932999)
