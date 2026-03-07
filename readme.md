# ToggleMaster Infrastructure — Branch `Manual`

Branch para provisionamento **local** da infraestrutura do ToggleMaster, sem depender de pipeline CI/CD.
A branch `main` possui CI/CD automatizado; esta branch existe para quem precisa subir o ambiente manualmente via CLI.

---

## Diferenças em relação à branch `main`

| Configuração | `main` (Pipeline) | `Manual` (Local) |
|---|---|---|
| **Backend** | S3 remoto | `local` |
| `deletion_protection` | `true` | `false` |
| `endpoint_public_access` | `false` | `true` |
| `endpoint_private_access` | `true` | `true` |

Como o endpoint do EKS é **público** nesta branch, não é necessário usar VPN para acessar o cluster.
Após o `terraform apply`, a VPN (Pritunl) pode ser destruída para economizar recursos.

---

## Como usar

### 1. Inicializar o Terraform

```bash
terraform init
```

### 2. Configurar Credenciais no `bootstrap.tf` (Obrigatório ⚠️)

Nesta branch, o módulo de bootstrap precisa de credenciais diretas para gerenciar recursos dentro do cluster (como Helm charts e manifestos).

Abra o arquivo `bootstrap.tf` está definido e substitua os placeholders pelas suas credenciais atuais da AWS:

```hcl
  aws_credentials = <<-EOT
[default]
aws_access_key_id=COLE_SUA_ACCESS_KEY_AQUI
aws_secret_access_key=COLE_SUA_SECRET_ACCESS_KEY
aws_session_token=COLE_SEU_SESSION_TOKEN_AQUI
  EOT
```

> ⚠️ **Atenção:** Nunca versione este arquivo com as chaves reais preenchidas em repositórios públicos.

### 3. Provisionar a infraestrutura

```bash
terraform apply
```

### 4. Configurar o `kubectl`

Como o endpoint é público, basta rodar:

```bash
aws eks update-kubeconfig --region us-east-1 --name ToggleMaster
```

Validar a conexão:

```bash
kubectl get nodes
```

### 5. Destruir a VPN (opcional — economia de recursos)

A VPN não é necessária nesta branch porque o endpoint do EKS é público.
Após confirmar que o `kubectl` está funcionando:

```bash
terraform destroy -target=module.pritunl_vpn
```

---

## Destruir toda a infraestrutura

```bash
terraform destroy
```

> Como `deletion_protection = false`, o `destroy` não será bloqueado.