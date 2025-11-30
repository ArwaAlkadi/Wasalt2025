import SwiftUI
import Combine

class SplashViewModel: ObservableObject {

    @Published var showLogo: Bool = false
    @Published var shake: Bool = false
    @Published var moveLeftDown: Bool = false
    @Published var showText: Bool = false

    init() {
        startAnimation()
    }

    func startAnimation() {

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.easeOut(duration: 0.5)) {
                self.showLogo = true
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            withAnimation(.linear(duration: 0.1).repeatCount(4, autoreverses: true)) {
                self.shake = true
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            self.shake = false

            withAnimation(.easeOut(duration: 0.3)) {
                self.moveLeftDown = true
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.spring()) {
                self.showText = true
            }
        }
    }
}
