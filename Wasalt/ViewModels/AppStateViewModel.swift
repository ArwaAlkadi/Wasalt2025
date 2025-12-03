import SwiftUI
import Combine

class AppStateViewModel: ObservableObject {

    @Published var showSplash: Bool = true
    @Published var showOnboarding: Bool = false

    init() {
        startFlow()
    }

    func startFlow() {
        // مدة بقاء السبلاتش 1 ثانية فقط
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.showSplash = false
            self.showOnboarding = true
        }
    }
}
