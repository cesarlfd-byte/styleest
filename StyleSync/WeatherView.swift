import SwiftUI
import CoreLocation
import WeatherKit
import Combine

struct WeatherView: View {
    @StateObject private var locationManager = LocationManager()
    @EnvironmentObject private var profile: UserProfile
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    @State private var weather: Weather?
    @State private var error: String?
    @State private var cityName: String?
    private let fallbackLocation = CLLocation(latitude: -23.5505, longitude: -46.6333) // São Paulo
    
    private var canContinue: Bool {
        // Habilita quando o clima foi carregado (inclui fallback) ou quando houve erro após tentativas
        if weather != nil { return true }
        if error != nil { return true }
        return false
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {
                    Text("Clima")
                        .font(.largeTitle.bold())
                        .multilineTextAlignment(.center)
                    
                    Text("Vamos usar o clima da sua região para sugerir looks ideais.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    if let error = error {
                        Text(error)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    if let weather = weather {
                        // ✅ Clima carregado
                        VStack(spacing: 12) {
                            Image(systemName: weather.currentWeather.condition.iconName)
                                .font(.system(size: 60))
                                .foregroundColor(AppColors.primaryPurple)
                            
                            Text("\(Int(weather.currentWeather.temperature.converted(to: .celsius).value))°")
                                .font(.system(size: 48, weight: .light))
                            
                            if let cityName = cityName {
                                Text(cityName)
                                    .font(.title3)
                                    .foregroundColor(.secondary)
                            } else if let loc = locationManager.location {
                                Text(String(format: "Lat: %.3f, Lon: %.3f", loc.coordinate.latitude, loc.coordinate.longitude))
                                    .font(.title3)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 20)
                        .frame(maxWidth: .infinity)
                        .background(colorScheme == .dark ? Color(red: 0.11, green: 0.11, blue: 0.12) : Color.gray.opacity(0.05))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .padding(.horizontal)
                    } else if locationManager.authorizationStatus == .notDetermined {
                        // ❓ Pedir permissão
                        Button {
                            locationManager.requestPermission()
                        } label: {
                            Text("Permitir acesso à localização")
                                .font(.body)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(AppColors.primaryPurple)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal)
                    } else if locationManager.authorizationStatus == .denied {
                        // ❌ Permissão negada
                        VStack(spacing: 12) {
                            Image(systemName: "location.slash")
                                .font(.title2)
                                .foregroundColor(.red)
                            
                            Text("Localização negada")
                                .font(.headline)
                            
                            Text("Ative a localização nas Configurações para receber sugestões baseadas no clima.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(colorScheme == .dark ? Color.red.opacity(0.2) : Color.red.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.horizontal)
                    } else {
                        // ⏳ Carregando
                        ProgressView()
                            .scaleEffect(1.2)
                            .padding()
                    }
                    
                    Spacer()
                }
                .padding()
                .navigationTitle("Clima")
                .navigationBarTitleDisplayMode(.inline)
                .onAppear {
                    loadWeather()
                }
                .onReceive(locationManager.$authorizationStatus) { _ in
                    loadWeather()
                }
                .onReceive(locationManager.$location.compactMap { $0 }) { location in
                    updateCityName(from: location)
                    Task { await loadWeatherAsync() }
                }
            }
            .scrollIndicators(.hidden)
            
            // ✅ Botão fixo no rodapé
            .safeAreaInset(edge: .bottom) {
                if profile.isEditingMode {
                    // Modo edição: salva e volta
                    PrimaryButton(
                        action: {
                            dismiss()
                        },
                        label: {
                            Text("Salvar")
                        },
                        isEnabled: canContinue
                    )
                } else {
                    // Modo onboarding: continua para próxima tela
                    PrimaryNavigationButton(
                        destination: ProfileSummaryView(),
                        label: "Continuar",
                        isEnabled: canContinue
                    )
                }
            }
        }
        .task {
            await loadWeatherAsync()
        }
    }
    
    private func loadWeather() {
        Task {
            await loadWeatherAsync()
        }
    }
    
    @MainActor
    private func loadWeatherAsync() async {
        // Helper to attempt fetch for a given location
        func fetch(for location: CLLocation) async throws -> Weather {
            try await WeatherService.shared.weather(for: location)
        }

        // 1) Try current location if available; otherwise, immediately fall back
        let primaryLocation = locationManager.location ?? fallbackLocation
        do {
            let w = try await fetch(for: primaryLocation)
            self.weather = w
            self.error = nil
            // If we used fallback and cityName is empty, set a default name
            if primaryLocation.coordinate.latitude == fallbackLocation.coordinate.latitude &&
                primaryLocation.coordinate.longitude == fallbackLocation.coordinate.longitude &&
                self.cityName == nil {
                self.cityName = "São Paulo, SP"
            }
            DispatchQueue.main.async {
                profile.weatherLocation = cityName ?? ""
                profile.weatherTemperature = Int(w.currentWeather.temperature.converted(to: .celsius).value)
                profile.weatherCondition = w.currentWeather.condition.iconName
            }
            return
        } catch {
            // 2) If the primary attempt failed and it wasn't already the fallback, try fallback once
            if !(primaryLocation.coordinate.latitude == fallbackLocation.coordinate.latitude &&
                  primaryLocation.coordinate.longitude == fallbackLocation.coordinate.longitude) {
                do {
                    let w = try await fetch(for: fallbackLocation)
                    self.weather = w
                    self.error = nil
                    self.cityName = "São Paulo, SP"
                    DispatchQueue.main.async {
                        profile.weatherLocation = cityName ?? "São Paulo, SP"
                        profile.weatherTemperature = Int(w.currentWeather.temperature.converted(to: .celsius).value)
                        profile.weatherCondition = w.currentWeather.condition.iconName
                    }
                    return
                } catch {
                    self.error = "Erro ao carregar o clima (fallback)."
                }
            } else {
                self.error = "Erro ao carregar o clima."
            }
        }
    }
    
    private func updateCityName(from location: CLLocation) {
        if #unavailable(iOS 26.0) {
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(location) { placemarks, error in
                guard error == nil, let placemark = placemarks?.first else { return }
                let locality = placemark.locality ?? placemark.subLocality
                let admin = placemark.administrativeArea
                DispatchQueue.main.async {
                    if let locality = locality, let admin = admin, !admin.isEmpty {
                        self.cityName = "\(locality), \(admin)"
                    } else if let locality = locality {
                        self.cityName = locality
                    } else if let name = placemark.name {
                        self.cityName = name
                    }
                }
            }
        } else {
            // iOS 26+: Skip reverse geocoding to avoid deprecated API. Consider adopting the new MapKit geocoder when available.
            self.cityName = nil
        }
    }
}

// MARK: - Location Manager
class LocationManager: NSObject, ObservableObject {
    private let locationManager = CLLocationManager()
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var location: CLLocation?
    
