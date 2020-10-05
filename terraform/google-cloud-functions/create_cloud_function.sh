#!/bin/bash

gcloud iam service-accounts create vault-verifier

gcloud projects add-iam-policy-binding ${GOOGLE_CLOUD_PROJECT} \
    --member=serviceAccount:vault-verifier@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com \
    --role=roles/iam.serviceAccountUser

vault secrets enable -path=secret kv
vault write secret/apikeys/twitter value=abcd1234

vault auth enable \
    -default-lease-ttl=1m \
    -max-lease-ttl=10m \
    -token-type=batch \
    gcp

vault write auth/gcp/config \
    credentials="$(gcloud iam service-accounts keys create - --iam-account=vault-verifier@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com)"

vault policy write apikey-twitter -<<EOF
path "secret/apikeys/twitter" {
  capabilities = ["read"]
}
EOF

gcloud iam service-accounts create app1-vault-auther

vault write auth/gcp/role/socialmedia \
    type=iam \
    project_id=${GOOGLE_CLOUD_PROJECT} \
    policies=apikey-twitter \
    bound_service_accounts=app1-vault-auther@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com \
    max_jwt_exp=60m

gcloud beta functions deploy vault-serverless \
    --source ./python \
    --runtime python37 \
    --entry-point F \
    --service-account app1-vault-auther@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com \
    --set-env-vars VAULT_ADDR=${VAULT_ADDR} \
    --trigger-http