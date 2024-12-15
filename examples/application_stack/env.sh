#!/bin/sh

# env.sh

# Change the contents of this output to get the environment variables
# of interest. The output must be valid JSON, with strings for both
# keys and values.
cat <<EOF
{
"os_endpoint_type": "$OS_ENDPOINT_TYPE",
"os_region_name": "$OS_REGION_NAME",
"os_interface": "$OS_INTERFACE",
"os_auth_plugin": "$OS_AUTH_PLUGIN",
"os_auth_url": "$OS_AUTH_URL",
"os_project_domain_name": "$OS_PROJECT_DOMAIN_NAME",
"os_tenant_name": "$OS_TENANT_NAME",
"os_username": "$OS_USERNAME",
"os_user_domain_name": "$OS_USER_DOMAIN_NAME",
"os_project_name": "$OS_PROJECT_NAME",
"os_mistral_endpoint_type": "$OS_MISTRAL_ENDPOINT_TYPE",
"os_password": "$OS_PASSWORD",
"os_manila_endpoint_type": "$OS_MANILA_ENDPOINT_TYPE",
"os_identity_api_version": "$OS_IDENTITY_API_VERSION"
}
EOF