    override init() {
        super.init()
        self.locationManager.delegate = self
        self.authorizationStatus = locationManager.authorizationStatus
    }
    
    func requestPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    private var locationTimeout: Timer?

    func startLocationTimeout() {
        locationTimeout?.invalidate()
        locationTimeout = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: false) { _ in
            DispatchQueue.main.async {
                // Se em 10s não tiver localização, assume um fallback (São Paulo)
                self.location = CLLocation(latitude: -23.5505, longitude: -46.6333) // São Paulo
            }
        }
    }

    func stopLocationTimeout() {
        locationTimeout?.invalidate()
        locationTimeout = nil
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        DispatchQueue.main.async {
            self.authorizationStatus = status
            if status == .authorizedWhenInUse || status == .authorizedAlways {
                manager.requestLocation()
                self.startLocationTimeout() // ⏱️
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        DispatchQueue.main.async {
            self.location = locations.last
            self.stopLocationTimeout() // ✅
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Erro na localização: \(error)")
    }
}


// MARK: - Weather Condition Icon
extension WeatherCondition {
    var iconName: String {
        switch self {
        case .clear: return "sun.max"
        case .mostlyClear, .partlyCloudy: return "cloud.sun"
        case .cloudy, .mostlyCloudy: return "cloud"
        case .foggy: return "cloud.fog"
        case .haze: return "sun.haze"
        case .smoky: return "smoke"
        case .drizzle, .rain, .heavyRain: return "cloud.rain"
        case .sleet: return "cloud.sleet"
        case .snow, .heavySnow, .flurries: return "cloud.snow"
        case .hail: return "cloud.hail"
        case .thunderstorms, .isolatedThunderstorms, .scatteredThunderstorms: return "cloud.bolt.rain"
        default: return "cloud"
        }
    }
}

#Preview {
    WeatherView()
}

