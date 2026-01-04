import SwiftUI

struct ProfileSummaryView: View {
    @EnvironmentObject var profile: UserProfile
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    Text("Seu perfil")
                        .font(.largeTitle.bold())
                        .multilineTextAlignment(.center)
                    
                    Text("Essas são as suas preferências. Elas nos ajudam a sugerir looks perfeitos para você!")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    // Card: Identidade
                    ProfileCard(title: "Identidade", value: profile.gender)
                    
                    // Card: Rosto
                    if !profile.faceShape.isEmpty {
                        ProfileCardWithIcon(title: "Rosto", value: profile.faceShape, iconName: profile.faceShapeIcon)
                    }
                    
                    // Card: Corpo
                    if !profile.bodyType.isEmpty {
                        ProfileCardWithIcon(title: "Corpo", value: profile.bodyType, iconName: profile.bodyTypeIcon)
                    }
                    
                    // Card: Cabelo
                    if !profile.hairColorName.isEmpty {
                        ProfileCardWithColor(title: "Cabelo", value: profile.hairColorName, color: profile.hairColor)
                    }
                    
                    // Card: Música
                    if !profile.musicGenres.isEmpty {
                        ProfileCard(title: "Música", value: profile.musicGenres.joined(separator: ", "))
                    }
                    
                    // Card: Clima
                    if !profile.weatherLocation.isEmpty {
                        ProfileCardWithWeather(
                            title: "Clima",
                            location: profile.weatherLocation,
                            temperature: profile.weatherTemperature,
                            condition: profile.weatherCondition
                        )
                    }
                    
                    Spacer()
                }
                .padding()
                .navigationTitle("Perfil")
                .navigationBarTitleDisplayMode(.inline)
            }
            .scrollIndicators(.hidden)
            
            // ✅ Botão fixo no rodapé
            .safeAreaInset(edge: .bottom) {
                PrimaryNavigationButton(
                    destination: HomeView(), // ← substitua pela Home real depois
                    label: "Começar",
                    isEnabled: true
                )
            }
        }
    }
}

// MARK: - Componentes de Card

struct ProfileCard: View {
    let title: String
    let value: String
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        HStack {
            Text(title)
                .font(.callout)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.body)
                .fontWeight(.medium)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(colorScheme == .dark ? Color(red: 0.11, green: 0.11, blue: 0.12) : Color.gray.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct ProfileCardWithIcon: View {
    let title: String
    let value: String
    let iconName: String
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        HStack {
            Text(title)
                .font(.callout)
                .foregroundColor(.secondary)
            Spacer()
            HStack(spacing: 8) {
                Image(iconName)
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(colorScheme == .dark ? AppColors.lightPurple : AppColors.darkPurple)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 18, height: 18)
                Text(value)
                    .font(.body)
                    .fontWeight(.medium)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(colorScheme == .dark ? Color(red: 0.11, green: 0.11, blue: 0.12) : Color.gray.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct ProfileCardWithColor: View {
    let title: String
    let value: String
    let color: Color
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        HStack {
            Text(title)
                .font(.callout)
                .foregroundColor(.secondary)
            Spacer()
            HStack(spacing: 8) {
                Circle()
                    .fill(color)
                    .frame(width: 20, height: 20)
                    .overlay(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 0.5))
                Text(value)
                    .font(.body)
                    .fontWeight(.medium)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(colorScheme == .dark ? Color(red: 0.11, green: 0.11, blue: 0.12) : Color.gray.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct ProfileCardWithWeather: View {
    let title: String
    let location: String
    let temperature: Int
    let condition: String
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        HStack {
            Text(title)
                .font(.callout)
                .foregroundColor(.secondary)
            Spacer()
            HStack(spacing: 8) {
                Image(systemName: condition)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(colorScheme == .dark ? AppColors.lightPurple : AppColors.primaryPurple)
                Text("\(temperature)° • \(location)")
                    .font(.body)
                    .fontWeight(.medium)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(colorScheme == .dark ? Color(red: 0.11, green: 0.11, blue: 0.12) : Color.gray.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    ProfileSummaryView()
        .environmentObject(UserProfile())
}

