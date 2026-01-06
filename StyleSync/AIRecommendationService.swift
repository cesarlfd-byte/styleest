import Foundation
import UIKit
import Combine

// MARK: - Serviço de IA para Recomendações (Hugging Face - 100% GRATUITO)
class AIRecommendationService: ObservableObject {
    
    // ⚠️ IMPORTANTE: Substitua pelo seu token do Hugging Face
    // Obtenha em: https://huggingface.co/settings/tokens
    private let apiToken = ProcessInfo.processInfo.environment["HUGGINGFACE_API_TOKEN"] ?? ""
    
    // Modelo gratuito e poderoso da Hugging Face (ENDPOINT ATUALIZADO)
    private let endpoint = "https://router.huggingface.co/models/meta-llama/Meta-Llama-3-8B-Instruct"
    
    // MARK: - Gerar recomendação personalizada
    func generateLookRecommendation(
        gender: String,
        bodyType: String,
        hairColor: String,
        musicGenres: [String],
        temperature: Int,
        weatherCondition: String,
        occasion: String = "casual"
    ) async throws -> LookRecommendation {
        
        let prompt = """
        Você é um stylist profissional brasileiro especializado em moda. Analise este perfil e crie UMA recomendação de look:

        PERFIL:
        - Gênero: \(gender)
        - Tipo de corpo: \(bodyType)
        - Cor do cabelo: \(hairColor)
        - Estilo musical favorito: \(musicGenres.joined(separator: ", "))
        - Temperatura atual: \(temperature)°C
        - Clima: \(weatherCondition)
        - Ocasião: \(occasion)

        Responda APENAS com um objeto JSON válido no seguinte formato exato (sem markdown, sem texto adicional, apenas o JSON):
        {"title":"Nome criativo do look","description":"Breve descrição das peças principais","items":["peça 1","peça 2","peça 3","peça 4"],"styleNote":"Dica de estilo"}

        Exemplo de resposta esperada:
        {"title":"Urban Chill","description":"Moletom oversized, calça cargo e tênis chunky","items":["Moletom cinza oversized","Calça cargo preta","Tênis chunky branco","Boné preto"],"styleNote":"Combine com acessórios minimalistas para um look urbano moderno"}
        """
        
        // Ensure API token is present from environment
        guard !apiToken.isEmpty else {
            // If missing token, return a safe fallback recommendation instead of calling the API
            return generateFallbackLook(
                gender: gender,
                bodyType: bodyType,
                temperature: temperature,
                occasion: occasion
            )
        }
        
        let requestBody: [String: Any] = [
            "inputs": prompt,
            "parameters": [
                "max_new_tokens": 250,
                "temperature": 0.7,
                "top_p": 0.9,
                "do_sample": true,
                "return_full_text": false
            ],
            "options": [
                "wait_for_model": true,
                "use_cache": false
            ]
        ]
        
        guard let url = URL(string: endpoint) else {
            throw AIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            throw AIError.invalidRequest
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AIError.requestFailed
        }
        
        // Log para debug
        print("Status Code: \(httpResponse.statusCode)")
        
        if httpResponse.statusCode != 200 {
            if let errorString = String(data: data, encoding: .utf8) {
                print("Error Response: \(errorString)")
            }
            throw AIError.requestFailed
        }
        
        // Parse Hugging Face response
        do {
            if let jsonArray = try JSONSerialization.jsonObject(with: data) as? [[String: Any]],
               let firstResult = jsonArray.first,
               let generatedText = firstResult["generated_text"] as? String {
                
                print("Generated Text: \(generatedText)")
                
                // Limpar o texto e extrair JSON
                let cleanedText = cleanGeneratedText(generatedText)
                
                if let jsonData = cleanedText.data(using: .utf8),
                   let recommendation = try? JSONDecoder().decode(LookRecommendation.self, from: jsonData) {
                    return recommendation
                }
            }
        } catch {
            print("Parse error: \(error)")
        }
        
        // Se falhar, retornar um look genérico baseado no perfil
        return generateFallbackLook(
            gender: gender,
            bodyType: bodyType,
            temperature: temperature,
            occasion: occasion
        )
    }
    
