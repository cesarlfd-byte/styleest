import SwiftUI

struct GenderSelectionView: View {
    @EnvironmentObject var profile: UserProfile
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    @State private var selectedGender = ""
    
    let genderOptions = [
        "Mulher / Feminino",
        "Homem / Masculino",
        "Não binário",
        "Prefiro não dizer"
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    Text("Como você se identifica?")
                        .font(.largeTitle.bold())
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Text("Isso nos ajuda a sugerir looks que respeitem sua identidade e biotipo.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    VStack(spacing: 12) {
                        ForEach(genderOptions, id: \.self) { option in
                            Button(action: {
                                selectedGender = option
                                profile.gender = option
                            }) {
                                let isSelected = selectedGender == option
                                let bg = isSelected
                                    ? (colorScheme == .dark ? AppColors.lightPurple.opacity(0.12) : AppColors.lightPurple.opacity(0.18))
                                    : (colorScheme == .dark ? Color(red: 0.11, green: 0.11, blue: 0.12) : Color.gray.opacity(0.10))
                                let border = (colorScheme == .dark
                                    ? (isSelected ? AppColors.lightPurple : Color.gray.opacity(0.3))
                                    : (isSelected ? AppColors.darkPurple : Color.gray.opacity(0.3)))
                                
                                Text(option)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding(.vertical, 14)
                                    .background(bg)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(border, lineWidth: 1.5)
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding()
                .navigationTitle("Identidade")
                .navigationBarTitleDisplayMode(.inline)
            }
            .scrollIndicators(.hidden)
            .onAppear {
                // Carregar seleção anterior se existir
                if !profile.gender.isEmpty {
                    selectedGender = profile.gender
                }
            }
            
            .safeAreaInset(edge: .bottom) {
                if profile.isEditingMode {
                    PrimaryButton(
                        action: { dismiss() },
                        label: { Text("Salvar") },
                        isEnabled: !selectedGender.isEmpty
                    )
                } else {
                    PrimaryNavigationButton(
                        destination: FaceShapeView(),
                        label: "Continuar",
                        isEnabled: !selectedGender.isEmpty
                    )
                }
            }
        }
    }
}

#Preview {
    GenderSelectionView()
        .environmentObject(UserProfile())
}
