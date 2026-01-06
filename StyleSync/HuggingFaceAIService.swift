import Foundation

// MARK: - Serviço de IA com Hugging Face (100% GRATUITO)
class HuggingFaceAIService {
    
    // ⚠️ Substitua pelo seu token do Hugging Face
    // Obtenha em: https://huggingface.co/settings/tokens
    private let apiToken = "SEU_TOKEN_HUGGINGFACE_AQUI"
    private let endpoint = "https://router.huggingface.co/models/mistralai/Mixtral-8x7B-Instruct-v0.1"
    
    // MARK: - Gerar recomendação
    func generateLookRecommendation(
        profile: UserProfile,
        occasion: String = "casual"
    ) async throws -> LookRecommendation {
        
        let prompt = """
        Você é um stylist profissional brasileiro. Crie UMA recomendação de look no formato JSON:
        
        Perfil:
        - Gênero: \(profile.gender)
        - Corpo: \(profile.bodyType)
        - Cabelo: \(profile.hairColorName)
        - Música: \(profile.musicGenres.joined(separator: ", "))
        - Clima: \(profile.weatherTemperature)°C
        - Ocasião: \(occasion)
        
        Retorne APENAS este JSON:
        {"title":"Nome curto","description":"Descrição de 1 linha","items":["peça 1","peça 2","peça 3"],"styleNote":"Dica rápida"}
        """
        
        let requestBody: [String: Any] = [
            "inputs": prompt,
            "parameters": [
                "max_new_tokens": 200,
                "temperature": 0.7,
                "return_full_text": false
            ]
        ]
        
        guard let url = URL(string: endpoint) else {
            throw AIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw AIError.requestFailed
        }
        
        // Parse Hugging Face response
        if let jsonArray = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]],
           let firstResult = jsonArray.first,
           let generatedText = firstResult["generated_text"] as? String {
            
            // Extrair JSON do texto gerado
            if let jsonData = generatedText.data(using: .utf8),
               let recommendation = try? JSONDecoder().decode(LookRecommendation.self, from: jsonData) {
                return recommendation
            }
        }
        
        throw AIError.invalidResponse
    }
}
