# 🔐 Configuração de API Keys - StyleSync

## ⚠️ IMPORTANTE: Nunca commite suas API keys!

Este projeto usa APIs externas que requerem autenticação. Para proteger suas credenciais:

## 🛠️ Como Configurar

### Opção 1: Variáveis de Ambiente no Xcode (Recomendado para desenvolvimento)

1. Abra o projeto no Xcode
2. Selecione o scheme **StyleSync** no topo da janela
3. Clique em **Edit Scheme...** (ou pressione ⌘<)
4. Selecione **Run** no menu lateral esquerdo
5. Vá para a aba **Arguments**
6. Na seção **Environment Variables**, adicione:

   | Name | Value |
   |------|-------|
   | `HUGGINGFACE_API_TOKEN` | Sua chave do Hugging Face |
   | `OPENAI_API_KEY` | Sua chave da OpenAI |

7. ✅ Marque as caixas de seleção para ativar as variáveis
8. Clique em **Close**

### Opção 2: Config.plist (Mais avançado)

Se preferir usar um arquivo de configuração:

1. Crie um arquivo `Config.plist` na raiz do projeto
2. Adicione suas chaves:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>HUGGINGFACE_API_TOKEN</key>
    <string>SEU_TOKEN_AQUI</string>
    <key>OPENAI_API_KEY</key>
    <string>SUA_CHAVE_AQUI</string>
</dict>
</plist>
```

3. ⚠️ **IMPORTANTE**: Este arquivo já está no `.gitignore` e não será commitado
4. Atualize o código para ler deste plist

## 🔑 Onde Obter as API Keys

### Hugging Face (Gratuito)
1. Acesse: https://huggingface.co/settings/tokens
2. Crie uma conta se ainda não tiver
3. Clique em **New token**
4. Dê um nome (ex: "StyleSync Dev")
5. Selecione permissão **Read**
6. Copie o token (começa com `hf_...`)

### OpenAI (Pago)
1. Acesse: https://platform.openai.com/api-keys
2. Crie uma conta e adicione método de pagamento
3. Clique em **Create new secret key**
4. Copie a chave (começa com `sk-...`)
5. ⚠️ Custo do DALL-E 3: ~$0.04-0.08 por imagem

## 🔒 Segurança

- ✅ Todas as chaves estão configuradas via variáveis de ambiente
- ✅ Nenhuma chave está hardcoded no código
- ✅ O arquivo `.gitignore` previne commit acidental de secrets
- ✅ O GitHub Push Protection está ativo

## 🚨 Se Você Expor uma Chave Acidentalmente

1. **Revogue imediatamente** a chave comprometida:
   - Hugging Face: https://huggingface.co/settings/tokens
   - OpenAI: https://platform.openai.com/api-keys

2. **Gere uma nova chave** e configure localmente

3. **Limpe o histórico do Git**:
   ```bash
   # CUIDADO: Reescreve o histórico!
   git filter-branch --force --index-filter \
     'git rm --cached --ignore-unmatch ARQUIVO_COM_SECRET' \
     --prune-empty --tag-name-filter cat -- --all
   
   # Force push (se necessário)
   git push origin --force --all
   ```

## 📝 Notas

- O projeto funciona sem as chaves OpenAI usando placeholders
- A chave Hugging Face é necessária para recomendações de IA
- Para produção, considere usar **Keychain** ou serviços de secrets management
