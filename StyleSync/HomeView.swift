import SwiftUI

struct HomeView: View {
    @EnvironmentObject var profile: UserProfile
    
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
                    // ✅ Cabeçalho com "StyleEst" em destaque
                    HStack(spacing: 0) {
                        Text("Seu estilo, seu jeito")
                            .font(.title)
                            .foregroundColor(.primary)
                    }
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal)

                    // ✅ Texto secundário menor
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
                    
                    // ✅ Looks para hoje (em carrossel automático)
                    if !todayLooks.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Looks para hoje")
                                .font(.title2.bold())
                            
                            AutomaticCarousel(views: todayLooks.map { look in
                                LookCard(look: look)
                                    .padding(.horizontal, 8)
                            })
                            .frame(height: 280)
                        }
                        .padding(.horizontal)
                    }
                    
                    // ✅ Looks para sua música
                    if !profile.musicGenres.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Looks para sua vibe")
                                .font(.title2.bold())
                            
                            AutomaticCarousel(views: musicLooks.map { look in
                                LookCard(look: look)
                                    .padding(.horizontal, 8)
                            })
                            .frame(height: 280)
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer()
                }
                .padding(.top, 12)
                .navigationTitle("styleest.") // ← aqui!
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink(destination: EditProfileView()) {
                            Image(systemName: "gear")
                                .foregroundColor(.primary)
                        }
                    }
                }
            }
            .scrollIndicators(.hidden)
        }
    }
}

// MARK: - Componente LookCard
struct LookCard: View {
    let look: Look
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Imagem (use Rectangle + gradiente por enquanto)
            Rectangle()
                .fill(LinearGradient(
                    gradient: Gradient(colors: [AppColors.lightPurple, AppColors.primaryPurple]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            
            // Título + ícone na mesma linha
            HStack(spacing: 6) {
                if look.tags.contains("Clima") {
                    Image(systemName: "cloud.sun")
                        .font(.caption)
                        .foregroundColor(.primary)
                } else if look.tags.contains("Música") {
                    Image(systemName: "music.note")
                        .font(.caption)
                        .foregroundColor(.primary)
                } else {
                    Image(systemName: "person.crop.circle")
                        .font(.caption)
                        .foregroundColor(.primary)
                }
                
                Text(look.title)
                    .font(.headline)
                    .lineLimit(1)
            }
            
            Text(look.description)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            // Tags
            HStack(spacing: 6) {
                ForEach(look.tags, id: \.self) { tag in
                    Text(tag)
                        .font(.caption2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.gray.opacity(0.15))
                        .clipShape(Capsule())
                }
            }
            .padding(.top, 4)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

#Preview {
    HomeView()
        .environmentObject(UserProfile())
}
