import Foundation
import Combine

// MARK: - Serviço de Tendências de Moda
// Gera tendências personalizadas usando IA baseadas no perfil do usuário
class FashionTrendsService: ObservableObject {
    
    private let apiToken = "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"
    private let textEndpoint = "https://router.huggingface.co/models/meta-llama/Meta-Llama-3-8B-Instruct"
    
    // MARK: - Gerar tendências da semana
    func generateWeeklyTrends(profile: UserProfile) async throws -> [FashionTrend] {
        
        // Obter data atual
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "pt_BR")
        dateFormatter.dateFormat = "MMMM 'de' yyyy"
        let currentDate = dateFormatter.string(from: Date())
        
        let prompt = """
        Você é um especialista em tendências de moda internacional. Analise o perfil e crie 5 tendências de moda atuais da semana, personalizadas para este perfil.
        
        DATA ATUAL: \(currentDate)
        
        PERFIL DO USUÁRIO:
        - Gênero: \(profile.gender)
        - Tipo de corpo: \(profile.bodyType)
        - Cor de cabelo: \(profile.hairColorName)
        - Estilos musicais favoritos: \(profile.musicGenres.joined(separator: ", "))
        - Temperatura: \(profile.weatherTemperature)°C
        
        Crie tendências REAIS e ATUAIS de \(currentDate). Considere:
        - Semanas de moda recentes (Paris, Milão, Nova York, São Paulo)
        - Tendências do TikTok e Instagram
        - Sustentabilidade e moda consciente
        - Streetwear e alta costura
        
        Retorne APENAS um JSON válido neste formato:
        {"trends":[{"title":"Nome da Tendência","description":"Descrição breve","category":"Categoria","relevanceScore":95,"tags":["tag1","tag2"],"howToWear":"Como usar esta tendência"},{"title":"..."}]}
        
        Exemplo:
        {"trends":[{"title":"Quiet Luxury","description":"Peças minimalistas de alta qualidade em tons neutros","category":"Minimalismo","relevanceScore":98,"tags":["minimalismo","luxo","neutro"],"howToWear":"Combine peças atemporais em tons bege, cinza e branco com tecidos nobres"}]}
        """
        
        let requestBody: [String: Any] = [
            "inputs": prompt,
            "parameters": [
                "max_new_tokens": 800,
                "temperature": 0.7,
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
        request.timeoutInterval = 30
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        // Parse da resposta
        if let jsonArray = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]],
           let firstResult = jsonArray.first,
           let generatedText = firstResult["generated_text"] as? String {
            
            print("📊 Tendências geradas: \(generatedText)")
            
            // Extrair JSON do texto
            if let jsonData = extractJSON(from: generatedText)?.data(using: .utf8),
               let response = try? JSONDecoder().decode(TrendsResponse.self, from: jsonData) {
                return response.trends
            }
        }
        
