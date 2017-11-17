# Portworx-ready cluster for Kubernetes on Google Cloud Platform

This terraform will create a Kubernetes cluster on Google Cloud Platform and start a single node ETCD server on the Master node so that you can then install Portworx as a daemon set.

## Follow these steps
1) Install terraform
  Download the right package here: https://www.terraform.io/downloads.html
  Unzip the package and add the terraform executable to your PATH
2) Clone the github repository for terraporx into $HOME
  git clone https://github.com/portworx/terraporx.git

3) Edit the $HOME/terraporx/gcp/kubernetes_ubuntu16/vars.tf 

 * modify the project_name variable (use your GCP project-id) 
 * modify the credentials_file_path
   * first download the credentials JSON by navigating to GCP Console -> IAM & Admin -> Service Credentials  
   * pick the right credentials (most likely default) and use the menu to it's right to create a key in JSON format
   * edit the credentials_file_path to point to the dowloaded file

4) Generate an ssh key from your ~/.ssh directory
  ```shell
  $ssh-keygen 
    /* Accept all the defaults */
  ```
5) Execute the Terraform Scripts 
  ```shell
  $terraform init
  $terraform plan
  $terraform apply
  ```
6) ssh to the master host and install Portworx (should run as root)
  ```shell
  $sudo su
  $K8S_VERSION=`kubectl version --short | grep Server | awk '{print $3}'`
  $curl -o px-spec.yaml "http://install.portworx.com?cluster=mycluster&kvdb=etcd://10.128.0.2:2479&k8sVersion=$K8S_VERSION"
  $kubectl apply -f px-spec.yaml
  ```
## Validate the install

run this command from the master (as root) and look for any errors 
```shell
$kubectl logs -n kube-system -l name=portworx --tail=1000
```
ssh to one of the minion nodes and run the following status commmand:
  ```shell
  $/opt/pwx/bin/pxctl status
  ```
if all went well you should see the following:
``` shell
Status: PX is operational
License: Trial (expires in 30 days)
Node ID: mypx-k8s-2
        IP: 10.128.0.5 
        Local Storage Pool: 1 pool
        POOL    IO_PRIORITY     RAID_LEVEL      USABLE  USED    STATUS  ZONE    REGION
        0       MEDIUM          raid0           20 GiB  276 MiB Online  default default
        Local Storage Devices: 1 device
        Device  Path            Media Type              Size            Last-Scan
        0:1     /dev/sdb        STORAGE_MEDIUM_SSD      20 GiB          17 Nov 17 15:58 UTC
        total                   -                       20 GiB
Cluster Summary
        Cluster ID: mycluster
        Cluster UUID: 5351c426-4843-4642-b057-b7ee849ed458
        IP              ID              Used    Capacity        Status  StorageStatus
        10.128.0.4      mypx-k8s-1      0 B     20 GiB          Online  Up
        10.128.0.5      mypx-k8s-2      0 B     20 GiB          Online  Up (This node)
        10.128.0.3      mypx-k8s-0      266 MiB 20 GiB          Online  Up
Global Storage Pool
        Total Used      :  266 MiB
        Total Capacity  :  60 GiB
```
