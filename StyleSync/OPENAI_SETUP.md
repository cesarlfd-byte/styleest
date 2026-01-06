# 🎨 Integração com OpenAI DALL-E 3

## ✅ O que foi feito

Integrei a geração de imagens com o **DALL-E 3 da OpenAI**, que é muito mais confiável e gera imagens de alta qualidade para os looks de moda.

## 📋 Como configurar

### 1. Obter API Key da OpenAI

1. Acesse: https://platform.openai.com/api-keys
2. Faça login ou crie uma conta
3. Clique em **"Create new secret key"**
4. Copie a chave (ela começa com `sk-...`)
5. ⚠️ **IMPORTANTE**: Guarde essa chave em lugar seguro, ela não será mostrada novamente!

### 2. Adicionar a API Key no código

No arquivo `AIRecommendationServiceSimple.swift`, linha ~29:

```swift
// OpenAI API - DALL-E 3 para geração de imagens
private let openAIApiKey = "SUA_OPENAI_API_KEY_AQUI" // ⚠️ SUBSTITUA pela sua chave
```

Substitua `"SUA_OPENAI_API_KEY_AQUI"` pela sua chave real:

```swift
private let openAIApiKey = "sk-proj-xxxxxxxxxxxxxxxxxxxxxxxx"
```

### 3. Garantir que está usando DALL-E

Verifique que a flag está como `false`:

```swift
private let useStyledPlaceholder = false
```

## 💰 Custos

O DALL-E 3 é um serviço pago, mas com preços acessíveis:

- **Standard quality (1024x1792)**: ~$0.040 por imagem
- **HD quality (1024x1792)**: ~$0.080 por imagem

**Exemplo**: 
- 25 imagens em qualidade standard = ~$1.00
- 100 imagens em qualidade standard = ~$4.00

Você pode ajustar a qualidade na linha ~173:

```swift
"quality": "standard", // ou "hd" para maior qualidade
```

## 🎯 Vantagens do DALL-E 3

✅ **Alta confiabilidade** - Funciona consistentemente  
✅ **Qualidade superior** - Imagens realistas e detalhadas  
✅ **Entende contexto** - Interpreta bem os prompts de moda  
✅ **Suporte oficial** - API bem documentada e mantida  
✅ **Formato vertical** - Perfeito para exibir looks completos  

## 🔧 Personalizações disponíveis

### Tamanho da imagem (linha ~171)

```swift
"size": "1024x1792", // Vertical (recomendado para moda)
// Outras opções: "1024x1024", "1792x1024"
```

### Estilo (linha ~173)

```swift
"style": "vivid" // Cores vibrantes e dramáticas
// ou
"style": "natural" // Mais realista e natural
```

### Qualidade (linha ~172)

```swift
"quality": "standard" // Mais rápido e barato
// ou
"quality": "hd" // Maior qualidade (2x o preço)
```

## 🛡️ Segurança da API Key

⚠️ **NUNCA** compartilhe sua API key publicamente!

### Opção 1: Usar arquivo de configuração (Recomendado)

Crie um arquivo `Config.plist`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>OpenAI_API_Key</key>
    <string>sk-proj-xxxxxxxxxxxxxxxxxxxxxxxx</string>
</dict>
</plist>
```

Adicione ao `.gitignore`:
```
Config.plist
```

Leia no código:
```swift
private let openAIApiKey: String = {
    guard let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
          let config = NSDictionary(contentsOfFile: path),
          let key = config["OpenAI_API_Key"] as? String else {
        fatalError("Configure sua API Key no Config.plist")
    }
    return key
}()
```

### Opção 2: Variáveis de ambiente

Configure no esquema do Xcode:
1. Product > Scheme > Edit Scheme
2. Run > Arguments > Environment Variables
3. Adicione: `OPENAI_API_KEY = sk-proj-...`

Leia no código:
```swift
private let openAIApiKey: String = {
    guard let key = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] else {
        fatalError("Configure OPENAI_API_KEY nas variáveis de ambiente")
    }
    return key
}()
```

## 🔄 Fallback automático

Se a API da OpenAI falhar por qualquer motivo (sem créditos, sem internet, etc.), o código automaticamente usa o **placeholder estilizado** como backup, garantindo que seu app nunca quebre! 🛡️

## 📊 Monitoramento de uso

Acompanhe seus gastos em:
https://platform.openai.com/usage

## ❓ Problemas comuns

### "Incorrect API key provided"
- Verifique se copiou a chave completa
- API keys começam com `sk-proj-` ou `sk-`

### "You exceeded your current quota"
- Adicione créditos em: https://platform.openai.com/account/billing

### Timeout ao gerar imagens
- Já configurado para 120 segundos
- DALL-E 3 normalmente responde em 10-30 segundos

## 🎉 Pronto!

Agora seu app vai gerar imagens incríveis de alta qualidade para cada look recomendado! 👗👔

---

**Dúvidas?** Consulte a documentação oficial:
- [OpenAI DALL-E API](https://platform.openai.com/docs/guides/images)
- [Pricing](https://openai.com/pricing)
