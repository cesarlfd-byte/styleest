import SwiftUI
import CoreLocation
import Combine

class UserProfile: ObservableObject {
    // Keys para UserDefaults
    private let hasCompletedOnboardingKey = "hasCompletedOnboarding"
    private let genderKey = "userGender"
    private let faceShapeKey = "userFaceShape"
    private let faceShapeIconKey = "userFaceShapeIcon"
    private let bodyTypeKey = "userBodyType"
    private let bodyTypeIconKey = "userBodyTypeIcon"
    private let hairColorNameKey = "userHairColorName"
    private let hairColorHexKey = "userHairColorHex"
    private let musicGenresKey = "userMusicGenres"
    private let weatherLocationKey = "userWeatherLocation"
    private let weatherTemperatureKey = "userWeatherTemperature"
    private let weatherConditionKey = "userWeatherCondition"
    
    // Controle de fluxo
    @Published var isEditingMode: Bool = false
    @Published var hasCompletedOnboarding: Bool {
        didSet {
            UserDefaults.standard.set(hasCompletedOnboarding, forKey: hasCompletedOnboardingKey)
        }
    }
    
    // Identidade
    @Published var gender: String {
        didSet {
            UserDefaults.standard.set(gender, forKey: genderKey)
        }
    }
    
    // Rosto
    @Published var faceShape: String {
        didSet {
            UserDefaults.standard.set(faceShape, forKey: faceShapeKey)
        }
    }
    @Published var faceShapeIcon: String {
        didSet {
            UserDefaults.standard.set(faceShapeIcon, forKey: faceShapeIconKey)
        }
    }
    
    // Corpo
    @Published var bodyType: String {
        didSet {
            UserDefaults.standard.set(bodyType, forKey: bodyTypeKey)
        }
    }
    @Published var bodyTypeIcon: String {
        didSet {
            UserDefaults.standard.set(bodyTypeIcon, forKey: bodyTypeIconKey)
        }
    }
    
    // Cabelo
    @Published var hairColorName: String {
        didSet {
            UserDefaults.standard.set(hairColorName, forKey: hairColorNameKey)
        }
    }
    @Published var hairColor: Color {
        didSet {
            // Converte Color para hex String para salvar
            let uiColor = UIColor(hairColor)
            var red: CGFloat = 0
            var green: CGFloat = 0
            var blue: CGFloat = 0
            var alpha: CGFloat = 0
            uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            let hex = String(format: "%02X%02X%02X", Int(red * 255), Int(green * 255), Int(blue * 255))
            UserDefaults.standard.set(hex, forKey: hairColorHexKey)
        }
    }
    
    // Música
    @Published var musicGenres: [String] {
        didSet {
            UserDefaults.standard.set(musicGenres, forKey: musicGenresKey)
        }
    }
    
    // Clima
    @Published var weatherLocation: String {
        didSet {
            UserDefaults.standard.set(weatherLocation, forKey: weatherLocationKey)
        }
    }
    @Published var weatherTemperature: Int {
        didSet {
            UserDefaults.standard.set(weatherTemperature, forKey: weatherTemperatureKey)
        }
    }
    @Published var weatherCondition: String {
        didSet {
            UserDefaults.standard.set(weatherCondition, forKey: weatherConditionKey)
        }
    }
    
    init() {
        // Carregar dados salvos
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: hasCompletedOnboardingKey)
        self.gender = UserDefaults.standard.string(forKey: genderKey) ?? ""
        self.faceShape = UserDefaults.standard.string(forKey: faceShapeKey) ?? ""
        self.faceShapeIcon = UserDefaults.standard.string(forKey: faceShapeIconKey) ?? ""
        self.bodyType = UserDefaults.standard.string(forKey: bodyTypeKey) ?? ""
        self.bodyTypeIcon = UserDefaults.standard.string(forKey: bodyTypeIconKey) ?? ""
        self.hairColorName = UserDefaults.standard.string(forKey: hairColorNameKey) ?? ""
        self.musicGenres = UserDefaults.standard.stringArray(forKey: musicGenresKey) ?? []
        self.weatherLocation = UserDefaults.standard.string(forKey: weatherLocationKey) ?? ""
        self.weatherTemperature = UserDefaults.standard.integer(forKey: weatherTemperatureKey)
        self.weatherCondition = UserDefaults.standard.string(forKey: weatherConditionKey) ?? "cloud"
        
        // Carregar cor do cabelo
        if let hexString = UserDefaults.standard.string(forKey: hairColorHexKey),
           let hex = UInt(hexString, radix: 16) {
            self.hairColor = Color(hex: hex)
        } else {
            self.hairColor = .black
        }
    }
    
    // Reset - apaga apenas dados do perfil (não favoritos)
    func resetProfile() {
        hasCompletedOnboarding = false
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
        
        // Remove do UserDefaults
        UserDefaults.standard.removeObject(forKey: hasCompletedOnboardingKey)
        UserDefaults.standard.removeObject(forKey: genderKey)
        UserDefaults.standard.removeObject(forKey: faceShapeKey)
        UserDefaults.standard.removeObject(forKey: faceShapeIconKey)
        UserDefaults.standard.removeObject(forKey: bodyTypeKey)
        UserDefaults.standard.removeObject(forKey: bodyTypeIconKey)
        UserDefaults.standard.removeObject(forKey: hairColorNameKey)
        UserDefaults.standard.removeObject(forKey: hairColorHexKey)
        UserDefaults.standard.removeObject(forKey: musicGenresKey)
        UserDefaults.standard.removeObject(forKey: weatherLocationKey)
        UserDefaults.standard.removeObject(forKey: weatherTemperatureKey)
        UserDefaults.standard.removeObject(forKey: weatherConditionKey)
    }
}

