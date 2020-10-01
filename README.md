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

Optionally if you do not wish to use application-default credentials, for example you are using a service account

    export GOOGLE_CREDENTIALS=<path_to_credentials_file> 

Enable APIs for required Google Cloud services
    
    gcloud services enable \
        compute.googleapis.com \
        container.googleapis.com \
        iam.googleapis.com \
        cloudkms.googleapis.com \
        cloudfunctions.googleapis.com \
        cloudbuild.googleapis.com






## Create GCP KMS key

Note alternatively... if you do not have exiting GCP KMS key, simply uncomment `new-kms.tf` before running `terraform apply`. This will create KMS keys if they do not already exit. However once created these keys can not be delete, including via `terraform destroy`. So on susequent applies please comment back out `kms.tf`.
<!-- 
    $ gcloud kms keyrings create vault \
        --location <region>

    $ gcloud kms keys create vault-init \
        --location <region> \
        --keyring vault \
        --purpose encryption

    $ export GOOGLE_CLOUD_PROJECT="<project>"

    $ export SERVICE_ACCOUNT="vault-server@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com"

    $ gcloud iam service-accounts create vault-server \
        --display-name "vault service account"

    $ gcloud kms keys add-iam-policy-binding vault-init \
        --location <region> \
        --keyring vault \
        --member "serviceAccount:${SERVICE_ACCOUNT}" \
        --role roles/cloudkms.cryptoKeyEncrypterDecrypter

Note: may need to create a service account key also...

    gcloud iam service-accounts keys create --iam-account "vault-server@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com" credentials.json -->

## Create GKE cluster

Navigate to `/terraform` directory and update `terraform.tfvars` with your project_id. Specify number of nodes to be 1 (this is to avoid regional quota restrictiction present in GCP).

    cd /terrform
    sed -i -e 's/REPLACE_ME/<your_project_id>/g' terraform.tfvars

Create GKE cluster using Terraform. You may encounter and error and be prompted to enable Compute Engine API. In this case navigate to the link provided and click enable button. 

    terraform init
    terraform apply -auto-approve

Take note of the outputted `kubernetes_cluster_name` and `region`

Configure kubectl

    gcloud container clusters get-credentials <your_cluster_name> --region <your_region>

<!-- Deploy and access Kubernetes Dashboard

    kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0-beta8/aio/deploy/recommended.yaml -->

Run proxy server in order to naviagate to dashboard in your browser

    kubectl proxy

Then navigate to:

    http://127.0.0.1:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/

<!-- Authenticate to Kubernetes Dashboard by opening another terminal session and running the following commands to generate token

    kubectl apply -f https://raw.githubusercontent.com/hashicorp/learn-terraform-provision-eks-cluster/master/kubernetes-dashboard-admin.rbac.yaml

    kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep service-controller-token | awk '{print $1}') -->


Now you can sign into Kubernetes Dashboard using token exposed in terraform output

    terraform output -json kubernetes_dashboard_token_data | jq -r .token

### Vault Auto Unseal

Initialize the Vault on pod 1

    kubectl exec -it vault-0 sh
    vault operator init -recovery-shares=1 -recovery-threshold=1
    vault status
    export VAULT_TOKEN=<root_token>
    vault operator raft list-peers

Add Vault pod 2 and 3 to the raft cluster
    
    vault operator raft join "http://vault-0.vault-internal:8200"
    export VAULT_TOKEN=<root_token>
    vault operator raft list-peers

View Vault UI by performing the following command then navigating to `127.0.0.1:8200`

    kubectl port-forward vault-0 8200:8200
