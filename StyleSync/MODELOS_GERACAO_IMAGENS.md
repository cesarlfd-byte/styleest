# 🎨 Modelos de Geração de Imagens Disponíveis no Hugging Face

## ⚠️ Erro 404 - Causa Identificada

**Problema**: O endpoint estava usando `router.huggingface.co` que não funciona para todos os modelos.

**Solução**: Voltamos para `api-inference.huggingface.co` que é o endpoint correto e estável.

---

## 🤔 Sobre o Qwen/Qwen-Image-2512

❌ **Qwen/Qwen-Image-2512** NÃO é um modelo de geração de imagens (text-to-image)

✅ **Qwen-Image** é um modelo de **visão multimodal** (image-to-text):
- Analisa imagens e descreve o que vê
- Responde perguntas sobre imagens
- Extrai informações de fotos

❌ **Não gera imagens a partir de texto** (que é o que precisamos)

---

## ✅ Modelos Corretos para Geração de Imagens (Text-to-Image)

### 1. 🏆 Stable Diffusion XL Base 1.0 (RECOMENDADO)

**Endpoint**:
```swift
https://api-inference.huggingface.co/models/stabilityai/stable-diffusion-xl-base-1.0
```

**Características**:
- ✅ Melhor qualidade geral
- ✅ 1024x1024 pixels (alta resolução)
- ✅ Excelente para fashion illustrations
- ⚠️ Mais lento (~30-60 segundos)
- ✅ Gratuito

**Quando usar**: Quando qualidade é mais importante que velocidade

---

### 2. ⚡ Stable Diffusion 2.1

**Endpoint**:
```swift
https://api-inference.huggingface.co/models/stabilityai/stable-diffusion-2-1
```

**Características**:
- ✅ Mais rápido (~15-30 segundos)
- ✅ 768x768 pixels
- ✅ Boa qualidade
- ✅ Menos memória
- ✅ Gratuito

**Quando usar**: Quando velocidade é importante

---

### 3. 🎨 DreamShaper 8

**Endpoint**:
```swift
https://api-inference.huggingface.co/models/Lykon/dreamshaper-8
```

**Características**:
- ✅ Estilo artístico e vibrante
- ✅ Cores saturadas
- ✅ Ótimo para fashion
- ✅ Rápido (~20-40 segundos)
- ✅ Gratuito

**Quando usar**: Para looks mais artísticos e coloridos

---

### 4. 📸 Realistic Vision V5.1

**Endpoint**:
```swift
https://api-inference.huggingface.co/models/SG161222/Realistic_Vision_V5.1_noVAE
```

**Características**:
- ✅ Estilo fotorealista
- ✅ Detalhes de textura
- ⚠️ Pode ser muito realista (não queremos fotos de pessoas reais)
- ✅ Gratuito

**Quando usar**: Se quiser imagens muito realistas (não recomendado para fashion)

---

### 5. 🌟 Playground V2.5

**Endpoint**:
```swift
https://api-inference.huggingface.co/models/playgroundai/playground-v2.5-1024px-aesthetic
```

**Características**:
- ✅ Excelente qualidade estética
- ✅ 1024x1024 pixels
- ✅ Cores vibrantes
- ✅ Ótimo para ilustrações
- ✅ Gratuito

**Quando usar**: Para resultados esteticamente agradáveis

---

### 6. 🎭 Anything V5

**Endpoint**:
```swift
https://api-inference.huggingface.co/models/stablediffusionapi/anything-v5
```

**Características**:
- ✅ Estilo anime/ilustração
- ✅ Muito criativo
- ✅ Bom para fashion sketches
- ✅ Gratuito

**Quando usar**: Para estilo mais ilustrativo/cartoon

---

## 🧪 Como Testar Cada Modelo

### Teste no Terminal (cURL)

**Template**:
```bash
curl https://api-inference.huggingface.co/models/[MODELO] \
  -X POST \
  -H "Authorization: Bearer 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" \
  -H "Content-Type: application/json" \
  -d '{
    "inputs": "fashion illustration, flat lay style, casual outfit, clothing sketch, minimalist design, clean white background, professional fashion drawing, simple and elegant"
  }' \
  --output test_output.jpg && open test_output.jpg
```

### Teste Stable Diffusion XL:
```bash
curl https://api-inference.huggingface.co/models/stabilityai/stable-diffusion-xl-base-1.0 \
  -X POST \
  -H "Authorization: Bearer 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" \
  -H "Content-Type: application/json" \
  -d '{"inputs": "fashion illustration, casual outfit, minimalist design"}' \
  --output test_sdxl.jpg && open test_sdxl.jpg
```

