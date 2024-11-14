USER_NAME="your-iam-username"

# Detach all managed policies
aws iam list-attached-user-policies --user-name $USER_NAME --query 'AttachedPolicies[*].PolicyArn' --output text | while read -r policy_arn; do
  aws iam detach-user-policy --user-name $USER_NAME --policy-arn $policy_arn
done

# Delete all inline policies
aws iam list-user-policies --user-name $USER_NAME --query 'PolicyNames' --output text | while read -r policy_name; do
  aws iam delete-user-policy --user-name $USER_NAME --policy-name $policy_name
done

# Delete all access keys
aws iam list-access-keys --user-name $USER_NAME --query 'AccessKeyMetadata[*].AccessKeyId' --output text | while read -r access_key_id; do
  aws iam delete-access-key --user-name $USER_NAME --access-key-id $access_key_id
done

# Delete all service-specific credentials
aws iam list-service-specific-credentials --user-name $USER_NAME --query 'ServiceSpecificCredentials[*].ServiceSpecificCredentialId' --output text | while read -r credential_id; do
  aws iam delete-service-specific-credential --user-name $USER_NAME --service-specific-credential-id $credential_id
done

# Finally, delete the user
aws iam delete-user --user-name $USER_NAME
