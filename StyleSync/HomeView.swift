import SwiftUI

struct HomeView: View {
    @EnvironmentObject var profile: UserProfile
    @EnvironmentObject var favoritesManager: FavoritesManager
    @StateObject private var trendsService = FashionTrendsService()
    @StateObject private var aiService = AIRecommendationService()
    @State private var vibeContent: VibeContent?
    @State private var isLoadingVibe = false
    @State private var aiTodayLook: Look?
    
    // ✅ Propriedades computadas
    private var todayLooks: [Look] {
        let temperature = profile.weatherTemperature
        let isCold = temperature < 20
        let isHot = temperature > 28
        let isRainy = profile.weatherCondition.contains("rain")
        let bodyType = profile.bodyType.lowercased()
        
        if isRainy {
            return [
                Look(title: "Estilo urbano à prova d'água", description: "Jaqueta impermeável, calça skinny e botas.", imageName: "look_rain", tags: ["Clima", "Chuva"]),
                Look(title: "Cores vibrantes na chuva", description: "Guarda-chuva colorido, trench coat e ankle boots.", imageName: "look_rain2", tags: ["Clima", "Estilo"]),
                Look(title: "Conforto indoor", description: "Moletom, legging e chinelos fofos. Ideal para dias em casa!", imageName: "look_rain3", tags: ["Clima", "Relax"])
            ]
        } else if isCold {
            return [
                Look(title: "Casual de inverno", description: "Suéter chunky, calça jeans e botas.", imageName: "look_cold", tags: ["Clima", "Frio"]),
                Look(title: "Elegância térmica", description: "Casaco longo, bota cano alto e cachecol.", imageName: "look_cold2", tags: ["Clima", "Elegante"]),
                Look(title: "Conforto total", description: "Pijama estiloso com robe e pantufas. Quem disse que não?", imageName: "look_cold3", tags: ["Clima", "Home"])
            ]
        } else if isHot {
            return [
                Look(title: "Verão refrescante", description: "Vestido leve, sandálias e óculos.", imageName: "look_hot", tags: ["Clima", "Calor"]),
                Look(title: "Praia urbana", description: "Shorts, cropp top e chapéu de palha.", imageName: "look_hot2", tags: ["Clima", "Verão"]),
                Look(title: "Fresh office", description: "Blusa de linho, saia midi e rasteirinhas.", imageName: "look_hot3", tags: ["Clima", "Trabalho"])
            ]
        } else {
            return [
                Look(title: "Look versátil", description: "Camisa leve, shorts e tênis.", imageName: "look_mild", tags: ["Clima", "Morno"]),
                Look(title: "Estilo caminhada", description: "Tênis confortável, mochila e óculos de sol.", imageName: "look_mild2", tags: ["Clima", "Passeio"]),
                Look(title: "Transição perfeita", description: "Cardigã leve, camiseta básica e calça jogger.", imageName: "look_mild3", tags: ["Clima", "Versátil"])
            ]
        }
    }
    
