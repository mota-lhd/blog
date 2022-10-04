#!/bin/bash

echo "Linking project to billing account"
gcloud beta billing projects link $DEVSHELL_PROJECT_ID --billing-account=$BILLING_ACCOUNT

echo "Enabling various Google APIs"
gcloud services enable cloudbuild.googleapis.com

echo "Creating blog-backend-account service account"
gcloud iam service-accounts create blog-backend-account --display-name "Blog Backend Account"
gcloud iam service-accounts keys create key.json --iam-account=blog-backend-account@$DEVSHELL_PROJECT_ID.iam.gserviceaccount.com

echo "Setting blog-backend-account IAM Role"
gcloud projects add-iam-policy-binding $DEVSHELL_PROJECT_ID --member serviceAccount:blog-backend-account@$DEVSHELL_PROJECT_ID.iam.gserviceaccount.com --role roles/owner

echo "Creating Datastore / App Engine instance"
gcloud app create --region $G_REGION

echo "Creating virtual environment"
python3 -m venv venv
source venv/bin/activate

echo "Installing Python libraries"
pip install --upgrade pip
pip install -r requirements.txt

echo "Export credentials key.json"
export GOOGLE_APPLICATION_CREDENTIALS=key.json

echo "Creating Datastore entities"
python entities.py

echo "Deploying the app"
gcloud app deploy
gcloud app domain-mappings create --certificate-management=automatic backend.louhaidia.info