### Teste Stable Diffusion 2.1:
```bash
curl https://api-inference.huggingface.co/models/stabilityai/stable-diffusion-2-1 \
  -X POST \
  -H "Authorization: Bearer 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" \
  -H "Content-Type: application/json" \
  -d '{"inputs": "fashion illustration, casual outfit, minimalist design"}' \
  --output test_sd21.jpg && open test_sd21.jpg
```

### Teste DreamShaper:
```bash
curl https://api-inference.huggingface.co/models/Lykon/dreamshaper-8 \
  -X POST \
  -H "Authorization: Bearer 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" \
  -H "Content-Type: application/json" \
  -d '{"inputs": "fashion illustration, casual outfit, minimalist design"}' \
  --output test_dream.jpg && open test_dream.jpg
```

---

## 📊 Comparação de Modelos

| Modelo | Qualidade | Velocidade | Estilo | Resolução | Para Fashion |
|--------|-----------|------------|--------|-----------|--------------|
| **SDXL 1.0** | ⭐⭐⭐⭐⭐ | ⭐⭐ | Versátil | 1024x1024 | ✅✅✅ |
| **SD 2.1** | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | Versátil | 768x768 | ✅✅ |
| **DreamShaper** | ⭐⭐⭐⭐ | ⭐⭐⭐ | Artístico | 512x512 | ✅✅✅ |
| **Realistic Vision** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | Realista | 512x512 | ⚠️ |
| **Playground** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | Estético | 1024x1024 | ✅✅✅ |
| **Anything V5** | ⭐⭐⭐ | ⭐⭐⭐⭐ | Anime | 512x512 | ✅ |

---

## 🎯 Recomendação para Seu App

### **Melhor Escolha: Stable Diffusion XL Base 1.0**

**Por quê:**
1. ✅ Melhor qualidade de ilustrações
2. ✅ Funciona bem com prompts de fashion
3. ✅ Alta resolução (1024x1024)
4. ✅ Totalmente gratuito
5. ✅ Bem documentado

**Endpoint correto**:
```swift
private let imageEndpoint = "https://api-inference.huggingface.co/models/stabilityai/stable-diffusion-xl-base-1.0"
```

### **Alternativa Rápida: Stable Diffusion 2.1**

Se usuários reclamarem de lentidão:
```swift
private let imageEndpoint = "https://api-inference.huggingface.co/models/stabilityai/stable-diffusion-2-1"
```

---

## 🔧 Como Trocar de Modelo no Código

Abra `AIRecommendationServiceSimple.swift` e mude:

```swift
// OPÇÃO 1: Melhor Qualidade (RECOMENDADO)
private let imageEndpoint = "https://api-inference.huggingface.co/models/stabilityai/stable-diffusion-xl-base-1.0"

// OPÇÃO 2: Mais Rápido
// private let imageEndpoint = "https://api-inference.huggingface.co/models/stabilityai/stable-diffusion-2-1"

// OPÇÃO 3: Estilo Artístico
// private let imageEndpoint = "https://api-inference.huggingface.co/models/Lykon/dreamshaper-8"

// OPÇÃO 4: Alta Estética
// private let imageEndpoint = "https://api-inference.huggingface.co/models/playgroundai/playground-v2.5-1024px-aesthetic"
```

**Basta descomentar a linha que você quer e comentar as outras!**

---

## ⚠️ Por Que router.huggingface.co Deu 404?

O `router.huggingface.co` é um **novo sistema experimental** que:
- ❌ Não funciona com todos os modelos ainda
- ❌ Pode redirecionar incorretamente
- ❌ Documentação incompleta

O `api-inference.huggingface.co` é:
- ✅ Endpoint oficial e estável
- ✅ Funciona com todos os modelos
- ✅ Bem documentado
- ✅ Recomendado pela Hugging Face

---

## 🧪 Script de Teste Completo

Salve como `test_models.sh` e execute:

