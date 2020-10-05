# serverless-vault
This repository aims to provide you with all the steps required to:

- Create a Kubernetes cluster (hosted on GKE) 
- Deploy Vault cluster onto Kuberneetes via Helm
- Deploy a serverless Google Cloud function that retrieves secrets from the Vault cluster 


## Prerequisites

- A GCP account (Either an Owner Account or a Service Account with Owner access to given project)
- A Google KMS key (See instructions below on how to create)  
- `gcloud` SDK (In order for Terraform to run operations on your behalf)
- `terraform` (Version 0.13)
- `kubectl` (Kubernetes CLI)
- `helm` (Version 3)

## Connect local workstation to GCP 

Intialise GCloud on your local machine, you will be prompted for account and project you wish to work with.

Also add your account to the Application Default Credentials (ADC). This will allow Terraform to access these credentials to provision resources on GCloud.

    gcloud init
    gcloud auth application-default login

Define environment variables

    export GOOGLE_PROJECT=<your_project_id>
    export GOOGLE_REGION=<your_region>

Optionally if you do not wish to use application-default credential (for example you are using a service account)

    export GOOGLE_CREDENTIALS=<path_to_credentials_file> 

Enable APIs for required Google Cloud services
    
    gcloud services enable \
        compute.googleapis.com \
        container.googleapis.com \
        iam.googleapis.com \
        cloudkms.googleapis.com \
        cloudfunctions.googleapis.com \
        cloudbuild.googleapis.com \
        cloudresourcemanager.googleapis.com

## Steps

1.  [create-gke-cluster](https://github.com/robertpountney92/serverless-vault/tree/master/terraform/gke-cluster/README.md)
2.  [deploy-vault-helm](https://github.com/robertpountney92/serverless-vault/tree/master/terraform/vault-helm/README.md)
3.  [deploy-cloud-function](https://github.com/robertpountney92/serverless-vault/tree/master/terraform/google-cloud-functions/README.md)