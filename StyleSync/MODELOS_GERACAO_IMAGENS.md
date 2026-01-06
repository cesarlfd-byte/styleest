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

