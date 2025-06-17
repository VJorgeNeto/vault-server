#!/bin/bash

# CONFIGURAÇÕES
IP_VAULT="" # Defina o IP do Vault aqui, por exemplo: "192.168.122.39"
DNS_VAULT="vault.local"
TLS_DIR="/etc/vault/tls"
VAULT_HCL="/etc/vault.d/vault.hcl"
CERT_FILE="$TLS_DIR/vault.crt"
KEY_FILE="$TLS_DIR/vault.key"
OPENSSL_CONF="/etc/ssl/vault_san.cnf"
HOSTS_FILE="/etc/hosts"

# 1. Criação do arquivo de configuração SAN para OpenSSL
echo "[req]
default_bits       = 2048
distinguished_name = req_distinguished_name
req_extensions     = v3_req
prompt             = no

[req_distinguished_name]
C  = BR
ST = Estado
L  = Cidade
O  = MinhaEmpresa
OU = TI
CN = $DNS_VAULT

[v3_req]
subjectAltName = @alt_names

[alt_names]
IP.1 = $IP_VAULT
DNS.1 = $DNS_VAULT" > "$OPENSSL_CONF"

echo "✅ Arquivo SAN gerado: $OPENSSL_CONF"

# 2. Criar diretório TLS e gerar certificado
mkdir -p "$TLS_DIR"

openssl req -x509 -nodes -days 365 \
  -newkey rsa:2048 \
  -keyout "$KEY_FILE" \
  -out "$CERT_FILE" \
  -config "$OPENSSL_CONF" \
  -extensions v3_req

echo "✅ Certificado TLS gerado em: $CERT_FILE"
echo "✅ Chave privada gerada em: $KEY_FILE"

# 3. Ajustar permissões
chown -R vault:vault "$TLS_DIR"
chmod 640 "$KEY_FILE"
chmod 644 "$CERT_FILE"

echo "✅ Permissões ajustadas"

# 4. Atualizar vault.hcl
echo "🔄 Atualizando arquivo de configuração do Vault"
cp "$VAULT_HCL" "${VAULT_HCL}.bak.$(date +%s)"

# Remove possíveis blocos anteriores de listener
sed -i '/listener "tcp"/,+10d' "$VAULT_HCL"

cat <<EOF >> "$VAULT_HCL"

listener "tcp" {
  address       = "0.0.0.0:8200"
  tls_cert_file = "$CERT_FILE"
  tls_key_file  = "$KEY_FILE"
}
EOF

echo "✅ vault.hcl atualizado com listener TLS"

# 5. Adicionar entrada no /etc/hosts se não existir
if ! grep -q "$DNS_VAULT" "$HOSTS_FILE"; then
  echo "$IP_VAULT $DNS_VAULT" >> "$HOSTS_FILE"
  echo "✅ Entrada adicionada ao /etc/hosts: $IP_VAULT $DNS_VAULT"
else
  echo "ℹ️ Entrada DNS já existe no /etc/hosts"
fi

# 6. Reiniciar Vault
echo "🔁 Reiniciando Vault..."
systemctl restart vault

sleep 2
systemctl status vault --no-pager

echo "🎉 Finalizado! Teste com:"
echo "    vault status -address=https://$DNS_VAULT:8200"