    // MARK: - Limpar texto gerado
    private func cleanGeneratedText(_ text: String) -> String {
        // Remove markdown
        var cleaned = text.replacingOccurrences(of: "```json", with: "")
        cleaned = cleaned.replacingOccurrences(of: "```", with: "")
        
        // Procura por JSON válido
        if let startIndex = cleaned.range(of: "{")?.lowerBound,
           let endIndex = cleaned.range(of: "}", options: .backwards)?.upperBound {
            cleaned = String(cleaned[startIndex..<endIndex])
        }
        
        return cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    // MARK: - Look de fallback (caso a IA falhe)
    private func generateFallbackLook(
        gender: String,
        bodyType: String,
        temperature: Int,
        occasion: String
    ) -> LookRecommendation {
        
        let isCold = temperature < 20
        let isHot = temperature > 28
        
        if isCold {
            return LookRecommendation(
                title: "Conforto Térmico",
                description: "Suéter, calça jeans e botas",
                items: ["Suéter de tricô", "Calça jeans", "Botas de couro", "Cachecol"],
                styleNote: "Adicione camadas para manter o calor com estilo"
            )
        } else if isHot {
            return LookRecommendation(
                title: "Frescor Urbano",
                description: "Camiseta leve, shorts e tênis",
                items: ["Camiseta básica", "Shorts de sarja", "Tênis leve", "Óculos de sol"],
                styleNote: "Escolha tecidos leves e respiráveis"
            )
        } else {
            return LookRecommendation(
                title: "Versátil \(occasion.capitalized)",
                description: "Look equilibrado e confortável",
                items: ["Camisa casual", "Calça chino", "Tênis branco", "Jaqueta leve"],
                styleNote: "Perfeito para transições de temperatura"
            )
        }
    }
    
    // MARK: - Gerar múltiplas recomendações
    func generateMultipleRecommendations(
        profile: UserProfile,
        count: Int = 3
    ) async throws -> [Look] {
        var looks: [Look] = []
        
        for i in 0..<count {
            let occasion = i == 0 ? "casual" : i == 1 ? "trabalho" : "festa"
            
            do {
                let recommendation = try await generateLookRecommendation(
                    gender: profile.gender,
                    bodyType: profile.bodyType,
                    hairColor: profile.hairColorName,
                    musicGenres: profile.musicGenres,
                    temperature: profile.weatherTemperature,
                    weatherCondition: profile.weatherCondition,
                    occasion: occasion
                )
                
                let look = Look(
                    title: recommendation.title,
                    description: recommendation.description,
                    imageName: "ai_look_\(i)",
                    tags: ["IA", occasion.capitalized, "Personalizado"]
                )
                
                looks.append(look)
                
                // Delay pequeno entre requisições
                if i < count - 1 {
                    try await Task.sleep(nanoseconds: 500_000_000) // 0.5 segundos
                }
            } catch {
                print("Error generating look \(i): \(error)")
                // Continua gerando os próximos mesmo se um falhar
            }
        }
        
        // Se nenhum look foi gerado, retorna looks de fallback
        if looks.isEmpty {
            looks = generateFallbackLooks(profile: profile)
        }
        
        return looks
    }
    
    // MARK: - Looks de fallback
    private func generateFallbackLooks(profile: UserProfile) -> [Look] {
        return [
            Look(
                title: "Casual Diário",
                description: "Look confortável para o dia a dia baseado no seu perfil",
                imageName: "ai_look_0",
                tags: ["IA", "Casual", "Conforto"]
            ),
            Look(
                title: "Trabalho Elegante",
                description: "Visual profissional que valoriza seu biotipo",
                imageName: "ai_look_1",
                tags: ["IA", "Trabalho", "Elegante"]
            ),
            Look(
                title: "Noite Especial",
                description: "Look sofisticado para ocasiões especiais",
                imageName: "ai_look_2",
                tags: ["IA", "Festa", "Sofisticado"]
            )
        ]
    }
}

// MARK: - Modelos
struct LookRecommendation: Codable {
    let title: String
    let description: String
    let items: [String]
    let styleNote: String
}

// Modelo para look completo com imagem
struct CompleteLook: Identifiable {
    let id = UUID() // Identificador único para cada look gerado
    let recommendation: LookRecommendation
    let image: UIImage
    let occasion: String
}

enum AIError: LocalizedError {
    case invalidURL
    case invalidRequest
    case requestFailed
    case noResponse
    case invalidResponse
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "URL inválida"
        case .invalidRequest:
            return "Erro ao preparar requisição"
        case .requestFailed:
            return "Falha na conexão com a IA. Verifique sua conexão com a internet."
        case .noResponse:
            return "A IA não retornou uma resposta"
        case .invalidResponse:
            return "Resposta da IA em formato inválido"
        }
    }
}

