## Connect local workstation to GCP 

If you have not worked with gcloud cli before to interact with GCP resources first you must intialise GCloud on your local machine. You will be prompted for account and project you wish to work with. 

Also add your account to the Application Default Credentials (ADC). This will allow Terraform to access these credentials to provision resources on GCloud.

    gcloud init
    gcloud auth application-default login

## Create GKE cluster

Update `terraform.tfvars` with your project_id. Specify number of nodes to be 1 (this is to avoid regional quota restrictiction present in GCP).

    sed -i -e 's/REPLACE_ME/<your_project_id>/g' terraform.tfvars

Create GKE cluster using Terraform.

    terraform init
    terraform apply -auto-approve