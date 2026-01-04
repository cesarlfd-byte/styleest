import SwiftUI

struct OnboardingView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    // Mascote no topo
                    Image("mascot")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 120, height: 120)
                        .padding(.top, 40)
                    
                    // Texto com "StyleSync" em destaque
                    HStack(spacing: 0) {
                        Text("style")
                            .font(.largeTitle)
                            .bold()
                        Text("est.")
                            .font(.largeTitle)
                            .bold()
                            .foregroundColor(AppColors.primaryPurple)
                    }
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                    .multilineTextAlignment(.center)
                    
                    Text("Seu stylist digital pessoal. É hora de criar looks que combinam com você, seu clima e sua vibe.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Spacer()
                }
                .padding(.horizontal)
            }
            .scrollIndicators(.hidden)
            .navigationTitle("Boas-vindas")
            .navigationBarTitleDisplayMode(.inline)
            
            // Botão fixo no rodapé
            .safeAreaInset(edge: .bottom) {
                PrimaryNavigationButton(
                    destination: GenderSelectionView(),
                    label: "Começar",
                    isEnabled: true
                )
            }
        }
    }
}

#Preview {
    OnboardingView()
}
