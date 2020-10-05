### Deploy vault cluster
Add vaule to terraform.tfvars for `existing_kms`. If no exisitng kms resouce exists, set to `false`. However once this resouce is created it cannot be deleted. So if you destroy then reapply you must update this variables to `true`.

    terraform init
    terraform apply -auto-approve

### Vault Auto Unseal

Configure kubectl

    gcloud container clusters get-credentials $(terraform output gke_cluster_name) --region $(terraform output region)

Initialize the Vault on pod 1

    kubectl exec -it vault-0 -- vault operator init -recovery-shares=1 -recovery-threshold=1 | grep "Initial Root Token:" | awk 'NR==1 {print $NF}'
    export VAULT_TOKEN=<root_token> # From command above

Add Vault pod 2 to the raft cluster
    
    kubectl exec -it vault-1 -- vault operator raft join "http://vault-0.vault-internal:8200"

Add Vault pod 3 to the raft cluster
    
    kubectl exec -it vault-2 -- vault operator raft join "http://vault-0.vault-internal:8200"

### Connect to Vault Cluster

Connect to Vault cluster from local machine

    export VAULT_ADDR=$(terraform output vault_lb_endpoint)

Test connection

    vault secrets list