    private var musicLooks: [Look] {
        if profile.musicGenres.contains("Rock") {
            return [
                Look(title: "Rock clássico", description: "Camiseta preta, jeans rasgado e coturno.", imageName: "look_rock", tags: ["Música", "Rock"]),
                Look(title: "Estilo festival", description: "Coleira, pulseiras e jaqueta de couro.", imageName: "look_rock2", tags: ["Música", "Festival"]),
                Look(title: "Rock minimalista", description: "Tons sóbrios, silhuetas fortes e acessórios discretos.", imageName: "look_rock3", tags: ["Música", "Minimal"])
            ]
        } else if profile.musicGenres.contains("Pop") {
            return [
                Look(title: "Pop colorido", description: "Cropped neon, saia midi e acessórios brilhantes.", imageName: "look_pop", tags: ["Música", "Pop"]),
                Look(title: "Estilo palco", description: "Lantejoulas, brilho e shapes ousados.", imageName: "look_pop2", tags: ["Música", "Show"]),
                Look(title: "Pop casual", description: "Tênis brancos, jeans e top estampado.", imageName: "look_pop3", tags: ["Música", "Dia a Dia"])
            ]
        } else if profile.musicGenres.contains("Hip Hop") {
            return [
                Look(title: "Streetwear clássico", description: "Moletom oversized, calça baggy e tênis chunky.", imageName: "look_hiphop", tags: ["Música", "Hip Hop"]),
                Look(title: "Luxo urbano", description: "Peças de grife, logomania e drapeados.", imageName: "look_hiphop2", tags: ["Música", "Luxo"]),
                Look(title: "Conforto e atitude", description: "Conjunto de moletom, boné e óculos redondo.", imageName: "look_hiphop3", tags: ["Música", "Conforto"])
            ]
        } else {
            return [
                Look(title: "Estilo neutro", description: "Peças versáteis que combinam com qualquer vibe.", imageName: "look_neutral", tags: ["Música", "Neutro"]),
                Look(title: "Basics poderosos", description: "Preto, branco e cinza com cortes perfeitos.", imageName: "look_neutral2", tags: ["Música", "Essencial"]),
                Look(title: "Toque pessoal", description: "Adicione um acessório que represente você!", imageName: "look_neutral3", tags: ["Música", "Você"])
            ]
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    HStack(spacing: 0) {
                        Text("Seu estilo, seu jeito")
                            .font(.title2)
                            .foregroundColor(.primary)
                    }
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal)

                    if !profile.weatherLocation.isEmpty {
                        HStack(spacing: 8) {
                            Image(systemName: profile.weatherCondition)
                                .font(.caption)
                                .foregroundColor(AppColors.primaryPurple)
                            
                            Text("\(profile.weatherTemperature)° • \(profile.weatherLocation)")
                                .font(.callout)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal)
                    }
                    
                    // Looks para hoje (um card)
                    if let look = aiTodayLook ?? todayLooks.first {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Looks para hoje")
                                .font(.title2.bold())
                            LookCard(look: look)
                                .padding(.horizontal, 8)
                                .frame(height: 220)
                        }
                        .padding(.horizontal)
                    }
                    
                    // ✅ Para a sua vibe - Tendências + Música
                    if !profile.musicGenres.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Para a sua vibe")
                                    .font(.title2.bold())
                                
                                Spacer()
                                
                                if isLoadingVibe {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                }
                            }
                            
                            if let content = vibeContent {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 16) {
                                        ForEach(content.cards) { card in
                                            VibeCardView(card: card)
                                                .frame(width: 280)
                                        }
                                    }
                                    .padding(.horizontal, 2)
                                }
                            } else {
                                // Placeholder enquanto carrega
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 16) {
                                        ForEach(0..<4, id: \.self) { _ in
                                            VibeCardPlaceholder()
                                                .frame(width: 280)
                                        }
                                    }
                                    .padding(.horizontal, 2)
                                }
                            }
                        }
                        .padding(.horizontal)
                        .task {
                            await loadVibeContent()
                        }
                    }
                    
                    // ✅ Favoritos recentes (até 5) - sempre por último
                    if !favoritesManager.favorites.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Favoritos recentes")
                                .font(.title2.bold())
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(Array(favoritesManager.favorites.prefix(5))) { favorite in
                                        FavoriteLookCard(
                                            favoriteLook: favorite,
                                            onRemove: {
                                                withAnimation { favoritesManager.removeFavorite(favorite) }
                                            },
                                            onShare: {
                                                let text = "\n\(favorite.title)\n\(favorite.description)\nTags: \(favorite.tags.joined(separator: ", "))"
                                                let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
                                                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                                                   let rootVC = windowScene.windows.first?.rootViewController {
                                                    rootVC.present(activityVC, animated: true)
                                                }
                                            }
                                        )
                                        .frame(width: 280)
                                    }
                                }
                                .padding(.horizontal, 2)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer()
                }
                .padding(.top, 12)
                .navigationTitle("styleest.")
                .navigationBarTitleDisplayMode(.large)
                .task {
                    await loadAITodayLook()
                }
            }
            .scrollIndicators(.hidden)
        }
    }
    
    // MARK: - Functions
    
    private func loadVibeContent() async {
        guard vibeContent == nil && !isLoadingVibe else { return }
        
        isLoadingVibe = true
        
        do {
            let content = try await trendsService.generateVibeContent(profile: profile)
            await MainActor.run {
                vibeContent = content
                isLoadingVibe = false
            }
        } catch {
            print("❌ Erro ao carregar conteúdo vibe: \(error)")
            await MainActor.run {
                isLoadingVibe = false
            }
        }
    }
    
    private func loadAITodayLook() async {
        guard aiTodayLook == nil else { return }
        do {
            let rec = try await aiService.generateLookRecommendation(
                gender: profile.gender,
                bodyType: profile.bodyType,
                hairColor: profile.hairColorName,
                musicGenres: profile.musicGenres,
                temperature: profile.weatherTemperature,
                weatherCondition: profile.weatherCondition,
                occasion: "casual"
            )
            let look = Look(title: rec.title, description: rec.description, imageName: "ai_today", tags: ["IA", "Hoje", "Personalizado"])
            await MainActor.run { aiTodayLook = look }
        } catch {
            // fallback fica pelo todayLooks.first
            print("Falha IA looks hoje: \(error)")
        }
    }
}

