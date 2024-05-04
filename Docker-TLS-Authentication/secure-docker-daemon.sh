set -eu

# Navigate to the home directory and create a .docker directory if it doesn't exist
cd ~
echo "You are now in $PWD"

if [ ! -d ".docker/" ]; then
    echo "Directory .docker/ does not exist."
    echo "Creating the directory."
    mkdir .docker
fi

cd .docker/
echo "Type in your certificate password (characters are not echoed):"
read -p '>' -s PASSWORD
echo ""

echo "Type in the server name you’ll use to connect to the Docker server:"
read -p '>' SERVER

# Generate the CA key and certificate
openssl genrsa -aes256 -passout pass:$PASSWORD -out ca-key.pem 2048
openssl req -new -x509 -days 365 -key ca-key.pem -passin pass:$PASSWORD -sha256 -out ca.pem -subj "/C=US/ST=State/L=City/O=Organization/CN=$SERVER"

# Generate the server key and CSR
openssl genrsa -out server-key.pem 2048
openssl req -new -key server-key.pem -subj "/CN=$SERVER" -out server.csr

# Create a configuration file for server certificate SANs
echo "subjectAltName = DNS:$SERVER,IP:192.168.1.75" > server-ext.cnf

# Sign the server key, generating the server certificate with SAN
openssl x509 -req -days 365 -in server.csr -CA ca.pem -CAkey ca-key.pem -passin "pass:$PASSWORD" -CAcreateserial -out server-cert.pem -extfile server-ext.cnf

# Generate the client key and CSR
openssl genrsa -out key.pem 2048
openssl req -subj '/CN=client' -new -key key.pem -out client.csr

# Create a configuration file for client certificate extensions
echo "extendedKeyUsage = clientAuth" > client-ext.cnf

# Sign the client key, generating the client certificate
openssl x509 -req -days 365 -in client.csr -CA ca.pem -
