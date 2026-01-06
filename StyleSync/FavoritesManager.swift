import SwiftUI
import Combine

// MARK: - Modelo de Look Favorito (para armazenamento)
struct FavoriteLook: Codable, Identifiable, Equatable {
    let id: String // UUID como String para Codable
    let title: String
    let description: String
    let imageName: String
    let tags: [String]
    let favoritedAt: Date
    var note: String? // Nota/comentário do usuário
    var lookGenerationId: String? // ID único da geração do look (para looks de IA)
    
    // Para imagens geradas por IA (não persistidas - recriadas ao carregar)
    var generatedImageData: Data? // Armazenar como Data para ser Codable
    
    init(from look: Look, lookGenerationId: String? = nil, note: String? = nil) {
        self.id = look.id.uuidString
        self.title = look.title
        self.description = look.description
        self.imageName = look.imageName
        self.tags = look.tags
        self.favoritedAt = Date()
        self.note = note
        self.lookGenerationId = lookGenerationId
        
        // Converter UIImage para Data se existir
        if let generatedImage = look.generatedImage {
            self.generatedImageData = generatedImage.jpegData(compressionQuality: 0.8)
        } else {
            self.generatedImageData = nil
        }
    }
    
    // Converter de volta para Look
    func toLook() -> Look {
        // Se tem imagem gerada, usar o inicializador com UIImage
        if let imageData = generatedImageData,
           let image = UIImage(data: imageData) {
            return Look(title: title, description: description, image: image, tags: tags)
        } else {
            return Look(title: title, description: description, imageName: imageName, tags: tags)
        }
    }
    
    // Propriedade computada para acessar a imagem gerada
    var look: Look {
        return toLook()
    }
}

// MARK: - Gerenciador de Favoritos
class FavoritesManager: ObservableObject {
    @Published var favorites: [FavoriteLook] = []
    
    private let favoritesKey = "saved_favorites"
    
    init() {
        loadFavorites()
    }
    
    // Verifica se um look está favoritado
    func isFavorite(_ look: Look) -> Bool {
        return favorites.contains { $0.id == look.id.uuidString }
    }
    
    // Adiciona aos favoritos
    func addFavorite(_ look: Look) {
        // Verifica se já não está nos favoritos
        if !isFavorite(look) {
            let favoriteLook = FavoriteLook(from: look)
            favorites.insert(favoriteLook, at: 0) // Adiciona no início
            saveFavorites()
        }
    }
    
    // Adiciona ou remove dos favoritos
    func toggleFavorite(_ look: Look) {
        if let index = favorites.firstIndex(where: { $0.id == look.id.uuidString }) {
            // Remove dos favoritos
            favorites.remove(at: index)
        } else {
            // Adiciona aos favoritos
            addFavorite(look)
        }
        saveFavorites()
    }
    
    // Remove um favorito específico
    func removeFavorite(_ favoriteLook: FavoriteLook) {
        favorites.removeAll { $0.id == favoriteLook.id }
        saveFavorites()
    }
    
    // Atualiza a nota de um favorito
    func updateNote(for favoriteLook: FavoriteLook, note: String) {
        if let index = favorites.firstIndex(where: { $0.id == favoriteLook.id }) {
            var updated = favorites[index]
            updated.note = note.isEmpty ? nil : note
            favorites[index] = updated
            saveFavorites()
        }
    }
    
    // Obtém todos os favoritos filtrados por tag
    func filteredFavorites(by tag: String?) -> [FavoriteLook] {
        guard let tag = tag, tag != "Todos" else {
            return favorites
        }
        return favorites.filter { $0.tags.contains(tag) }
    }
    
    // Obtém todas as tags únicas dos favoritos
    var allTags: [String] {
        let tags = Set(favorites.flatMap { $0.tags })
        return ["Todos"] + tags.sorted()
    }
    
    // MARK: - Persistência Local
    
    func saveFavorites() {
        if let encoded = try? JSONEncoder().encode(favorites) {
            UserDefaults.standard.set(encoded, forKey: favoritesKey)
        }
    }
    
    private func loadFavorites() {
        if let data = UserDefaults.standard.data(forKey: favoritesKey),
           let decoded = try? JSONDecoder().decode([FavoriteLook].self, from: data) {
            favorites = decoded
        }
    }
    
    // Limpar todos os favoritos
    func clearAll() {
        favorites.removeAll()
        saveFavorites()
    }
}

