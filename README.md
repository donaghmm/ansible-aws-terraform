# Demo using Ansible Teraform and AWS for Cloud provisioning

  Ansible playbook will initially creates an image with apache and tomcat 8.
  Terraform then uses this image to launch ELB and ASG in three AZ in AWS eu-east-1 region.
  The workflow is controlled and orchestrated through Ansible

## Python requirments
  boto3
  boto

## Configuration

Before running the playbook, you need to to make changes to a few of the configuration files.

### ansible.cfg

Edit `ansible.cfg` to specify the location of your AWS private key file. Ensure key pair is created in the region. KeyPair used in the demo is aws_demo.

### group_vars/all

Edit `group_vars/all` to set the following values:

- aws_access_key: **specify AWS Access Key**
- aws_secret_key: **specify AWS Secret Key**


### inventory/hosts

Edit `inventory/hosts` to specify a custom Python path

### Terraform/terrafor.tfvars

Edit `Terraform/terrafor.tfvars` to set the following values:

  access_key = **specify AWS Access Key**
  secret_key = **specify AWS Secret Key**

## Run Playbook

To run the playbook, you only need to use a single command

```bash
$ ansible-playbook -i inventory/hosts ansible-terraform.yml
```
