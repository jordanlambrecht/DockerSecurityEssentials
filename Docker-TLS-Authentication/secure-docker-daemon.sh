set -eu

# Navigate to the home directory and create a .docker directory if it doesn't exist
cd ~
echo "👋 You are now in $PWD"

if [ ! -d ".docker/" ]; then
    echo "🚫 Directory .docker/ does not exist"
    echo "📂 Creating the directory"
    mkdir .docker
fi

cd .docker/
echo "🔒 Type in your certificate password (characters are not echoed)"
read -p '>' -s PASSWORD
echo ""

echo "💻 Type in the IP address you’ll use to connect to the Docker server, i.e., 192.168.1.69"
read -p '>' IP_ADDRESS

echo "🗺️ Type in the DNS name for the server certificate (e.g., example.com or example.local, press Enter for none):"
read -p '>' DNS_NAME

# Generate the CA key and certificate
openssl genrsa -aes256 -passout pass:$PASSWORD -out ca-key.pem 2048
openssl req -new -x509 -days 365 -key ca-key.pem -passin pass:$PASSWORD -sha256 -out ca.pem -subj "/C=US/ST=State/L=City/O=Organization/CN=$DNS_NAME"

# Generate the server key
openssl genrsa -out server-key.pem 2048

# Generate a certificate signing request (CSR) for the server key
openssl req -new -key server-key.pem -subj "/CN=$DNS_NAME" -out server.csr

# Create a configuration file for server certificate SANs
if [[ -n "$DNS_NAME" ]]; then
    echo "subjectAltName = DNS:$DNS_NAME,IP:$IP_ADDRESS" > server-ext.cnf
else
    echo "subjectAltName = IP:$IP_ADDRESS" > server-ext.cnf
fi

# Sign the server key, generating the server certificate with SAN
openssl x509 -req -days 365 -in server.csr -CA ca.pem -CAkey ca-key.pem -passin "pass:$PASSWORD" -CAcreateserial -out server-cert.pem -extfile server-ext.cnf

# Generate a client key
openssl genrsa -out key.pem 2048

# Generate a CSR for the client key
openssl req -subj '/CN=client' -new -key key.pem -out client.csr

# Create an extensions config file for client authentication
echo "extendedKeyUsage = clientAuth" > client-ext.cnf

# Sign the client key, generating the client certificate
openssl x509 -req -days 365 -in client.csr -CA ca.pem -CAkey ca-key.pem -passin "pass:$PASSWORD" -CAcreateserial -out cert.pem -extfile client-ext.cnf

# Clean up unnecessary files
echo "♻️ Removing unnecessary files i.e., ca.srl client.csr server.csr server-ext.cnf client-ext.cnf"
rm -f ca.srl client.csr server.csr server-ext.cnf client-ext.cnf

echo "🤝 Changing the permissions to read-only by root for the server files."
chmod 0400 ca-key.pem key.pem server-key.pem

echo "🤝 Changing the permissions of the certificates to read-only by everyone."
chmod 0444 ca.pem server-cert.pem cert.pem

echo "✅ Certificate setup complete."
