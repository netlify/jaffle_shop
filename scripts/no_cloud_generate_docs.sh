#!/bin/bash

# NOTE: the following environment variables need to be set before running this:
# DBT_ARTIFACT_STATE_PATH - The path to store the index.html in
# DBT_SUB_DIR - The subdirectory of your dbt project from the repo root. Leave blank if your dbt project is at the top

if [ -z "$DBT_ARTIFACT_STATE_PATH" ]; then
    echo "Required environment variables are missing"
    exit 1
fi

# Constants
ROOT_DIR=$(git rev-parse --show-toplevel)/
ARTIFACT_PATH=$ROOT_DIR$DBT_SUB_DIR$DBT_ARTIFACT_STATE_PATH

mkdir -p $ARTIFACT_PATH

# Run dbt docs generate
dbt docs generate

# Copy over required files for SSO auth
cp ${DBT_SUB_DIR}docs/* $ARTIFACT_PATH/.