// MARK: - Componente LookCard (REFORMULADO)
struct LookCard: View {
    let look: Look
    
    // Cores baseadas nas tags do look
    private var cardColor: Color {
        if look.tags.contains("Clima") {
            if look.tags.contains("Frio") {
                return Color.blue
            } else if look.tags.contains("Calor") {
                return Color.orange
            } else if look.tags.contains("Chuva") {
                return Color.cyan
            } else {
                return Color.green
            }
        } else if look.tags.contains("Música") {
            return AppColors.primaryPurple
        } else {
            return Color.indigo
        }
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            // Fundo sólido do card na cor definida
            RoundedRectangle(cornerRadius: 16)
                .fill(cardColor)
            
            // Ícone e temperatura no mesmo tom com 50% de opacidade
            VStack(alignment: .trailing, spacing: 4) {
                Image(systemName: weatherIcon)
                    .font(.system(size: 64))
                    .foregroundColor(.white.opacity(0.5))
                if let temp = weatherTemperature {
                    Text("\(temp)°C")
                        .font(.title.bold())
                        .foregroundColor(.white.opacity(0.5))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            .padding(16)
            
            // Conteúdo textual por cima
            VStack(alignment: .leading, spacing: 8) {
                Text(look.title)
                    .font(.headline)
                    .foregroundColor(.white)
                    .lineLimit(1)
                Text(look.description)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.9))
                    .lineLimit(2)
                HStack(spacing: 6) {
                    ForEach(look.tags, id: \.self) { tag in
                        Text(tag)
                            .font(.caption2)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.white.opacity(0.2))
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                    }
                }
                .padding(.top, 4)
                Spacer(minLength: 0)
            }
            .padding(16)
        }
        .frame(height: 220)
        .shadow(color: .black.opacity(0.1), radius: 12, x: 0, y: 6)
    }
    
    // MARK: - Computed Properties
    
    private var weatherIcon: String {
        if look.tags.contains("Frio") {
            return "snowflake"
        } else if look.tags.contains("Calor") {
            return "sun.max.fill"
        } else if look.tags.contains("Chuva") {
            return "cloud.rain.fill"
        } else {
            return "cloud.sun.fill"
        }
    }
    
    private var weatherTemperature: Int? {
        // Retorna temperatura baseada na tag
        if look.tags.contains("Frio") {
            return 15
        } else if look.tags.contains("Calor") {
            return 30
        } else if look.tags.contains("Chuva") {
            return 18
        } else {
            return 22
        }
    }
}

// MARK: - Componente VibeCardView (SEM favoritar)
struct VibeCardView: View {
    let card: VibeCard
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Ícone + Tag
            HStack {
                Image(systemName: card.icon)
                    .font(.title2)
                    .foregroundColor(card.type == .fashion ? AppColors.primaryPurple : .blue)
                
                Spacer()
                
                Text(card.tag)
                    .font(.caption2.bold())
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(card.type == .fashion 
                                ? AppColors.primaryPurple.opacity(0.15) 
                                : Color.blue.opacity(0.15)
                            )
                    )
                    .foregroundColor(card.type == .fashion ? AppColors.primaryPurple : .blue)
            }
            
            // Título
            Text(card.title)
                .font(.headline)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
            
            // Conteúdo
            Text(card.content)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(4)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
        }
        .padding(16)
        .frame(height: 180)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    card.type == .fashion 
                        ? AppColors.primaryPurple.opacity(0.2)
                        : Color.blue.opacity(0.2),
                    lineWidth: 1
                )
        )
    }
}

// MARK: - Placeholder para VibeCard
struct VibeCardPlaceholder: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Circle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 32, height: 32)
                
                Spacer()
                
                Capsule()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 60, height: 20)
            }
            
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.gray.opacity(0.2))
                .frame(height: 20)
                .frame(maxWidth: 200)
            
            VStack(spacing: 6) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.15))
                    .frame(height: 14)
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.15))
                    .frame(height: 14)
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.15))
                    .frame(height: 14)
                    .frame(maxWidth: 180)
            }
            
            Spacer()
        }
        .padding(16)
        .frame(height: 180)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

#Preview {
    HomeView()
        .environmentObject(UserProfile())
        .environmentObject(FavoritesManager())
}