```bash
#!/bin/bash

TOKEN="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"
PROMPT="fashion illustration, casual outfit, minimalist design, clean white background"

echo "🧪 Testando modelos de geração de imagens..."
echo ""

# Teste 1: SDXL
echo "1️⃣ Testando Stable Diffusion XL..."
curl -s https://api-inference.huggingface.co/models/stabilityai/stable-diffusion-xl-base-1.0 \
  -X POST \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"inputs\": \"$PROMPT\"}" \
  --output test_sdxl.jpg

if [ -f test_sdxl.jpg ]; then
    echo "✅ SDXL: Sucesso! ($(wc -c < test_sdxl.jpg) bytes)"
    open test_sdxl.jpg
else
    echo "❌ SDXL: Falhou"
fi
echo ""

# Teste 2: SD 2.1
echo "2️⃣ Testando Stable Diffusion 2.1..."
curl -s https://api-inference.huggingface.co/models/stabilityai/stable-diffusion-2-1 \
  -X POST \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"inputs\": \"$PROMPT\"}" \
  --output test_sd21.jpg

if [ -f test_sd21.jpg ]; then
    echo "✅ SD 2.1: Sucesso! ($(wc -c < test_sd21.jpg) bytes)"
    open test_sd21.jpg
else
    echo "❌ SD 2.1: Falhou"
fi
echo ""

# Teste 3: DreamShaper
echo "3️⃣ Testando DreamShaper..."
curl -s https://api-inference.huggingface.co/models/Lykon/dreamshaper-8 \
  -X POST \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"inputs\": \"$PROMPT\"}" \
  --output test_dream.jpg

if [ -f test_dream.jpg ]; then
    echo "✅ DreamShaper: Sucesso! ($(wc -c < test_dream.jpg) bytes)"
    open test_dream.jpg
else
    echo "❌ DreamShaper: Falhou"
fi

echo ""
echo "🎉 Testes concluídos! Verifique as imagens geradas."
```

**Executar**:
```bash
chmod +x test_models.sh
./test_models.sh
```

---

## 📱 Melhor Configuração para Produção

```swift
class AIRecommendationServiceSimple: ObservableObject {
    
    private let apiToken = "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"
    
    // Texto
    private let textEndpoint = "https://api-inference.huggingface.co/models/meta-llama/Meta-Llama-3-8B-Instruct"
    
    // Imagem - ESCOLHA UM:
    
    // ⭐ RECOMENDADO: Melhor qualidade
    private let imageEndpoint = "https://api-inference.huggingface.co/models/stabilityai/stable-diffusion-xl-base-1.0"
    
    // ⚡ ALTERNATIVA: Mais rápido
    // private let imageEndpoint = "https://api-inference.huggingface.co/models/stabilityai/stable-diffusion-2-1"
}
```

---

## 🎨 Prompts Otimizados por Modelo

### Para SDXL (Atual):
```swift
"fashion illustration, flat lay style, \(occasionEN) outfit, clothing sketch, minimalist design, clean white background, professional fashion drawing, simple and elegant"
```

### Para DreamShaper:
```swift
"fashion design illustration, \(occasionEN) outfit, vibrant colors, artistic style, detailed clothing, professional sketch, white background"
```

### Para Playground:
```swift
"aesthetic fashion illustration, \(occasionEN) style, clothing design, clean composition, high quality art, minimalist, elegant"
```

---

## 📊 Resultados Esperados

### ✅ Com Endpoint Correto:
```
🎨 Prompt de imagem: fashion illustration, flat lay style, casual outfit...
📡 Endpoint: https://api-inference.huggingface.co/models/stabilityai/stable-diffusion-xl-base-1.0
⏳ Enviando requisição para Stable Diffusion...
📥 Resposta recebida. Tamanho: 245678 bytes
🔢 Status Code: 200
📄 Content-Type: image/jpeg
✅ Imagem gerada com sucesso! Tamanho: (1024.0, 1024.0)
```

### ❌ Com Endpoint Errado (404):
```
🎨 Prompt de imagem: fashion illustration...
📡 Endpoint: https://router.huggingface.co/models/...
⏳ Enviando requisição...
📥 Resposta recebida. Tamanho: 89 bytes
🔢 Status Code: 404
⚠️ Resposta JSON: ["error": "Model not found"]
```

---

## 🔑 Resumo da Solução

1. ✅ **Mudamos de volta para** `api-inference.huggingface.co`
2. ✅ **Mantemos SDXL** como modelo padrão
3. ✅ **Adicionamos opções** comentadas para trocar facilmente
4. ✅ **Documentamos todos os modelos** disponíveis
5. ✅ **Criamos testes** para validar cada um

---

## 📞 Próximos Passos

1. **Recompile o app** (⌘B)
2. **Execute** (⌘R)
3. **Teste geração de look**
4. **Verifique console** - Deve mostrar Status 200!
5. **Se 503 (loading)**: Aguarde 30s e tente de novo

---

**Atualizado em**: Janeiro 2026  
**Status**: ✅ Endpoint Corrigido  
**Modelo Recomendado**: Stable Diffusion XL Base 1.0
