# Portworx-ready cluster for Google Cloud Platform

This terraform will create a Portworx-ready cluster on Google Cloud Platform on Ubuntu 16.04.

## Follow these steps
1) Install terraform
  Download the right package here: https://www.terraform.io/downloads.html
  Unzip the package and add the terraform executable to your PATH
2) Clone the github repository for terraporx into $HOME
  git clone https://github.com/portworx/terraporx.git

3) Edit the $HOME/terraporx/gcp/ubuntu_1604/vars.tf 

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
