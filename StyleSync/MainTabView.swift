import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var profile: UserProfile
    @StateObject private var favoritesManager = FavoritesManager()
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Home Tab
            HomeView()
                .environmentObject(favoritesManager)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)
            
            // Tendências Tab (NOVO!)
            FashionTrendsView()
                .environmentObject(favoritesManager)
                .tabItem {
                    Label("Tendências", systemImage: "chart.line.uptrend.xyaxis")
                }
                .tag(1)
            
            // IA Stylist Tab
            AILookWithImageView()
                .environmentObject(favoritesManager)
                .tabItem {
                    Label("IA Stylist", systemImage: "sparkles")
                }
                .tag(2)
            
            // Favoritos Tab
            FavoritesView()
                .environmentObject(favoritesManager)
                .tabItem {
                    Label("Favoritos", systemImage: "heart.fill")
                }
                .tag(3)
            
            // Configurações Tab
            NavigationStack {
                EditProfileView()
                    .navigationTitle("Configurações")
                    .navigationBarTitleDisplayMode(.large)
            }
            .tabItem {
                Label("Configurações", systemImage: "gearshape.fill")
            }
            .tag(4)
        }
        .tint(AppColors.primaryPurple) // Cor dos ícones selecionados
    }
}

#Preview {
    MainTabView()
        .environmentObject(UserProfile())
}
