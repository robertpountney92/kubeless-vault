### Deploy vault cluster
Add vaule to terraform.tfvars for `existing_kms`. If no exisitng kms resouce exists, set to `false`. However once this resouce is created it cannot be deleted. So if you destroy then reapply you must update this variables to `true`.

    terraform init
    terraform apply -auto-approve

### Vault Auto Unseal

Configure kubectl

    gcloud container clusters get-credentials $(terraform output gke_cluster_name) --region $(terraform output region)

Initialize the Vault on pod 1

    kubectl exec -it vault-0 sh
    vault operator init -recovery-shares=1 -recovery-threshold=1
    vault status
    export VAULT_TOKEN=<root_token>
    vault operator raft list-peers

    kubectl exec -it vault-0 -- vault operator init -recovery-shares=1 -recovery-threshold=1 | grep "Initial Root Token:" | awk 'NR==1 {print $NF}' > root_token


Add Vault pod 2 to the raft cluster
    
    kubectl exec -it vault-1 sh
    vault operator raft join "http://vault-0.vault-internal:8200"
    export VAULT_TOKEN=<root_token>
    vault operator raft list-peers

    kubectl exec -it vault-1 -- vault operator raft join "http://vault-0.vault-internal:8200"

Add Vault pod 3 to the raft cluster
    
    kubectl exec -it vault-2 sh
    vault operator raft join "http://vault-0.vault-internal:8200"
    export VAULT_TOKEN=<root_token>
    vault operator raft list-peers

    kubectl exec -it vault-2 -- vault operator raft join "http://vault-0.vault-internal:8200"

### Connect to Vault Cluster

Connect to Vault cluster from local machine

    export VAULT_TOKEN=$(cat root_token)
    export VAULT_ADDR=$(terraform output vault_lb_endpoint)
    vault secrets list