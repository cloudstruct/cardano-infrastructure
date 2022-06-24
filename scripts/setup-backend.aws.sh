#!/usr/bin/env bash
set -e

##################################################
# This setup script will parse your cardano-infrastructure repo config.yaml
# and setup an AWS Object storage backend for your Terraform state based on
# the config options defined.
#
##################################################

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)

# Capture original arguments
POSITIONAL_ARGS=()

arch=$(uname -i)
[[ "$arch" == "x86_64" ]] && download_arch="amd64"
[[ "$arch" == "aarch64" ]] && download_arch="arm64"
[[ -z "$download_arch" ]] && echo "ERROR: Unsupported architecture '${arch}'!" && exit 1

help()
{
    echo "Usage: ./setup-aws-backend.sh
               [ -a ~/.aws/config | --aws-config ~/.aws/config ]
               [ -p MY_PROFILE    | --aws-profile MY_PROFILE ]
               [ -r us-east-2     | --region us-east-2 ]
               [ -h               | --help  ]"
    exit 2
}


install_yq()
{
  local yq_install_version="4.25.1"
  local yq_download_url="https://github.com/mikefarah/yq/releases/download/v${yq_install_version}/yq_linux_${download_arch}"
  echo "INFO: Installing 'yq' executable to /usr/local/bin/yq"
  sudo wget -qO /usr/local/bin/yq "${yq_download_url}"
  sudo chmod a+x /usr/local/bin/yq
}

# Function to check for yq executable and install if desired
check_yq()
{
  local yq_major_version_check=4
  if [[ ! $(type -P "yq") ]]; then
    read -p "INFO: 'yq' executable not found in path. Would you like to install? [Y/n] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[yY]$ ]]; then
      install_yq
    else
      echo "ERROR: 'yq' executable required in PATH." && exit 1
    fi
  else
    local yq_current_major_version=$(yq --version | awk '{ print $NF }' | cut -d'.' -f1)
    if [[ "$yq_current_major_version" -ne "$yq_major_version_check" ]]; then
      echo "ERROR: 'yq' executable major version '${yq_current_major_version}' does not match required version '${yq_major_version_check}'."
      exit 1
    fi
  fi
}

create_s3_bucket()
{
  local bucket_logging=$(yq e '.objectstorage[] | select(.terraform_state == true) | .logging' "${SCRIPT_DIR}/../config.yaml")

  # Create Terraform state logging bucket
  if [[ "$bucket_logging" == "true" ]]; then
    aws s3api create-bucket \
      --bucket "${bucket_name}-logging" \
      --acl "private"

    aws s3api put-bucket-acl \
      --bucket "${bucket_name}-logging" \
      --grant-write URI=http://acs.amazonaws.com/groups/s3/LogDelivery \
      --grant-read-acp URI=http://acs.amazonaws.com/groups/s3/LogDelivery
  fi

  # Create Terraform state bucket
  aws s3api create-bucket \
    --bucket "$bucket_name" \
    --acl "private"

  # Apply AES256 Default Encryption to bucket
  aws s3api put-bucket-encryption \
    --bucket "$bucket_name" \
    --server-side-encryption-configuration '{"Rules": [{"ApplyServerSideEncryptionByDefault": {"SSEAlgorithm": "AES256"}}]}'

  if [[ "$bucket_logging" == "true" ]]; then
    tmpfile=$(mktemp /tmp/setup-backend.aws.XXXXXX.json)
    echo '{ "LoggingEnabled": { "TargetBucket": "'"${bucket_name}"'-logging", "TargetPrefix": "logs/" } }' | jq . > "$tmpfile"

    aws s3api put-bucket-logging \
      --bucket "${bucket_name}" \
      --bucket-logging-status "file://${tmpfile}"

    rm -rf "$tmpfile"
  fi

  echo "INFO: Terraform State S3 backend bucket setup complete."
}

create_dynamodb_table()
{
  local billing_mode=$(yq e '.nosql[] | select(.terraform_state == true) | .billing_mode' "${SCRIPT_DIR}/../config.yaml")
  [[ "$billing_mode" == "null" ]] && echo "ERROR: NoSQL table must have attribute 'billing_mode' set to a valid value." && exit 1

  if [[ "$nosql_table_name" != "null" ]]; then
    (
      set +e
      local provision_table=$(
        aws dynamodb create-table \
          --table-name "$nosql_table_name" \
          --attribute-definitions AttributeName=LockID,AttributeType=S \
          --key-schema AttributeName=LockID,KeyType=HASH \
          --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 2> /dev/null
      )

      # DynamoDB create-table command is not idempotent.
      # Error code 254 is 'table already exists'.
      if [[ "$?" -ne 0 && "$?" -ne 254 ]]; then
        echo "ERROR: AWS DynamoDB create-table error '${provision_table}'."
        exit 1
      fi
      echo "INFO: DynamoDB Terraform state lock table setup complete."
    )
  fi
}

template_terraform_backend()
{
  local template_file="${SCRIPT_DIR}/templates/backend.s3.tf.tmpl"
  local output_file="${SCRIPT_DIR}/../terraform/backend.tf"

  cp "$template_file" "${output_file}"
  sed -i "s/REPLACE_REGION/${AWS_DEFAULT_REGION}/g" "$output_file"
  sed -i "s/REPLACE_BUCKET/${bucket_name}/g" "$output_file"
  [[ "$nosql_table_name" != "null" ]] && sed -i "s/#dynamodb_table = \"REPLACE_NOSQL_TABLE\"/dynamodb_table = \"${nosql_table_name}\"/g" "$output_file"
}

while [[ $# -gt 0 ]]; do
  case $1 in
    -a|--aws-config)
      AWS_CONFIG_FILE="$2"
      shift 2
      ;;
    -p|--aws-profile)
      AWS_PROFILE="$2"
      shift 2
      ;;
    -r|--region)
      AWS_DEFAULT_REGION="$2"
      shift 2
      ;;
    -h|--help)
      help
      exit 0
      ;;
    -*)
      echo "Unknown option $1"
      exit 1
      ;;
    *)
      POSITIONAL_ARGS+=("$1") # save positional arg
      shift # past argument
      ;;
  esac
done

set -- "${POSITIONAL_ARGS[@]}" # restore positional parameters

# Set default region or set region override
[[ -z "$AWS_DEFAULT_REGION" ]] && AWS_DEFAULT_REGION="us-east-2"

# Get TF S3 backend bucket name
bucket_name=$(yq -e e '.objectstorage[] | select(.terraform_state == true) | .name' "${SCRIPT_DIR}/../config.yaml")
# Ensure only single bucket exists for state
bucket_check=$(echo "${bucket_name}" | wc -l)
[[ "$bucket_check" -gt 1 ]] && "ERROR: More than one terraform_state bucket is not supported!" && exit 1

# Get TF S3 backend NoSQL table name
nosql_table_name=$(yq e '.nosql[] | select(.terraform_state == true) | .name' "${SCRIPT_DIR}/../config.yaml")
# Ensure only single table exists for state
table_check=$(echo "${nosql_table_name}" | wc -l)
[[ "$table_check" -gt 1 ]] && "ERROR: More than one terraform_state bucket is not supported!" && exit 1

echo "INFO: Starting AWS Terraform backend setup..."
check_yq
create_s3_bucket
create_dynamodb_table
template_terraform_backend
echo "INFO: Terraform statefile setup complete."
