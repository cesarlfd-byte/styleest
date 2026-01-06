import Foundation

// MARK: - Serviço Mock para testes (sem necessidade de API)
class MockAIService {
    
    func generateMockRecommendations(profile: UserProfile) -> [Look] {
        let isCold = profile.weatherTemperature < 20
        let isHot = profile.weatherTemperature > 28
        
        let mockLooks = [
            Look(
                title: "IA: Estilo Personalizado",
                description: "Look criado especialmente para \(profile.gender) com base em seu perfil musical \(profile.musicGenres.first ?? "eclético")",
                imageName: "ai_mock_1",
                tags: ["IA", "Personalizado", "Casual"]
            ),
            Look(
                title: "IA: Clima Perfeito",
                description: "\(isCold ? "Look térmico" : isHot ? "Look refrescante" : "Look versátil") para \(profile.weatherTemperature)° em \(profile.weatherLocation)",
                imageName: "ai_mock_2",
                tags: ["IA", "Clima", "Conforto"]
            ),
            Look(
                title: "IA: Seu Biotipo",
                description: "Peças que valorizam corpo tipo \(profile.bodyType) e harmonizam com cabelo \(profile.hairColorName)",
                imageName: "ai_mock_3",
                tags: ["IA", "Biotipo", "Elegante"]
            )
        ]
        
        return mockLooks
    }
}
