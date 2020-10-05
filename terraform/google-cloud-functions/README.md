### Configure Vault Cluster and Deploy Cloud Function

We must set additional enviornment variable to be provided the Cloud Function. We do not have access to the vaule of $VAULT_ADDR in our terraform configuration, so we must create an additiona variable prefixed with TF_VAR that we can access.
    
    export TF_VAR_VAULT_ADDR=$VAULT_ADDR

Then we can apply our configuration.
    
    terraform init
    terraform apply -auto-approve

Invoke the cloud function:

    gcloud functions call apikey