#!/bin/bash

gcloud beta functions delete vault-serverless -q

vault auth disable gcp
vault policy delete apikey-twitter
vault secrets disable secret

gcloud projects remove-iam-policy-binding ${GOOGLE_CLOUD_PROJECT} \
    --member=serviceAccount:vault-verifier@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com \
    --role=roles/iam.serviceAccountUser \
    -q
gcloud iam service-accounts delete app1-vault-auther@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com -q
gcloud iam service-accounts delete vault-verifier@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com -q
