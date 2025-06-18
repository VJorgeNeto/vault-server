# 🔐 Vault TLS Auto Config

Este script automatiza a configuração de TLS para o HashiCorp Vault, incluindo:

- Geração de certificado e chave privada com suporte a IP e DNS no SAN;
- Correção de permissões para uso pelo Vault;
- Atualização automática do arquivo `vault.hcl` com novo listener TLS;
- Inclusão do IP e hostname no `/etc/hosts`;
- Reinicialização do serviço Vault com validação.

---

## 🚀 Objetivo

Facilitar o uso do Vault com HTTPS utilizando um certificado autoassinado contendo:
- IP fixo do servidor (ex: `192.168.122.39`);
- Nome DNS (ex: `vault.local`), para permitir uso seguro com hostname.

---

## ⚙️ Requisitos

- Vault instalado como serviço (`systemd`);
- Acesso root;
- OpenSSL instalado;
- IP estático do servidor;
- Sistema baseado em Linux (testado no Ubuntu Server 24.04).

---

## 📂 Arquivos gerados

- Certificado: `/etc/vault/tls/vault.crt`
- Chave privada: `/etc/vault/tls/vault.key`
- Config SAN: `/etc/ssl/vault_san.cnf`
- Backup do `vault.hcl`: `vault.hcl.bak.TIMESTAMP`

---

## 🛠️ Como usar

1. Clone o repositório:

```bash
git clone https://github.com/seu-usuario/vault-tls-setup.git
cd vault-tls-setup

chmod +x configura_tls_vault.sh
sudo ./configura_tls_vault.sh
```

❗ Importante
O certificado é autoassinado, portanto não será confiável por navegadores ou clientes sem ignorar verificação TLS.

Para uso em produção, recomenda-se um certificado válido emitido por uma autoridade certificadora (CA).

🧰 Personalização
Você pode editar as variáveis no topo do script:

```bash
IP_VAULT="192.168.122.39"
DNS_VAULT="vault.local"
```

📜 Licença
MIT License

✍️ Autor
Desenvolvido por VJorgeNeto
