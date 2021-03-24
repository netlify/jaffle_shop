#!/bin/bash

# NOTE: the following environment variables need to be set before running this:
# DBT_ARTIFACT_STATE_PATH - The path to store the index.html in
# DBT_CLOUD_API_KEY - Your dbt cloud API key
# DBT_ACCOUNT_ID - Your dbt Cloud account id
# DBT_JOB_ID - Your dbt Cloud job id

if [ -z "$DBT_ARTIFACT_STATE_PATH" -o -z "$DBT_CLOUD_API_KEY" -o -z "$DBT_ACCOUNT_ID" -o -z "$DBT_JOB_ID" -o -z "$DBT_SUB_DIR" ]; then
    echo "Required environment variables are missing"
    exit 1
fi

# Constants
ROOT_DIR=$(git rev-parse --show-toplevel)/
ARTIFACT_PATH=$ROOT_DIR$DBT_SUB_DIR$DBT_ARTIFACT_STATE_PATH

mkdir -p $ARTIFACT_PATH

# Get the latest dbt Run Id for the documentation job
{
    DBT_RUN_ID=$(curl -s --request GET \
        --url "https://cloud.getdbt.com/api/v2/accounts/${DBT_ACCOUNT_ID}/runs/?job_definition_id=${DBT_JOB_ID}&order_by=-finished_at" \
        --header "Content-Type: application/json" \
        --header "Authorization: Token ${DBT_CLOUD_API_KEY}" \
        | jq '[.data[] | select( .status_humanized == "Success" )][0].id')
} || {
    echo "Fail to get DBT_RUN_ID: Be sure to set you DBT_CLOUD_API_KEY."
    exit 1
}

# If job run was found, download the important artifacts
if [ -n "$DBT_RUN_ID" ]; then
    for ARTIFACT_NAME in {manifest.json,catalog.json,index.html,run_results.json}; do
        ARTIFACT_URL="https://cloud.getdbt.com/api/v2/accounts/$DBT_ACCOUNT_ID/runs/$DBT_RUN_ID/artifacts/$ARTIFACT_NAME"

        echo "$ARTIFACT_URL => $ARTIFACT_PATH$ARTIFACT_NAME";
        curl -s --request GET \
            --url $ARTIFACT_URL \
            --header "Content-Type: application/json" \
            --header "Authorization: Token ${DBT_CLOUD_API_KEY}" > $ARTIFACT_PATH$ARTIFACT_NAME
    done;
    else
        echo "No DBT_RUN_ID found."
        exit 1 
fi

# Copy other required files into the artifact path
cp ${DBT_SUB_DIR}docs/* $ARTIFACT_PATH/.
