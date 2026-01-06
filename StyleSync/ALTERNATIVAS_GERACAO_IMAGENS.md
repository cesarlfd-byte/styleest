# 🎨 Alternativas de APIs de Geração de Imagens

⚠️ **ATUALIZAÇÃO IMPORTANTE**: O Hugging Face migrou para um novo endpoint!
- ❌ **Antigo**: `https://api-inference.huggingface.co`
- ✅ **Novo**: `https://router.huggingface.co`

---

Se você quiser usar outras APIs de geração de imagens além do Stable Diffusion da Hugging Face, aqui estão algumas opções:

## 1. 🤗 Hugging Face (Atual - GRATUITO)

**Modelo**: Stable Diffusion XL Base 1.0

**Vantagens**:
- ✅ 100% Gratuito
- ✅ Sem necessidade de cartão de crédito
- ✅ Boa qualidade de imagens
- ✅ API simples

**Desvantagens**:
- ⚠️ Pode ter filas em horários de pico
- ⚠️ Cold start inicial (primeira geração mais lenta)

**Custo**: **GRÁTIS**

---

## 2. 🎨 OpenAI DALL-E 3

**API**: `https://api.openai.com/v1/images/generations`

### Implementação

```swift
private let openaiEndpoint = "https://api.openai.com/v1/images/generations"
private let openaiToken = "sk-..." // Seu token OpenAI

private func generateWithDALLE(prompt: String) async throws -> UIImage {
    let requestBody: [String: Any] = [
        "model": "dall-e-3",
        "prompt": prompt,
        "n": 1,
        "size": "1024x1024",
        "quality": "standard"
    ]
    
    guard let url = URL(string: openaiEndpoint) else {
        throw AIError.invalidURL
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("Bearer \(openaiToken)", forHTTPHeaderField: "Authorization")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
    
    let (data, _) = try await URLSession.shared.data(for: request)
    
    if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
       let dataArray = json["data"] as? [[String: Any]],
       let imageUrl = dataArray.first?["url"] as? String,
       let url = URL(string: imageUrl),
       let imageData = try? Data(contentsOf: url),
       let image = UIImage(data: imageData) {
        return image
    }
    
    throw AIError.invalidResponse
}
```

**Vantagens**:
- ✅ Imagens de altíssima qualidade
- ✅ Entende bem prompts complexos
- ✅ API confiável e rápida

**Desvantagens**:
- ❌ Pago (não gratuito)
- ❌ Requer cartão de crédito

**Custo**: ~$0.04 por imagem (1024x1024, qualidade standard)

---

## 3. 🎭 Stability AI (Official)

**API**: `https://api.stability.ai/v1/generation/stable-diffusion-xl-1024-v1-0/text-to-image`

### Implementação

```swift
private let stabilityEndpoint = "https://api.stability.ai/v1/generation/stable-diffusion-xl-1024-v1-0/text-to-image"
private let stabilityToken = "sk-..." // Seu token Stability AI

private func generateWithStabilityAI(prompt: String) async throws -> UIImage {
    let requestBody: [String: Any] = [
        "text_prompts": [
            [
                "text": prompt,
                "weight": 1
            ],
            [
                "text": "ugly, deformed, low quality",
                "weight": -1
            ]
        ],
        "cfg_scale": 7,
        "height": 768,
        "width": 512,
        "samples": 1,
        "steps": 30
    ]
    
    guard let url = URL(string: stabilityEndpoint) else {
        throw AIError.invalidURL
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue(stabilityToken, forHTTPHeaderField: "Authorization")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
    
    let (data, _) = try await URLSession.shared.data(for: request)
    
    if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
       let artifacts = json["artifacts"] as? [[String: Any]],
       let base64 = artifacts.first?["base64"] as? String,
       let imageData = Data(base64Encoded: base64),
       let image = UIImage(data: imageData) {
        return image
    }
    
    throw AIError.invalidResponse
}
```

**Vantagens**:
- ✅ Melhor controle sobre geração
- ✅ Diversos modelos disponíveis
- ✅ Créditos grátis iniciais

**Desvantagens**:
- ❌ Requer cadastro com cartão
- ❌ Pago após créditos iniciais

**Custo**: $0.02-0.04 por imagem (varia por modelo)

---

## 4. 🖼️ Replicate

**API**: `https://api.replicate.com/v1/predictions`

### Implementação

