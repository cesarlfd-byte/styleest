# 🧪 Guia de Teste e Debug de Geração de Imagens

## 🔍 Como Identificar o Problema

Execute o app e verifique o **console do Xcode**. Você verá logs detalhados:

### Exemplo de Log Normal (Sucesso):
```
🚀 Gerando look completo...
✅ Descrição criada: Look Casual Descontraído
🎨 Prompt de imagem: fashion illustration, flat lay style, casual outfit, clothing sketch, minimalist design, clean white background, professional fashion drawing, simple and elegant
📡 Endpoint: https://router.huggingface.co/models/stabilityai/stable-diffusion-xl-base-1.0
⏳ Enviando requisição para Stable Diffusion...
📥 Resposta recebida. Tamanho: 245678 bytes
🔢 Status Code: 200
📄 Content-Type: image/jpeg
✅ Imagem gerada com sucesso! Tamanho: (512.0, 768.0)
```

### Exemplo de Log com Erro (Modelo Carregando):
```
🚀 Gerando look completo...
✅ Descrição criada: Look Casual Descontraído
🎨 Prompt de imagem: fashion illustration, flat lay style, casual outfit...
📡 Endpoint: https://router.huggingface.co/models/...
⏳ Enviando requisição para Stable Diffusion...
📥 Resposta recebida. Tamanho: 156 bytes
🔢 Status Code: 503
⚠️ Resposta JSON (pode ser erro ou status): ["error": "Model is currently loading", "estimated_time": 20.5]
⏰ Modelo ainda está carregando. Aguarde 20-30 segundos e tente novamente.
⚠️ API não retornou imagem válida, usando placeholder estilizado
```

---

## 🐛 Problemas Comuns e Soluções

### 1. **Modelo Carregando (503)**

**Sintoma:**
```json
{
  "error": "Model is currently loading",
  "estimated_time": 20.5
}
```

**Causa**: Modelos Hugging Face entram em "hibernação" quando não usados. Na primeira requisição, eles precisam "acordar".

**Solução**:
- ✅ **Aguarde 20-30 segundos** e tente novamente
- ✅ A segunda tentativa deve funcionar
- ✅ O placeholder será usado automaticamente enquanto isso

---

### 2. **Token Inválido (401)**

**Sintoma:**
```json
{
  "error": "Invalid authentication token"
}
```

**Solução**:
1. Vá para: https://huggingface.co/settings/tokens
2. Crie um novo token (tipo: "Read")
3. Copie o token
4. Cole em `AIRecommendationServiceSimple.swift`:
   ```swift
   private let apiToken = "hf_SEU_TOKEN_AQUI"
   ```

---

### 3. **Timeout (Network Error)**

**Sintoma:**
```
❌ Erro de rede: The request timed out
   Código: -1001
```

**Causa**: Conexão lenta ou modelo demorando muito

**Solução**:
- ✅ Verifique sua conexão com internet
- ✅ Timeout já está em 120 segundos (2 minutos)
- ✅ Tente em rede WiFi mais rápida

---

### 4. **Prompt Muito Complexo**

**Sintoma**: Imagem gerada estranha ou erro 400

**Solução**: ✅ Já simplificamos o prompt para:
```
fashion illustration, flat lay style, [ocasião] outfit, 
clothing sketch, minimalist design, clean white background, 
professional fashion drawing, simple and elegant
```

---

## 🧪 Como Testar o Prompt Manualmente

### Opção 1: Testar no Hugging Face (Web)

1. Acesse: https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0
2. Role até "Inference API"
3. Cole este prompt:
   ```
   fashion illustration, flat lay style, casual outfit, clothing sketch, minimalist design, clean white background, professional fashion drawing, simple and elegant
   ```
4. Clique em "Compute"
5. Aguarde 20-30 segundos
6. Veja o resultado!

---

### Opção 2: Usar cURL no Terminal

Abra o Terminal e execute:

```bash
curl https://router.huggingface.co/models/stabilityai/stable-diffusion-xl-base-1.0 \
  -X POST \
  -H "Authorization: Bearer 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" \
  -H "Content-Type: application/json" \
  -d '{
    "inputs": "fashion illustration, flat lay style, casual outfit, clothing sketch, minimalist design, clean white background, professional fashion drawing, simple and elegant",
    "parameters": {
      "negative_prompt": "ugly, deformed, low quality, blurry, nsfw, nude, realistic photo",
      "num_inference_steps": 20,
      "guidance_scale": 7.0,
      "width": 512,
      "height": 768
    }
  }' \
  --output test_image.jpg
```

**Resultados possíveis:**

✅ **Sucesso**: Arquivo `test_image.jpg` criado
```bash
open test_image.jpg  # Mac
```

⚠️ **Modelo carregando**: Aguarde 20 segundos e execute novamente

❌ **Erro**: Veja a mensagem de erro no terminal

---

### Opção 3: Ferramenta Online (Postman/Insomnia)

1. **Abra Postman** (ou Insomnia)
2. **Crie nova requisição POST**
3. **URL**: `https://router.huggingface.co/models/stabilityai/stable-diffusion-xl-base-1.0`
4. **Headers**:
   ```
   Authorization: Bearer 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
   Content-Type: application/json
   ```
