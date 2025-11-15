# README

## Prerequisites

Before running this project, ensure the following tools and configurations are available:

1. **Installed Tools**
   - Terraform
   - Ansible
   - AWS CLI
   - bash shell

2. **AWS Requirements**
   - AWS account with permissions to create VPCs, subnets, EC2 instances, and security groups.
   - AWS credentials configured locally through:
     - `aws configure`  
       **or**  
     - Environment variables: `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_DEFAULT_REGION`. 
---

## Execution Steps

### 1. Download the repo.
### 2. Go to Part3 folder and give execution permission to the file deploy.sh
### 3. Execute the file deploy.sh, it will start automatically creating everything needed on aws, and then, setup everything with Ansible.
### 4. You might be asked for host key checking to add the db and webserver to known hosts.

## Description about the integration between Terraform and Ansible

Terraform is responsible for provisioning the AWS infrastructure, while Ansible is used to configure the servers after they are created.  
The integration between both tools is achieved through Terraform outputs and a dynamic inventory mechanism:

1. **Terraform creates the infrastructure**  
   Terraform builds the VPC, subnets, security groups, and EC2 instances. Each instance is tagged (for example: `role = "web"` and `role = "db"`).

2. **Terraform exposes connection information**  
   After applying the infrastructure, Terraform exports important details — such as public IPs of the web server(s) and private IP of the database server — using `terraform output -json`.

3. **Dynamic inventory generation for Ansible**  
   A script or plugin reads the Terraform outputs and generates an Ansible inventory file.  
   This inventory tells Ansible:
   - Which hosts belong to the *web* group  
   - Which hosts belong to the *db* group  
   - What IP address to use  
   - Which SSH user/key to use  

4. **Ansible uses the inventory to configure the EC2 servers**  
   With the dynamically generated inventory, Ansible connects to the instances and:
   - Installs required packages
   - Configures web and database services
   - Deploys the application
   - Performs optional post-deploy health checks

This creates a fully automated pipeline where **Terraform provisions** and **Ansible configures**, ensuring a clean separation of responsibilities and a reproducible infrastructure + configuration workflow.
