import SwiftUI

struct Look: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let description: String
    let imageName: String // ex: "look1", "look2" — assets
    let tags: [String]
    
    // Para looks gerados por IA
    var generatedImage: UIImage? = nil
    
    // Inicializador padrão (usando imageName)
    init(title: String, description: String, imageName: String, tags: [String]) {
        self.title = title
        self.description = description
        self.imageName = imageName
        self.tags = tags
        self.generatedImage = nil
    }
    
    // Inicializador para looks com imagem gerada por IA
    init(title: String, description: String, image: UIImage, tags: [String]) {
        self.title = title
        self.description = description
        self.imageName = "" // Vazio para looks gerados
        self.tags = tags
        self.generatedImage = image
    }
    
    static func == (lhs: Look, rhs: Look) -> Bool {
        return lhs.id == rhs.id
    }
}

