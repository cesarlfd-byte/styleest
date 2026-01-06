import Foundation
import Combine
import UIKit

// MARK: - Serviço de IA para Recomendações
// Texto: Hugging Face (Meta Llama 3)
// Imagens: OpenAI DALL-E 3
//
// 📝 CONFIGURAÇÃO:
// 1. Obtenha sua chave da OpenAI em: https://platform.openai.com/api-keys
// 2. Substitua "SUA_OPENAI_API_KEY_AQUI" pela sua chave real
// 3. O DALL-E 3 é pago, mas oferece qualidade superior
//    - Custo: ~$0.04 por imagem (standard) ou ~$0.08 (HD)
//    - Resolução: 1024x1792 pixels (formato vertical)
//
// ⚙️ OPÇÕES:
// - useStyledPlaceholder = false: Usa DALL-E 3 (requer API key)
// - useStyledPlaceholder = true: Usa placeholder estilizado (gratuito, sempre funciona)
//
class AIRecommendationServiceSimple: ObservableObject {
    
    // ⚠️ IMPORTANTE: Tokens de API
    private let apiToken = ProcessInfo.processInfo.environment["HUGGINGFACE_API_TOKEN"] ?? ""
    
    // Modelo gratuito e poderoso da Hugging Face para texto
    private let textEndpoint = "https://router.huggingface.co/models/meta-llama/Meta-Llama-3-8B-Instruct"
    
