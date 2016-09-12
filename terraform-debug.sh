#!/usr/bin/env bash


docker run \
  -t \
  -i \
  --rm \
  -e "TF_VAR_aws_access_key=${AWS_ACCESS_KEY_ID}" \
  -e "TF_VAR_aws_secret_key=${AWS_SECRET_ACCESS_KEY}" \
  -e "TF_VAR_aws_region=${AWS_DEFAULT_REGION}" \
  -e "TF_LOG=debug" \
  --workdir="/data" \
  --volume="$(pwd):/data" \
  hashicorp/terraform:0.7.3 \
  "$@"