5. **Body (JSON)**:
   ```json
   {
     "inputs": "fashion illustration, flat lay style, casual outfit, clothing sketch, minimalist design, clean white background, professional fashion drawing, simple and elegant",
     "parameters": {
       "negative_prompt": "ugly, deformed, low quality, blurry, nsfw, nude, realistic photo",
       "num_inference_steps": 20,
       "guidance_scale": 7.0,
       "width": 512,
       "height": 768
     }
   }
   ```
6. **Enviar** e aguardar resposta

---

## 📊 Interpretando Respostas

### ✅ Sucesso (200)
```
Content-Type: image/jpeg
Content-Length: 245678
[binary image data]
```
→ Imagem gerada com sucesso!

### ⚠️ Modelo Carregando (503)
```json
{
  "error": "Model stabilityai/stable-diffusion-xl-base-1.0 is currently loading",
  "estimated_time": 20.5
}
```
→ Aguarde e tente novamente

### ❌ Token Inválido (401)
```json
{
  "error": "Invalid authentication token"
}
```
→ Gere novo token

### ❌ Rate Limit (429)
```json
{
  "error": "Rate limit exceeded"
}
```
→ Aguarde alguns minutos

---

## 🔧 Melhorias Aplicadas

### 1. **Logs Detalhados**
Agora você vê:
- ✅ Prompt exato sendo usado
- ✅ Endpoint sendo chamado
- ✅ Status HTTP da resposta
- ✅ Content-Type recebido
- ✅ Tamanho dos dados
- ✅ Erros específicos da API
- ✅ Tempo estimado de carregamento

### 2. **Prompt Simplificado**
**Antes** (muito complexo):
```
fashion illustration, professional work outfit for male, 
Camisa social, Calça de alfaiataria, Sapato social, Cinto de couro, 
professional fashion sketch, clean background, stylish, modern, trendy, 
high quality, detailed clothing, fashion design, editorial style, professional photography
```

**Depois** (mais simples e efetivo):
```
fashion illustration, flat lay style, casual outfit, 
clothing sketch, minimalist design, clean white background, 
professional fashion drawing, simple and elegant
```

### 3. **Parâmetros Otimizados**
```swift
"parameters": [
    "negative_prompt": "ugly, deformed, low quality, blurry, nsfw, nude, realistic photo",
    "num_inference_steps": 20,  // Reduzido de 30 para ser mais rápido
    "guidance_scale": 7.0,       // Reduzido de 7.5 para mais criatividade
    "width": 512,
    "height": 768
]
```

### 4. **Timeout Aumentado**
```swift
request.timeoutInterval = 120  // 2 minutos (era 60 segundos)
```

---

## 📋 Checklist de Debug

Quando a imagem não for gerada:

- [ ] Verifique o **console do Xcode**
- [ ] Procure por logs com 🎨, 📡, 📥, ⚠️
- [ ] Identifique o **Status Code** (200, 503, 401, etc.)
- [ ] Veja se há mensagem de **"Model is currently loading"**
- [ ] Se houver, **aguarde 30 segundos** e tente novamente
- [ ] Verifique se o **Content-Type** é `image/jpeg` ou `image/png`
- [ ] Se for `application/json`, veja o erro específico
- [ ] Teste o prompt manualmente (opções acima)
- [ ] Verifique sua **conexão com internet**
- [ ] Confirme que o **token é válido**

---

## 🎯 Testes Recomendados

### Teste 1: Verificar Token
```bash
curl https://huggingface.co/api/whoami-v2 \
  -H "Authorization: Bearer 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"
```

**Esperado**: Informações do seu usuário Hugging Face

---

### Teste 2: Prompt Mínimo
```bash
curl https://router.huggingface.co/models/stabilityai/stable-diffusion-xl-base-1.0 \
  -X POST \
  -H "Authorization: Bearer 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" \
  -H "Content-Type: application/json" \
  -d '{"inputs": "a simple fashion sketch"}' \
  --output minimal_test.jpg
```

**Esperado**: Imagem gerada ou mensagem de loading

---

### Teste 3: Status do Modelo
```bash
curl -I https://router.huggingface.co/models/stabilityai/stable-diffusion-xl-base-1.0
```

**Esperado**: Headers mostrando status do endpoint

---

## 💡 Dicas Finais

1. **Primeira execução sempre demora mais** - O modelo precisa "acordar"
2. **Segunda tentativa é mais rápida** - Modelo já está carregado
3. **Placeholder é seu amigo** - Sempre mostra algo bonito enquanto API carrega
4. **Console é essencial** - Sempre verifique os logs detalhados
5. **Teste manualmente primeiro** - Use cURL ou Postman para validar
6. **Paciência** - APIs gratuitas podem ter filas

---

## 📞 Próximos Passos

Se ainda não funcionar:

1. **Cole os logs do console aqui** - Vou analisar o erro específico
2. **Teste com cURL** - Confirme se é problema do código ou da API
3. **Considere alternativas** - Veja `ALTERNATIVAS_GERACAO_IMAGENS.md`
4. **Use placeholder temporariamente** - Já está implementado e bonito!

---

**Criado em**: Janeiro 2026  
**Status**: 🧪 Guia de Debug  
**Próxima ação**: Execute o app e verifique os logs!