    // OpenAI API - DALL-E 3 para geração de imagens
    private let openAIApiKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] ?? ""
    private let openAIImageEndpoint = "https://api.openai.com/v1/images/generations"
    
    // OPÇÃO 1: Placeholder Estilizado (FUNCIONA SEMPRE - Recomendado temporariamente) ✅
    private let useStyledPlaceholder = false
    
    // OPÇÃO 2: Pollinations.AI (GRATUITO, sem API key, funciona!) 🎨
    // private let usePollinationsAI = true
    // private let pollinationsEndpoint = "https://image.pollinations.ai/prompt"
    
    // OPÇÃO 3: Hugging Face (quando voltar a funcionar) 🔄
    // private let imageEndpoint = "https://api-inference.huggingface.co/models/stabilityai/stable-diffusion-2-1"
    
    // MARK: - Gerar look completo com imagem
    func generateCompleteLook(
        profile: UserProfile,
        occasion: String
    ) async throws -> CompleteLook {
        
        print("🚀 Gerando look completo...")
        
        // 1. Gerar descrição do look com IA de texto
        let recommendation = try await generateLookRecommendation(profile: profile, occasion: occasion)
        
        print("✅ Descrição criada: \(recommendation.title)")
        
        // 2. Gerar imagem com IA baseada na descrição
        let image = try await generateAIImage(for: recommendation, profile: profile, occasion: occasion)
        
        print("✅ Imagem gerada pela IA!")
        
        return CompleteLook(
            recommendation: recommendation,
            image: image,
            occasion: occasion
        )
    }
    
    // MARK: - Gerar recomendação de look com IA de texto
    private func generateLookRecommendation(
        profile: UserProfile,
        occasion: String
    ) async throws -> LookRecommendation {
        
        // Garantir token do Hugging Face via variável de ambiente
        guard !apiToken.isEmpty else {
            // Fallback para recomendação local se não houver token
            return createFallbackRecommendation(profile: profile, occasion: occasion)
        }
        
        let prompt = """
        Você é um stylist profissional brasileiro. Crie UMA recomendação de look detalhada.
        
        Perfil:
        - Gênero: \(profile.gender)
        - Tipo de corpo: \(profile.bodyType)
        - Cor de cabelo: \(profile.hairColorName)
        - Gêneros musicais: \(profile.musicGenres.joined(separator: ", "))
        - Temperatura: \(profile.weatherTemperature)°C
        - Ocasião: \(occasion)
        
        Retorne APENAS um JSON válido neste formato:
        {"title":"Nome do Look","description":"Descrição breve em português","items":["peça 1","peça 2","peça 3","peça 4"],"styleNote":"Dica de estilo"}
        """
        
        let requestBody: [String: Any] = [
            "inputs": prompt,
            "parameters": [
                "max_new_tokens": 250,
                "temperature": 0.8,
                "return_full_text": false
            ]
        ]
        
        guard let url = URL(string: textEndpoint) else {
            throw AIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        // Parse da resposta
        if let jsonArray = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]],
           let firstResult = jsonArray.first,
           let generatedText = firstResult["generated_text"] as? String {
            
            // Tentar extrair JSON do texto
            if let jsonData = extractJSON(from: generatedText)?.data(using: .utf8),
               let recommendation = try? JSONDecoder().decode(LookRecommendation.self, from: jsonData) {
                return recommendation
            }
        }
        
        // Fallback caso a IA não retorne JSON válido
        return createFallbackRecommendation(profile: profile, occasion: occasion)
    }
    
    // MARK: - Gerar imagem com IA
    private func generateAIImage(
        for recommendation: LookRecommendation,
        profile: UserProfile,
        occasion: String
    ) async throws -> UIImage {
        
        let imagePrompt = createImagePrompt(recommendation: recommendation, profile: profile, occasion: occasion)
        
        print("🎨 Prompt de imagem: \(imagePrompt)")
        
        if useStyledPlaceholder {
            // Opção 1: Placeholder estilizado (sempre funciona)
            print("✅ Usando placeholder estilizado (confiável)")
            return generateStylizedPlaceholder(for: recommendation, occasion: occasion)
        } else {
            // Tentar gerar com OpenAI DALL-E
            do {
                return try await generateWithOpenAI(prompt: imagePrompt)
            } catch {
                print("⚠️ OpenAI DALL-E falhou: \(error.localizedDescription)")
                print("📋 Usando fallback para placeholder estilizado")
                return generateStylizedPlaceholder(for: recommendation, occasion: occasion)
            }
        }
    }
    
    // MARK: - Gerar com OpenAI DALL-E
    private func generateWithOpenAI(prompt: String) async throws -> UIImage {
        print("🎨 Gerando imagem com OpenAI DALL-E 3...")
        
        // Garantir chave da OpenAI via variável de ambiente
        guard !openAIApiKey.isEmpty else {
            throw AIError.invalidRequest
        }
        
        guard let url = URL(string: openAIImageEndpoint) else {
            throw AIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(openAIApiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Body da requisição para DALL-E 3
        let body: [String: Any] = [
            "model": "dall-e-3",
            "prompt": prompt,
            "n": 1,
            "size": "1024x1792", // Formato vertical ideal para looks
            "quality": "standard", // "standard" ou "hd"
            "style": "vivid" // "vivid" ou "natural"
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        request.timeoutInterval = 120
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            print("🔢 OpenAI Status Code: \(httpResponse.statusCode)")
        }
        
        // Parse da resposta
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            print("⚠️ Erro ao fazer parse do JSON")
            if let responseText = String(data: data, encoding: .utf8) {
                print("📄 Resposta: \(responseText)")
            }
            throw AIError.invalidResponse
        }
        
        // Verificar se há erro
        if let error = json["error"] as? [String: Any] {
            let errorMessage = error["message"] as? String ?? "Erro desconhecido"
            print("❌ Erro da OpenAI: \(errorMessage)")
            throw AIError.requestFailed
        }
        
        // Extrair URL da imagem
        guard
            let dataArray = json["data"] as? [[String: Any]],
            let firstImage = dataArray.first,
            let imageUrlString = firstImage["url"] as? String,
            let imageUrl = URL(string: imageUrlString)
        else {
            print("⚠️ Estrutura inesperada da resposta: \(json)")
            throw AIError.invalidResponse
        }
        
        print("📡 URL da imagem gerada: \(imageUrlString)")
        
        // Baixar a imagem
        let (imageData, imageResponse) = try await URLSession.shared.data(from: imageUrl)
        
        if let httpResponse = imageResponse as? HTTPURLResponse {
            print("🔢 Download da imagem - Status Code: \(httpResponse.statusCode)")
        }
        
        guard let image = UIImage(data: imageData) else {
            throw AIError.invalidResponse
        }
        
        print("✅ Imagem gerada com sucesso! Tamanho: \(image.size)")
        return image
    }
    
    // MARK: - Criar prompt de imagem otimizado para DALL-E 3
    private func createImagePrompt(
        recommendation: LookRecommendation,
        profile: UserProfile,
        occasion: String
    ) -> String {
        
        // Traduzir ocasião para inglês
        let occasionEN: String
        let occasionDesc: String
        switch occasion {
        case "trabalho": 
            occasionEN = "business professional"
            occasionDesc = "in a modern office setting"
        case "festa": 
            occasionEN = "party festive"
            occasionDesc = "in an elegant evening atmosphere"
        case "esporte": 
            occasionEN = "sports athletic"
            occasionDesc = "in a dynamic sports environment"
        case "casual": 
            occasionEN = "casual everyday"
            occasionDesc = "in a relaxed urban setting"
        default: 
            occasionEN = "casual"
            occasionDesc = "in a neutral setting"
        }
        
        // Construir lista de peças de forma mais descritiva
        let itemsText = recommendation.items.joined(separator: ", ")
        
        // Mapear gênero para inglês
        let genderEN: String
        let genderDesc: String
        switch profile.gender.lowercased() {
        case "masculino", "homem", "male": 
            genderEN = "male"
            genderDesc = "man"
        case "feminino", "mulher", "female": 
            genderEN = "female"
            genderDesc = "woman"
        default: 
            genderEN = "model"
            genderDesc = "person"
        }
        
        // Prompt otimizado para DALL-E 3
        // DALL-E 3 funciona melhor com descrições detalhadas e naturais
        return """
        A professional fashion photography of ONE SINGLE \(genderDesc) wearing a \(occasionEN) outfit. \
        CRITICAL: Show ONLY ONE PERSON, complete FULL BODY from head to toes including feet visible. \
        
        Person details:
        - Gender: \(genderDesc)
        - Body type: \(profile.bodyType)
        - Hair color: \(profile.hairColorName)
        
        Outfit details:
        - Style: \(occasionEN)
        - Items: \(itemsText)
        - Weather appropriate: \(profile.weatherTemperature)°C
        
        BACKGROUND REQUIREMENTS (VERY IMPORTANT):
        - Plain solid WHITE WALL only
        - Completely EMPTY and CLEAN
        - NO decorations, NO objects, NO furniture, NO plants, NO windows, NO doors
        - NO patterns, NO texture, NO shadows on wall
        - Just a simple BLANK WHITE backdrop
        - The wall should be completely featureless to highlight the person 100%
        
        Composition:
        - Centered full-length portrait
        - Front facing view
        - Entire body visible including feet
        - Professional studio lighting
        - High fashion aesthetic
        - Sharp focus on person
        - Vibrant clothing colors
        - Modern and elegant presentation
        """
    }
    
    // MARK: - Extrair JSON de texto
    private func extractJSON(from text: String) -> String? {
        // Procurar por { e } para extrair JSON
        if let startIndex = text.firstIndex(of: "{"),
           let endIndex = text.lastIndex(of: "}") {
            return String(text[startIndex...endIndex])
        }
        return nil
    }
    
    // MARK: - Criar recomendação fallback
    private func createFallbackRecommendation(profile: UserProfile, occasion: String) -> LookRecommendation {
        let title: String
        let items: [String]
        let note: String
        
        switch occasion {
        case "trabalho":
            title = "Look Profissional Elegante"
            items = ["Camisa social", "Calça de alfaiataria", "Sapato social", "Cinto de couro"]
            note = "Mantenha cores neutras para transmitir seriedade e elegância"
            
        case "festa":
            title = "Look Festivo Estiloso"
            items = ["Camisa estampada", "Calça jeans escura", "Tênis branco", "Jaqueta jeans"]
            note = "Adicione acessórios para dar personalidade ao visual"
            
        case "esporte":
            title = "Look Esportivo Confortável"
            items = ["Camiseta dry-fit", "Short esportivo", "Tênis de corrida", "Meia esportiva"]
            note = "Priorize conforto e tecidos que absorvem transpiração"
            
        default: // casual
            title = "Look Casual Descontraído"
            items = ["Camiseta básica", "Jeans confortável", "Tênis casual", "Boné"]
            note = "Perfeito para o dia a dia, confortável e estiloso"
        }
        
        return LookRecommendation(
            title: title,
            description: "Look personalizado criado especialmente para você, com base no seu perfil e preferências",
            items: items,
            styleNote: note
        )
    }
    
    // MARK: - Gerar placeholder estilizado (fallback)
    private func generateStylizedPlaceholder(for recommendation: LookRecommendation, occasion: String) -> UIImage {
        let size = CGSize(width: 512, height: 768)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let image = renderer.image { context in
            // Gradiente roxo bonito
            let gradient = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: [
                    UIColor(red: 0.88, green: 0.82, blue: 1.0, alpha: 1.0).cgColor,
                    UIColor(red: 0.48, green: 0.30, blue: 1.0, alpha: 1.0).cgColor
                ] as CFArray,
                locations: [0.0, 1.0]
            )!
            
            context.cgContext.drawLinearGradient(
                gradient,
                start: CGPoint(x: 0, y: 0),
                end: CGPoint(x: size.width, y: size.height),
                options: []
            )
            
            // Ícone baseado na ocasião
            let icon: String
            switch occasion {
            case "trabalho": icon = "💼"
            case "festa": icon = "🎉"
            case "esporte": icon = "👟"
            default: icon = "👔"
            }
            
            // Desenhar ícone
            let iconAttr: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 100)
            ]
            icon.draw(in: CGRect(x: size.width/2 - 50, y: 150, width: 100, height: 120), withAttributes: iconAttr)
            
            // Configurar estilo de texto
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            
            // Título
            let titleAttr: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 28, weight: .bold),
                .foregroundColor: UIColor.white,
                .paragraphStyle: paragraphStyle
            ]
            recommendation.title.draw(
                in: CGRect(x: 30, y: 320, width: size.width - 60, height: 80),
                withAttributes: titleAttr
            )
            
            // Descrição
            let descAttr: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 18),
                .foregroundColor: UIColor.white.withAlphaComponent(0.95),
                .paragraphStyle: paragraphStyle
            ]
            recommendation.description.draw(
                in: CGRect(x: 30, y: 420, width: size.width - 60, height: 100),
                withAttributes: descAttr
            )
            
            // Itens do look
            let itemsY: CGFloat = 560
            for (index, item) in recommendation.items.prefix(3).enumerated() {
                let text = "✓ " + item
                text.draw(
                    in: CGRect(x: 40, y: itemsY + CGFloat(index * 35), width: size.width - 80, height: 30),
                    withAttributes: [
                        .font: UIFont.systemFont(ofSize: 16),
                        .foregroundColor: UIColor.white.withAlphaComponent(0.9)
                    ]
                )
            }
        }
        
        return image
    }
}

