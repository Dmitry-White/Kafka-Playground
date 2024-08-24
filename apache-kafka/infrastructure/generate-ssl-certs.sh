#!/bin/sh -e

KAFKA_ADMIN_USERNAME="${KAFKA_ADMIN_USERNAME}"
KAFKA_ADMIN_PASSWORD="${KAFKA_ADMIN_PASSWORD}"
KAFKA_USERNAME="${KAFKA_USERNAME}"
KAFKA_PASSWORD="${KAFKA_PASSWORD}"
SECRETS_LOCATION="${KAFKA_SECRETS_LOCATION}"
KEY_ALIAS="${KAFKA_SSL_KEY_ALIAS}"
KEY_PASSWORD="${KAFKA_SSL_KEY_PASSWORD}"
KEY_CREDENTIALS="${KAFKA_SSL_KEY_CREDENTIALS}"
KEYSTORE_PATH="${KAFKA_SSL_KEYSTORE_LOCATION}"
KEYSTORE_PASSWORD="${KAFKA_SSL_KEYSTORE_PASSWORD}"
KEYSTORE_CREDENTIALS="${KAFKA_SSL_KEYSTORE_CREDENTIALS}"
TRUSTSTORE_PATH="${KAFKA_SSL_TRUSTSTORE_LOCATION}"
TRUSTSTORE_PASSWORD="${KAFKA_SSL_TRUSTSTORE_PASSWORD}"
TRUSTSTORE_CREDENTIALS="${KAFKA_SSL_TRUSTSTORE_CREDENTIALS}"
CERT_FILE_PATH="${KAFKA_SSL_CERT_FILE_PATH}"

prepare_secrets_directory() {
    echo "Creating a directory for secrets..."

    mkdir -p "$(dirname "$SECRETS_LOCATION")"

    echo "Directory for secrets is created."
}

create_keystore() {
    echo "Generating Keystore with a Self-Signed Certificate..."

    keytool -genkeypair \
        -alias $KEY_ALIAS \
        -keypass $KEY_PASSWORD \
        -keystore $KEYSTORE_PATH \
        -storepass $KEYSTORE_PASSWORD \
        -dname "CN=$KEY_ALIAS" \
        -storetype JKS \
        -keyalg RSA \
        -keysize 2048 \
        -validity 365

    echo "Keystore is generated at: $KEYSTORE_PATH."
}

export_certificate() {
    echo "Exporting certificate from Keystore..."

    keytool --exportcert -v \
        -alias $KEY_ALIAS \
        -keystore $KEYSTORE_PATH \
        -storepass $KEYSTORE_PASSWORD \
        -file $CERT_FILE_PATH

    echo "Certificate is exported at: $CERT_FILE_PATH."
}

create_truststore() {
    echo "Creating Truststore with the imported certificate..."

    keytool -import \
        -alias $KEY_ALIAS \
        -keystore $TRUSTSTORE_PATH \
        -storepass $TRUSTSTORE_PASSWORD \
        -file $CERT_FILE_PATH \
        -noprompt

    echo "Truststore is created at: $TRUSTSTORE_PATH."
}

create_credentials_file() {
    local path=$1
    local password=$2

    echo "Creating $path credentials file..."

    echo "$password" >$path

    echo "Credentials file created at: $path."
}

create_credentials() {
    echo "Creating credentials..."

    create_credentials_file \
        $SECRETS_LOCATION/$KEY_CREDENTIALS \
        $KEY_PASSWORD

    create_credentials_file \
        $SECRETS_LOCATION/$KEYSTORE_CREDENTIALS \
        $KEYSTORE_PASSWORD

    create_credentials_file \
        $SECRETS_LOCATION/$TRUSTSTORE_CREDENTIALS \
        $TRUSTSTORE_PASSWORD

    echo "Credentials are created."
}

cleanup_certificate() {
    echo "Deleting the certificate file..."

    rm $CERT_FILE_PATH

    echo "Certificate file is deleted at: $CERT_FILE_PATH."
}

generate_secrets() {
    echo "Generating SSL secrets..."

    prepare_secrets_directory
    create_keystore
    export_certificate
    create_truststore
    create_credentials
    cleanup_certificate

    echo "SSL secrets generated and configured."
}

# Check if keystore and truststore already exist
if [ -f "$KEYSTORE_PATH" ] && [ -f "$TRUSTSTORE_PATH" ]; then
    echo "Keystore and Truststore files already exist, skipping generation..."
else
    generate_secrets
fi