        // Fallback: tendências genéricas personalizadas
        return generateFallbackTrends(profile: profile)
    }
    
    // MARK: - Buscar tendência específica por categoria
    func getTrendsByCategory(
        category: TrendCategory,
        profile: UserProfile
    ) async throws -> [FashionTrend] {
        let allTrends = try await generateWeeklyTrends(profile: profile)
        return allTrends.filter { $0.category.lowercased().contains(category.rawValue.lowercased()) }
    }
    
    // MARK: - Gerar conteúdo "Para Sua Vibe" (Tendências + Música)
    func generateVibeContent(profile: UserProfile) async throws -> VibeContent {
        
        // Obter data atual
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "pt_BR")
        dateFormatter.dateFormat = "MMMM 'de' yyyy"
        let currentDate = dateFormatter.string(from: Date())
        
        let prompt = """
        Você é um curador cultural especializado em moda e música. Crie conteúdo personalizado para este perfil.
        
        DATA ATUAL: \(currentDate)
        
        PERFIL:
        - Gênero: \(profile.gender)
        - Estilos musicais: \(profile.musicGenres.joined(separator: ", "))
        - Tipo de corpo: \(profile.bodyType)
        - Clima: \(profile.weatherTemperature)°C
        
        Crie 4 cards de conteúdo (2 de moda + 2 de música):
        
        MODA (2 cards):
        - Tendências atuais de \(currentDate)
        - Como aplicar no guarda-roupa
        
        MÚSICA (2 cards):
        - Notícias/lançamentos dos gêneros favoritos
        - Artistas trendy que combinam com o estilo
        
        Retorne APENAS JSON válido:
        {"cards":[
          {"type":"fashion","icon":"sparkles","title":"Título","content":"Conteúdo breve (2-3 linhas)","tag":"Tendência"},
          {"type":"music","icon":"music.note","title":"Artista X em Alta","content":"Por que está trendy","tag":"Artista"}
        ]}
        """
        
        let requestBody: [String: Any] = [
            "inputs": prompt,
            "parameters": [
                "max_new_tokens": 600,
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
        request.timeoutInterval = 30
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        // Parse da resposta
        if let jsonArray = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]],
           let firstResult = jsonArray.first,
           let generatedText = firstResult["generated_text"] as? String {
            
            print("🎵 Vibe content gerado: \(generatedText)")
            
            // Extrair JSON do texto
            if let jsonData = extractJSON(from: generatedText)?.data(using: .utf8),
               let response = try? JSONDecoder().decode(VibeContent.self, from: jsonData) {
                return response
            }
        }
        
        // Fallback: conteúdo personalizado
        return generateFallbackVibeContent(profile: profile)
    }
    
    // MARK: - Extrair JSON de texto
    private func extractJSON(from text: String) -> String? {
        if let startIndex = text.firstIndex(of: "{"),
           let endIndex = text.lastIndex(of: "}") {
            return String(text[startIndex...endIndex])
        }
        return nil
    }
    
    // MARK: - Tendências fallback (sempre funcionam)
    private func generateFallbackTrends(profile: UserProfile) -> [FashionTrend] {
        let year = "2026"
        let isCold = profile.weatherTemperature < 20
        
        var trends: [FashionTrend] = [
            FashionTrend(
                title: "Quiet Luxury",
                description: "Minimalismo sofisticado com peças atemporais em tons neutros",
                category: "Minimalismo",
                relevanceScore: 98,
                tags: ["minimalismo", "luxo", "atemporal"],
                howToWear: "Combine peças de alfaiataria impecável em tons bege, cinza e branco. Foque em tecidos nobres como cashmere e seda."
            ),
            FashionTrend(
                title: "Tech Wear \(year)",
                description: "Roupas funcionais com elementos tecnológicos e design futurista",
                category: "Streetwear",
                relevanceScore: 92,
                tags: ["tech", "futurista", "funcional"],
                howToWear: "Peças com bolsos utilitários, tecidos impermeáveis e silhuetas oversized. Combine preto com detalhes em neon."
            ),
            FashionTrend(
                title: "Moda Sustentável",
                description: "Peças eco-friendly e upcycling com consciência ambiental",
                category: "Sustentabilidade",
                relevanceScore: 95,
                tags: ["sustentável", "eco", "consciente"],
                howToWear: "Invista em peças vintage, brechó e marcas sustentáveis. Priorize qualidade sobre quantidade."
            ),
            FashionTrend(
                title: "Gorpcore Evolved",
                description: "Estética outdoor sofisticada para o dia a dia urbano",
                category: "Streetwear",
                relevanceScore: 88,
                tags: ["outdoor", "urbano", "conforto"],
                howToWear: "Combine jaquetas técnicas, cargo pants e tênis de trilha com peças casuais elegantes."
            )
        ]
        
        // Adicionar tendência específica para o clima
        if isCold {
            trends.append(FashionTrend(
                title: "Layering Artístico",
                description: "Sobreposição criativa de camadas para clima frio",
                category: "Inverno",
                relevanceScore: 90,
                tags: ["layering", "inverno", "criativo"],
                howToWear: "Combine diferentes texturas e comprimentos. Base térmica + camisa + suéter + jaqueta + casaco."
            ))
        } else {
            trends.append(FashionTrend(
                title: "Linho Contemporâneo",
                description: "Peças leves e sofisticadas para o calor",
                category: "Verão",
                relevanceScore: 90,
                tags: ["linho", "verão", "leve"],
                howToWear: "Camisas e calças de linho em tons claros. Combine com acessórios minimalistas."
            ))
        }
        
        // Personalizar por estilo musical
        if profile.musicGenres.contains(where: { $0.lowercased().contains("rock") || $0.lowercased().contains("metal") }) {
            trends[1].relevanceScore = 96 // Tech Wear mais relevante
        }
        
        if profile.musicGenres.contains(where: { $0.lowercased().contains("jazz") || $0.lowercased().contains("clássica") }) {
            trends[0].relevanceScore = 99 // Quiet Luxury mais relevante
        }
        
        return trends.sorted { $0.relevanceScore > $1.relevanceScore }
    }
    
    // MARK: - Conteúdo Vibe fallback
    private func generateFallbackVibeContent(profile: UserProfile) -> VibeContent {
        var cards: [VibeCard] = []
        
        // Card 1: Tendência de Moda
        let fashionCard1 = VibeCard(
            type: .fashion,
            icon: "sparkles",
            title: "Quiet Luxury em Alta",
            content: "O minimalismo sofisticado continua dominando 2026. Invista em peças atemporais em tons neutros e tecidos nobres.",
            tag: "Tendência"
        )
        
        // Card 2: Dica de Styling baseada no clima
        let isCold = profile.weatherTemperature < 20
        let fashionCard2 = VibeCard(
            type: .fashion,
            icon: isCold ? "snowflake" : "sun.max",
            title: isCold ? "Layering Criativo" : "Leve e Sofisticado",
            content: isCold 
                ? "Sobreponha camadas com texturas diferentes. Mix de tricô, denim e couro cria profundidade visual."
                : "Linho e algodão em tons claros são essenciais. Combine com acessórios minimalistas para elevar o look.",
            tag: "Styling"
        )
        
        // Card 3: Artista Trendy baseado no gênero musical
        var musicCard1: VibeCard
        let primaryGenre = profile.musicGenres.first?.lowercased() ?? "pop"
        
        if primaryGenre.contains("rock") || primaryGenre.contains("metal") {
            musicCard1 = VibeCard(
                type: .music,
                icon: "guitars",
                title: "Sleep Token em Ascensão",
                content: "A banda britânica mistura metal progressivo com elementos atmosféricos. Perfeito para quem gosta de inovação sonora.",
                tag: "Artista"
            )
        } else if primaryGenre.contains("jazz") || primaryGenre.contains("blues") {
            musicCard1 = VibeCard(
                type: .music,
                icon: "music.note",
                title: "Norah Jones: Novo Álbum",
                content: "A cantora retorna com sonoridade intimista e sofisticada. Ideal para momentos de reflexão e estilo.",
                tag: "Artista"
            )
        } else if primaryGenre.contains("eletrônica") || primaryGenre.contains("eletronica") {
            musicCard1 = VibeCard(
                type: .music,
                icon: "waveform",
                title: "Fred again.. Domina Festivais",
                content: "O produtor britânico revoluciona a cena eletrônica com sets emocionantes e produções íntimas.",
                tag: "Artista"
            )
        } else if primaryGenre.contains("rap") || primaryGenre.contains("hip hop") {
            musicCard1 = VibeCard(
                type: .music,
                icon: "mic",
                title: "Kendrick Lamar: Nova Era",
                content: "O rapper continua redefinindo o hip hop com letras profundas e produções inovadoras.",
                tag: "Artista"
            )
        } else {
            musicCard1 = VibeCard(
                type: .music,
                icon: "music.note.list",
                title: "Taylor Swift: The Eras Tour",
                content: "A artista pop mais influente do momento. Seu estilo eclético inspira tendências globais de moda.",
                tag: "Artista"
            )
        }
        
        // Card 4: Notícia Musical
        let musicCard2 = VibeCard(
            type: .music,
            icon: "newspaper",
            title: "Festivais de 2026",
            content: "Lollapalooza, Rock in Rio e Primavera Sound confirmam line-ups históricos. Prepare o guarda-roupa para a temporada!",
            tag: "Evento"
        )
        
        cards = [fashionCard1, fashionCard2, musicCard1, musicCard2]
        
        return VibeContent(cards: cards)
    }
}

