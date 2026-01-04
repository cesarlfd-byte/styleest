import SwiftUI

struct AutomaticCarousel<Content: View>: View {
    let views: [Content]
    @State private var currentIndex = 0
    @State private var isAutoScrolling = true
    @State private var progress: CGFloat = 0
    
    private let autoScrollInterval: TimeInterval = 9.0
    private let timerInterval: TimeInterval = 0.05
    @State private var progressTimer: Timer?
    
    var body: some View {
        VStack(spacing: 12) {
            // ✅ Carrossel
            TabView(selection: $currentIndex) {
                ForEach(0..<views.count, id: \.self) { index in
                    views[index]
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .onAppear {
                startAutoScroll()
            }
            .onDisappear {
                stopTimers()
            }
            .gesture(
                DragGesture()
                    .onChanged { _ in
                        isAutoScrolling = false
                    }
                    .onEnded { _ in
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            withAnimation {
                                isAutoScrolling = true
                            }
                            startAutoScroll()
                        }
                    }
            )
            
            // ✅ Indicador de dots (Apple TV style)
            if views.count > 1 {
                HStack(spacing: 6) {
                    ForEach(0..<views.count, id: \.self) { index in
                        Circle()
                            .fill(index == currentIndex ? AppColors.primaryPurple : Color.gray.opacity(0.4))
                            .frame(width: 8, height: 8)
                            .scaleEffect(index == currentIndex ? 1.2 : 1.0)
                            .animation(.easeInOut(duration: 0.2), value: currentIndex)
                    }
                }
                .padding(.horizontal, 8)
            }
        }
        .onChange(of: isAutoScrolling) { newValue in
            if newValue {
                startAutoScroll()
            } else {
                stopTimers()
            }
        }
    }
    
    private func startAutoScroll() {
        guard isAutoScrolling, views.count > 1 else { return }
        
        // Timer do carrossel
        Timer.scheduledTimer(withTimeInterval: autoScrollInterval, repeats: false) { _ in
            DispatchQueue.main.async {
                withAnimation {
                    currentIndex = (currentIndex + 1) % views.count
                }
                progress = 0
                startAutoScroll() // recursivo
            }
        }
        
        // Timer do progresso (opcional, se quiser manter o círculo também)
        stopProgressTimer()
        progress = 0
        progressTimer = Timer.scheduledTimer(withTimeInterval: timerInterval, repeats: true) { _ in
            DispatchQueue.main.async {
                if progress < 1.0 && isAutoScrolling {
                    progress += CGFloat(timerInterval / autoScrollInterval)
                } else {
                    progress = 1.0
                    stopProgressTimer()
                }
            }
        }
    }
    
    private func stopTimers() {
        isAutoScrolling = false
        stopProgressTimer()
    }
    
    private func stopProgressTimer() {
        progressTimer?.invalidate()
        progressTimer = nil
    }
}
