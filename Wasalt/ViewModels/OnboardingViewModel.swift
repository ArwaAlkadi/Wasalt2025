import SwiftUI
import Combine

struct OnboardingPage1 {
    let lightIcon: String
    let darkIcon: String
    let title: String
    let subtitle: String
}

class OnboardingViewModel: ObservableObject {

    @Published var currentPage: Int = 0
    
    // نحفظ قيمة الانتهاء من الأونبوردنق
    @AppStorage("didFinishOnboarding") var isOnboardingFinished: Bool = false

    let pages: [OnboardingPage1] = [
        .init(lightIcon: "Train", darkIcon: "Train Dark",
              title: "تنقّل آمن",
              subtitle: "نسهل تنقّلك داخل المترو بخطوات بسيطة!"),
        
        .init(lightIcon: "phone", darkIcon: "Phone Dark",
              title: "تنبيهات ذكية",
              subtitle: "ننبّهك بالاهتزاز والومض عند الاقتراب من محطتك"),
        
        .init(lightIcon: "Map", darkIcon: "Map Dark",
              title: "ابدأ رحلتك بثقة",
              subtitle: "اختر وجهتك، واترك التطبيق يتابع خط سير المترو")
    ]

    func next() {
        withAnimation {
            if currentPage < pages.count - 1 {
                currentPage += 1
            } else {
                isOnboardingFinished = true
            }
        }
    }

    func skip() {
        withAnimation {
            isOnboardingFinished = true
        }
    }
}