// MARK: - Modelos de Dados

struct FashionTrend: Identifiable, Codable {
    let id = UUID()
    let title: String
    let description: String
    let category: String
    var relevanceScore: Int // 0-100 (quanto mais alto, mais relevante para o perfil)
    let tags: [String]
    let howToWear: String
    
    enum CodingKeys: String, CodingKey {
        case title, description, category, relevanceScore, tags, howToWear
    }
}

struct TrendsResponse: Codable {
    let trends: [FashionTrend]
}

enum TrendCategory: String, CaseIterable {
    case all = "Todas"
    case streetwear = "Streetwear"
    case minimal = "Minimalismo"
    case luxury = "Luxo"
    case sustainable = "Sustentável"
    case casual = "Casual"
    case formal = "Formal"
    case seasonal = "Sazonal"
}
// MARK: - Modelos "Para Sua Vibe"

struct VibeCard: Identifiable, Codable {
    let id = UUID()
    let type: VibeCardType
    let icon: String // SF Symbol name
    let title: String
    let content: String
    let tag: String
    
    enum CodingKeys: String, CodingKey {
        case type, icon, title, content, tag
    }
}

enum VibeCardType: String, Codable {
    case fashion = "fashion"
    case music = "music"
    case trend = "trend"
    case artist = "artist"
}

struct VibeContent: Codable {
    let cards: [VibeCard]
}