```swift
private let replicateEndpoint = "https://api.replicate.com/v1/predictions"
private let replicateToken = "r8_..." // Seu token Replicate

private func generateWithReplicate(prompt: String) async throws -> UIImage {
    // 1. Criar predição
    let requestBody: [String: Any] = [
        "version": "39ed52f2a78e934b3ba6e2a89f5b1c712de7dfea535525255b1aa35c5565e08b",
        "input": [
            "prompt": prompt,
            "negative_prompt": "ugly, deformed, low quality",
            "num_outputs": 1,
            "width": 512,
            "height": 768
        ]
    ]
    
    guard let url = URL(string: replicateEndpoint) else {
        throw AIError.invalidURL
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("Token \(replicateToken)", forHTTPHeaderField: "Authorization")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
    
    let (data, _) = try await URLSession.shared.data(for: request)
    
    guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
          let predictionId = json["id"] as? String else {
        throw AIError.invalidResponse
    }
    
    // 2. Poll até completar
    var attempts = 0
    while attempts < 30 {
        try await Task.sleep(nanoseconds: 2_000_000_000) // 2 segundos
        
        let statusURL = URL(string: "\(replicateEndpoint)/\(predictionId)")!
        var statusRequest = URLRequest(url: statusURL)
        statusRequest.setValue("Token \(replicateToken)", forHTTPHeaderField: "Authorization")
        
        let (statusData, _) = try await URLSession.shared.data(for: statusRequest)
        
        if let statusJson = try? JSONSerialization.jsonObject(with: statusData) as? [String: Any],
           let status = statusJson["status"] as? String {
            
            if status == "succeeded",
               let output = statusJson["output"] as? [String],
               let imageUrl = output.first,
               let url = URL(string: imageUrl),
               let imageData = try? Data(contentsOf: url),
               let image = UIImage(data: imageData) {
                return image
            }
            
            if status == "failed" {
                throw AIError.requestFailed
            }
        }
        
        attempts += 1
    }
    
    throw AIError.requestFailed
}
```

**Vantagens**:
- ✅ Muitos modelos disponíveis
- ✅ Fácil de usar
- ✅ Pay-as-you-go

**Desvantagens**:
- ❌ Pago (não gratuito)
- ⚠️ Requer polling

**Custo**: Varia por modelo (~$0.01-0.05 por imagem)

---

## 5. 🌟 Modelos Locais com Core ML

Se você quiser rodar IA **localmente** no dispositivo:

```swift
import CoreML

class LocalImageGenerator {
    private var model: StableDiffusionPipeline?
    
    func loadModel() async throws {
        // Você precisa converter o modelo para Core ML
        // Veja: https://github.com/apple/ml-stable-diffusion
        let config = MLModelConfiguration()
        config.computeUnits = .cpuAndNeuralEngine
        
        model = try await StableDiffusionPipeline.load(
            resourcesAt: modelURL,
            configuration: config
        )
    }
    
    func generate(prompt: String) async throws -> UIImage {
        guard let model = model else {
            throw AIError.invalidURL
        }
        
        let images = try await model.generateImages(
            prompt: prompt,
            imageCount: 1,
            stepCount: 20,
            seed: UInt32.random(in: 0...UInt32.max)
        )
        
        guard let cgImage = images.first else {
            throw AIError.invalidResponse
        }
        
        return UIImage(cgImage: cgImage)
    }
}
```

**Vantagens**:
- ✅ Totalmente GRATUITO
- ✅ Privacidade total (100% offline)
- ✅ Sem dependência de internet
- ✅ Sem custos recorrentes

**Desvantagens**:
- ❌ Tamanho do app aumenta muito (~2-4GB)
- ❌ Requer dispositivos potentes (A14+)
- ❌ Mais lento que APIs cloud
- ❌ Setup complexo

**Custo**: **GRÁTIS** (mas aumenta tamanho do app)

---

## 📊 Comparação Rápida

| Serviço | Custo | Qualidade | Velocidade | Setup |
|---------|-------|-----------|------------|-------|
| **Hugging Face** | GRÁTIS ✅ | ⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **DALL-E 3** | $0.04/img | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| **Stability AI** | $0.02/img | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| **Replicate** | $0.01-0.05/img | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ |
| **Core ML Local** | GRÁTIS ✅ | ⭐⭐⭐ | ⭐⭐ | ⭐ |

---

## 🎯 Recomendação

### Para Desenvolvimento/Teste
👉 **Hugging Face** (atual implementação)
- Totalmente gratuito
- Boa qualidade
- Fácil de começar

### Para Produção (Alta Qualidade)
👉 **DALL-E 3** ou **Stability AI**
- Melhor qualidade
- Mais confiável
- Vale o investimento para UX premium

### Para Privacidade/Offline
👉 **Core ML Local**
- Privacidade total
- Funciona offline
- Mas requer muito espaço

---

## 🔄 Como Trocar de API

1. Substitua o método `generateAIImage()` no arquivo `AIRecommendationServiceSimple.swift`
2. Adicione o novo endpoint e token
3. Ajuste o parsing da resposta
4. Teste!

---

## 💡 Dicas

- **Hugging Face**: Use por enquanto, é grátis!
- **Upgrade**: Se o app crescer, migre para DALL-E ou Stability
- **Hybrid**: Use Hugging Face com fallback para Core ML local
- **Cache**: Salve imagens geradas para não gerar de novo

---

**Documentação útil:**
- [Hugging Face Inference](https://huggingface.co/docs/api-inference)
- [OpenAI Images API](https://platform.openai.com/docs/guides/images)
- [Stability AI Docs](https://platform.stability.ai/docs)
- [Replicate Docs](https://replicate.com/docs)
- [Apple ML Stable Diffusion](https://github.com/apple/ml-stable-diffusion)
