This example shows how to access secrets in [HashiCorp Vault][hashicorp-vault],
and then access them inside a serverless [Google Cloud Function][gcp-func].


## Setup

If you have not previously used cloud functions or cloud storage, enable the
APIs:

  gcloud services enable \
    cloudfunctions.googleapis.com \
    iam.googleapis.com \
    cloudbuild.googleapis.com


  export GOOGLE_CLOUD_PROJECT=<your_project_id>
  export VAULT_ADDR=http://127.0.0.1:8200


## Create Vault IAM User

Vault itself needs the ability to communicate with the Google Cloud API to
validate identity. Create a dedicated service account for Vault:

  gcloud iam service-accounts create vault-verifier


Grant the service account the ability to verify other service accounts:

  gcloud projects add-iam-policy-binding ${GOOGLE_CLOUD_PROJECT} \
    --member=serviceAccount:vault-verifier@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com \
    --role=roles/iam.serviceAccountUser


<!-- This IAM user can be attached directly to the GCE/GKE instances on which Vault
is running, or it can be provided to Vault as a configuration parameter. For
simplicity, this guide supplies the credentials directly to Vault. -->


## Create secret

For the purpose of this exercise, the Cloud Function needs to access an API key for
communicating with the Twitter API.

  vault secrets enable -path secret kv
  vault write secret/apikeys/twitter value=my-twitter-api-key



## Enable Authentication

Enable Google Cloud authentication within Vault. This enables Google Cloud
entities, including Cloud Functions, to authenticaticate to Vault.

  vault auth enable \
    -default-lease-ttl=1m \
    -max-lease-ttl=10m \
    -token-type=batch \
    gcp


- `-default-lease-ttl` is set to 1 minute because that is the default function
  timeout.

- `-max-lease-ttl` is set to 10 minutes because that is the maximum allowed
  function execution time

- `-token-type` is set to batch, which allows for much more scalability than
  service tokens

Finally, configure the auth method with permission to validate other service
accounts (which is how our Cloud Function will authenticate).

  vault write auth/gcp/config \
    credentials="$(gcloud iam service-accounts keys create - --iam-account=vault-verifier@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com)"



## Create Vault Policy

Create a policy in Vault that permits retrieving the Twitter API key value
created above. Vault will assign this policy to the Cloud Function's
authentication, allowing it to retrieve the value.

  vault policy write apikey-twitter -<<EOF
path "secret/apikeys/twitter" {
  capabilities = ["read"]
}
EOF



## Create Service Account and Vault Role

Create a new service account which will be attached to the Cloud Function at
boot.

  gcloud iam service-accounts create app1-vault-auther


Create a role that permits this service account to authenticate to Vault. Upon
success, Vault will assign the policy just created to the resulting token.

  vault write auth/gcp/role/socialmedia \
    type=iam \
    project_id=${GOOGLE_CLOUD_PROJECT} \
    policies=apikey-twitter \
    bound_service_accounts=app1-vault-auther@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com \
    max_jwt_exp=60m



## Deploy


  gcloud beta functions deploy vault-batch \
    --source ./python \
    --runtime python37 \
    --entry-point F \
    --service-account app1-vault-auther@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com \
    --set-env-vars VAULT_ADDR=${VAULT_ADDR} \
    --trigger-http


## Invoke

Invoke the cloud function at its invoke endpoint:

  gcloud functions call vault-batch



