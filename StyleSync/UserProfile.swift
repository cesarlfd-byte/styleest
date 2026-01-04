import SwiftUI
import CoreLocation
import Combine

class UserProfile: ObservableObject {
    // Controle de fluxo
    @Published var isEditingMode: Bool = false
    
    // Identidade
    @Published var gender: String = ""
    
    // Rosto
    @Published var faceShape: String = ""
    @Published var faceShapeIcon: String = ""
    
    // Corpo
    @Published var bodyType: String = ""
    @Published var bodyTypeIcon: String = ""
    
    // Cabelo
    @Published var hairColorName: String = ""
    @Published var hairColor: Color = .black
    
    // Música
    @Published var musicGenres: [String] = []
    
    // Clima
    @Published var weatherLocation: String = ""
    @Published var weatherTemperature: Int = 0
    @Published var weatherCondition: String = "cloud"
    
    // Reset
    func reset() {
        gender = ""
        faceShape = ""
        faceShapeIcon = ""
        bodyType = ""
        bodyTypeIcon = ""
        hairColorName = ""
        hairColor = .black
        musicGenres = []
        weatherLocation = ""
        weatherTemperature = 0
        weatherCondition = "cloud"
    }
}

